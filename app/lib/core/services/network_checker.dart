import 'dart:io' show InternetAddress;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../error/exceptions.dart';
import '../utils/logger.dart';

/// Service for checking network connectivity
class NetworkChecker {
  static NetworkChecker? _instance;
  static NetworkChecker get instance => _instance ??= NetworkChecker._();

  NetworkChecker._();

  final Connectivity _connectivity = Connectivity();

  /// Test mode override: when set, forces offline mode for testing
  bool? _testModeOverride;

  /// Sets test mode override (null = use real network check, true = force offline, false = force online)
  void setTestModeOverride(bool? override) {
    _testModeOverride = override;
    Logger.network('Test mode override set to: $override');
  }

  /// Checks if device is connected to internet
  Future<bool> isConnected() async {
    // Test mode override for offline testing
    if (_testModeOverride != null) {
      Logger.network(
        'Using test mode override: ${_testModeOverride! ? "OFFLINE" : "ONLINE"}',
      );
      return !_testModeOverride!; // If override is true (offline), return false (not connected)
    }

    try {
      Logger.network('Checking network connectivity');

      // Check connectivity status
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        Logger.network('No network connection');
        return false;
      }

      // Try to reach a reliable host to confirm internet access
      final hasInternet = await _hasInternetAccess();

      Logger.network('Network connected: $hasInternet');
      return hasInternet;
    } catch (e) {
      Logger.network('Error checking network connectivity', error: e);
      return false;
    }
  }

  /// Checks if device has internet access by pinging a reliable host
  /// On web, we assume connectivity means internet access (browser handles DNS)
  Future<bool> _hasInternetAccess() async {
    // On web, InternetAddress.lookup is not available
    // If we have connectivity, assume internet access
    if (kIsWeb) {
      Logger.network(
        'Web platform: assuming connectivity means internet access',
      );
      return true;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      Logger.network('No internet access', error: e);
      return false;
    }
  }

  /// Gets current connectivity status
  Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      Logger.network('Getting connectivity status');
      final statusList = await _connectivity.checkConnectivity();
      final status = statusList.isNotEmpty
          ? statusList.first
          : ConnectivityResult.none;
      Logger.network('Connectivity status: $status');
      return status;
    } catch (e) {
      Logger.network('Error getting connectivity status', error: e);
      throw NetworkException(
        message: 'Failed to get connectivity status',
        originalError: e,
      );
    }
  }

  /// Listens to connectivity changes
  Stream<ConnectivityResult> get connectivityStream {
    Logger.network('Starting connectivity stream');
    return _connectivity.onConnectivityChanged.map(
      (resultList) =>
          resultList.isNotEmpty ? resultList.first : ConnectivityResult.none,
    );
  }

  /// Checks if connected via WiFi
  Future<bool> isConnectedViaWiFi() async {
    try {
      final status = await getConnectivityStatus();
      final isWiFi = status == ConnectivityResult.wifi;
      Logger.network('Connected via WiFi: $isWiFi');
      return isWiFi;
    } catch (e) {
      Logger.network('Error checking WiFi connection', error: e);
      return false;
    }
  }

  /// Checks if connected via mobile data
  Future<bool> isConnectedViaMobile() async {
    try {
      final status = await getConnectivityStatus();
      final isMobile = status == ConnectivityResult.mobile;
      Logger.network('Connected via mobile: $isMobile');
      return isMobile;
    } catch (e) {
      Logger.network('Error checking mobile connection', error: e);
      return false;
    }
  }

  /// Checks if connected via ethernet
  Future<bool> isConnectedViaEthernet() async {
    try {
      final status = await getConnectivityStatus();
      final isEthernet = status == ConnectivityResult.ethernet;
      Logger.network('Connected via ethernet: $isEthernet');
      return isEthernet;
    } catch (e) {
      Logger.network('Error checking ethernet connection', error: e);
      return false;
    }
  }

  /// Gets connection type as string
  Future<String> getConnectionType() async {
    try {
      final status = await getConnectivityStatus();
      String connectionType = 'Unknown';

      switch (status) {
        case ConnectivityResult.wifi:
          connectionType = 'WiFi';
          break;
        case ConnectivityResult.mobile:
          connectionType = 'Mobile Data';
          break;
        case ConnectivityResult.ethernet:
          connectionType = 'Ethernet';
          break;
        case ConnectivityResult.bluetooth:
          connectionType = 'Bluetooth';
          break;
        case ConnectivityResult.vpn:
          connectionType = 'VPN';
          break;
        case ConnectivityResult.other:
          connectionType = 'Other';
          break;
        case ConnectivityResult.none:
          connectionType = 'No Connection';
          break;
      }

      Logger.network('Connection type: $connectionType');
      return connectionType;
    } catch (e) {
      Logger.network('Error getting connection type', error: e);
      return 'Unknown';
    }
  }

  /// Waits for network connection
  Future<void> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      Logger.network(
        'Waiting for network connection (timeout: ${timeout.inSeconds}s)',
      );

      final stopwatch = Stopwatch()..start();

      while (stopwatch.elapsed < timeout) {
        if (await isConnected()) {
          Logger.network('Network connection established');
          return;
        }

        // Wait 1 second before checking again
        await Future.delayed(const Duration(seconds: 1));
      }

      Logger.network('Network connection timeout');
      throw NetworkException(
        message:
            'Network connection timeout after ${timeout.inSeconds} seconds',
      );
    } catch (e) {
      Logger.network('Error waiting for network connection', error: e);
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException(
        message: 'Failed to wait for network connection',
        originalError: e,
      );
    }
  }

  /// Checks network quality (basic implementation)
  Future<NetworkQuality> getNetworkQuality() async {
    try {
      Logger.network('Checking network quality');

      if (!await isConnected()) {
        return NetworkQuality.none;
      }

      final stopwatch = Stopwatch()..start();

      try {
        // On web, skip the lookup and assume good quality if connected
        if (kIsWeb) {
          stopwatch.stop();
          return NetworkQuality.good; // Assume good quality on web
        }

        await InternetAddress.lookup('google.com');
        stopwatch.stop();

        final responseTime = stopwatch.elapsedMilliseconds;

        if (responseTime < 100) {
          return NetworkQuality.excellent;
        } else if (responseTime < 300) {
          return NetworkQuality.good;
        } else if (responseTime < 1000) {
          return NetworkQuality.fair;
        } else {
          return NetworkQuality.poor;
        }
      } catch (e) {
        return NetworkQuality.poor;
      }
    } catch (e) {
      Logger.network('Error checking network quality', error: e);
      return NetworkQuality.none;
    }
  }

  /// Gets network speed category
  Future<NetworkSpeed> getNetworkSpeed() async {
    try {
      final quality = await getNetworkQuality();

      switch (quality) {
        case NetworkQuality.excellent:
          return NetworkSpeed.fast;
        case NetworkQuality.good:
          return NetworkSpeed.medium;
        case NetworkQuality.fair:
          return NetworkSpeed.slow;
        case NetworkQuality.poor:
          return NetworkSpeed.verySlow;
        case NetworkQuality.none:
          return NetworkSpeed.none;
      }
    } catch (e) {
      Logger.network('Error getting network speed', error: e);
      return NetworkSpeed.none;
    }
  }

  /// Checks if network is suitable for sync operations
  Future<bool> isNetworkSuitableForSync() async {
    try {
      final quality = await getNetworkQuality();
      final isSuitable =
          quality == NetworkQuality.excellent || quality == NetworkQuality.good;

      Logger.network('Network suitable for sync: $isSuitable');
      return isSuitable;
    } catch (e) {
      Logger.network('Error checking network suitability for sync', error: e);
      return false;
    }
  }

  /// Gets network status summary
  Future<NetworkStatus> getNetworkStatus() async {
    try {
      final isConnected = await this.isConnected();
      final connectionType = await getConnectionType();
      final quality = await getNetworkQuality();
      final speed = await getNetworkSpeed();

      return NetworkStatus(
        isConnected: isConnected,
        connectionType: connectionType,
        quality: quality,
        speed: speed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      Logger.network('Error getting network status', error: e);
      return NetworkStatus(
        isConnected: false,
        connectionType: 'Unknown',
        quality: NetworkQuality.none,
        speed: NetworkSpeed.none,
        timestamp: DateTime.now(),
      );
    }
  }
}

/// Network quality levels
enum NetworkQuality { none, poor, fair, good, excellent }

/// Network speed categories
enum NetworkSpeed { none, verySlow, slow, medium, fast }

/// Network status information
class NetworkStatus {
  final bool isConnected;
  final String connectionType;
  final NetworkQuality quality;
  final NetworkSpeed speed;
  final DateTime timestamp;

  const NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    required this.quality,
    required this.speed,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'NetworkStatus(isConnected: $isConnected, connectionType: $connectionType, quality: $quality, speed: $speed, timestamp: $timestamp)';
  }
}
