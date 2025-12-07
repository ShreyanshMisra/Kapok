/// Represents the visible camera/viewport on the Mapbox surface.
class MapCameraState {
  final double latitude;
  final double longitude;
  final double zoom;

  const MapCameraState({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  MapCameraState copyWith({double? latitude, double? longitude, double? zoom}) {
    return MapCameraState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
    );
  }
}
