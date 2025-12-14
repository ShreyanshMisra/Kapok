import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/task_priority.dart';
import 'package:kapok_app/core/enums/task_status.dart';
import 'package:kapok_app/data/models/task_model.dart';

/// Tests for TaskModel to ensure field consistency and data integrity
/// Critical for disaster relief operations where data accuracy is paramount
void main() {
  group('TaskModel Field Consistency', () {
    final testTask = TaskModel(
      id: 'test_task_1',
      title: 'Deliver medical supplies',
      description: 'Urgent delivery needed to shelter',
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      assignedTo: 'user_123',
      teamId: 'team_456',
      geoLocation: GeoPoint(34.0522, -118.2437),
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      createdBy: 'leader_789',
    );

    test('new field names are canonical', () {
      expect(testTask.title, equals('Deliver medical supplies'));
      expect(testTask.description, equals('Urgent delivery needed to shelter'));
      expect(testTask.priority, equals(TaskPriority.high));
      expect(testTask.status, equals(TaskStatus.pending));
    });

    test('deprecated getters maintain backward compatibility', () {
      // These deprecated fields should still work for existing code
      expect(testTask.taskName, equals(testTask.title));
      expect(testTask.taskDescription, equals(testTask.description));
      expect(testTask.taskCompleted, equals(false)); // pending status
      expect(testTask.taskSeverity, equals(4)); // high priority = 4
    });

    test('taskSeverity correctly maps priority enum to legacy int', () {
      final lowTask = testTask.copyWith(priority: TaskPriority.low);
      final mediumTask = testTask.copyWith(priority: TaskPriority.medium);
      final highTask = testTask.copyWith(priority: TaskPriority.high);

      expect(lowTask.taskSeverity, equals(2));
      expect(mediumTask.taskSeverity, equals(3));
      expect(highTask.taskSeverity, equals(4));
    });

    test('taskCompleted correctly maps status enum to legacy bool', () {
      final pendingTask = testTask.copyWith(status: TaskStatus.pending);
      final completedTask = testTask.copyWith(status: TaskStatus.completed);

      expect(pendingTask.taskCompleted, equals(false));
      expect(completedTask.taskCompleted, equals(true));
    });

    test('copyWith preserves all fields correctly', () {
      final updatedTask = testTask.copyWith(
        title: 'Updated title',
        priority: TaskPriority.medium,
      );

      expect(updatedTask.title, equals('Updated title'));
      expect(updatedTask.priority, equals(TaskPriority.medium));
      // Other fields should remain unchanged
      expect(updatedTask.description, equals(testTask.description));
      expect(updatedTask.status, equals(testTask.status));
      expect(updatedTask.teamId, equals(testTask.teamId));
    });

    test('toJson and fromJson maintain data integrity', () {
      final json = testTask.toJson();
      final reconstructed = TaskModel.fromJson(json);

      expect(reconstructed.title, equals(testTask.title));
      expect(reconstructed.description, equals(testTask.description));
      expect(reconstructed.priority, equals(testTask.priority));
      expect(reconstructed.status, equals(testTask.status));
      expect(reconstructed.assignedTo, equals(testTask.assignedTo));
      expect(reconstructed.teamId, equals(testTask.teamId));
    });

    test('latitude and longitude getters work correctly', () {
      expect(testTask.latitude, equals(34.0522));
      expect(testTask.longitude, equals(-118.2437));
    });

    test('isOverdue calculates correctly', () {
      final overdueTask = testTask.copyWith(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.pending,
      );
      final notOverdueTask = testTask.copyWith(
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.pending,
      );
      final completedTask = testTask.copyWith(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.completed,
      );

      expect(overdueTask.isOverdue, equals(true));
      expect(notOverdueTask.isOverdue, equals(false));
      expect(completedTask.isOverdue, equals(false)); // completed tasks aren't overdue
    });
  });

  group('TaskModel Edge Cases', () {
    test('handles null description correctly', () {
      final task = TaskModel(
        id: 'test_task_2',
        title: 'Task without description',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        teamId: 'team_123',
        geoLocation: GeoPoint(0, 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user_123',
      );

      expect(task.description, isNull);
      expect(task.taskDescription, equals('')); // deprecated getter returns empty string
    });

    test('handles null optional fields', () {
      final minimalTask = TaskModel(
        id: 'test_task_3',
        title: 'Minimal task',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        teamId: 'team_123',
        geoLocation: GeoPoint(0, 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user_123',
      );

      expect(minimalTask.description, isNull);
      expect(minimalTask.assignedTo, isNull);
      expect(minimalTask.address, isNull);
      expect(minimalTask.dueDate, isNull);
      expect(minimalTask.completedAt, isNull);
    });
  });
}
