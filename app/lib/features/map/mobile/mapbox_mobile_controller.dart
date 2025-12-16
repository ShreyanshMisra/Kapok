import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../data/models/offline_map_region_model.dart';
import '../../../data/models/task_model.dart';
import '../models/map_camera_state.dart';

/// Mobile-specific controller that uses the native Mapbox Maps SDK.
class MapboxMobileController {
  MapboxMobileController._({
    required this.accessToken,
    required this.styleUri,
  });

  factory MapboxMobileController.create({
    required String accessToken,
    required String styleUri,
  }) {
    return MapboxMobileController._(accessToken: accessToken, styleUri: styleUri);
  }

  final String accessToken;
  final String styleUri;

  MapCameraState? initialCamera;
  OfflineMapRegion? offlineBubble;
  bool isOfflineMode = false;
  bool _interactive = true;
  void Function(MapCameraState state)? onCameraIdle;
  VoidCallback? onMapReady;
  void Function(double latitude, double longitude)? onDoubleClick;
  void Function(TaskModel task)? onTaskMarkerTap;

  bool get interactive => _interactive;
  set interactive(bool value) {
    _interactive = value;
    _updateInteractionSettings();
  }

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _taskAnnotationManager;
  final Map<String, TaskModel> _taskAnnotationMap = {};
  bool _annotationListenerAdded = false;

  // User location tracking
  StreamSubscription<void>? _locationSubscription;

  /// Sets the MapboxMap instance from the widget callback
  void setMapboxMap(MapboxMap map) {
    _mapboxMap = map;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (_mapboxMap == null) return;

    // Set up camera idle listener
    _mapboxMap!.setCamera(CameraOptions(
      center: Point(
        coordinates: Position(
          initialCamera?.longitude ?? 0,
          initialCamera?.latitude ?? 0,
        ),
      ),
      zoom: initialCamera?.zoom ?? 2,
    ));

    // Enable user location display
    await _enableUserLocationDisplay();

    // Create annotation manager for task markers
    _taskAnnotationManager = await _mapboxMap!.annotations.createPointAnnotationManager();

    // Set up tap listener for annotations ONCE during initialization
    // The listener references _taskAnnotationMap which is updated when markers change
    if (!_annotationListenerAdded && _taskAnnotationManager != null) {
      _taskAnnotationManager!.addOnPointAnnotationClickListener(
        _AnnotationClickListener(
          taskAnnotationMap: _taskAnnotationMap,
          onTaskTap: (task) => onTaskMarkerTap?.call(task),
        ),
      );
      _annotationListenerAdded = true;
    }

    // Set up interaction settings
    _updateInteractionSettings();

    // Notify that map is ready
    onMapReady?.call();
  }

