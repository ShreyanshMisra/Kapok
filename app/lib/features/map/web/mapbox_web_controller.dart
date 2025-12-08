// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js' show allowInterop;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../models/map_camera_state.dart';

/// Web-specific controller that embeds Mapbox GL JS via HtmlElementView.
class MapboxWebController {
  MapboxWebController._({required this.accessToken, required this.styleUri}) {
    _registerViewFactory();
  }

  factory MapboxWebController.create({
    required String accessToken,
    required String styleUri,
  }) {
    return MapboxWebController._(accessToken: accessToken, styleUri: styleUri);
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

  bool get interactive => _interactive;
  set interactive(bool value) {
    _interactive = value;
    _updateInteractionSettings();
  }

  static int _viewCounter = 0;
  late final String viewType = 'mapbox-html-view-${_viewCounter++}';

  html.DivElement? _container;
  Object? _mapInstance;
  bool _scriptsInjected = false;

  /// Builds the HtmlElementView widget that hosts the Mapbox canvas.
  Widget buildView() {
    return HtmlElementView(
      viewType: viewType,
      onPlatformViewCreated: (_) => _ensureRendered(),
    );
  }

  /// Programmatically moves the camera.
  void setCenter(double lat, double lon, {double? zoom}) {
    if (_mapInstance == null) return;
    final options = <String, dynamic>{
      'center': {'lat': lat, 'lng': lon},
    };
    if (zoom != null) {
      options['zoom'] = zoom;
    }
    js_util.callMethod(_mapInstance!, 'jumpTo', [js_util.jsify(options)]);
  }

  void dispose() {
    if (_mapInstance != null) {
      js_util.callMethod(_mapInstance!, 'remove', const []);
      _mapInstance = null;
    }
    _container = null;
  }

  Future<void> _ensureRendered() async {
    if (_mapInstance != null) return;
    await _injectScripts();
    if (_container == null) {
      throw StateError('Mapbox container not ready for $viewType');
    }
    final mapbox = js_util.getProperty<Object>(js_util.globalThis, 'mapboxgl');
    js_util.setProperty(mapbox, 'accessToken', accessToken);
    final camera =
        initialCamera ??
        const MapCameraState(latitude: 0, longitude: 0, zoom: 2);
    final jsOptions = js_util.jsify({
      'container': _container,
      'style': styleUri,
      'center': {'lat': camera.latitude, 'lng': camera.longitude},
      'zoom': camera.zoom,
      'pitch': 0,
      'bearing': 0,
      'transformRequest': allowInterop(_handleTransformRequest),
      'interactive': _interactive,
      'dragPan': _interactive,
      'dragRotate': _interactive,
      'scrollZoom': _interactive,
      'boxZoom': _interactive,
      'doubleClickZoom': _interactive,
      'keyboard': _interactive,
      'touchZoomRotate': _interactive,
    });
    _mapInstance = js_util.callConstructor(js_util.getProperty(mapbox, 'Map'), [
      jsOptions,
    ]);
    js_util.callMethod(_mapInstance!, 'on', [
      'load',
      allowInterop((_) => onMapReady?.call()),
    ]);
    js_util.callMethod(_mapInstance!, 'on', [
      'moveend',
      allowInterop((_) => _emitCamera()),
    ]);
    js_util.callMethod(_mapInstance!, 'on', [
      'zoomend',
      allowInterop((_) => _emitCamera()),
    ]);

    // Add double-click handler if callback is provided
    if (onDoubleClick != null) {
      js_util.callMethod(_mapInstance!, 'on', [
        'dblclick',
        allowInterop((e) {
          // Extract lat/lng from event
          final lngLat = js_util.getProperty(e, 'lngLat');
          if (lngLat != null) {
            final lat = js_util.getProperty(lngLat, 'lat') as num?;
            final lng = js_util.getProperty(lngLat, 'lng') as num?;
            if (lat != null && lng != null) {
              onDoubleClick!(lat.toDouble(), lng.toDouble());
            }
          }
        }),
      ]);
    }

    // Update interaction settings if map already exists
    _updateInteractionSettings();
  }

  void _updateInteractionSettings() {
    if (_mapInstance == null) return;
    try {
      // Get the map's interaction handlers
      final handlers = js_util.getProperty(_mapInstance!, 'handlers');
      if (handlers == null) return;

      // Enable/disable drag pan
      final dragPan = js_util.getProperty(handlers, 'dragPan');
      if (dragPan != null) {
        js_util.setProperty(dragPan, 'enabled', interactive);
      }
      // Enable/disable scroll zoom
      final scrollZoom = js_util.getProperty(handlers, 'scrollZoom');
      if (scrollZoom != null) {
        js_util.setProperty(scrollZoom, 'enabled', interactive);
      }
      // Enable/disable box zoom
      final boxZoom = js_util.getProperty(handlers, 'boxZoom');
      if (boxZoom != null) {
        js_util.setProperty(boxZoom, 'enabled', interactive);
      }
      // Enable/disable double click zoom
      final doubleClickZoom = js_util.getProperty(handlers, 'doubleClickZoom');
      if (doubleClickZoom != null) {
        js_util.setProperty(doubleClickZoom, 'enabled', interactive);
      }
      // Enable/disable keyboard
      final keyboard = js_util.getProperty(handlers, 'keyboard');
      if (keyboard != null) {
        js_util.setProperty(keyboard, 'enabled', interactive);
      }
      // Enable/disable touch zoom rotate
      final touchZoomRotate = js_util.getProperty(handlers, 'touchZoomRotate');
      if (touchZoomRotate != null) {
        js_util.setProperty(touchZoomRotate, 'enabled', interactive);
      }
    } catch (e) {
      Logger.task('Error updating interaction settings', error: e);
    }
  }

  /// Gets current camera state from the map
  MapCameraState? getCurrentCamera() {
    if (_mapInstance == null) return null;
    try {
      final center = js_util.callMethod<Object>(
        _mapInstance!,
        'getCenter',
        const [],
      );
      final lat = js_util.getProperty(center, 'lat') as num? ?? 0;
      final lon = js_util.getProperty(center, 'lng') as num? ?? 0;
      final zoomResult = js_util.callMethod(_mapInstance!, 'getZoom', const []);
      final zoom = (zoomResult as num?)?.toDouble() ?? 0.0;
      return MapCameraState(
        latitude: lat.toDouble(),
        longitude: lon.toDouble(),
        zoom: zoom.toDouble(),
      );
    } catch (e) {
      Logger.task('Error getting current camera', error: e);
      return null;
    }
  }

  /// Projects lat/lon to screen coordinates
  Offset? projectLatLonToScreen(double lat, double lon) {
    if (_mapInstance == null) return null;
    try {
      // Mapbox project() expects [lng, lat] array, not {lat, lng} object
      final point = js_util.callMethod<Object>(_mapInstance!, 'project', [
        js_util.jsify([lon, lat]),
      ]);
      final x = js_util.getProperty(point, 'x') as num? ?? 0;
      final y = js_util.getProperty(point, 'y') as num? ?? 0;
      return Offset(x.toDouble(), y.toDouble());
    } catch (e) {
      Logger.task('Error projecting lat/lon to screen', error: e);
      return null;
    }
  }

  Object _handleTransformRequest(dynamic url, dynamic resourceType) {
    final urlString = url?.toString() ?? '';
    final resource = resourceType?.toString() ?? '';
    final shouldBlock = isOfflineMode && _shouldBlockUrl(urlString, resource);
    if (shouldBlock) {
      Logger.task('[MapboxWeb] Blocking remote tile: $urlString');
      return js_util.jsify({'url': 'data:,'});
    }
    return js_util.jsify({'url': urlString});
  }

  bool _shouldBlockUrl(String url, String resourceType) {
    if (offlineBubble == null) {
      return false;
    }
    if (resourceType != 'Tile' && resourceType != 'tile') {
      return false;
    }
    final match = RegExp(
      r'/(\d{1,2})/(\d+)/(\d+)(?:[@\.\w-]*)$',
    ).firstMatch(url);
    if (match == null) return false;
    final z = int.tryParse(match.group(1) ?? '');
    final x = int.tryParse(match.group(2) ?? '');
    final y = int.tryParse(match.group(3) ?? '');
    if (z == null || x == null || y == null) return false;
    final bubble = offlineBubble!;
    if (z < bubble.zoomMin || z > bubble.zoomMax) {
      return true;
    }
    return !bubble.containsTile(z, x, y);
  }

  void _emitCamera() {
    if (_mapInstance == null || onCameraIdle == null) return;
    final center = js_util.callMethod<Object>(
      _mapInstance!,
      'getCenter',
      const [],
    );
    final lat = js_util.getProperty(center, 'lat') as num? ?? 0;
    final lon = js_util.getProperty(center, 'lng') as num? ?? 0;
    final zoomResult = js_util.callMethod(_mapInstance!, 'getZoom', const []);
    final zoom = (zoomResult as num?)?.toDouble() ?? 0.0;
    onCameraIdle!(
      MapCameraState(
        latitude: lat.toDouble(),
        longitude: lon.toDouble(),
        zoom: zoom.toDouble(),
      ),
    );
  }

  Future<void> _injectScripts() async {
    if (_scriptsInjected) return;
    _scriptsInjected = true;
    final head = html.document.head!;
    const cssUrl = 'https://api.mapbox.com/mapbox-gl-js/v3.4.0/mapbox-gl.css';
    const jsUrl = 'https://api.mapbox.com/mapbox-gl-js/v3.4.0/mapbox-gl.js';
    if (html.document.querySelector('#mapbox-gl-css') == null) {
      head.append(
        html.LinkElement()
          ..id = 'mapbox-gl-css'
          ..rel = 'stylesheet'
          ..href = cssUrl,
      );
    }
    if (html.document.querySelector('#mapbox-gl-js') == null) {
      final script = html.ScriptElement()
        ..id = 'mapbox-gl-js'
        ..src = jsUrl
        ..defer = true;
      final completer = Completer<void>();
      script.onLoad.listen((_) => completer.complete());
      script.onError.listen((e) => completer.completeError(e));
      head.append(script);
      await completer.future;
    }
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.DivElement()
        ..id = 'mapbox-view-$viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0';
      _container = element;
      return element;
    });
  }
}
