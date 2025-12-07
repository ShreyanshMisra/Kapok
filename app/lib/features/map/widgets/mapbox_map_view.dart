import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/constants/mapbox_constants.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../models/map_camera_state.dart';
import '../web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../web/mapbox_web_controller.dart';

String get _mapboxStyleUri =>
    'mapbox://styles/${MapboxConstants.defaultStyleId}';

/// Simple wrapper so web/mobile share a common interface.
typedef MapCameraCallback = void Function(MapCameraState state);

/// A platform-aware Mapbox map view that delegates all rendering/gestures to Mapbox GL.
class MapboxMapView extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final OfflineMapRegion? offlineBubble;
  final bool isOfflineMode;
  final MapCameraCallback? onCameraIdle;
  final VoidCallback? onMapReady;
  final bool interactive;
  final void Function(MapboxWebController controller)? onControllerReady;

  const MapboxMapView({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom = 16,
    this.offlineBubble,
    this.isOfflineMode = false,
    this.onCameraIdle,
    this.onMapReady,
    this.interactive = true,
    this.onControllerReady,
  });

  @override
  State<MapboxMapView> createState() => _MapboxMapViewState();
}

class _MapboxMapViewState extends State<MapboxMapView> {
  late final MapboxWebController _webController = MapboxWebController.create(
    accessToken: MapboxConstants.accessToken,
    styleUri: _mapboxStyleUri,
  );

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _webController
        ..offlineBubble = widget.offlineBubble
        ..isOfflineMode = widget.isOfflineMode
        ..initialCamera = MapCameraState(
          latitude: widget.initialLatitude,
          longitude: widget.initialLongitude,
          zoom: widget.initialZoom,
        )
        ..onCameraIdle = widget.onCameraIdle
        ..onMapReady = () {
          widget.onMapReady?.call();
          widget.onControllerReady?.call(_webController);
        };
      _webController.interactive = widget.interactive;
      // Also call onControllerReady immediately if map already exists
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onControllerReady?.call(_webController);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MapboxMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb) {
      // Only update bubble and offline mode, don't reset camera position
      // This allows user to zoom/pan freely
      _webController
        ..offlineBubble = widget.offlineBubble
        ..isOfflineMode = widget.isOfflineMode;
      _webController.interactive = widget.interactive;
      // Don't call setCenter here - it resets user's zoom/pan position
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _webController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _webController.buildView();
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text(
        'Mapbox mobile view coming soon.\n'
        'Web version remains fully interactive.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
