import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/task_category.dart';

void main() {
  group('TaskCategory', () {
    test('round-trips through value for every member', () {
      for (final c in TaskCategory.values) {
        expect(TaskCategory.fromString(c.value), c);
      }
    });

    test('defaults to other for unknown input', () {
      expect(TaskCategory.fromString(''), TaskCategory.other);
      expect(TaskCategory.fromString('logistics'), TaskCategory.other);
    });

    test('covers the disaster-response categories the UI exposes', () {
      const expected = {
        'medical',
        'engineering',
        'carpentry',
        'plumbing',
        'construction',
        'electrical',
        'supplies',
        'transportation',
        'other',
      };
      final actual = TaskCategory.values.map((c) => c.value).toSet();
      expect(actual, expected);
    });
  });
}
