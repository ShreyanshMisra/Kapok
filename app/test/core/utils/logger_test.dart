import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/utils/logger.dart';

/// Logger is heavy on side effects (writes to `developer.log`) so we can't
/// assert formatted output without mocking the platform channel. These tests
/// pin down the small bits of pure behavior the logger exposes plus a smoke
/// check that every category helper is wired up and doesn't throw.
void main() {
  group('LogLevel', () {
    test('has exactly the levels the app relies on', () {
      expect(
        LogLevel.values.map((l) => l.name).toSet(),
        {'debug', 'info', 'warning', 'error', 'fatal'},
      );
    });

    test('ordering goes from least to most severe', () {
      expect(LogLevel.debug.index, lessThan(LogLevel.info.index));
      expect(LogLevel.info.index, lessThan(LogLevel.warning.index));
      expect(LogLevel.warning.index, lessThan(LogLevel.error.index));
      expect(LogLevel.error.index, lessThan(LogLevel.fatal.index));
    });
  });

  group('Logger category helpers', () {
    test('all helpers are callable without throwing', () {
      // Each helper writes to developer.log; we just want to confirm none
      // of them blow up under a default test config.
      expect(() => Logger.debug('debug-msg'), returnsNormally);
      expect(() => Logger.info('info-msg'), returnsNormally);
      expect(() => Logger.warning('warning-msg'), returnsNormally);
      expect(() => Logger.error('error-msg'), returnsNormally);
      expect(() => Logger.fatal('fatal-msg'), returnsNormally);
      expect(() => Logger.auth('auth-msg'), returnsNormally);
      expect(() => Logger.network('network-msg'), returnsNormally);
      expect(() => Logger.firebase('firebase-msg'), returnsNormally);
      expect(() => Logger.task('task-msg'), returnsNormally);
      expect(() => Logger.team('team-msg'), returnsNormally);
      expect(() => Logger.map('map-msg'), returnsNormally);
      expect(() => Logger.permission('permission-msg'), returnsNormally);
      expect(() => Logger.security('security-msg'), returnsNormally);
    });

    test('tolerates error + stack trace arguments', () {
      expect(
        () => Logger.error(
          'boom',
          error: StateError('detail'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });
}
