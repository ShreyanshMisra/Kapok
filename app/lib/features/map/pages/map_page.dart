import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/mapbox_constants.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/services/geolocation_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../../../data/models/task_model.dart';
import '../models/map_camera_state.dart';
import '../widgets/mapbox_map_view.dart';
import '../web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../web/mapbox_web_controller.dart';
import '../mobile/mapbox_mobile_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../teams/bloc/team_state.dart';
import '../../../app/router.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Map page showing interactive map with live, location-based offline map functionality
/// It orchestrates a continuous cycle of "current location → live snapshot → offline cache refresh"
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxWebController? _webMapController;
  MapboxMobileController? _mobileMapController;

  // User's current location for initial map position
  MapCameraState? _userLocationCamera;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;


  @override
  void initState() {
    super.initState();
    // Load user location first, then initialize map
    _loadUserLocation();

    // Use post-frame callback to ensure BlocProvider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MapBloc>().add(const MapStarted());

      // Load user's teams to get team IDs for task filtering
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<TeamBloc>().add(
          LoadUserTeams(userId: authState.user.id),
        );
      }
    });
  }

  /// Load user's current location for initial map position
  Future<void> _loadUserLocation() async {
    try {
      final geolocationService = GeolocationService.instance;

      // Check and request permission if needed
      final hasPermission = await geolocationService.hasLocationPermission();
      if (!hasPermission) {
        final permission = await geolocationService.requestLocationPermission();
        // Check if permission was granted
        final isGranted = permission.name == 'always' || permission.name == 'whileInUse';
        if (!isGranted) {
          // Fall back to default location if permission denied
          return;
        }
      }

      // Get current position
      final position = await geolocationService.getCurrentPosition();

      if (mounted) {
        setState(() {
          _userLocationCamera = MapCameraState(
            latitude: position.latitude,
            longitude: position.longitude,
            zoom: 15.0,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading user location: $e');
      // Fall back to default location on error
    }
  }

  /// Fly to user's current location
  void _goToCurrentLocation() async {
    try {
      final geolocationService = GeolocationService.instance;
      final position = await geolocationService.getCurrentPosition();
      _webMapController?.flyTo(position.latitude, position.longitude, 15.0);
      _mobileMapController?.flyTo(position.latitude, position.longitude, 15.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get current location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose map controllers when page is disposed (e.g., on logout)
    _webMapController?.dispose();
    _webMapController = null;
    _mobileMapController?.dispose();
    _mobileMapController = null;
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to dispose map on logout
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          // Dispose map controllers immediately when user logs out
          _webMapController?.dispose();
          _webMapController = null;
          _mobileMapController?.dispose();
          _mobileMapController = null;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(AppLocalizations.of(context).map),
          actions: [
            IconButton(
              icon: const Icon(Icons.storage),
              tooltip: 'View Cache',
              onPressed: () {
                Navigator.of(context).pushNamed('/map-cache');
              },
            ),
            const KapokLogo(),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            // Listen for team loading to trigger task loading on map
            BlocListener<TeamBloc, TeamState>(
              listener: (context, teamState) {
                if (teamState is TeamLoaded) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    final teamIds = teamState.teams.map((team) => team.id).toList();

                    // Load tasks for map display
                    context.read<MapBloc>().add(
                      LoadTasksOnMap(
                        teamIds: teamIds,
                        userId: authState.user.id,
                      ),
                    );
                  }
                }
              },
            ),
            // Listen for map errors
            BlocListener<MapBloc, MapState>(
              listener: (context, state) {
                if (state is MapError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                // When MapReset is triggered, MapBloc emits MapLoading state
                // Dispose the map controllers immediately to stop the map
                if (state is MapLoading && (_webMapController != null || _mobileMapController != null)) {
                  _webMapController?.dispose();
                  _webMapController = null;
                  _mobileMapController?.dispose();
                  _mobileMapController = null;
                }
              },
            ),
          ],
          child: BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
            // Debug: Show current state (throttled to avoid spam)
            // Removed frequent state logging - only log on state changes if needed

            if (state is MapLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Loading region for current location...'),
                    if (kDebugMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        'State: LoadingRegion',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            if (state is MapReady) {
              return _buildInteractiveMap(
                context,
                region: state.region,
                isOffline: state.isOfflineMode,
                camera: state.lastCamera,
                progressOverlay: null,
              );
            }

            if (state is OfflineRegionUpdating) {
              return _buildInteractiveMap(
                context,
                region: state.region,
                isOffline: state.isOfflineMode,
                camera: null,
                progressOverlay: state.progress,
              );
            }

            if (state is MapWithTasks) {
              return _buildInteractiveMap(
                context,
                region: state.region,
                isOffline: state.isOfflineMode,
                camera: state.lastCamera,
                progressOverlay: null,
                tasks: state.tasks,
              );
            }

            // Initial or error state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state is MapError
                        ? Icons.error_outline
                        : Icons.map_outlined,
                    size: 64,
                    color: state is MapError
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  if (state is MapError) ...[
                    Text(
                      'ERROR: ${(state).message}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(
                      'Map page - Waiting for region load',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (kDebugMode) ...[
                    const SizedBox(height: 8),
                    Text(
                      'State: ${state.runtimeType}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MapBloc>().add(
                        const OfflineBubbleRefreshRequested(force: true),
                      );
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Refresh Offline Region'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                    ),
                  ),
                ],
              ),
            );
          },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: AppColors.surface.withValues(alpha: 0.95),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).searchLocation,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _showSearchResults = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              if (value.length >= 3) {
                _performSearch(value);
              } else {
                setState(() {
                  _searchResults = [];
                  _showSearchResults = false;
                });
              }
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _performSearch(value);
              }
            },
          ),
        ),
        if (_showSearchResults && _searchResults.isNotEmpty)
          Card(
            color: AppColors.surface,
            elevation: 4,
            margin: const EdgeInsets.only(top: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on, size: 20),
                    title: Text(
                      result['place_name'] as String? ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),
          ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final token = MapboxConstants.accessToken;
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json?access_token=$token&limit=5',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];
        setState(() {
          _searchResults = features.cast<Map<String, dynamic>>();
          _showSearchResults = true;
          _isSearching = false;
        });
      } else {
        setState(() {
          _isSearching = false;
          _showSearchResults = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _showSearchResults = false;
      });
    }
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final center = result['center'] as List<dynamic>?;
    if (center != null && center.length >= 2) {
      final lng = (center[0] as num).toDouble();
      final lat = (center[1] as num).toDouble();

      // Animate map to the location
      _webMapController?.flyTo(lat, lng, 14.0);
      _mobileMapController?.flyTo(lat, lng, 14.0);

      // Trigger offline cache for the searched location
      context.read<MapBloc>().add(
        OfflineBubbleRefreshRequested(
          force: true,
          targetLat: lat,
          targetLon: lng,
        ),
      );

      setState(() {
        _searchController.text = result['place_name'] as String? ?? '';
        _searchResults = [];
        _showSearchResults = false;
      });
    }
  }

  Widget _buildInteractiveMap(
    BuildContext context, {
    OfflineMapRegion? region,
    required bool isOffline,
    MapCameraState? camera,
    double? progressOverlay,
    List<TaskModel>? tasks,
  }) {
    // Priority: 1) provided camera, 2) user location, 3) region center, 4) default (UMass Amherst)
    final initialCamera = camera ??
        _userLocationCamera ??
        (region != null
            ? MapCameraState(
                latitude: region.centerLat,
                longitude: region.centerLon,
                zoom: region.zoomMax.toDouble(),
              )
            : MapCameraState(
                latitude: MapboxConstants.defaultLatitude,
                longitude: MapboxConstants.defaultLongitude,
                zoom: MapboxConstants.defaultZoom,
              ));

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: MapboxMapView(
              initialLatitude: initialCamera.latitude,
              initialLongitude: initialCamera.longitude,
              initialZoom: initialCamera.zoom,
              offlineBubble: region,
              isOfflineMode: isOffline,
              // Pass tasks for mobile native markers
              tasks: tasks,
              onTaskMarkerTap: (task) {
                // Navigate to task detail
                Navigator.of(context).pushNamed(
                  AppRouter.taskDetail,
                  arguments: {
                    'task': task,
                    'currentUserId': context.read<AuthBloc>().state is AuthAuthenticated
                        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
                        : '',
                  },
                );
              },
              onCameraIdle: (cameraState) {
                setState(() {});
                context.read<MapBloc>().add(MapCameraMoved(cameraState));
              },
              onControllerReady: (controller) {
                _webMapController = controller;
              },
              onMobileControllerReady: (controller) {
                _mobileMapController = controller;
              },
            ),
          ),
          // Task markers overlay (web only - mobile uses native markers)
          if (kIsWeb && tasks != null && tasks.isNotEmpty && _webMapController != null)
            ...tasks.map((task) => _buildTaskMarker(task)),
          // Current location button
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              color: AppColors.surface.withValues(alpha: 0.95),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.my_location, color: AppColors.primary),
                tooltip: AppLocalizations.of(context).currentLocation,
                onPressed: _goToCurrentLocation,
              ),
            ),
          ),
          // Location search bar
          Positioned(
            top: 16,
            left: 64,
            right: 16,
            child: _buildSearchBar(context),
          ),
        ],
      ),
    );
  }

  /// Build a task marker widget positioned on the map
  Widget _buildTaskMarker(TaskModel task) {
    if (_webMapController == null) return const SizedBox.shrink();

    // Project task location to screen coordinates
    final screenPos = _webMapController!.projectLatLonToScreen(
      task.geoLocation.latitude,
      task.geoLocation.longitude,
    );

    if (screenPos == null) return const SizedBox.shrink();

    // Use blue for all priorities, gray for completed
    Color markerColor;
    IconData markerIcon;
    String priorityLabel;
    int starCount;

    if (task.status.value == 'completed') {
      markerColor = AppColors.textSecondary;
      markerIcon = Icons.check_circle;
      priorityLabel = 'Completed';
      starCount = 0;
    } else {
      markerColor = AppColors.primary;
      markerIcon = Icons.star;
      switch (task.priority) {
        case TaskPriority.high:
          priorityLabel = 'High Priority';
          starCount = 3;
          break;
        case TaskPriority.medium:
          priorityLabel = 'Medium Priority';
          starCount = 2;
          break;
        case TaskPriority.low:
          priorityLabel = 'Low Priority';
          starCount = 1;
          break;
      }
    }

    return Positioned(
      left: screenPos.dx - 20, // Center the 40px pin
      top: screenPos.dy - 50, // Position pin point at location
      child: _MapPin(
        task: task,
        markerColor: markerColor,
        markerIcon: markerIcon,
        priorityLabel: priorityLabel,
        starCount: starCount,
        onTap: () {
          // Navigate to task detail
          Navigator.of(context).pushNamed(
            AppRouter.taskDetail,
            arguments: {
              'task': task,
              'currentUserId': context.read<AuthBloc>().state is AuthAuthenticated
                  ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
                  : '',
            },
          );
        },
      ),
    );
  }
}

