import 'package:hive_flutter/hive_flutter.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/offline_map_region_model.dart';

/// Tracks which regions the user has explicitly downloaded so we can show status and manage disk usage.
/// Stores which regions are "installed" using a separate Hive box offline_map_regions.
class OfflineMapRegionRepository {
  static const String _boxName = 'offline_map_regions';
  Box? _regionsBox;

  /// Initializes the repository by opening the Hive box
  Future<void> initialize() async {
    try {
      Logger.hive('Initializing offline map region repository');

      if (!Hive.isBoxOpen(_boxName)) {
        _regionsBox = await Hive.openBox(_boxName);
      } else {
        _regionsBox = Hive.box(_boxName);
      }

      Logger.hive(
        'Offline map region repository initialized: ${_regionsBox!.length} regions',
      );
    } catch (e) {
      Logger.hive(
        'Failed to initialize offline map region repository',
        error: e,
      );
      throw CacheException(
        message: 'Failed to initialize offline map region repository',
        originalError: e,
      );
    }
  }

  /// Saves a region to the repository
  Future<void> saveRegion(OfflineMapRegion region) async {
    try {
      if (_regionsBox == null) {
        await initialize();
      }

      Logger.hive('Saving region: ${region.id}');
      await _regionsBox!.put(region.id, region.toJson());
      Logger.hive('Region saved successfully');
    } catch (e) {
      Logger.hive('Error saving region: ${region.id}', error: e);
      throw CacheException(message: 'Failed to save region', originalError: e);
    }
  }

  /// Gets a region by ID
  Future<OfflineMapRegion?> getRegion(String regionId) async {
    try {
      if (_regionsBox == null) {
        await initialize();
      }

      final regionData = _regionsBox!.get(regionId);
      if (regionData == null) {
        return null;
      }

      return OfflineMapRegion.fromJson(Map<String, dynamic>.from(regionData));
    } catch (e) {
      Logger.hive('Error getting region: $regionId', error: e);
      throw CacheException(message: 'Failed to get region', originalError: e);
    }
  }

  /// Gets all saved regions
  Future<List<OfflineMapRegion>> getAllRegions() async {
    try {
      if (_regionsBox == null) {
        await initialize();
      }

      final regions = <OfflineMapRegion>[];
      for (final key in _regionsBox!.keys) {
        final regionData = _regionsBox!.get(key);
        if (regionData != null) {
          try {
            final region = OfflineMapRegion.fromJson(
              Map<String, dynamic>.from(regionData),
            );
            regions.add(region);
          } catch (_) {
            // Ignore deserialization errors
          }
        }
      }

      return regions;
    } catch (e) {
      Logger.hive('Error getting all regions', error: e);
      throw CacheException(
        message: 'Failed to get all regions',
        originalError: e,
      );
    }
  }

  /// Deletes a region
  Future<void> deleteRegion(String regionId) async {
    try {
      if (_regionsBox == null) {
        await initialize();
      }

      Logger.hive('Deleting region: $regionId');
      await _regionsBox!.delete(regionId);
      Logger.hive('Region deleted successfully');
    } catch (e) {
      Logger.hive('Error deleting region: $regionId', error: e);
      throw CacheException(
        message: 'Failed to delete region',
        originalError: e,
      );
    }
  }

  /// Clears all regions
  Future<void> clearAll() async {
    try {
      if (_regionsBox == null) {
        await initialize();
      }

      Logger.hive('Clearing all regions');
      await _regionsBox!.clear();
      Logger.hive('All regions cleared');
    } catch (e) {
      Logger.hive('Error clearing all regions', error: e);
      throw CacheException(
        message: 'Failed to clear all regions',
        originalError: e,
      );
    }
  }

  /// We keep at most one offline region (the latest around the user's location) to control disk usage;
  /// all older regions are removed before caching a new one.
  /// Deletes all regions except the one with the specified ID
  Future<void> deleteAllRegionsExcept(String keepRegionId) async {
    try {
      if (_regionsBox == null) {
        await initialize();
      }

      Logger.hive('Deleting all regions except: $keepRegionId');
      final allRegions = await getAllRegions();
      int deletedCount = 0;

      for (final region in allRegions) {
        if (region.id != keepRegionId) {
          await _regionsBox!.delete(region.id);
          deletedCount++;
        }
      }

      Logger.hive('Deleted $deletedCount regions, kept: $keepRegionId');
    } catch (e) {
      Logger.hive('Error deleting regions except: $keepRegionId', error: e);
      throw CacheException(
        message: 'Failed to delete regions',
        originalError: e,
      );
    }
  }

  /// Gets the latest region (most recently synced)
  Future<OfflineMapRegion?> getLatestRegion() async {
    try {
      final allRegions = await getAllRegions();
      if (allRegions.isEmpty) {
        return null;
      }

      // Sort by lastSyncedAt descending and return the most recent
      allRegions.sort((a, b) => b.lastSyncedAt.compareTo(a.lastSyncedAt));
      return allRegions.first;
    } catch (e) {
      Logger.hive('Error getting latest region', error: e);
      throw CacheException(
        message: 'Failed to get latest region',
        originalError: e,
      );
    }
  }
}
