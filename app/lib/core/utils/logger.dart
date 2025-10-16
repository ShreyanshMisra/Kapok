import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Custom logger class for the Kapok app
class Logger {
  static const String _tag = 'Kapok';
  
  /// Logs debug messages (only in debug mode)
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs info messages
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs warning messages
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Logs fatal messages
  static void fatal(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.name.toUpperCase();
    
    final logMessage = '[$timestamp] [$levelString] [$logTag] $message';
    
    // Use developer.log for better debugging experience
    developer.log(
      logMessage,
      name: logTag,
      level: _getLogLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );
    
    // Also print to console in debug mode
    if (kDebugMode) {
      print(logMessage);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  /// Converts LogLevel to numeric value for developer.log
  static int _getLogLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  /// Logs authentication events
  static void auth(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'AUTH', error: error, stackTrace: stackTrace);
  }

  /// Logs network events
  static void network(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'NETWORK', error: error, stackTrace: stackTrace);
  }

  /// Logs database events
  static void database(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'DATABASE', error: error, stackTrace: stackTrace);
  }

  /// Logs location events
  static void location(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'LOCATION', error: error, stackTrace: stackTrace);
  }

  /// Logs sync events
  static void sync(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'SYNC', error: error, stackTrace: stackTrace);
  }

  /// Logs UI events
  static void ui(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'UI', error: error, stackTrace: stackTrace);
  }

  /// Logs performance metrics
  static void performance(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'PERFORMANCE', error: error, stackTrace: stackTrace);
  }

  /// Logs user actions
  static void userAction(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'USER_ACTION', error: error, stackTrace: stackTrace);
  }

  /// Logs API calls
  static void api(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'API', error: error, stackTrace: stackTrace);
  }

  /// Logs cache operations
  static void cache(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'CACHE', error: error, stackTrace: stackTrace);
  }

  /// Logs team operations
  static void team(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'TEAM', error: error, stackTrace: stackTrace);
  }

  /// Logs task operations
  static void task(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'TASK', error: error, stackTrace: stackTrace);
  }

  /// Logs map operations
  static void map(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'MAP', error: error, stackTrace: stackTrace);
  }

  /// Logs localization events
  static void localization(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'LOCALIZATION', error: error, stackTrace: stackTrace);
  }

  /// Logs Firebase events
  static void firebase(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'FIREBASE', error: error, stackTrace: stackTrace);
  }

  /// Logs Hive events
  static void hive(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'HIVE', error: error, stackTrace: stackTrace);
  }

  /// Logs Mapbox events
  static void mapbox(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'MAPBOX', error: error, stackTrace: stackTrace);
  }

  /// Logs dependency injection events
  static void di(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'DI', error: error, stackTrace: stackTrace);
  }

  /// Logs BLoC events
  static void bloc(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'BLOC', error: error, stackTrace: stackTrace);
  }

  /// Logs navigation events
  static void navigation(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'NAVIGATION', error: error, stackTrace: stackTrace);
  }

  /// Logs permission events
  static void permission(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'PERMISSION', error: error, stackTrace: stackTrace);
  }

  /// Logs validation events
  static void validation(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: 'VALIDATION', error: error, stackTrace: stackTrace);
  }

  /// Logs security events
  static void security(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: 'SECURITY', error: error, stackTrace: stackTrace);
  }

  /// Logs analytics events
  static void analytics(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'ANALYTICS', error: error, stackTrace: stackTrace);
  }

  /// Logs crash events
  static void crash(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, tag: 'CRASH', error: error, stackTrace: stackTrace);
  }

  /// Logs startup events
  static void startup(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'STARTUP', error: error, stackTrace: stackTrace);
  }

  /// Logs shutdown events
  static void shutdown(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: 'SHUTDOWN', error: error, stackTrace: stackTrace);
  }
}

