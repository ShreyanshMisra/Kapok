import 'hive_service.dart';
import '../utils/logger.dart';

/// Tracks whether a user has logged in before (per-user, via Hive).
/// First login routes to the About page; subsequent logins go to Home/Map.
class FirstLoginService {
  static FirstLoginService? _instance;
  static FirstLoginService get instance => _instance ??= FirstLoginService._();

  FirstLoginService._();

  String _keyForUser(String uid) => 'has_logged_in_before_$uid';

  /// Returns true if this user has logged in at least once before.
  bool hasLoggedInBefore(String uid) {
    try {
      final value =
          HiveService.instance.getSetting<bool>(_keyForUser(uid));
      return value ?? false;
    } catch (e) {
      Logger.error('Error checking first login status',
          tag: 'FIRST_LOGIN', error: e);
      return false;
    }
  }

  /// Marks the user as having completed their first login.
  Future<void> markLoggedIn(String uid) async {
    try {
      await HiveService.instance.storeSetting(_keyForUser(uid), true);
    } catch (e) {
      Logger.error('Error marking first login',
          tag: 'FIRST_LOGIN', error: e);
    }
  }
}
