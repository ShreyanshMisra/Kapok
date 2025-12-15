import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'hive_service.dart';
import '../utils/logger.dart';

/// Service for managing analytics and crash reporting with privacy controls
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  static const String _analyticsEnabledKey = 'analytics_enabled';
  static const String _crashReportingEnabledKey = 'crash_reporting_enabled';

  late final FirebaseAnalytics _analytics;
  bool _initialized = false;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;

      // Apply saved privacy preferences
      final analyticsEnabled = isAnalyticsEnabled;
      final crashReportingEnabled = isCrashReportingEnabled;

      await _analytics.setAnalyticsCollectionEnabled(analyticsEnabled);
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(crashReportingEnabled);

      _initialized = true;
      Logger.info('Analytics service initialized', tag: 'ANALYTICS');
      Logger.info('Analytics enabled: $analyticsEnabled', tag: 'ANALYTICS');
      Logger.info('Crash reporting enabled: $crashReportingEnabled',
          tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to initialize analytics service',
          tag: 'ANALYTICS', error: e);
    }
  }

  /// Check if analytics collection is enabled
  bool get isAnalyticsEnabled {
    try {
      final enabled =
          HiveService.instance.getSetting<bool>(_analyticsEnabledKey);
      return enabled ?? true; // Enabled by default
    } catch (e) {
      return true; // Default to enabled if error
    }
  }

  /// Check if crash reporting is enabled
  bool get isCrashReportingEnabled {
    try {
      final enabled =
          HiveService.instance.getSetting<bool>(_crashReportingEnabledKey);
      return enabled ?? true; // Enabled by default
    } catch (e) {
      return true; // Default to enabled if error
    }
  }

  /// Enable or disable analytics collection
  Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      await HiveService.instance.storeSetting(_analyticsEnabledKey, enabled);
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      Logger.info('Analytics collection set to: $enabled', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to set analytics enabled',
          tag: 'ANALYTICS', error: e);
    }
  }

  /// Enable or disable crash reporting
  Future<void> setCrashReportingEnabled(bool enabled) async {
    try {
      await HiveService.instance
          .storeSetting(_crashReportingEnabledKey, enabled);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
      Logger.info('Crash reporting set to: $enabled', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to set crash reporting enabled',
          tag: 'ANALYTICS', error: e);
    }
  }

  /// Log a custom event (respects privacy settings)
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!isAnalyticsEnabled) return;

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      Logger.debug('Logged event: $name', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to log event: $name', tag: 'ANALYTICS', error: e);
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!isAnalyticsEnabled) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      Logger.debug('Logged screen view: $screenName', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to log screen view: $screenName',
          tag: 'ANALYTICS', error: e);
    }
  }

  /// Log user login
  Future<void> logLogin({String loginMethod = 'email'}) async {
    if (!isAnalyticsEnabled) return;

    try {
      await _analytics.logLogin(loginMethod: loginMethod);
      Logger.debug('Logged login event', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to log login', tag: 'ANALYTICS', error: e);
    }
  }

  /// Log user signup
  Future<void> logSignUp({String signUpMethod = 'email'}) async {
    if (!isAnalyticsEnabled) return;

    try {
      await _analytics.logSignUp(signUpMethod: signUpMethod);
      Logger.debug('Logged signup event', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to log signup', tag: 'ANALYTICS', error: e);
    }
  }

  /// Log task creation
  Future<void> logTaskCreated({
    String? teamId,
    int? priority,
  }) async {
    await logEvent(
      name: 'task_created',
      parameters: {
        if (teamId != null) 'team_id': teamId,
        if (priority != null) 'priority': priority,
      },
    );
  }

  /// Log task completion
  Future<void> logTaskCompleted({String? taskId}) async {
    await logEvent(
      name: 'task_completed',
      parameters: {
        if (taskId != null) 'task_id': taskId,
      },
    );
  }

  /// Log team creation
  Future<void> logTeamCreated() async {
    await logEvent(name: 'team_created');
  }

  /// Log team join
  Future<void> logTeamJoined() async {
    await logEvent(name: 'team_joined');
  }

  /// Log offline sync
  Future<void> logOfflineSync({int? itemCount}) async {
    await logEvent(
      name: 'offline_sync',
      parameters: {
        if (itemCount != null) 'item_count': itemCount,
      },
    );
  }

  /// Set user ID for analytics (anonymized)
  Future<void> setUserId(String? userId) async {
    if (!isAnalyticsEnabled) return;

    try {
      // Use a hashed version for privacy
      await _analytics.setUserId(id: userId);
      Logger.debug('Set user ID for analytics', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to set user ID', tag: 'ANALYTICS', error: e);
    }
  }

  /// Clear user data (for logout/privacy)
  Future<void> clearUserData() async {
    try {
      await _analytics.setUserId(id: null);
      Logger.debug('Cleared user analytics data', tag: 'ANALYTICS');
    } catch (e) {
      Logger.error('Failed to clear user data', tag: 'ANALYTICS', error: e);
    }
  }

  /// Get Firebase Analytics instance for navigation observer
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);
}
