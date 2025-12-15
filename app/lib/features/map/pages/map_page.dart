import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/network_checker.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../../../data/models/task_model.dart';
import '../models/map_camera_state.dart';
import '../widgets/mapbox_map_view.dart';
import '../web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../web/mapbox_web_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../teams/bloc/team_state.dart';
import '../../../app/router.dart';

/// Map page showing interactive map with live, location-based offline map functionality
/// It orchestrates a continuous cycle of "current location → live snapshot → offline cache refresh"
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _testOfflineMode = false;
  bool _showCacheOverlay = false;
  MapCameraState? _currentCamera;
  MapboxWebController? _mapController;

  // Pre-computed overlay circle coordinates (in screen pixels)
  OverlayCircle? _overlayCircle;

  void _updateOverlayCircle(OfflineMapRegion region) async {
    if (_mapController == null || !_showCacheOverlay) {
      _overlayCircle = null;
      return;
    }

    // Project region center to screen coordinates
    final centerScreen = _mapController!.projectLatLonToScreen(
      region.centerLat,
      region.centerLon,
    );

    if (centerScreen == null) {
      _overlayCircle = null;
      return;
    }

    // Calculate point 4.8km north of center for radius calculation
    final latDelta = 4.8 / 111.0; // 4.8 km in degrees
    final northLat = (region.centerLat + latDelta).clamp(-90.0, 90.0);
    final northScreen = _mapController!.projectLatLonToScreen(
      northLat,
      region.centerLon,
    );

    if (northScreen == null) {
      _overlayCircle = null;
      return;
    }

    // Calculate radius in pixels
    final radiusPixels = (northScreen - centerScreen).distance;

    setState(() {
      _overlayCircle = OverlayCircle(
        center: centerScreen,
        radius: radiusPixels,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // Load region and tasks when page opens
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

  @override
  void dispose() {
    // Dispose map controller when page is disposed (e.g., on logout)
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  void _toggleTestOfflineMode() {
    setState(() {
      _testOfflineMode = !_testOfflineMode;
      NetworkChecker.instance.setTestModeOverride(
        _testOfflineMode ? true : null,
      );
    });
    // Refresh the map state to reflect offline mode change
    final currentState = context.read<MapBloc>().state;
    if (currentState is MapReady) {
      context.read<MapBloc>().add(
        const OfflineBubbleRefreshRequested(force: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to dispose map on logout
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          // Logger.task(
          //   '[MAP_PAGE] AuthUnauthenticated detected - disposing map controller',
          // );
          // Dispose map controller immediately when user logs out
          _mapController?.dispose();
          _mapController = null;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.surface,
          title: Text(AppLocalizations.of(context).map),
          actions: [
            IconButton(
              icon: const Icon(Icons.storage),
              tooltip: 'View Cache',
              onPressed: () {
                Navigator.of(context).pushNamed('/map-cache');
              },
            ),
            // Note: Map filters intentionally deferred - tasks already have filtering in TasksPage
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.tasks);
              },
            ),
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
                // Dispose the map controller immediately to stop the map
                if (state is MapLoading && _mapController != null) {
                  // Logger.task(
                  //   '[MAP_PAGE] MapReset detected - disposing map controller',
                  // );
                  _mapController?.dispose();
                  _mapController = null;
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

  Widget _buildInteractiveMap(
    BuildContext context, {
    OfflineMapRegion? region,
    required bool isOffline,
    MapCameraState? camera,
    double? progressOverlay,
    List<TaskModel>? tasks,
  }) {
    // If no region is available yet, use a default location
    final initialCamera =
        camera ??
        (region != null
            ? MapCameraState(
                latitude: region.centerLat,
                longitude: region.centerLon,
                zoom: region.zoomMax.toDouble(),
              )
            : const MapCameraState(
                latitude: 37.7749, // Default to San Francisco
                longitude: -122.4194,
                zoom: 13.0,
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
              isOfflineMode: isOffline || _testOfflineMode,
              onCameraIdle: (cameraState) {
                setState(() {
                  _currentCamera = cameraState;
                });
                // Update overlay circle when camera changes
                if (region != null) {
                  _updateOverlayCircle(region);
                }
                context.read<MapBloc>().add(MapCameraMoved(cameraState));
              },
              onControllerReady: (controller) {
                _mapController = controller;
                // Initial overlay calculation
                if (region != null) {
                  _updateOverlayCircle(region);
                }
              },
            ),
          ),
          // Task markers overlay
          if (tasks != null && tasks.isNotEmpty && _mapController != null)
            ...tasks.map((task) => _buildTaskMarker(task)),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: MapStatusCard(
              regionName: region?.name ?? 'Loading...',
              isOffline: isOffline || _testOfflineMode,
              progress: progressOverlay,
            ),
          ),
          // Offline test controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Offline test toggle
                Card(
                  color: AppColors.surface.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _testOfflineMode ? Icons.cloud_off : Icons.cloud,
                          size: 18,
                          color: _testOfflineMode
                              ? AppColors.warning
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _testOfflineMode ? 'Test Offline' : 'Test Online',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Switch(
                          value: _testOfflineMode,
                          onChanged: (_) => _toggleTestOfflineMode(),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Cache overlay toggle
                Card(
                  color: AppColors.surface.withOpacity(0.9),
                  child: IconButton(
                    icon: Icon(
                      _showCacheOverlay ? Icons.layers : Icons.layers_outlined,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Show cached region overlay',
                    onPressed: () {
                      setState(() {
                        _showCacheOverlay = !_showCacheOverlay;
                      });
                      // Update overlay when toggled
                      if (_showCacheOverlay) {
                        final currentState = context.read<MapBloc>().state;
                        if (currentState is MapReady) {
                          _updateOverlayCircle(currentState.region);
                        } else if (currentState is OfflineRegionUpdating) {
                          _updateOverlayCircle(currentState.region);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Cached region overlay
          if (_showCacheOverlay && _overlayCircle != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: CachedRegionOverlayPainter(
                    overlayCircle: _overlayCircle!,
                    isOffline: isOffline || _testOfflineMode,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build a task marker widget positioned on the map
  Widget _buildTaskMarker(TaskModel task) {
    if (_mapController == null) return const SizedBox.shrink();

    // Project task location to screen coordinates
    final screenPos = _mapController!.projectLatLonToScreen(
      task.geoLocation.latitude,
      task.geoLocation.longitude,
    );

    if (screenPos == null) return const SizedBox.shrink();

    // Get color based on priority
    Color markerColor;
    IconData markerIcon;
    String priorityLabel;

    if (task.priority.value == 'high') {
      markerColor = AppColors.error; // Red for high priority
      markerIcon = Icons.warning;
      priorityLabel = 'High Priority';
    } else if (task.priority.value == 'medium') {
      markerColor = AppColors.warning; // Orange for medium priority
      markerIcon = Icons.info;
      priorityLabel = 'Medium Priority';
    } else {
      markerColor = AppColors.success; // Green for low priority
      markerIcon = Icons.check_circle;
      priorityLabel = 'Low Priority';
    }

    // If completed, use gray
    if (task.status.value == 'completed') {
      markerColor = AppColors.textSecondary;
      markerIcon = Icons.check_circle;
      priorityLabel = 'Completed';
    }

    return Positioned(
      left: screenPos.dx - 20, // Center the 40px pin
      top: screenPos.dy - 50, // Position pin point at location
      child: _MapPin(
        task: task,
        markerColor: markerColor,
        markerIcon: markerIcon,
        priorityLabel: priorityLabel,
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
  final VoidCallback onTap;

  const _MapPin({
    required this.task,
    required this.markerColor,
    required this.markerIcon,
    required this.priorityLabel,
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
                      child: Icon(
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

class MapStatusCard extends StatelessWidget {
  final String regionName;
  final bool isOffline;
  final double? progress;

  const MapStatusCard({
    required this.regionName,
    required this.isOffline,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isOffline ? Icons.cloud_off : Icons.cloud_queue,
                  size: 18,
                  color: isOffline ? AppColors.warning : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  regionName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(value: progress),
              ),
              const SizedBox(height: 4),
              Text(
                'Refreshing ${(progress! * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11),
              ),
            ] else ...[
              const SizedBox(height: 6),
              Text(
                isOffline ? 'Offline bubble active' : 'Live + offline bubble',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-computed overlay circle coordinates
class OverlayCircle {
  final Offset center;
  final double radius;

  OverlayCircle({required this.center, required this.radius});
}

/// Custom painter to show cached region overlay on map
/// Draws a circle representing the 3-mile radius cached region
/// Uses pre-computed screen coordinates from Mapbox's native project() method
class CachedRegionOverlayPainter extends CustomPainter {
  final OverlayCircle overlayCircle;
  final bool isOffline;

  CachedRegionOverlayPainter({
    required this.overlayCircle,
    required this.isOffline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerScreen = overlayCircle.center;
    final radiusPixels = overlayCircle.radius;

    // Draw circle fill with radial gradient (transparent at center to semi-transparent at edge)
    final fillPaint = Paint()
      ..shader =
          RadialGradient(
            center: Alignment.center,
            colors: [
              (isOffline ? AppColors.warning : AppColors.primary).withOpacity(
                0.0,
              ),
              (isOffline ? AppColors.warning : AppColors.primary).withOpacity(
                0.15,
              ),
            ],
            stops: const [0.0, 1.0],
          ).createShader(
            Rect.fromCircle(center: centerScreen, radius: radiusPixels),
          )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(centerScreen, radiusPixels, fillPaint);

    // Draw circle border
    final borderPaint = Paint()
      ..color = isOffline ? AppColors.warning : AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(centerScreen, radiusPixels, borderPaint);

    // Draw center marker
    final centerPaint = Paint()
      ..color = isOffline ? AppColors.warning : AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(centerScreen, 6, centerPaint);
    canvas.drawCircle(centerScreen, 6, borderPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: isOffline
            ? 'OFFLINE - Cached Region (3 mi)'
            : 'Cached Region - 3 mile radius',
        style: TextStyle(
          color: isOffline ? AppColors.warning : AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position label above the circle
    final labelY = (centerScreen.dy - radiusPixels - textPainter.height - 8)
        .clamp(10.0, size.height - textPainter.height - 10);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, labelY),
    );
  }

  @override
  bool shouldRepaint(covariant CachedRegionOverlayPainter oldDelegate) {
    return oldDelegate.isOffline != isOffline ||
        (oldDelegate.overlayCircle.center - overlayCircle.center).distance >
            1.0 ||
        (oldDelegate.overlayCircle.radius - overlayCircle.radius).abs() > 1.0;
  }
}
