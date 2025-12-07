import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/network_checker.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../models/map_camera_state.dart';
import '../widgets/mapbox_map_view.dart';
import '../web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../web/mapbox_web_controller.dart';
import '../../../core/localization/app_localizations.dart';

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
    // Load region for current location when page opens
    // Use post-frame callback to ensure BlocProvider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MapBloc>().add(const MapStarted());
    });
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
    return Scaffold(
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show map filters
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // TODO: Navigate to tasks list view
            },
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // Debug: Show current state
          if (kDebugMode) {
            print('[MAP_PAGE] Current state: ${state.runtimeType}');
          }

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

          // Initial or error state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state is MapError ? Icons.error_outline : Icons.map_outlined,
                  size: 64,
                  color: state is MapError
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                if (state is MapError) ...[
                  Text(
                    'ERROR: ${state.message}',
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
    );
  }

  Widget _buildInteractiveMap(
    BuildContext context, {
    required OfflineMapRegion region,
    required bool isOffline,
    MapCameraState? camera,
    double? progressOverlay,
  }) {
    final initialCamera =
        camera ??
        MapCameraState(
          latitude: region.centerLat,
          longitude: region.centerLon,
          zoom: region.zoomMax.toDouble(),
        );
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
                _updateOverlayCircle(region);
                context.read<MapBloc>().add(MapCameraMoved(cameraState));
              },
              onControllerReady: (controller) {
                _mapController = controller;
                // Initial overlay calculation
                _updateOverlayCircle(region);
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: MapStatusCard(
              regionName: region.name,
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
