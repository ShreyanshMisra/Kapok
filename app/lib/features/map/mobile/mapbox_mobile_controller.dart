import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../data/models/offline_map_region_model.dart';
import '../../../data/models/task_model.dart';
import '../models/map_camera_state.dart';

/// Marker icon names for different priorities/states
class _MarkerIcons {
  static const String high = 'marker-high';
  static const String medium = 'marker-medium';
  static const String low = 'marker-low';
  static const String completed = 'marker-completed';
}

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
  void Function(double latitude, double longitude)? onTap;
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
  bool _markerImagesRegistered = false;

  // User location tracking
  StreamSubscription<void>? _locationSubscription;

  // Marker colors matching web priority colours
  static const Color _highPriorityColor = Color(0xFFE53935);  // red
  static const Color _mediumPriorityColor = Color(0xFFFFA000); // amber
  static const Color _lowPriorityColor = Color(0xFF43A047);   // green
  static const Color _completedColor = Color(0xFF808080);     // grey

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

    // Register custom marker images for task pins
    await _registerMarkerImages();

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

  /// Register custom marker images with the map style
  Future<void> _registerMarkerImages() async {
    if (_mapboxMap == null || _markerImagesRegistered) return;

    try {
      // Create and register marker images for each priority with star counts
      await _addMarkerImage(_MarkerIcons.high, _highPriorityColor, Icons.star, starCount: 3);
      await _addMarkerImage(_MarkerIcons.medium, _mediumPriorityColor, Icons.star, starCount: 2);
      await _addMarkerImage(_MarkerIcons.low, _lowPriorityColor, Icons.star, starCount: 1);
      await _addMarkerImage(_MarkerIcons.completed, _completedColor, Icons.check_circle, starCount: 0);
      
      _markerImagesRegistered = true;
      debugPrint('Marker images registered successfully');
    } catch (e) {
      debugPrint('Error registering marker images: $e');
    }
  }

  /// Create a marker image with the specified color and icon, then add it to the map
  Future<void> _addMarkerImage(String name, Color color, IconData icon, {int starCount = 0}) async {
    if (_mapboxMap == null) return;

    try {
      final imageData = await _createMarkerImageData(color, icon, starCount: starCount);
      if (imageData != null) {
        // Add image to map style using MbxImage
        final mbxImage = MbxImage(
          width: 64,
          height: 80,
          data: imageData,
        );
        await _mapboxMap!.style.addStyleImage(
          name,
          2.0, // pixel ratio for retina displays
          mbxImage,
          false, // sdf (signed distance field) - false for regular images
          [], // stretch X ranges
          [], // stretch Y ranges
          null, // content insets
        );
      }
    } catch (e) {
      debugPrint('Error adding marker image $name: $e');
    }
  }

  /// Create marker image data as bytes
  Future<Uint8List?> _createMarkerImageData(Color color, IconData icon, {int starCount = 0}) async {
    try {
      // Create a picture recorder to draw the marker
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      const width = 64.0;
      const height = 80.0;
      const pinRadius = 28.0;
      const pinCenterY = 28.0;
      
      // Draw shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      // Shadow for circle
      canvas.drawCircle(
        const Offset(width / 2 + 2, pinCenterY + 2),
        pinRadius - 2,
        shadowPaint,
      );
      
      // Shadow for pin point
      final shadowPath = Path()
        ..moveTo(width / 2 + 2, height - 2)
        ..lineTo(width / 2 - 8 + 2, pinCenterY + pinRadius * 0.7 + 2)
        ..lineTo(width / 2 + 8 + 2, pinCenterY + pinRadius * 0.7 + 2)
        ..close();
      canvas.drawPath(shadowPath, shadowPaint);
      
      // Draw white border/background
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        const Offset(width / 2, pinCenterY),
        pinRadius,
        borderPaint,
      );
      
      // Draw pin point with white background
      final pinPath = Path()
        ..moveTo(width / 2, height - 4)
        ..lineTo(width / 2 - 10, pinCenterY + pinRadius * 0.7)
        ..lineTo(width / 2 + 10, pinCenterY + pinRadius * 0.7)
        ..close();
      canvas.drawPath(pinPath, borderPaint);
      
      // Draw colored circle
      final colorPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        const Offset(width / 2, pinCenterY),
        pinRadius - 3,
        colorPaint,
      );
      
      // Draw colored pin point
      final colorPinPath = Path()
        ..moveTo(width / 2, height - 7)
        ..lineTo(width / 2 - 7, pinCenterY + pinRadius * 0.65)
        ..lineTo(width / 2 + 7, pinCenterY + pinRadius * 0.65)
        ..close();
      canvas.drawPath(colorPinPath, colorPaint);
      
      // Draw icon or stars in center
      if (starCount > 0) {
        // Draw star characters for priority level
        final starPainter = TextPainter(
          text: TextSpan(
            text: '★' * starCount,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        starPainter.layout();
        starPainter.paint(
          canvas,
          Offset(
            (width - starPainter.width) / 2,
            pinCenterY - starPainter.height / 2,
          ),
        );
      } else {
        final iconPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 24,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        iconPainter.layout();
        iconPainter.paint(
          canvas,
          Offset(
            (width - iconPainter.width) / 2,
            pinCenterY - iconPainter.height / 2,
          ),
        );
      }
      
      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error creating marker image: $e');
      return null;
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

  /// Fly to a specific location with animation
  Future<void> flyTo(double lat, double lon, double zoom) async {
    await setCenter(lat, lon, zoom: zoom);
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

    // Ensure marker images are registered before adding markers
    if (!_markerImagesRegistered) {
      await _registerMarkerImages();
    }

    try {
      // Clear existing annotations
      await _taskAnnotationManager!.deleteAll();
      _taskAnnotationMap.clear();

      // Note: The tap listener is set up once in _initializeMap()
      // It references _taskAnnotationMap which we update below

      // Create new annotations for each task
      final annotationOptions = <PointAnnotationOptions>[];

      for (final task in tasks) {
        // Determine icon and text color based on priority/status
        String iconImage;
        int textColor;
        
        if (task.status.value == 'completed') {
          iconImage = _MarkerIcons.completed;
          textColor = 0xFF808080; // grey
        } else if (task.priority.value == 'high') {
          iconImage = _MarkerIcons.high;
          textColor = 0xFFE53935; // red
        } else if (task.priority.value == 'medium') {
          iconImage = _MarkerIcons.medium;
          textColor = 0xFFFFA000; // amber
        } else {
          iconImage = _MarkerIcons.low;
          textColor = 0xFF43A047; // green
        }

        annotationOptions.add(PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              task.geoLocation.longitude,
              task.geoLocation.latitude,
            ),
          ),
          iconImage: iconImage,
          iconSize: 0.6, // Scale down the 64x80 image
          iconAnchor: IconAnchor.BOTTOM, // Anchor at bottom of pin
          textField: task.title.length > 20
              ? '${task.title.substring(0, 17)}...'
              : task.title,
          textSize: 11.0,
          textOffset: [0.0, 0.5], // Position text below the pin
          textAnchor: TextAnchor.TOP,
          textColor: textColor,
          textHaloColor: 0xFFFFFFFF,
          textHaloWidth: 2.0,
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
        
        debugPrint('Added ${annotations.length} task markers to map');
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
    _pendingSingleTapTimer?.cancel();
    _locationSubscription?.cancel();
    _taskAnnotationManager = null;
    _taskAnnotationMap.clear();
    _annotationListenerAdded = false;
    _mapboxMap = null;
  }

  // Track last tap time for double-tap detection
  DateTime? _lastTapTime;
  Point? _lastTapPoint;
  Timer? _pendingSingleTapTimer;
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
            // Double-tap detected - cancel pending single-tap and fire double-click
            _pendingSingleTapTimer?.cancel();
            _pendingSingleTapTimer = null;
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

        // Schedule single-tap callback after threshold if no second tap occurs
        _pendingSingleTapTimer?.cancel();
        final tapLat = point.coordinates.lat.toDouble();
        final tapLon = point.coordinates.lng.toDouble();
        _pendingSingleTapTimer = Timer(
          const Duration(milliseconds: _doubleTapThresholdMs),
          () {
            onTap?.call(tapLat, tapLon);
            onMapTap?.call(context);
          },
        );
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
