import 'package:flutter/material.dart';

import '../../../data/models/offline_map_region_model.dart';
import '../models/map_camera_state.dart';

/// Fallback controller used on non-web targets (no-op).
class MapboxWebController {
  final String accessToken;
  final String styleUri;

  MapboxWebController._({required this.accessToken, required this.styleUri});

  factory MapboxWebController.create({
    required String accessToken,
    required String styleUri,
  }) {
    return MapboxWebController._(accessToken: accessToken, styleUri: styleUri);
  }

  MapCameraState? initialCamera;
  OfflineMapRegion? offlineBubble;
  bool isOfflineMode = false;
  bool interactive = true;
  void Function(MapCameraState state)? onCameraIdle;
  VoidCallback? onMapReady;

  Widget buildView() {
    return const SizedBox.shrink();
  }

  void setCenter(double lat, double lon, {double? zoom}) {}

  void dispose() {}

  MapCameraState? getCurrentCamera() => null;

  Offset? projectLatLonToScreen(double lat, double lon) => null;
}
