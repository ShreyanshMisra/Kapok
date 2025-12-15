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

      // Create new annotations for each task
      final annotationOptions = <PointAnnotationOptions>[];

      for (final task in tasks) {
        // Determine text color based on priority/status
        int textColor;
        if (task.status.value == 'completed') {
          textColor = 0xFF808080; // Gray
        } else if (task.priority.value == 'high') {
          textColor = 0xFFE53935; // Red
        } else if (task.priority.value == 'medium') {
          textColor = 0xFFFB8C00; // Orange
        } else {
          textColor = 0xFF43A047; // Green
        }

        annotationOptions.add(PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              task.geoLocation.longitude,
              task.geoLocation.latitude,
            ),
          ),
          iconSize: 1.5,
          textField: task.title.length > 20
              ? '${task.title.substring(0, 17)}...'
              : task.title,
          textSize: 12.0,
          textOffset: [0, 2.0],
          textAnchor: TextAnchor.TOP,
          textColor: textColor,
          textHaloColor: 0xFFFFFFFF,
          textHaloWidth: 1.0,
        ));
      }

      if (annotationOptions.isNotEmpty) {
        final annotations = await _taskAnnotationManager!.createMulti(annotationOptions);

        // Map annotation IDs to tasks for tap handling
        for (int i = 0; i < annotations.length && i < tasks.length; i++) {
          // Use index-based key for consistent mapping
          _taskAnnotationMap['task_$i'] = tasks[i];
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
    _mapboxMap = null;
  }

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
      onTapListener: onMapTap,
    );
  }
}
