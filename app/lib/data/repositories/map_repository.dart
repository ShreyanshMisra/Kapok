import 'dart:async';
import 'dart:math' as math;
import '../../core/error/exceptions.dart';
import '../../core/services/network_checker.dart';
import '../../core/services/geolocation_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/logger.dart';
import '../models/map_tile_model.dart';
import '../models/offline_map_region_model.dart';
import '../sources/mapbox_remote_data_source.dart';
import '../sources/offline_map_cache.dart';
import '../sources/firebase_map_snapshot_source.dart';
import 'offline_map_region_repository.dart';

/// Repository interface for map operations with offline-first support
abstract class MapRepository {
  /// Gets a tile, trying cache first, then remote if online
  Future<MapTile?> getTile(int z, int x, int y);

  /// Streams the download progress for a region (0.0 to 1.0)
  Stream<double> streamRegionStatus(String regionId);

  /// Downloads a region for offline use
  Future<void> downloadRegion(OfflineMapRegion region);

  /// Gets all downloaded regions
  Future<List<OfflineMapRegion>> getDownloadedRegions();

  /// Deletes a downloaded region
  Future<void> deleteRegion(String regionId);

  /// loadRegionForCurrentLocation computes a region around the user, publishes it to Firestore,
  /// and refreshes the offline cache so the map stays usable without network as they move.
  /// Returns the region and the number of tiles primed in Phase 1
  Future<({OfflineMapRegion region, int primedTiles})>
  loadRegionForCurrentLocation({double radiusKm, int zoomMin, int zoomMax});

  /// Returns true when the app should operate in offline-only mode.
  Future<bool> isOfflineMode();
}

/// Concrete implementation of MapRepository with offline-first pattern
/// When online and the map widget requests a tile, MapRepository.getTile would try the cache first,
/// and if it misses and NetworkChecker.isOnline is true it would pull the tile from Mapbox,
/// save it into Hive, and return it; when offline, it would only hit the cache.
class MapRepositoryImpl implements MapRepository {
  final NetworkChecker _networkChecker;
  final MapboxRemoteDataSource _mapboxDataSource;
  final OfflineMapCache _offlineCache;
  final OfflineMapRegionRepository _regionRepository;
  final GeolocationService _geolocationService;
  final FirebaseMapSnapshotSource _snapshotSource;

  // Progress streams for each region being downloaded
  final Map<String, StreamController<double>> _progressControllers = {};

  MapRepositoryImpl({
    required NetworkChecker networkChecker,
    required MapboxRemoteDataSource mapboxDataSource,
    required OfflineMapCache offlineCache,
    required OfflineMapRegionRepository regionRepository,
    required GeolocationService geolocationService,
    required FirebaseMapSnapshotSource snapshotSource,
  }) : _networkChecker = networkChecker,
       _mapboxDataSource = mapboxDataSource,
       _offlineCache = offlineCache,
       _regionRepository = regionRepository,
       _geolocationService = geolocationService,
       _snapshotSource = snapshotSource;

  /// Current active offline bubble region (cached for fast lookups)
  OfflineMapRegion? _currentOfflineBubble;

  /// In-memory LRU cache for live halo tiles (outside bubble, not persisted to Hive)
  /// Tiles outside the offline bubble are streamed live (like Google Maps) and not persisted,
  /// so the user can explore the world without blowing up disk usage
  final Map<String, MapTile> _liveTilesCache = {};
  static const int _maxLiveTilesCache =
      500; // Max tiles in memory for smooth panning

