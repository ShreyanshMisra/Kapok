import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Mapbox API configuration constants
/// Reads from environment variables via .env file
class MapboxConstants {
  /// Mapbox access token - loaded from .env file
  /// Get your token from: https://account.mapbox.com/access-tokens/
  /// Make sure to create a .env file in the app root directory
  static String get accessToken {
    try {
      final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      if (token == null || token.isEmpty) {
        // Return a placeholder token if not found
        // This prevents crashes but map won't work until proper token is set
        return 'pk.mapbox_token_not_configured';
      }
      return token;
    } catch (e) {
      // If dotenv isn't loaded, return placeholder
      return 'pk.mapbox_token_not_configured';
    }
  }

  /// Default Mapbox style ID - loaded from .env file or defaults to mapbox/streets-v11
  static String get defaultStyleId {
    try {
      return dotenv.env['MAPBOX_STYLE_ID'] ?? 'mapbox/streets-v11';
    } catch (e) {
      return 'mapbox/streets-v11';
    }
  }

  /// Private constructor to prevent instantiation
  MapboxConstants._();
}
