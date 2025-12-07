import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Mapbox API configuration constants
/// Reads from environment variables via .env file
class MapboxConstants {
  /// Mapbox access token - loaded from .env file
  /// Get your token from: https://account.mapbox.com/access-tokens/
  /// Make sure to create a .env file in the app root directory
  static String get accessToken {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) {
      throw Exception(
        'MAPBOX_ACCESS_TOKEN not found in .env file. '
        'Please create a .env file with your Mapbox access token. '
        'See .env.example for reference.',
      );
    }
    return token;
  }

  /// Default Mapbox style ID - loaded from .env file or defaults to mapbox/streets-v11
  static String get defaultStyleId {
    return dotenv.env['MAPBOX_STYLE_ID'] ?? 'mapbox/streets-v11';
  }

  /// Private constructor to prevent instantiation
  MapboxConstants._();
}