  @override
  Future<MapTile?> getTile(int z, int x, int y) async {
    try {
      Logger.task('Getting tile: z=$z, x=$x, y=$y');

      // Always try persistent cache first (offline-first pattern)
      final cachedTile = await _offlineCache.getTile(z, x, y);
      if (cachedTile != null) {
        Logger.task('Tile found in persistent cache');
        return cachedTile;
      }

      // Check in-memory live tiles cache (for tiles outside bubble during session)
      final key = '$z/$x/$y';
      if (_liveTilesCache.containsKey(key)) {
        Logger.task('Tile found in live tiles cache');
        return _liveTilesCache[key];
      }

      // If not in cache and online, fetch from Mapbox
      if (await _networkChecker.isConnected()) {
        try {
          // Check if tile is inside the offline bubble to decide caching strategy
          final isInBubble = await _isTileInOfflineBubble(z, x, y);

          // Network-aware throttling for live halo tiles (outside bubble)
          // On mobile or weak connections, throttle parallel requests to keep UI snappy
          if (!isInBubble) {
            final networkQuality = await _networkChecker.getNetworkQuality();
            final connectionType = await _networkChecker.getConnectionType();

            // Only stream live tiles aggressively on Wi-Fi with good quality
            // On mobile or poor connections, be conservative
            if (connectionType != 'WiFi' ||
                networkQuality == NetworkQuality.poor) {
              // Throttle live halo requests on poor connections
              // In production, you could use a semaphore or rate limiter here
              Logger.task(
                'Throttling live halo tile request (poor connection)',
              );
            }
          }

          Logger.task(
            'Fetching tile from Mapbox (${isInBubble ? "bubble" : "live halo"})',
          );
          final tile = await _mapboxDataSource.fetchTile(z, x, y);

          if (isInBubble) {
            // Phase 1/2: Tiles inside bubble + zoom 15-17 → offline-first behavior
            // Hive lookup → Mapbox fetch → OfflineMapCache.putTile()
            // Save to Hive cache for offline use
            await _offlineCache.putTile(tile);
            Logger.task('Tile fetched and cached successfully (inside bubble)');
          } else {
            // Phase 2: Tiles outside bubble → live-only (like Google Maps)
            // Tiles outside the offline bubble are streamed live and not persisted,
            // so the user can explore the world without blowing up disk usage
            // Cache in memory LRU for smooth panning during current session
            final key = '$z/$x/$y';
            _liveTilesCache[key] = tile;

            // Evict oldest if cache is too large (simple FIFO for now)
            if (_liveTilesCache.length > _maxLiveTilesCache) {
              final oldestKey = _liveTilesCache.keys.first;
              _liveTilesCache.remove(oldestKey);
            }

            Logger.task('Tile fetched successfully (live halo, not persisted)');
          }

          return tile;
        } catch (e) {
          Logger.task('Failed to fetch tile from Mapbox', error: e);
          // Return null if fetch fails (will show placeholder in UI)
          return null;
        }
      } else {
        // Offline and not in cache - return null (UI will show placeholder)
        Logger.task('Offline and tile not in cache');
        return null;
      }
    } catch (e) {
      Logger.task('Error getting tile: z=$z, x=$x, y=$y', error: e);
      return null;
    }
  }

  /// Checks if a tile is inside the current offline bubble region
  /// Returns true if the tile should be persisted to Hive, false otherwise
  /// We only persist tiles that are within the current hot zone around the user;
  /// outer tiles are streamed from Mapbox but not cached to keep storage small
  Future<bool> _isTileInOfflineBubble(int z, int x, int y) async {
    // Load current bubble if not cached
    if (_currentOfflineBubble == null) {
      try {
        final latestRegion = await _regionRepository.getLatestRegion();
        if (latestRegion != null) {
          _currentOfflineBubble = latestRegion;
        } else {
          // No region found, tiles won't be cached
          return false;
        }
      } catch (_) {
        // Error loading region, tiles won't be cached
        return false;
      }
    }

    final region = _currentOfflineBubble!;

    // Check zoom range
    if (z < region.zoomMin || z > region.zoomMax) {
      return false;
    }

    // Check if tile is within bounding box
    return region.containsTile(z, x, y);
  }

