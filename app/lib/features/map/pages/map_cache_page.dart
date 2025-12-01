import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../../../data/repositories/offline_map_region_repository.dart';
import '../widgets/mapbox_map_view.dart';

/// Cache Page displays information about cached offline map regions
class MapCachePage extends StatefulWidget {
  const MapCachePage({super.key});

  @override
  State<MapCachePage> createState() => _MapCachePageState();
}

class _MapCachePageState extends State<MapCachePage> {
  final OfflineMapRegionRepository _regionRepository =
      OfflineMapRegionRepository();
  OfflineMapRegion? _latestRegion;
  List<OfflineMapRegion> _allRegions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() => _isLoading = true);
    try {
      await _regionRepository.initialize();
      _latestRegion = await _regionRepository.getLatestRegion();
      _allRegions = await _regionRepository.getAllRegions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading regions: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Offline Map Cache'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _latestRegion == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cached regions',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download a region from the map page',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRegions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Latest region card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Latest Region',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Visual map preview showing cached region
                          _buildRegionMapPreview(_latestRegion!),
                          const SizedBox(height: 16),
                          _buildRegionInfo(_latestRegion!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // All regions list
                  if (_allRegions.length > 1) ...[
                    Text(
                      'All Cached Regions (${_allRegions.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._allRegions.map(
                      (region) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.map),
                          title: Text(region.name),
                          subtitle: Text(
                            'Downloaded: ${_formatDate(region.lastSyncedAt)}',
                          ),
                          trailing: Text(
                            '${region.downloadedTiles}/${region.totalTiles} tiles',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRegionInfo(OfflineMapRegion region) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Name', region.name),
        _buildInfoRow(
          'Center',
          '${region.centerLat.toStringAsFixed(4)}, ${region.centerLon.toStringAsFixed(4)}',
        ),
        _buildInfoRow(
          'Bounding Box',
          'NE: ${region.northEastLat.toStringAsFixed(4)}, ${region.northEastLon.toStringAsFixed(4)}\n'
              'SW: ${region.southWestLat.toStringAsFixed(4)}, ${region.southWestLon.toStringAsFixed(4)}',
        ),
        _buildInfoRow('Zoom Range', '${region.zoomMin} - ${region.zoomMax}'),
        _buildInfoRow(
          'Tiles',
          '${region.downloadedTiles} / ${region.totalTiles}',
        ),
        _buildInfoRow('Status', region.status.toString().split('.').last),
        _buildInfoRow('Last Synced', _formatDate(region.lastSyncedAt)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionMapPreview(OfflineMapRegion region) {
    // Calculate center of bounding box
    final centerLat = (region.northEastLat + region.southWestLat) / 2;
    final centerLon = (region.northEastLon + region.southWestLon) / 2;

    // Calculate zoom level to fit the 3-mile bubble (approximately zoom 13-14)
    // For a 3-mile radius, we want to show roughly 6 miles across
    // At zoom 13, 1 tile ≈ 0.3 km, so we need zoom that shows ~10 km
    final zoom = 13.5; // Good balance to show the bubble

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Map view showing the cached region (non-interactive)
            SizedBox.expand(
              child: MapboxMapView(
                initialLatitude: centerLat,
                initialLongitude: centerLon,
                initialZoom: zoom,
                offlineBubble: region,
                isOfflineMode: false, // Show live map in preview
                interactive: false, // Disable zoom/pan for preview
              ),
            ),
            // Center marker
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
            // Info overlay
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cached Region Preview - Center: ${region.centerLat.toStringAsFixed(4)}, ${region.centerLon.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bounding box indicator (simplified)
            Positioned.fill(
              child: CustomPaint(painter: RegionBoundsPainter(region: region)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw the bounding box of the cached region
class RegionBoundsPainter extends CustomPainter {
  final OfflineMapRegion region;

  RegionBoundsPainter({required this.region});

  @override
  void paint(Canvas canvas, Size size) {
    // Simplified visualization - draw a semi-transparent overlay
    // In production, you'd convert lat/lon bounding box to screen coordinates
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw a rectangle covering most of the preview (simplified)
    // In production, you'd calculate actual screen coordinates from lat/lon
    final margin = size.width * 0.15;
    final rect = Rect.fromLTWH(
      margin,
      margin,
      size.width - 2 * margin,
      size.height - 2 * margin,
    );

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
