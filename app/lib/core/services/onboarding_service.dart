import 'hive_service.dart';
import '../utils/logger.dart';

/// Service for managing onboarding state persistence
class OnboardingService {
  static OnboardingService? _instance;
  static OnboardingService get instance => _instance ??= OnboardingService._();

  OnboardingService._();

  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Checks if onboarding has been completed
  bool get hasCompletedOnboarding {
    try {
      final completed =
          HiveService.instance.getSetting<bool>(_onboardingCompletedKey);
      Logger.info('Onboarding completed status: ${completed ?? false}',
          tag: 'ONBOARDING');
      return completed ?? false;
    } catch (e) {
      Logger.error('Error checking onboarding status',
          tag: 'ONBOARDING', error: e);
      return false;
    }
  }

  /// Marks onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      Logger.info('Marking onboarding as completed', tag: 'ONBOARDING');
      await HiveService.instance.storeSetting(_onboardingCompletedKey, true);
      Logger.info('Onboarding marked as completed successfully',
          tag: 'ONBOARDING');
    } catch (e) {
      Logger.error('Error marking onboarding as completed',
          tag: 'ONBOARDING', error: e);
    }
  }

  /// Resets onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    try {
      Logger.info('Resetting onboarding status', tag: 'ONBOARDING');
      await HiveService.instance.storeSetting(_onboardingCompletedKey, false);
      Logger.info('Onboarding status reset successfully', tag: 'ONBOARDING');
    } catch (e) {
      Logger.error('Error resetting onboarding status',
          tag: 'ONBOARDING', error: e);
    }
  }
}