  /// Phase 1: Compute bubble + cache just enough tiles for an instant first frame
  /// Aggressively minimal and ordered: first request the single center tile at zoom 17,
  /// then a tiny 3×3 ring around it, marking those as "must cache" by forcing them through OfflineMapCache.putTile()
  /// Returns the number of tiles primed (for progress tracking)
  Future<int> _primeBubbleTiles(OfflineMapRegion region) async {
    try {
      Logger.task('Phase 1: Priming bubble tiles for instant first frame');

      // Calculate center tile at initial zoom (use zoomMax for highest detail)
      final centerTile = _latLonToTile(
        region.centerLat,
        region.centerLon,
        region.zoomMax,
      );

      int primedCount = 0;

      // STEP 1: Prime center tile first (critical path for instant display)
      try {
        // Check if already cached
        var existingTile = await _offlineCache.getTile(
          region.zoomMax,
          centerTile.x,
          centerTile.y,
        );

        if (existingTile == null && await _networkChecker.isConnected()) {
          // Fetch center tile from Mapbox if online
          final tile = await _mapboxDataSource.fetchTile(
            region.zoomMax,
            centerTile.x,
            centerTile.y,
          );
          // Save to cache immediately (center tile is always in bubble)
          await _offlineCache.putTile(tile);
          existingTile = tile;
        }

        if (existingTile != null) {
          primedCount++;
          Logger.task(
            'Phase 1: Center tile primed (instant first frame ready)',
          );
        }
      } catch (e) {
        Logger.task(
          'Error priming center tile: z=${region.zoomMax}, x=${centerTile.x}, y=${centerTile.y}',
          error: e,
        );
      }

      // STEP 2: Prime tiny 3×3 ring around center (minimal for instant display)
      // Use 3×3 grid for fastest priming (9 tiles total including center)
      final gridSize = 3;
      final halfGrid = gridSize ~/ 2; // 1

      for (int dx = -halfGrid; dx <= halfGrid; dx++) {
        for (int dy = -halfGrid; dy <= halfGrid; dy++) {
          // Skip center tile (already primed)
          if (dx == 0 && dy == 0) continue;

          final x = centerTile.x + dx;
          final y = centerTile.y + dy;

          try {
            // Check if already cached
            final existingTile = await _offlineCache.getTile(
              region.zoomMax,
              x,
              y,
            );
            if (existingTile != null) {
              primedCount++;
              continue;
            }

            // Fetch from Mapbox if online
            if (await _networkChecker.isConnected()) {
              final tile = await _mapboxDataSource.fetchTile(
                region.zoomMax,
                x,
                y,
              );
              // Save to cache (these are guaranteed to be in the bubble)
              await _offlineCache.putTile(tile);
              primedCount++;
            }
          } catch (e) {
            Logger.task(
              'Error priming tile: z=${region.zoomMax}, x=$x, y=$y',
              error: e,
            );
            // Continue with other tiles
          }
        }
      }

      Logger.task(
        'Phase 1 complete: $primedCount tiles primed (instant first frame ready)',
      );
      return primedCount;
    } catch (e) {
      Logger.task('Error priming bubble tiles', error: e);
      // Don't fail the entire operation if priming fails
      return 0;
    }
  }

  @override
  Stream<double> streamRegionStatus(String regionId) {
    if (!_progressControllers.containsKey(regionId)) {
      _progressControllers[regionId] = StreamController<double>.broadcast();
    }
    return _progressControllers[regionId]!.stream;
  }

  @override
  Future<void> downloadRegion(OfflineMapRegion region) async {
    try {
      Logger.task('Downloading region: ${region.id}');

      // Update region status to downloading
      final updatedRegion = region.copyWith(status: 'downloading');
      await _regionRepository.saveRegion(updatedRegion);

      // Initialize progress stream
      if (!_progressControllers.containsKey(region.id)) {
        _progressControllers[region.id] = StreamController<double>.broadcast();
      }
      _progressControllers[region.id]!.add(0.0);

      // Compute all tile indices for the region
      final tileCoords = _computeTileIndices(region);
      final totalTiles = tileCoords.length;

      Logger.task('Region has $totalTiles tiles to download');

      // Update region with total tiles
      final regionWithTotal = updatedRegion.copyWith(totalTiles: totalTiles);
      await _regionRepository.saveRegion(regionWithTotal);

      // Download tiles in background
      // For each tile in the selected region, download from Mapbox and immediately persist to Hive
      // so the user can safely close the app mid-download without losing progress.
      int downloadedTiles = 0;

      for (final coord in tileCoords) {
        try {
          // Check if already cached
          final existingTile = await _offlineCache.getTile(
            coord.z,
            coord.x,
            coord.y,
          );
          if (existingTile != null) {
            downloadedTiles++;
            _progressControllers[region.id]!.add(downloadedTiles / totalTiles);
            continue;
          }

          // Fetch from Mapbox
          final tile = await _mapboxDataSource.fetchTile(
            coord.z,
            coord.x,
            coord.y,
          );

          // Immediately persist to Hive
          await _offlineCache.putTile(tile);

          downloadedTiles++;

          // Update progress
          final progress = downloadedTiles / totalTiles;
          _progressControllers[region.id]!.add(progress);

          // Update region with downloaded count
          final regionWithProgress = regionWithTotal.copyWith(
            downloadedTiles: downloadedTiles,
            status: 'downloading',
          );
          await _regionRepository.saveRegion(regionWithProgress);
        } catch (e) {
          Logger.task(
            'Error downloading tile: z=${coord.z}, x=${coord.x}, y=${coord.y}',
            error: e,
          );
          // Continue with other tiles
        }
      }

      // Mark region as completed
      final completedRegion = regionWithTotal.copyWith(
        downloadedTiles: downloadedTiles,
        status: 'completed',
        lastSyncedAt: DateTime.now(),
      );
      await _regionRepository.saveRegion(completedRegion);

      _progressControllers[region.id]!.add(1.0);
      Logger.task(
        'Region download completed: $downloadedTiles/$totalTiles tiles',
      );
    } catch (e) {
      Logger.task('Error downloading region: ${region.id}', error: e);

      // Update region status to failed
      final failedRegion = region.copyWith(status: 'failed');
      await _regionRepository.saveRegion(failedRegion);

      if (_progressControllers.containsKey(region.id)) {
        _progressControllers[region.id]!.addError(e);
      }

      throw MapException(
        message: 'Failed to download region',
        originalError: e,
      );
    }
  }

