import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/task_priority.dart';

void main() {
  group('TaskPriority', () {
    test('round-trips through value for every member', () {
      for (final p in TaskPriority.values) {
        expect(TaskPriority.fromString(p.value), p);
      }
    });

    test('defaults to medium for unknown input', () {
      expect(TaskPriority.fromString(''), TaskPriority.medium);
      expect(TaskPriority.fromString('critical'), TaskPriority.medium);
      expect(TaskPriority.fromString('LOW'), TaskPriority.medium,
          reason: 'fromString is intentionally case-sensitive');
    });

    test('display names are human-facing', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
    });
  });
}