  Future<void> _enableUserLocationDisplay() async {
    if (_mapboxMap == null) return;

    try {
      // Enable location component with pulsing indicator
      await _mapboxMap!.location.updateSettings(LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: 0xFF4285F4, // Google Blue color
        showAccuracyRing: true,
        puckBearingEnabled: true,
      ));
    } catch (e) {
      debugPrint('Error enabling user location display: $e');
    }
  }

  /// Programmatically moves the camera.
  Future<void> setCenter(double lat, double lon, {double? zoom}) async {
    if (_mapboxMap == null) return;

    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lon, lat)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  /// Fly to the user's current location
  /// Uses the Geolocator service to get current position since MapboxMap doesn't expose puck position directly
  Future<void> flyToUserLocation({double zoom = 15, double? lat, double? lon}) async {
    if (_mapboxMap == null) return;

    try {
      // If coordinates provided, use them; otherwise caller should provide from geolocator
      if (lat != null && lon != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(lon, lat)),
            zoom: zoom,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    } catch (e) {
      debugPrint('Error flying to user location: $e');
    }
  }

  /// Gets current camera state from the map
  Future<MapCameraState?> getCurrentCamera() async {
    if (_mapboxMap == null) return null;
    try {
      final camera = await _mapboxMap!.getCameraState();
      final center = camera.center;
      return MapCameraState(
        latitude: center.coordinates.lat.toDouble(),
        longitude: center.coordinates.lng.toDouble(),
        zoom: camera.zoom,
      );
    } catch (e) {
      debugPrint('Error getting current camera: $e');
      return null;
    }
  }

  /// Projects lat/lon to screen coordinates
  Future<Offset?> projectLatLonToScreen(double lat, double lon) async {
    if (_mapboxMap == null) return null;
    try {
      final screenCoord = await _mapboxMap!.pixelForCoordinate(
        Point(coordinates: Position(lon, lat)),
      );
      return Offset(screenCoord.x, screenCoord.y);
    } catch (e) {
      debugPrint('Error projecting lat/lon to screen: $e');
      return null;
    }
  }

  /// Updates task markers on the map using native Mapbox annotations
  Future<void> updateTaskMarkers(List<TaskModel> tasks) async {
    if (_mapboxMap == null || _taskAnnotationManager == null) return;

    try {
      // Clear existing annotations
      await _taskAnnotationManager!.deleteAll();
      _taskAnnotationMap.clear();

      // Note: The tap listener is set up once in _initializeMap()
      // It references _taskAnnotationMap which we update below

      // Create new annotations for each task
      final annotationOptions = <PointAnnotationOptions>[];

      for (final task in tasks) {
        // Determine icon color based on priority/status
        int iconColor;
        String iconImage;
        if (task.status.value == 'completed') {
          iconColor = 0xFF808080; // Gray
          iconImage = 'marker'; // Default marker
        } else if (task.priority.value == 'high') {
          iconColor = 0xFFE53935; // Red
          iconImage = 'marker'; // Default marker
        } else if (task.priority.value == 'medium') {
          iconColor = 0xFFFB8C00; // Orange
          iconImage = 'marker'; // Default marker
        } else {
          iconColor = 0xFF43A047; // Green
          iconImage = 'marker'; // Default marker
        }

        annotationOptions.add(PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              task.geoLocation.longitude,
              task.geoLocation.latitude,
            ),
          ),
          iconImage: iconImage,
          iconSize: 1.5,
          iconColor: iconColor,
          textField: task.title.length > 20
              ? '${task.title.substring(0, 17)}...'
              : task.title,
          textSize: 12.0,
          textOffset: [0.0, 2.0],
          textAnchor: TextAnchor.TOP,
          textColor: iconColor,
          textHaloColor: 0xFFFFFFFF,
          textHaloWidth: 1.5,
        ));
      }

      if (annotationOptions.isNotEmpty) {
        final annotations = await _taskAnnotationManager!.createMulti(annotationOptions);

        // Map annotation IDs to tasks for tap handling
        for (int i = 0; i < annotations.length && i < tasks.length; i++) {
          final annotation = annotations[i];
          if (annotation != null) {
            _taskAnnotationMap[annotation.id] = tasks[i];
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating task markers: $e');
    }
  }

  void _updateInteractionSettings() {
    if (_mapboxMap == null) return;
    try {
      _mapboxMap!.gestures.updateSettings(GesturesSettings(
        scrollEnabled: _interactive,
        rotateEnabled: _interactive,
        pitchEnabled: _interactive,
        doubleTapToZoomInEnabled: _interactive,
        doubleTouchToZoomOutEnabled: _interactive,
        quickZoomEnabled: _interactive,
        pinchToZoomEnabled: _interactive,
        pinchPanEnabled: _interactive,
      ));
    } catch (e) {
      debugPrint('Error updating interaction settings: $e');
    }
  }

  void dispose() {
    _locationSubscription?.cancel();
    _taskAnnotationManager = null;
    _taskAnnotationMap.clear();
    _annotationListenerAdded = false;
    _mapboxMap = null;
  }

  // Track last tap time for double-tap detection
  DateTime? _lastTapTime;
  Point? _lastTapPoint;
  static const _doubleTapThresholdMs = 300;

  /// Builds the native MapWidget
  Widget buildView({
    Function(MapboxMap)? onMapCreated,
    Function(MapContentGestureContext)? onMapTap,
  }) {
    // Set the access token before creating the map
    MapboxOptions.setAccessToken(accessToken);

    final camera = initialCamera ?? const MapCameraState(
      latitude: 0,
      longitude: 0,
      zoom: 2,
    );

    return MapWidget(
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(camera.longitude, camera.latitude),
        ),
        zoom: camera.zoom,
      ),
      styleUri: styleUri,
      onMapCreated: (map) {
        setMapboxMap(map);
        onMapCreated?.call(map);
      },
      onCameraChangeListener: (cameraChangedEventData) {
        // Debounce camera changes to avoid too many updates
      },
      onMapIdleListener: (mapIdleEventData) async {
        final currentCamera = await getCurrentCamera();
        if (currentCamera != null) {
          onCameraIdle?.call(currentCamera);
        }
      },
      onTapListener: (context) {
        // Check for double-tap to trigger onDoubleClick
        final now = DateTime.now();
        final point = context.point;
        
        if (_lastTapTime != null && _lastTapPoint != null) {
          final timeDiff = now.difference(_lastTapTime!).inMilliseconds;
          if (timeDiff < _doubleTapThresholdMs) {
            // Double-tap detected - use the first tap's coordinates
            final lat = _lastTapPoint!.coordinates.lat.toDouble();
            final lon = _lastTapPoint!.coordinates.lng.toDouble();
            onDoubleClick?.call(lat, lon);
            _lastTapTime = null;
            _lastTapPoint = null;
            return;
          }
        }
        
        _lastTapTime = now;
        _lastTapPoint = point;
        
        // Call the original onMapTap if provided
        onMapTap?.call(context);
      },
      onLongTapListener: (context) {
        // Also support long-press as an alternative to double-tap
        final lat = context.point.coordinates.lat.toDouble();
        final lon = context.point.coordinates.lng.toDouble();
        onDoubleClick?.call(lat, lon);
      },
    );
  }
}

/// Listener for annotation clicks to handle task marker taps
class _AnnotationClickListener extends OnPointAnnotationClickListener {
  final Map<String, TaskModel> taskAnnotationMap;
  final void Function(TaskModel task)? onTaskTap;

  _AnnotationClickListener({
    required this.taskAnnotationMap,
    required this.onTaskTap,
  });

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final task = taskAnnotationMap[annotation.id];
    if (task != null && onTaskTap != null) {
      onTaskTap!(task);
    }
  }
}
