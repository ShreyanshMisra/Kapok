import 'package:hive_flutter/hive_flutter.dart';
import '../../core/error/exceptions.dart';
// import '../../core/utils/logger.dart'; // Commented out - map logs disabled
import '../models/map_tile_model.dart';
import '../models/offline_map_region_model.dart';

/// OfflineMapCache stores Mapbox raster/vector tiles keyed by zoom/x/y so the map can render even with no network.
/// Tiles stored by z/x/y, used when network is unavailable, synced incrementally so the user can quit anytime.
class OfflineMapCache {
  static const String _boxName = 'offline_map_tiles';
  Box? _tilesBox;

  /// Maximum cache size in bytes (default: 500MB)
  final int maxCacheSizeBytes;

  /// Current cache size in bytes
  int _currentCacheSizeBytes = 0;

  OfflineMapCache({this.maxCacheSizeBytes = 500 * 1024 * 1024});

  /// Initializes the cache by opening the Hive box
  Future<void> initialize() async {
    try {
      // Logger.hive('Initializing offline map cache'); // Commented out - map logs disabled

      if (!Hive.isBoxOpen(_boxName)) {
        _tilesBox = await Hive.openBox(_boxName);
      } else {
        _tilesBox = Hive.box(_boxName);
      }

      // Calculate current cache size
      _calculateCacheSize();

      // Logger.hive(
      //   'Offline map cache initialized: ${_tilesBox!.length} tiles, ${_formatBytes(_currentCacheSizeBytes)}',
      // ); // Commented out - map logs disabled
    } catch (e) {
      // Logger.hive('Failed to initialize offline map cache', error: e); // Commented out - map logs disabled
      throw CacheException(
        message: 'Failed to initialize offline map cache',
        originalError: e,
      );
    }
  }

  /// getTile tries Hive first, then falls back to the remote Mapbox API when online, caching the result for next time.
  /// Returns the tile if found in cache, null otherwise.
  Future<MapTile?> getTile(int z, int x, int y) async {
    try {
      if (_tilesBox == null) {
        await initialize();
      }

      final key = _makeKey(z, x, y);
      final tileData = _tilesBox!.get(key);

      if (tileData == null) {
        // Logger.hive('Tile not found in cache: $key'); // Commented out - map logs disabled
        return null;
      }

      // Deserialize tile from stored data
      final tile = MapTile.fromJson(Map<String, dynamic>.from(tileData));
      // Logger.hive('Tile retrieved from cache: $key'); // Commented out - map logs disabled
      return tile;
    } catch (e) {
      // Logger.hive('Error getting tile from cache: z=$z, x=$x, y=$y', error: e); // Commented out - map logs disabled
      return null;
    }
  }

  /// Stores a tile in the cache
  /// For each tile in the selected region, download from Mapbox and immediately persist to Hive
  /// so the user can safely close the app mid-download without losing progress.
  Future<void> putTile(MapTile tile) async {
    try {
      if (_tilesBox == null) {
        await initialize();
      }

      final key = tile.key;

      // Check cache size before adding
      if (_currentCacheSizeBytes + tile.sizeInBytes > maxCacheSizeBytes) {
        // Logger.hive('Cache size limit reached. Evicting old tiles...'); // Commented out - map logs disabled
        await _evictOldTiles(tile.sizeInBytes);
      }

      // Store tile
      await _tilesBox!.put(key, tile.toJson());
      _currentCacheSizeBytes += tile.sizeInBytes;

      // Logger.hive(
      //   'Tile stored in cache: $key (${_formatBytes(tile.sizeInBytes)})',
      // ); // Commented out - map logs disabled
    } catch (e) {
      // Logger.hive('Error storing tile in cache: ${tile.key}', error: e); // Commented out - map logs disabled
      throw CacheException(
        message: 'Failed to store tile in cache',
        originalError: e,
      );
    }
  }

