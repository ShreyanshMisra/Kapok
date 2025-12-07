import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

part 'offline_map_region_model.g.dart';

/// Represents a geographic region that has been downloaded for offline map use.
/// Tracks which regions the user has explicitly downloaded so we can show status and manage disk usage.
@JsonSerializable()
class OfflineMapRegion {
  /// Unique identifier for this region
  final String id;

  /// Center point of the region (latitude, longitude)
  final double centerLat;
  final double centerLon;

  /// Zoom level range for downloaded tiles
  final int zoomMin;
  final int zoomMax;

  /// Bounding box coordinates
  final double northEastLat;
  final double northEastLon;
  final double southWestLat;
  final double southWestLon;

  /// Human-readable name for this region
  final String name;

  /// Timestamp when region was last synced/downloaded
  final DateTime lastSyncedAt;

  /// Total number of tiles in this region
  final int totalTiles;

  /// Number of tiles successfully downloaded
  final int downloadedTiles;

  /// Download status: 'pending', 'downloading', 'completed', 'failed'
  final String status;

  const OfflineMapRegion({
    required this.id,
    required this.centerLat,
    required this.centerLon,
    required this.zoomMin,
    required this.zoomMax,
    required this.northEastLat,
    required this.northEastLon,
    required this.southWestLat,
    required this.southWestLon,
    required this.name,
    required this.lastSyncedAt,
    this.totalTiles = 0,
    this.downloadedTiles = 0,
    this.status = 'pending',
  });

  factory OfflineMapRegion.fromJson(Map<String, dynamic> json) =>
      _$OfflineMapRegionFromJson(json);

  Map<String, dynamic> toJson() => _$OfflineMapRegionToJson(this);

  OfflineMapRegion copyWith({
    String? id,
    double? centerLat,
    double? centerLon,
    int? zoomMin,
    int? zoomMax,
    double? northEastLat,
    double? northEastLon,
    double? southWestLat,
    double? southWestLon,
    String? name,
    DateTime? lastSyncedAt,
    int? totalTiles,
    int? downloadedTiles,
    String? status,
  }) {
    return OfflineMapRegion(
      id: id ?? this.id,
      centerLat: centerLat ?? this.centerLat,
      centerLon: centerLon ?? this.centerLon,
      zoomMin: zoomMin ?? this.zoomMin,
      zoomMax: zoomMax ?? this.zoomMax,
      northEastLat: northEastLat ?? this.northEastLat,
      northEastLon: northEastLon ?? this.northEastLon,
      southWestLat: southWestLat ?? this.southWestLat,
      southWestLon: southWestLon ?? this.southWestLon,
      name: name ?? this.name,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      totalTiles: totalTiles ?? this.totalTiles,
      downloadedTiles: downloadedTiles ?? this.downloadedTiles,
      status: status ?? this.status,
    );
  }

  /// Checks if a tile coordinate (x, y) at zoom level z falls within this region's bounding box
  bool containsTile(int z, int x, int y) {
    // Convert tile coordinates to lat/lon
    final n = 1 << z;
    final lonDeg = x / n * 360.0 - 180.0;
    // Calculate sinh manually as it's not directly available in dart:math
    final double val = math.pi * (1 - 2 * y / n);
    final double sinhVal = (math.exp(val) - math.exp(-val)) / 2;
    final latRad = math.atan(sinhVal);
    final latDeg = latRad * 180.0 / math.pi;

    return latDeg >= southWestLat &&
        latDeg <= northEastLat &&
        lonDeg >= southWestLon &&
        lonDeg <= northEastLon;
  }
}
