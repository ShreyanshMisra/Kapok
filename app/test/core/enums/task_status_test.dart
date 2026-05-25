import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/task_status.dart';

void main() {
  group('TaskStatus', () {
    test('round-trips through value for every member', () {
      for (final s in TaskStatus.values) {
        expect(TaskStatus.fromString(s.value), s);
      }
    });

    test('defaults to pending for unknown input', () {
      expect(TaskStatus.fromString(''), TaskStatus.pending);
      expect(TaskStatus.fromString('archived'), TaskStatus.pending);
    });

    test('inProgress serializes as camelCase, not snake_case', () {
      expect(TaskStatus.inProgress.value, 'inProgress');
      expect(TaskStatus.fromString('in_progress'), TaskStatus.pending,
          reason:
              'guards against unintentionally accepting snake_case from the wire');
    });
  });
}
