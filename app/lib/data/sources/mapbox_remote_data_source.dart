import 'package:http/http.dart' as http;
import '../../core/error/exceptions.dart';
// import '../../core/utils/logger.dart'; // Commented out - map logs disabled
import '../models/map_tile_model.dart';

/// MapboxRemoteDataSource is responsible for hitting Mapbox's tile endpoints and respecting their offline terms.
/// Fetches map tiles from Mapbox API for online use.
class MapboxRemoteDataSource {
  /// Mapbox access token (should be stored securely, not hardcoded)
  final String accessToken;

  /// Mapbox style ID (e.g., 'mapbox/streets-v11')
  final String styleId;

  /// Base URL for Mapbox tiles
  static const String _baseUrl = 'https://api.mapbox.com/styles/v1';

  MapboxRemoteDataSource({
    required this.accessToken,
    this.styleId = 'mapbox/streets-v11',
  });

  /// Fetches a single tile from Mapbox
  /// Returns the tile data as bytes
  ///
  /// Mapbox Styles API format: /styles/v1/{style_id}/tiles/{z}/{x}/{y}@{ratio}x?access_token={token}
  /// For raster tiles, the format is determined by the style itself
  Future<MapTile> fetchTile(
    int z,
    int x,
    int y, {
    String format = 'png256',
    int ratio = 2,
  }) async {
    try {
      // Logger.firebase('Fetching tile from Mapbox: z=$z, x=$x, y=$y'); // Commented out - map logs disabled

      // Mapbox Styles API tile URL format: /styles/v1/{style_id}/tiles/{z}/{x}/{y}@{ratio}x?access_token={token}
      // The format parameter is used for logging/identification, not in the URL path
      final url =
          '$_baseUrl/$styleId/tiles/$z/$x/$y@${ratio}x?access_token=$accessToken';

      // Logger.firebase('Mapbox URL: $url'); // Commented out - map logs disabled
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        // Logger.firebase('Failed to fetch tile: ${response.statusCode}'); // Commented out - map logs disabled
        throw DatabaseException(
          message: 'Failed to fetch tile from Mapbox: ${response.statusCode}',
        );
      }

      final tile = MapTile(
        zoom: z,
        x: x,
        y: y,
        data: response.bodyBytes,
        format: format,
        fetchedAt: DateTime.now(),
      );

      // Logger.firebase('Tile fetched successfully: ${tile.sizeInBytes} bytes'); // Commented out - map logs disabled
      return tile;
    } catch (e) {
      // Logger.firebase(
      //   'Error fetching tile from Mapbox: z=$z, x=$x, y=$y',
      //   error: e,
      // ); // Commented out - map logs disabled
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException(
        message: 'Failed to fetch tile from Mapbox',
        originalError: e,
      );
    }
  }

  /// Fetches multiple tiles in batch (for efficient downloading)
  /// Returns a list of successfully fetched tiles
  Future<List<MapTile>> fetchTiles(
    List<({int z, int x, int y})> tileCoords, {
    String format = 'png256',
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final tiles = <MapTile>[];
    int downloaded = 0;

    for (final coord in tileCoords) {
      try {
        final tile = await fetchTile(coord.z, coord.x, coord.y, format: format);
        tiles.add(tile);
        downloaded++;

        if (onProgress != null) {
          onProgress(downloaded, tileCoords.length);
        }
      } catch (e) {
        // Logger.firebase(
        //   'Error fetching tile: z=${coord.z}, x=${coord.x}, y=${coord.y}',
        //   error: e,
        // ); // Commented out - map logs disabled
        // Continue with other tiles even if one fails
      }
    }

    return tiles;
  }
}
