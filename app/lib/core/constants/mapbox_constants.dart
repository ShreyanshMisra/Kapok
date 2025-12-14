import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Mapbox API configuration constants
/// Reads from environment variables via .env file
class MapboxConstants {
  /// Validate that all required environment variables are configured
  /// Call this on app startup to fail loudly if configuration is missing
  static void validateConfiguration() {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];

    if (token == null || token.isEmpty || token == 'your_mapbox_token_here') {
      throw StateError(
        'Mapbox API token not configured!\n'
        '\n'
        'To fix this:\n'
        '1. Copy .env.example to .env: cp .env.example .env\n'
        '2. Get your token from: https://account.mapbox.com/access-tokens/\n'
        '3. Replace "your_mapbox_token_here" with your actual token in .env\n'
        '4. Restart the app\n'
        '\n'
        'IMPORTANT: Never commit your .env file to Git!',
      );
    }

    // Validate token format (Mapbox tokens start with 'pk.')
    if (!token.startsWith('pk.')) {
      throw StateError(
        'Invalid Mapbox token format!\n'
        'Mapbox access tokens should start with "pk."\n'
        'Please check your .env file and ensure you\'re using a valid token.',
      );
    }
  }

  /// Mapbox access token - loaded from .env file
  /// Get your token from: https://account.mapbox.com/access-tokens/
  /// Make sure to create a .env file in the app root directory
  static String get accessToken {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (token == null || token.isEmpty) {
      throw StateError('Mapbox token not configured. Call validateConfiguration() on app startup.');
    }
    return token;
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