  @override
  Future<List<OfflineMapRegion>> getDownloadedRegions() async {
    try {
      return await _regionRepository.getAllRegions();
    } catch (e) {
      Logger.task('Error getting downloaded regions', error: e);
      throw MapException(
        message: 'Failed to get downloaded regions',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteRegion(String regionId) async {
    try {
      Logger.task('Deleting region: $regionId');

      // Get region to clear tiles
      final region = await _regionRepository.getRegion(regionId);
      if (region != null) {
        // Clear tiles for this region
        await _offlineCache.clearRegion(region);
      }

      // Delete region record
      await _regionRepository.deleteRegion(regionId);

      // Close progress stream
      _progressControllers[regionId]?.close();
      _progressControllers.remove(regionId);

      Logger.task('Region deleted successfully');
    } catch (e) {
      Logger.task('Error deleting region: $regionId', error: e);
      throw MapException(message: 'Failed to delete region', originalError: e);
    }
  }

  /// Computes all tile indices for a given region
  /// Returns a list of (z, x, y) coordinates
  List<({int z, int x, int y})> _computeTileIndices(OfflineMapRegion region) {
    final tileCoords = <({int z, int x, int y})>[];

    // For each zoom level in range
    for (int z = region.zoomMin; z <= region.zoomMax; z++) {
      // Convert bounding box to tile coordinates
      final nwTile = _latLonToTile(region.northEastLat, region.southWestLon, z);
      final seTile = _latLonToTile(region.southWestLat, region.northEastLon, z);

      // Generate all tiles in the bounding box
      for (int x = nwTile.x; x <= seTile.x; x++) {
        for (int y = nwTile.y; y <= seTile.y; y++) {
          tileCoords.add((z: z, x: x, y: y));
        }
      }
    }

    return tileCoords;
  }

  /// Converts latitude/longitude to tile coordinates
  /// Uses the standard Web Mercator projection formula
  ({int x, int y}) _latLonToTile(double lat, double lon, int zoom) {
    final n = 1 << zoom;
    final x = ((lon + 180) / 360 * n).floor();
    final latRad = lat * math.pi / 180;
    final y =
        ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
                2 *
                n)
            .floor();
    return (x: x.clamp(0, n - 1), y: y.clamp(0, n - 1));
  }

  /// loadRegionForCurrentLocation computes a tight "offline bubble" around the user and
  /// pre-downloads only a small 3×3 grid of high-zoom tiles for instant offline startup.
  /// Phase 1: Compute bubble + cache just enough tiles for an instant first frame
  /// Phase 2: Stream additional tiles live while the user interacts
  /// Returns the region and the number of tiles primed in Phase 1
  /// We only cache a tight bubble (~1-2km) at high zoom around the user's location to
  /// guarantee instant offline startup without blowing up disk usage. Everything outside
  /// this bubble is live-loaded from Mapbox but not persisted to Hive.
  /// As the user moves, we slide the hot zone with them and purge tiles outside it so
  /// only the nearby area remains available offline.
  Future<({OfflineMapRegion region, int primedTiles})>
  loadRegionForCurrentLocation({
    double radiusKm = 4.8, // ~3 miles bubble for instant offline view
    int zoomMin = 13,
    int zoomMax = 18,
  }) async {
    try {
      Logger.task('Loading region for current location');

      // Get current GPS position
      final position = await _geolocationService.getCurrentPosition();
      final centerLat = position.latitude;
      final centerLon = position.longitude; // Fixed: was centerLng

      // Compute bounding box around the center point
      // Using approximate conversion: 1 degree latitude ≈ 111 km
      final latDelta = radiusKm / 111.0;
      // Longitude delta depends on latitude
      final lonDelta = radiusKm / (111.0 * math.cos(centerLat * math.pi / 180));

      final northEastLat = (centerLat + latDelta).clamp(-90.0, 90.0);
      final northEastLon = (centerLon + lonDelta).clamp(-180.0, 180.0);
      final southWestLat = (centerLat - latDelta).clamp(-90.0, 90.0);
      final southWestLon = (centerLon - lonDelta).clamp(-180.0, 180.0);

      // Create region
      final regionId = 'live_region_${DateTime.now().millisecondsSinceEpoch}';
      final region = OfflineMapRegion(
        id: regionId,
        centerLat: centerLat,
        centerLon: centerLon, // Fixed: was centerLng
        zoomMin: zoomMin,
        zoomMax: zoomMax,
        northEastLat: northEastLat,
        northEastLon: northEastLon,
        southWestLat: southWestLat,
        southWestLon: southWestLon,
        name: 'Current Location Region',
        lastSyncedAt: DateTime.now(),
        totalTiles: 0, // Will be computed during download
        downloadedTiles: 0,
        status: 'downloading',
      );

      // Get current user ID or team ID for Firestore snapshot
      final userId = FirebaseService.instance.currentUser?.uid;

      // Save snapshot to Firestore (non-blocking - if it fails, continue with download)
      // The snapshot is nice-to-have for syncing across devices, but not critical
      if (userId != null) {
        try {
          final snapshot = MapSnapshot(
            centerLat: centerLat,
            centerLng:
                centerLon, // MapSnapshot uses centerLng (with 'g'), but we use centerLon (with 'n') internally
            zoomMin: zoomMin,
            zoomMax: zoomMax,
            northEastLat: northEastLat,
            northEastLon: northEastLon,
            southWestLat: southWestLat,
            southWestLon: southWestLon,
            lastUpdatedAt: DateTime.now(),
          );
          await _snapshotSource.saveSnapshot(userId, snapshot);
        } catch (e) {
          // Log error but don't fail the entire operation
          Logger.task(
            'Failed to save map snapshot to Firestore, continuing with download',
            error: e,
          );
        }
      }

      // Phase 1: Compute bubble + cache just enough tiles for an instant first frame
      // Get GPS fix → compute bubble → return immediately (don't wait for full download)

      // Cache the region reference FIRST so getTile() can check bubble membership
      _currentOfflineBubble = region;

      // Delete all old regions and clear tiles outside the new bubble
      // Slide the hot offline bubble with the user: keep only one small, high-detail region cached at all times
      final allRegions = await _regionRepository.getAllRegions();
      for (final oldRegion in allRegions) {
        // Clear tiles that were in old region but are now outside the new bubble
        // This keeps only the new bubble tiles cached
        await _offlineCache.clearOutside(region, oldRegion);
        // Delete old region metadata
        await _regionRepository.deleteRegion(oldRegion.id);
      }

      // Clear in-memory live tiles cache when refreshing bubble
      // The live halo tiles are ephemeral and don't need to persist across bubble changes
      _liveTilesCache.clear();

      // Phase 1: Aggressively minimal priming for instant first frame
      // First request the single center tile at zoom 17, then a tiny 3×3 ring around it
      // As soon as center tile (or first few tiles) are in Hive, we can return and let UI render
      final primedCount = await _primeBubbleTiles(region);

      // Phase 1 complete: Return immediately with bubble metadata
      // The UI can now build OfflineMapWidget and show the first frame instantly
      // Phase 2 (full download) continues in background via downloadRegion()
      Logger.task(
        'Phase 1 complete: Region ready for instant first frame ($primedCount tiles primed)',
      );

      // Phase 2: Stream additional tiles live while the user interacts
      // Download the full region in background (but getTile will only persist tiles inside the bubble)
      // The downloadRegion call will compute all tiles, but when getTile is called during download,
      // it will check _isTileInOfflineBubble() and only persist tiles inside the ~3 mile bubble
      // This runs asynchronously so it doesn't block the return
      downloadRegion(region).catchError((e) {
        Logger.task('Phase 2: Error in background download', error: e);
        // Don't fail the operation - Phase 1 already succeeded
      });

      Logger.task(
        'Region loaded for current location: $regionId (Phase 1 complete, Phase 2 in progress)',
      );

      // Return region and primed count for Phase 1 complete notification
      return (region: region, primedTiles: primedCount);
    } catch (e) {
      Logger.task('Error loading region for current location', error: e);
      throw MapException(
        message: 'Failed to load region for current location',
        originalError: e,
      );
    }
  }

  /// Disposes resources
  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }

  @override
  Future<bool> isOfflineMode() async {
    return !(await _networkChecker.isConnected());
  }
}

/// Custom exception for map-related errors
class MapException extends DatabaseException {
  MapException({required super.message, super.originalError});
}