  /// Clears tiles outside the new region but inside the old region
  /// As the user moves, we slide the hot zone with them and purge tiles outside it
  /// so only the nearby area remains available offline
  Future<void> clearOutside(
    OfflineMapRegion newRegion,
    OfflineMapRegion oldRegion,
  ) async {
    try {
      if (_tilesBox == null) {
        await initialize();
      }

      // Logger.hive(
      //   'Clearing tiles outside new bubble: old=${oldRegion.id}, new=${newRegion.id}',
      // ); // Commented out - map logs disabled

      final keysToDelete = <String>[];
      int bytesFreed = 0;

      // Iterate through all tiles and find those in old region but outside new region
      for (final key in _tilesBox!.keys) {
        final keyStr = key.toString();
        final parts = keyStr.split('/');

        if (parts.length != 3) continue;

        final z = int.tryParse(parts[0]);
        final x = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);

        if (z == null || x == null || y == null) continue;

        // Check if tile is in old region's zoom range
        if (z >= oldRegion.zoomMin && z <= oldRegion.zoomMax) {
          // Check if tile was in old region
          if (oldRegion.containsTile(z, x, y)) {
            // Check if tile is NOT in new region (outside new bubble)
            if (!newRegion.containsTile(z, x, y)) {
              final tileData = _tilesBox!.get(key);
              if (tileData != null) {
                try {
                  final tile = MapTile.fromJson(
                    Map<String, dynamic>.from(tileData),
                  );
                  bytesFreed += tile.sizeInBytes;
                } catch (_) {
                  // Ignore deserialization errors
                }
              }
              keysToDelete.add(keyStr);
            }
          }
        }
      }

      // Delete tiles
      for (final key in keysToDelete) {
        await _tilesBox!.delete(key);
      }

      _currentCacheSizeBytes -= bytesFreed;
      if (_currentCacheSizeBytes < 0) {
        _currentCacheSizeBytes = 0;
        _calculateCacheSize();
      }

      // Logger.hive(
      //   'Tiles outside new bubble cleared: ${keysToDelete.length} tiles removed, ${_formatBytes(bytesFreed)} freed',
      // ); // Commented out - map logs disabled
    } catch (e) {
      // Logger.hive(
      //   'Error clearing tiles outside bubble: old=${oldRegion.id}, new=${newRegion.id}',
      //   error: e,
      // ); // Commented out - map logs disabled
      throw CacheException(
        message: 'Failed to clear tiles outside bubble',
        originalError: e,
      );
    }
  }

  /// Clears all tiles within a region's bounding box
  /// Deletes all tiles whose coordinates fall inside the region's bounding box
  Future<void> clearRegion(OfflineMapRegion region) async {
    try {
      if (_tilesBox == null) {
        await initialize();
      }

      // Logger.hive('Clearing region: ${region.id}'); // Commented out - map logs disabled

      final keysToDelete = <String>[];
      int bytesFreed = 0;

      // Iterate through all tiles and find those within the region
      for (final key in _tilesBox!.keys) {
        final keyStr = key.toString();
        final parts = keyStr.split('/');

        if (parts.length != 3) continue;

        final z = int.tryParse(parts[0]);
        final x = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);

        if (z == null || x == null || y == null) continue;

        // Check if tile is within zoom range and bounding box
        if (z >= region.zoomMin && z <= region.zoomMax) {
          if (region.containsTile(z, x, y)) {
            final tileData = _tilesBox!.get(key);
            if (tileData != null) {
              try {
                final tile = MapTile.fromJson(
                  Map<String, dynamic>.from(tileData),
                );
                bytesFreed += tile.sizeInBytes;
              } catch (_) {
                // Ignore deserialization errors
              }
            }
            keysToDelete.add(keyStr);
          }
        }
      }

      // Delete tiles
      for (final key in keysToDelete) {
        await _tilesBox!.delete(key);
      }

      _currentCacheSizeBytes -= bytesFreed;
      if (_currentCacheSizeBytes < 0) {
        _currentCacheSizeBytes = 0;
        _calculateCacheSize();
      }

      // Logger.hive(
      //   'Region cleared: ${keysToDelete.length} tiles removed, ${_formatBytes(bytesFreed)} freed',
      // ); // Commented out - map logs disabled
    } catch (e) {
      // Logger.hive('Error clearing region: ${region.id}', error: e); // Commented out - map logs disabled
      throw CacheException(message: 'Failed to clear region', originalError: e);
    }
  }

  /// Clears all tiles from cache
  Future<void> clearAll() async {
    try {
      if (_tilesBox == null) {
        await initialize();
      }

      // Logger.hive('Clearing all tiles from cache'); // Commented out - map logs disabled
      await _tilesBox!.clear();
      _currentCacheSizeBytes = 0;
      // Logger.hive('All tiles cleared from cache'); // Commented out - map logs disabled
    } catch (e) {
      // Logger.hive('Error clearing all tiles', error: e); // Commented out - map logs disabled
      throw CacheException(
        message: 'Failed to clear all tiles',
        originalError: e,
      );
    }
  }

  /// Gets the number of tiles in cache
  int get tileCount {
    if (_tilesBox == null) return 0;
    return _tilesBox!.length;
  }

  /// Gets the current cache size in bytes
  int get cacheSizeBytes => _currentCacheSizeBytes;

  /// Gets cache size as formatted string
  String get cacheSizeFormatted => _formatBytes(_currentCacheSizeBytes);

  /// Creates a unique key for a tile (format: "z/x/y")
  String _makeKey(int z, int x, int y) => '$z/$x/$y';

  /// Calculates current cache size by summing all tile sizes
  void _calculateCacheSize() {
    if (_tilesBox == null) return;

    _currentCacheSizeBytes = 0;
    for (final key in _tilesBox!.keys) {
      final tileData = _tilesBox!.get(key);
      if (tileData != null) {
        try {
          final tile = MapTile.fromJson(Map<String, dynamic>.from(tileData));
          _currentCacheSizeBytes += tile.sizeInBytes;
        } catch (_) {
          // Ignore deserialization errors
        }
      }
    }
  }

  /// Evicts old tiles to make room for new ones
  /// Uses LRU (Least Recently Used) strategy based on fetchedAt timestamp
  Future<void> _evictOldTiles(int bytesNeeded) async {
    if (_tilesBox == null) return;

    final tiles = <MapTile>[];

    // Load all tiles with their timestamps
    for (final key in _tilesBox!.keys) {
      final tileData = _tilesBox!.get(key);
      if (tileData != null) {
        try {
          final tile = MapTile.fromJson(Map<String, dynamic>.from(tileData));
          tiles.add(tile);
        } catch (_) {
          // Ignore deserialization errors
        }
      }
    }

    // Sort by fetchedAt (oldest first)
    tiles.sort((a, b) => a.fetchedAt.compareTo(b.fetchedAt));

    // Delete oldest tiles until we have enough space
    int bytesFreed = 0;
    for (final tile in tiles) {
      if (bytesFreed >= bytesNeeded) break;

      await _tilesBox!.delete(tile.key);
      bytesFreed += tile.sizeInBytes;
      _currentCacheSizeBytes -= tile.sizeInBytes;
    }

    // Logger.hive(
    //   'Evicted ${tiles.length} old tiles, freed ${_formatBytes(bytesFreed)}',
    // ); // Commented out - map logs disabled
  }

  /// Formats bytes to human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
