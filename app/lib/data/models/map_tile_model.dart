import 'dart:typed_data';

/// Represents a single map tile with its coordinates and raw tile data.
/// MapTile stores Mapbox raster/vector tiles keyed by zoom/x/y so the map can render even with no network.
class MapTile {
  /// Zoom level (0-20 typically)
  final int zoom;

  /// X coordinate (tile column)
  final int x;

  /// Y coordinate (tile row)
  final int y;

  /// Raw tile bytes (PNG for raster, MVT for vector)
  final Uint8List data;

  /// Tile format: 'png', 'jpg', 'mvt', etc.
  final String format;

  /// Timestamp when tile was fetched
  final DateTime fetchedAt;

  /// Size of tile data in bytes
  int get sizeInBytes => data.length;

  const MapTile({
    required this.zoom,
    required this.x,
    required this.y,
    required this.data,
    required this.format,
    required this.fetchedAt,
  });

  /// Creates a unique key for this tile (used for Hive storage)
  /// Format: "z/x/y" e.g., "14/4824/6150"
  String get key => '$zoom/$x/$y';

  /// Creates a MapTile from JSON (for serialization)
  factory MapTile.fromJson(Map<String, dynamic> json) {
    return MapTile(
      zoom: json['zoom'] as int,
      x: json['x'] as int,
      y: json['y'] as int,
      data: Uint8List.fromList(
        (json['data'] as List).map((e) => e as int).toList(),
      ),
      format: json['format'] as String? ?? 'png',
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  /// Converts MapTile to JSON (for serialization)
  Map<String, dynamic> toJson() {
    return {
      'zoom': zoom,
      'x': x,
      'y': y,
      'data': data.toList(),
      'format': format,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields
  MapTile copyWith({
    int? zoom,
    int? x,
    int? y,
    Uint8List? data,
    String? format,
    DateTime? fetchedAt,
  }) {
    return MapTile(
      zoom: zoom ?? this.zoom,
      x: x ?? this.x,
      y: y ?? this.y,
      data: data ?? this.data,
      format: format ?? this.format,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
