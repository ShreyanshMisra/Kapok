/// Mapbox API configuration constants
/// TODO: Replace with actual Mapbox access token from environment variables or secure storage
class MapboxConstants {
  /// Mapbox access token - should be stored securely, not hardcoded
  /// Get your token from: https://account.mapbox.com/access-tokens/
  static const String accessToken = 'pk.eyJ1IjoidGVzdGVyczEyMyIsImEiOiJjbWkxN2RieDcxN21jMm5xMG5vdHJiYWFuIn0.0Ew0zviHigoWBjE_sn0Z-g';

  /// Default Mapbox style ID
  static const String defaultStyleId = 'mapbox/streets-v11';

  /// Private constructor to prevent instantiation
  MapboxConstants._();
}
