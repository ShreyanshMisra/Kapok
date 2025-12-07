// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_map_region_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineMapRegion _$OfflineMapRegionFromJson(Map<String, dynamic> json) =>
    OfflineMapRegion(
      id: json['id'] as String,
      centerLat: (json['centerLat'] as num).toDouble(),
      centerLon: (json['centerLon'] as num).toDouble(),
      zoomMin: (json['zoomMin'] as num).toInt(),
      zoomMax: (json['zoomMax'] as num).toInt(),
      northEastLat: (json['northEastLat'] as num).toDouble(),
      northEastLon: (json['northEastLon'] as num).toDouble(),
      southWestLat: (json['southWestLat'] as num).toDouble(),
      southWestLon: (json['southWestLon'] as num).toDouble(),
      name: json['name'] as String,
      lastSyncedAt: DateTime.parse(json['lastSyncedAt'] as String),
      totalTiles: (json['totalTiles'] as num?)?.toInt() ?? 0,
      downloadedTiles: (json['downloadedTiles'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$OfflineMapRegionToJson(OfflineMapRegion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'centerLat': instance.centerLat,
      'centerLon': instance.centerLon,
      'zoomMin': instance.zoomMin,
      'zoomMax': instance.zoomMax,
      'northEastLat': instance.northEastLat,
      'northEastLon': instance.northEastLon,
      'southWestLat': instance.southWestLat,
      'southWestLon': instance.southWestLon,
      'name': instance.name,
      'lastSyncedAt': instance.lastSyncedAt.toIso8601String(),
      'totalTiles': instance.totalTiles,
      'downloadedTiles': instance.downloadedTiles,
      'status': instance.status,
    };
