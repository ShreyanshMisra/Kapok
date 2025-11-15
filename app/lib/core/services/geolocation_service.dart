import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';

/// Service for handling geolocation operations
class GeolocationService {
  static GeolocationService? _instance;
  static GeolocationService get instance => _instance ??= GeolocationService._();
  
  GeolocationService._();

  /// Checks if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      Logger.location('Location service enabled: $enabled');
      return enabled;
    } catch (e) {
      Logger.location('Error checking location service status', error: e);
      throw LocationException(
        message: 'Failed to check location service status',
        originalError: e,
      );
    }
  }

  /// Requests location permission
  Future<LocationPermission> requestLocationPermission() async {
    try {
      Logger.permission('Requesting location permission');
      
      // Check if permission is already granted
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      Logger.permission('Location permission status: $permission');
      return permission;
    } catch (e) {
      Logger.permission('Error requesting location permission', error: e);
      throw PermissionException(
        message: 'Failed to request location permission',
        originalError: e,
      );
    }
  }

  /// Gets current position
  Future<Position> getCurrentPosition() async {
    try {
      Logger.location('Getting current position');
      
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException(
          message: 'Location services are disabled',
        );
      }

      // Check and request permission
      final permission = await requestLocationPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        throw PermissionException(
          message: 'Location permission denied',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      Logger.location('Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      Logger.location('Error getting current position', error: e);
      if (e is LocationException || e is PermissionException) {
        rethrow;
      }
      throw LocationException(
        message: 'Failed to get current position',
        originalError: e,
      );
    }
  }

  /// Gets last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      Logger.location('Getting last known position');
      
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        Logger.location('Last known position: ${position.latitude}, ${position.longitude}');
      } else {
        Logger.location('No last known position available');
      }
      
      return position;
    } catch (e) {
      Logger.location('Error getting last known position', error: e);
      throw LocationException(
        message: 'Failed to get last known position',
        originalError: e,
      );
    }
  }

  /// Calculates distance between two positions
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    try {
      final distance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
      
      Logger.location('Distance calculated: ${distance.toStringAsFixed(2)} meters');
      return distance;
    } catch (e) {
      Logger.location('Error calculating distance', error: e);
      throw LocationException(
        message: 'Failed to calculate distance',
        originalError: e,
      );
    }
  }

  /// Converts coordinates to address
  Future<String> coordinatesToAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      Logger.location('Converting coordinates to address: $latitude, $longitude');
      
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = _formatAddress(placemark);
        Logger.location('Address: $address');
        return address;
      } else {
        throw LocationException(
          message: 'No address found for the given coordinates',
        );
      }
    } catch (e) {
      Logger.location('Error converting coordinates to address', error: e);
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException(
        message: 'Failed to convert coordinates to address',
        originalError: e,
      );
    }
  }

  /// Converts address to coordinates
  Future<Position> addressToCoordinates(String address) async {
    try {
      Logger.location('Converting address to coordinates: $address');
      
      final locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        
        Logger.location('Coordinates: ${position.latitude}, ${position.longitude}');
        return position;
      } else {
        throw LocationException(
          message: 'No coordinates found for the given address',
        );
      }
    } catch (e) {
      Logger.location('Error converting address to coordinates', error: e);
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException(
        message: 'Failed to convert address to coordinates',
        originalError: e,
      );
    }
  }

  /// Formats address from placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }
    
    return parts.join(', ');
  }

  /// Gets location updates stream
  Stream<Position> getLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    Logger.location('Starting location updates stream');
    
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).handleError((error) {
      Logger.location('Error in location updates stream', error: error);
      throw LocationException(
        message: 'Error in location updates stream',
        originalError: error,
      );
    });
  }

  /// Checks if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      final hasPermission = permission == LocationPermission.always ||
                           permission == LocationPermission.whileInUse;
      
      Logger.permission('Has location permission: $hasPermission');
      return hasPermission;
    } catch (e) {
      Logger.permission('Error checking location permission', error: e);
      return false;
    }
  }

  /// Opens location settings
  Future<void> openLocationSettings() async {
    try {
      Logger.location('Opening location settings');
      await Geolocator.openLocationSettings();
    } catch (e) {
      Logger.location('Error opening location settings', error: e);
      throw LocationException(
        message: 'Failed to open location settings',
        originalError: e,
      );
    }
  }

  /// Opens app settings
  Future<void> openAppSettings() async {
    try {
      Logger.location('Opening app settings');
      await openAppSettings();
    } catch (e) {
      Logger.location('Error opening app settings', error: e);
      throw LocationException(
        message: 'Failed to open app settings',
        originalError: e,
      );
    }
  }

  /// Validates coordinates
  bool isValidCoordinates({
    required double latitude,
    required double longitude,
  }) {
    final isValid = latitude >= -90 && latitude <= 90 &&
                   longitude >= -180 && longitude <= 180;
    
    Logger.location('Coordinates valid: $isValid ($latitude, $longitude)');
    return isValid;
  }

  /// Gets distance in human-readable format
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final kilometers = distanceInMeters / 1000;
      return '${kilometers.toStringAsFixed(1)} km';
    }
  }

  /// Gets bearing between two positions
  double getBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    try {
      final bearing = Geolocator.bearingBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
      
      Logger.location('Bearing calculated: ${bearing.toStringAsFixed(2)} degrees');
      return bearing;
    } catch (e) {
      Logger.location('Error calculating bearing', error: e);
      throw LocationException(
        message: 'Failed to calculate bearing',
        originalError: e,
      );
    }
  }
}
