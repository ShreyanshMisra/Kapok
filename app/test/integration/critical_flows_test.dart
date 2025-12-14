import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/task_priority.dart';
import 'package:kapok_app/core/enums/task_status.dart';
import 'package:kapok_app/data/models/task_model.dart';
import 'package:kapok_app/data/models/team_model.dart';
import 'package:kapok_app/data/models/user_model.dart';

/// Integration tests for critical user flows in Kapok
/// These tests verify the core disaster relief coordination workflows
///
/// Critical Flows Tested:
/// 1. User signup and profile creation
/// 2. Team creation with leader permissions
/// 3. Task creation and assignment
/// 4. Offline data handling
void main() {
  group('Critical Flow 1: User Signup', () {
    test('creates user with required fields and valid role', () {
      final user = UserModel(
        id: 'user_001',
        email: 'rescuer@disaster-relief.org',
        name: 'John Rescuer',
        role: 'Medical',
        createdAt: DateTime.now(),
      );

      expect(user.id, equals('user_001'));
      expect(user.email, equals('rescuer@disaster-relief.org'));
      expect(user.name, equals('John Rescuer'));
      expect(user.role, equals('Medical'));
      expect(user.createdAt, isA<DateTime>());
    });

    test('user model serialization maintains data integrity', () {
      final user = UserModel(
        id: 'user_002',
        email: 'engineer@relief.org',
        name: 'Jane Engineer',
        role: 'Engineering',
        createdAt: DateTime(2025, 1, 1, 10, 0),
      );

      final json = user.toJson();
      final reconstructed = UserModel.fromJson(json);

      expect(reconstructed.id, equals(user.id));
      expect(reconstructed.email, equals(user.email));
      expect(reconstructed.name, equals(user.name));
      expect(reconstructed.role, equals(user.role));
      expect(reconstructed.createdAt, equals(user.createdAt));
    });

    test('supports all disaster relief roles', () {
      final roles = [
        'Medical',
        'Engineering',
        'Carpentry',
        'Plumbing',
        'Construction',
        'Electrical',
        'Supplies',
        'Transportation',
        'Other',
      ];

      for (final role in roles) {
        final user = UserModel(
          id: 'user_role_$role',
          email: '$role@relief.org',
          name: '$role Specialist',
          role: role,
          createdAt: DateTime.now(),
        );

        expect(user.role, equals(role));
      }
    });
  });

  group('Critical Flow 2: Team Creation', () {
    test('creates team with leader and generates join code', () {
      final team = TeamModel(
        id: 'team_001',
        name: 'Hurricane Response Team Alpha',
        description: 'Primary medical response for affected areas',
        createdBy: 'user_001',
        teamCode: 'HRT-2025-ALPHA',
        members: ['user_001'],
        leaders: ['user_001'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      expect(team.id, equals('team_001'));
      expect(team.name, equals('Hurricane Response Team Alpha'));
      expect(team.teamCode, equals('HRT-2025-ALPHA'));
      expect(team.members, contains('user_001'));
      expect(team.leaders, contains('user_001'));
      expect(team.isActive, isTrue);
    });

    test('team serialization preserves all fields', () {
      final team = TeamModel(
        id: 'team_002',
        name: 'Flood Relief Engineering',
        description: 'Infrastructure repair and assessment',
        createdBy: 'user_002',
        teamCode: 'FRE-2025-001',
        members: ['user_002', 'user_003', 'user_004'],
        leaders: ['user_002'],
        createdAt: DateTime(2025, 1, 1, 12, 0),
        updatedAt: DateTime(2025, 1, 1, 12, 0),
        isActive: true,
      );

      final json = team.toJson();
      final reconstructed = TeamModel.fromJson(json);

      expect(reconstructed.id, equals(team.id));
      expect(reconstructed.name, equals(team.name));
      expect(reconstructed.teamCode, equals(team.teamCode));
      expect(reconstructed.members.length, equals(3));
      expect(reconstructed.members, containsAll(['user_002', 'user_003', 'user_004']));
      expect(reconstructed.leaders, contains('user_002'));
    });

    test('supports adding members to existing team', () {
      final team = TeamModel(
        id: 'team_003',
        name: 'Supply Distribution Network',
        description: 'Coordinating supply distribution',
        createdBy: 'user_001',
        teamCode: 'SDN-2025-001',
        members: ['user_001'],
        leaders: ['user_001'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      // Simulate adding a new member
      final updatedMembers = [...team.members, 'user_005'];
      final updatedTeam = team.copyWith(
        members: updatedMembers,
        updatedAt: DateTime.now(),
      );

      expect(updatedTeam.members.length, equals(2));
      expect(updatedTeam.members, contains('user_005'));
      expect(updatedTeam.leaders, contains('user_001'));
    });
  });

  group('Critical Flow 3: Task Creation and Assignment', () {
    test('creates task with location and priority', () {
      final task = TaskModel(
        id: 'task_001',
        title: 'Set up emergency medical tent',
        description: 'Establish triage area in town square',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(34.0522, -118.2437), // Los Angeles coordinates
        address: '123 Main St, Los Angeles, CA',
        createdBy: 'user_001',
        assignedTo: 'user_003',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.title, equals('Set up emergency medical tent'));
      expect(task.priority, equals(TaskPriority.high));
      expect(task.status, equals(TaskStatus.pending));
      expect(task.assignedTo, equals('user_003'));
      expect(task.latitude, equals(34.0522));
      expect(task.longitude, equals(-118.2437));
      expect(task.isOverdue, isFalse);
    });

    test('task priority correctly maps to severity levels', () {
      final now = DateTime.now();
      final baseTask = TaskModel(
        id: 'task_base',
        title: 'Base task',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(0, 0),
        createdBy: 'user_001',
        createdAt: now,
        updatedAt: now,
      );

      final lowTask = baseTask.copyWith(priority: TaskPriority.low);
      final mediumTask = baseTask.copyWith(priority: TaskPriority.medium);
      final highTask = baseTask.copyWith(priority: TaskPriority.high);

      // Using deprecated taskSeverity getter for backward compatibility
      expect(lowTask.taskSeverity, equals(2));
      expect(mediumTask.taskSeverity, equals(3));
      expect(highTask.taskSeverity, equals(4));
    });

    test('task status transitions correctly', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: 'task_002',
        title: 'Distribute water supplies',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(0, 0),
        createdBy: 'user_001',
        assignedTo: 'user_004',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.status, equals(TaskStatus.pending));
      expect(task.taskCompleted, isFalse);

      // Simulate status change to completed
      final completedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(completedTask.status, equals(TaskStatus.completed));
      expect(completedTask.taskCompleted, isTrue);
      expect(completedTask.completedAt, isNotNull);
    });

    test('task serialization with all fields', () {
      final task = TaskModel(
        id: 'task_003',
        title: 'Assess structural damage',
        description: 'Evaluate building safety in downtown area',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        teamId: 'team_002',
        geoLocation: GeoPoint(40.7128, -74.0060), // New York coordinates
        address: '456 Broadway, New York, NY',
        createdBy: 'user_002',
        assignedTo: 'user_005',
        dueDate: DateTime(2025, 1, 15, 17, 0),
        createdAt: DateTime(2025, 1, 15, 9, 0),
        updatedAt: DateTime(2025, 1, 15, 9, 0),
      );

      final json = task.toJson();
      final reconstructed = TaskModel.fromJson(json);

      expect(reconstructed.id, equals(task.id));
      expect(reconstructed.title, equals(task.title));
      expect(reconstructed.description, equals(task.description));
      expect(reconstructed.priority, equals(task.priority));
      expect(reconstructed.status, equals(task.status));
      expect(reconstructed.teamId, equals(task.teamId));
      expect(reconstructed.latitude, equals(task.latitude));
      expect(reconstructed.longitude, equals(task.longitude));
      expect(reconstructed.address, equals(task.address));
      expect(reconstructed.assignedTo, equals(task.assignedTo));
    });

    test('handles overdue task detection', () {
      final now = DateTime.now();

      final overdueTask = TaskModel(
        id: 'task_overdue',
        title: 'Overdue task',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(0, 0),
        createdBy: 'user_001',
        dueDate: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      );

      final futureTask = TaskModel(
        id: 'task_future',
        title: 'Future task',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(0, 0),
        createdBy: 'user_001',
        dueDate: now.add(const Duration(hours: 1)),
        createdAt: now,
        updatedAt: now,
      );

      expect(overdueTask.isOverdue, isTrue);
      expect(futureTask.isOverdue, isFalse);
    });
  });

  group('Critical Flow 4: Offline Data Handling', () {
    test('task model handles JSON serialization for offline storage', () {
      final task = TaskModel(
        id: 'offline_task_001',
        title: 'Offline created task',
        description: 'Created without internet connection',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(37.7749, -122.4194), // San Francisco
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate offline storage: convert to JSON
      final json = task.toJson();

      // Verify JSON has all required fields
      expect(json['id'], equals('offline_task_001'));
      expect(json['title'], equals('Offline created task'));
      expect(json['priority'], equals('medium'));
      expect(json['status'], equals('pending'));
      expect(json['geoLocation'], isA<Map>());
      expect(json['geoLocation']['latitude'], equals(37.7749));
      expect(json['geoLocation']['longitude'], equals(-122.4194));

      // Simulate retrieval from offline storage
      final retrieved = TaskModel.fromJson(json);

      expect(retrieved.id, equals(task.id));
      expect(retrieved.title, equals(task.title));
      expect(retrieved.priority, equals(task.priority));
      expect(retrieved.status, equals(task.status));
      expect(retrieved.latitude, equals(task.latitude));
      expect(retrieved.longitude, equals(task.longitude));
    });

    test('team model handles offline serialization', () {
      final team = TeamModel(
        id: 'offline_team_001',
        name: 'Offline Response Team',
        description: 'Created during connectivity outage',
        createdBy: 'user_001',
        teamCode: 'OFFLINE-001',
        members: ['user_001', 'user_002'],
        leaders: ['user_001'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      final json = team.toJson();
      final retrieved = TeamModel.fromJson(json);

      expect(retrieved.id, equals(team.id));
      expect(retrieved.name, equals(team.name));
      expect(retrieved.teamCode, equals(team.teamCode));
      expect(retrieved.members.length, equals(2));
      expect(retrieved.isActive, isTrue);
    });

    test('user model handles offline serialization', () {
      final user = UserModel(
        id: 'offline_user_001',
        email: 'offline@relief.org',
        name: 'Offline User',
        role: 'Medical',
        createdAt: DateTime.now(),
      );

      final json = user.toJson();
      final retrieved = UserModel.fromJson(json);

      expect(retrieved.id, equals(user.id));
      expect(retrieved.email, equals(user.email));
      expect(retrieved.name, equals(user.name));
      expect(retrieved.role, equals(user.role));
    });

    test('handles timestamp preservation for sync ordering', () {
      final createdTime = DateTime(2025, 1, 15, 10, 30, 0);
      final updatedTime = DateTime(2025, 1, 15, 11, 45, 0);

      final task = TaskModel(
        id: 'sync_task_001',
        title: 'Task with precise timestamps',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(0, 0),
        createdBy: 'user_001',
        createdAt: createdTime,
        updatedAt: updatedTime,
      );

      final json = task.toJson();
      final retrieved = TaskModel.fromJson(json);

      // Timestamps should be preserved for proper sync ordering
      expect(retrieved.createdAt, equals(createdTime));
      expect(retrieved.updatedAt, equals(updatedTime));

      // Verify update is newer than creation
      expect(retrieved.updatedAt.isAfter(retrieved.createdAt), isTrue);
    });
  });

  group('Data Integrity and Edge Cases', () {
    test('handles tasks with minimal required fields', () {
      final minimalTask = TaskModel(
        id: 'minimal_001',
        title: 'Minimal task',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(0, 0),
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(minimalTask.id, isNotEmpty);
      expect(minimalTask.title, isNotEmpty);
      expect(minimalTask.description, isNull);
      expect(minimalTask.assignedTo, isNull);
      expect(minimalTask.address, isNull);
      expect(minimalTask.dueDate, isNull);
      expect(minimalTask.completedAt, isNull);
    });

    test('handles tasks with all optional fields populated', () {
      final fullTask = TaskModel(
        id: 'full_001',
        title: 'Comprehensive task',
        description: 'This task has all fields populated',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        teamId: 'team_001',
        geoLocation: GeoPoint(51.5074, -0.1278), // London
        address: '10 Downing St, London, UK',
        createdBy: 'user_001',
        assignedTo: 'user_002',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        completedAt: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      );

      expect(fullTask.id, isNotEmpty);
      expect(fullTask.title, isNotEmpty);
      expect(fullTask.description, isNotNull);
      expect(fullTask.assignedTo, isNotNull);
      expect(fullTask.address, isNotNull);
      expect(fullTask.dueDate, isNotNull);
      expect(fullTask.completedAt, isNotNull);
      expect(fullTask.status, equals(TaskStatus.completed));
    });

    test('validates GeoPoint coordinates are within valid range', () {
      // Valid coordinates
      final validTask = TaskModel(
        id: 'geo_valid',
        title: 'Valid location',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        teamId: 'team_001',
        geoLocation: GeoPoint(45.5017, -73.5673), // Montreal
        createdBy: 'user_001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(validTask.latitude, greaterThanOrEqualTo(-90));
      expect(validTask.latitude, lessThanOrEqualTo(90));
      expect(validTask.longitude, greaterThanOrEqualTo(-180));
      expect(validTask.longitude, lessThanOrEqualTo(180));
    });
  });
}
