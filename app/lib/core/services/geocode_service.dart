import 'package:geocoding/geocoding.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';

/// Service for geocoding operations with caching
class GeocodeService {
  static GeocodeService? _instance;
  static GeocodeService get instance => _instance ??= GeocodeService._();

  GeocodeService._();

  static const String _cacheBoxName = 'geocode_cache';
  Box? _cacheBox;
  static const Duration _cacheTTL = Duration(hours: 24);

  /// Initialize cache
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_cacheBoxName)) {
        _cacheBox = await Hive.openBox(_cacheBoxName);
      } else {
        _cacheBox = Hive.box(_cacheBoxName);
      }
      Logger.location('Geocode cache initialized');
    } catch (e) {
      Logger.location('Error initializing geocode cache', error: e);
    }
  }

  /// Reverse geocode coordinates to address
  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      // Check cache first
      final cacheKey = '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
      final cached = await _getCachedAddress(cacheKey);
      if (cached != null) {
        Logger.location('Address retrieved from cache');
        return cached;
      }

      Logger.location('Reverse geocoding: $latitude, $longitude');
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        throw LocationException(message: 'No address found for coordinates');
      }

      final placemark = placemarks.first;
      final address = _formatAddress(placemark);

      // Cache the result
      await _cacheAddress(cacheKey, address);

      Logger.location('Address found: $address');
      return address;
    } catch (e) {
      // Check for location service errors
      if (e.toString().contains('location service') || 
          e.toString().contains('permission')) {
        throw LocationException(message: 'Location services are disabled or permission denied');
      }
      Logger.location('Error reverse geocoding', error: e);
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException(
        message: 'Failed to get address for location',
        originalError: e,
      );
    }
  }

  /// Forward geocode address to coordinates
  Future<({double latitude, double longitude})> forwardGeocode(
    String address,
  ) async {
    try {
      // Check cache first
      final cacheKey = 'addr_${address.hashCode}';
      final cached = await _getCachedLocation(cacheKey);
      if (cached != null) {
        Logger.location('Location retrieved from cache');
        return cached;
      }

      Logger.location('Forward geocoding: $address');
      final locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        throw LocationException(message: 'No location found for address');
      }

      final location = locations.first;
      final result = (latitude: location.latitude, longitude: location.longitude);

      // Cache the result
      await _cacheLocation(cacheKey, result);

      Logger.location('Location found: ${result.latitude}, ${result.longitude}');
      return result;
    } catch (e) {
      // Check for location service errors
      if (e.toString().contains('location service') || 
          e.toString().contains('permission')) {
        throw LocationException(message: 'Location services are disabled or permission denied');
      }
      Logger.location('Error forward geocoding', error: e);
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException(
        message: 'Failed to get location for address',
        originalError: e,
      );
    }
  }

  /// Format placemark to readable address
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      parts.add(placemark.postalCode!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }
    return parts.join(', ');
  }

  /// Get cached address
  Future<String?> _getCachedAddress(String key) async {
    if (_cacheBox == null) await initialize();
    final cached = _cacheBox!.get(key);
    if (cached == null) return null;

    final data = Map<String, dynamic>.from(cached);
    final timestamp = DateTime.parse(data['timestamp'] as String);
    if (DateTime.now().difference(timestamp) > _cacheTTL) {
      await _cacheBox!.delete(key);
      return null;
    }

    return data['address'] as String;
  }

  /// Cache address
  Future<void> _cacheAddress(String key, String address) async {
    if (_cacheBox == null) await initialize();
    await _cacheBox!.put(key, {
      'address': address,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get cached location
  Future<({double latitude, double longitude})?> _getCachedLocation(
    String key,
  ) async {
    if (_cacheBox == null) await initialize();
    final cached = _cacheBox!.get(key);
    if (cached == null) return null;

    final data = Map<String, dynamic>.from(cached);
    final timestamp = DateTime.parse(data['timestamp'] as String);
    if (DateTime.now().difference(timestamp) > _cacheTTL) {
      await _cacheBox!.delete(key);
      return null;
    }

    return (
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
    );
  }

  /// Cache location
  Future<void> _cacheLocation(
    String key,
    ({double latitude, double longitude}) location,
  ) async {
    if (_cacheBox == null) await initialize();
    await _cacheBox!.put(key, {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Clear cache
  Future<void> clearCache() async {
    if (_cacheBox == null) await initialize();
    await _cacheBox!.clear();
    Logger.location('Geocode cache cleared');
  }
}