/// Custom map pin widget with hover effects and tooltip
class _MapPin extends StatefulWidget {
  final TaskModel task;
  final Color markerColor;
  final IconData markerIcon;
  final String priorityLabel;
  final int starCount;
  final VoidCallback onTap;

  const _MapPin({
    required this.task,
    required this.markerColor,
    required this.markerIcon,
    required this.priorityLabel,
    required this.starCount,
    required this.onTap,
  });

  @override
  State<_MapPin> createState() => _MapPinState();
}

class _MapPinState extends State<_MapPin> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Tooltip on hover
            if (_isHovered)
              Positioned(
                bottom: 55,
                left: -60,
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.task.id.substring(widget.task.id.length - 8)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.markerColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.priorityLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: widget.markerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Pin marker
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: SizedBox(
                width: 40,
                height: 50,
                child: CustomPaint(
                  painter: _PinPainter(
                    color: widget.markerColor,
                    isHovered: _isHovered,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: widget.starCount > 0
                          ? Text(
                              '★' * widget.starCount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            )
                          : Icon(
                              widget.markerIcon,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for pin shape
class _PinPainter extends CustomPainter {
  final Color color;
  final bool isHovered;

  _PinPainter({required this.color, required this.isHovered});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 3 : 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final radius = size.width / 2;
    final center = Offset(size.width / 2, radius);

    // Draw shadow
    final shadowPath = Path();
    shadowPath.addOval(Rect.fromCircle(center: center, radius: radius - 2));
    shadowPath.moveTo(size.width / 2, size.height - 3);
    shadowPath.lineTo(size.width / 2 - 5, radius * 1.6 - 3);
    shadowPath.lineTo(size.width / 2 + 5, radius * 1.6 - 3);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw circular top
    path.addOval(Rect.fromCircle(center: center, radius: radius - 2));

    // Draw pin point (triangle at bottom)
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 - 6, radius * 1.6);
    path.lineTo(size.width / 2 + 6, radius * 1.6);
    path.close();

    // Fill the pin
    canvas.drawPath(path, paint);

    // Draw border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isHovered != isHovered;
  }
}


