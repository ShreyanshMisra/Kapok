import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/constants/mapbox_constants.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../../../data/models/task_model.dart';
import '../models/map_camera_state.dart';
import '../web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../web/mapbox_web_controller.dart';
import '../mobile/mapbox_mobile_controller.dart';

String get _mapboxStyleUri =>
    'mapbox://styles/${MapboxConstants.defaultStyleId}';

/// Simple wrapper so web/mobile share a common interface.
typedef MapCameraCallback = void Function(MapCameraState state);

/// Abstract controller interface for platform-agnostic map operations
abstract class MapController {
  void setCenter(double lat, double lon, {double? zoom});
  MapCameraState? getCurrentCamera();
  Offset? projectLatLonToScreen(double lat, double lon);
  void dispose();
}

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
  final void Function(MapboxMobileController controller)? onMobileControllerReady;
  final void Function(double latitude, double longitude)? onDoubleClick;
  final List<TaskModel>? tasks;
  final void Function(TaskModel task)? onTaskMarkerTap;

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
    this.onMobileControllerReady,
    this.onDoubleClick,
    this.tasks,
    this.onTaskMarkerTap,
  });

  @override
  State<MapboxMapView> createState() => _MapboxMapViewState();
}

class _MapboxMapViewState extends State<MapboxMapView> {
  // Web controller (only used on web)
  MapboxWebController? _webController;

  // Mobile controller (only used on mobile)
  MapboxMobileController? _mobileController;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWebController();
    } else {
      _initMobileController();
    }
  }

  void _initWebController() {
    _webController = MapboxWebController.create(
      accessToken: MapboxConstants.accessToken,
      styleUri: _mapboxStyleUri,
    );
    _webController!
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
        widget.onControllerReady?.call(_webController!);
      };
    if (widget.onDoubleClick != null) {
      _webController!.onDoubleClick = widget.onDoubleClick;
    }
    _webController!.interactive = widget.interactive;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onControllerReady?.call(_webController!);
    });
  }

  void _initMobileController() {
    _mobileController = MapboxMobileController.create(
      accessToken: MapboxConstants.accessToken,
      styleUri: _mapboxStyleUri,
    );
    _mobileController!
      ..initialCamera = MapCameraState(
        latitude: widget.initialLatitude,
        longitude: widget.initialLongitude,
        zoom: widget.initialZoom,
      )
      ..offlineBubble = widget.offlineBubble
      ..isOfflineMode = widget.isOfflineMode
      ..onCameraIdle = widget.onCameraIdle
      ..onMapReady = () {
        widget.onMapReady?.call();
        widget.onMobileControllerReady?.call(_mobileController!);
        // Update task markers if provided
        if (widget.tasks != null && widget.tasks!.isNotEmpty) {
          _mobileController!.updateTaskMarkers(widget.tasks!);
        }
      }
      ..onDoubleClick = widget.onDoubleClick
      ..onTaskMarkerTap = widget.onTaskMarkerTap
      ..interactive = widget.interactive;
  }

  @override
  void didUpdateWidget(covariant MapboxMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb && _webController != null) {
      _webController!
        ..offlineBubble = widget.offlineBubble
        ..isOfflineMode = widget.isOfflineMode;
      _webController!.onDoubleClick = widget.onDoubleClick;
      _webController!.interactive = widget.interactive;
    } else if (!kIsWeb && _mobileController != null) {
      _mobileController!
        ..offlineBubble = widget.offlineBubble
        ..isOfflineMode = widget.isOfflineMode
        ..interactive = widget.interactive
        ..onDoubleClick = widget.onDoubleClick
        ..onTaskMarkerTap = widget.onTaskMarkerTap;

      // Update task markers if they changed
      if (widget.tasks != oldWidget.tasks && widget.tasks != null) {
        _mobileController!.updateTaskMarkers(widget.tasks!);
      }
    }
  }

  @override
  void dispose() {
    _webController?.dispose();
    _mobileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _webController!.buildView();
    }

    // Mobile: Use native Mapbox Maps SDK
    // Double-tap and long-press are now handled internally by MapboxMobileController
    return _mobileController!.buildView();
  }
}
