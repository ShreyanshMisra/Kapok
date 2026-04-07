import 'package:flutter/material.dart';
import 'package:kapok_app/core/constants/app_colors.dart';
import 'package:kapok_app/data/models/offline_map_region_model.dart';
import 'package:kapok_app/data/repositories/map_repository.dart';
import 'package:kapok_app/injection_container.dart';
import 'package:kapok_app/core/widgets/kapok_logo.dart';

/// Test page to verify offline map functionality
class MapTestPage extends StatefulWidget {
  const MapTestPage({super.key});

  @override
  State<MapTestPage> createState() => _MapTestPageState();
}

class _MapTestPageState extends State<MapTestPage> {
  final MapRepository _mapRepository = sl<MapRepository>();
  String _status = 'Ready to test';
  bool _isLoading = false;
  List<OfflineMapRegion> _downloadedRegions = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedRegions();
  }

  Future<void> _loadDownloadedRegions() async {
    try {
      final regions = await _mapRepository.getDownloadedRegions();
      setState(() {
        _downloadedRegions = regions;
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading regions: $e';
      });
    }
  }

  /// Test fetching a single tile (online)
  Future<void> _testFetchTile() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing tile fetch (zoom: 10, x: 512, y: 512)...';
    });

    try {
      // Test fetching a tile for a common location (roughly center of world map)
      final tile = await _mapRepository.getTile(10, 512, 512);

      if (tile != null) {
        setState(() {
          _status =
              '✅ Tile fetched successfully!\n'
              'Format: ${tile.format}\n'
              'Size: ${(tile.sizeInBytes / 1024).toStringAsFixed(2)} KB\n'
              'Fetched at: ${tile.fetchedAt}';
        });
      } else {
        setState(() {
          _status = '❌ Tile fetch returned null';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error fetching tile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Test downloading a small region for offline use
  Future<void> _testDownloadRegion() async {
    setState(() {
      _isLoading = true;
      _status = 'Downloading test region...';
    });

    try {
      // Create a small test region around Amherst, MA (where the app seems to be based)
      final region = OfflineMapRegion(
        id: 'test_region_${DateTime.now().millisecondsSinceEpoch}',
        centerLat: 42.3909,
        centerLon: -72.5257,
        zoomMin: 10,
        zoomMax: 12,
        northEastLat: 42.4,
        northEastLon: -72.5,
        southWestLat: 42.38,
        southWestLon: -72.55,
        name: 'Test Region - Amherst',
        lastSyncedAt: DateTime.now(),
      );

      // Listen to progress
      final progressStream = _mapRepository.streamRegionStatus(region.id);
      progressStream.listen((progress) {
        if (mounted) {
          setState(() {
            _status =
                'Downloading region: ${(progress * 100).toStringAsFixed(1)}%';
          });
        }
      });

      await _mapRepository.downloadRegion(region);

      setState(() {
        _status = '✅ Region downloaded successfully!';
      });

      // Reload regions list
      await _loadDownloadedRegions();
    } catch (e) {
      setState(() {
        _status = '❌ Error downloading region: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Test fetching a tile that should be cached (offline simulation)
  Future<void> _testCachedTile() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing cached tile fetch...';
    });

    try {
      // Try to fetch a tile that we might have cached
      // Using the same coordinates as the download test
      final tile = await _mapRepository.getTile(10, 512, 512);

      if (tile != null) {
        setState(() {
          _status =
              '✅ Cached tile retrieved!\n'
              'Format: ${tile.format}\n'
              'Size: ${(tile.sizeInBytes / 1024).toStringAsFixed(2)} KB';
        });
      } else {
        setState(() {
          _status =
              '⚠️ Tile not found in cache. Try downloading a region first.';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error fetching cached tile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Delete a downloaded region
  Future<void> _deleteRegion(String regionId) async {
    setState(() {
      _isLoading = true;
      _status = 'Deleting region...';
    });

    try {
      await _mapRepository.deleteRegion(regionId);
      setState(() {
        _status = '✅ Region deleted successfully!';
      });
      await _loadDownloadedRegions();
    } catch (e) {
      setState(() {
        _status = '❌ Error deleting region: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: const Text('Offline Map Test'),
        centerTitle: true,
        elevation: 0,
        actions: const [KapokLogo()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status, style: const TextStyle(fontSize: 14)),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testFetchTile,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Test Fetch Tile (Online)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testDownloadRegion,
              icon: const Icon(Icons.download),
              label: const Text('Download Test Region'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testCachedTile,
              icon: const Icon(Icons.storage),
              label: const Text('Test Cached Tile (Offline)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Downloaded regions list
            const Text(
              'Downloaded Regions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_downloadedRegions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No regions downloaded yet.'),
                ),
              )
            else
              ..._downloadedRegions.map(
                (region) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(region.name),
                    subtitle: Text(
                      'Zoom: ${region.zoomMin}-${region.zoomMax}\n'
                      'Last synced: ${region.lastSyncedAt}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteRegion(region.id),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
