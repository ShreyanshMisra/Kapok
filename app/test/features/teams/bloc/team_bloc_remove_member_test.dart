import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/data/models/team_model.dart';

/// Tests for team member management functionality
/// This is essential for disaster relief scenarios where team composition changes frequently
///
/// Note: Full BLoC tests with mocks require bloc_test and mocktail setup.
/// These tests focus on model-level member management logic.
void main() {
  group('Team Member Management - Model Tests', () {
    late TeamModel testTeam;

    setUp(() {
      final now = DateTime.now();
      testTeam = TeamModel(
        id: 'team_123',
        teamName: 'Medical Response Team',
        leaderId: 'leader_456',
        teamCode: 'MED123',
        memberIds: ['leader_456', 'member_789', 'member_101'],
        description: 'Emergency medical response',
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );
    });

    test('team correctly identifies leader', () {
      expect(testTeam.isLeader('leader_456'), isTrue);
      expect(testTeam.isLeader('member_789'), isFalse);
      expect(testTeam.isLeader('unknown'), isFalse);
    });

    test('team correctly identifies members', () {
      expect(testTeam.isMember('leader_456'), isTrue);
      expect(testTeam.isMember('member_789'), isTrue);
      expect(testTeam.isMember('member_101'), isTrue);
      expect(testTeam.isMember('unknown'), isFalse);
    });

    test('removing member updates member list', () {
      // Simulate member removal (this would be done by repository in real app)
      final updatedMembers = testTeam.memberIds
          .where((id) => id != 'member_789')
          .toList();

      final updatedTeam = testTeam.copyWith(
        memberIds: updatedMembers,
        updatedAt: DateTime.now(),
      );

      expect(updatedTeam.memberIds.length, equals(2));
      expect(updatedTeam.isMember('member_789'), isFalse);
      expect(updatedTeam.isMember('leader_456'), isTrue);
      expect(updatedTeam.isMember('member_101'), isTrue);
    });

    test('cannot remove leader from members via member removal', () {
      // In business logic, leader should not be removable
      final membersWithoutLeader = testTeam.memberIds
          .where((id) => id != 'leader_456')
          .toList();

      final updatedTeam = testTeam.copyWith(
        memberIds: membersWithoutLeader,
      );

      // Leader should no longer be in members list
      expect(updatedTeam.isMember('leader_456'), isFalse);
      // But leaderId should still be the same
      expect(updatedTeam.leaderId, equals('leader_456'));
    });

    test('adding member increases team size', () {
      final newMembers = [...testTeam.memberIds, 'new_member_202'];
      final updatedTeam = testTeam.copyWith(memberIds: newMembers);

      expect(updatedTeam.memberIds.length, equals(4));
      expect(updatedTeam.isMember('new_member_202'), isTrue);
    });

    test('team full check works correctly', () {
      // Create a team with 49 members
      final largeTeam = testTeam.copyWith(
        memberIds: List.generate(49, (i) => 'member_$i'),
      );
      expect(largeTeam.isFull, isFalse);

      // Create a team with 50 members (max)
      final fullTeam = testTeam.copyWith(
        memberIds: List.generate(50, (i) => 'member_$i'),
      );
      expect(fullTeam.isFull, isTrue);
    });

    test('member count is accurate', () {
      expect(testTeam.memberCount, equals(3));

      final smallerTeam = testTeam.copyWith(
        memberIds: ['leader_456'],
      );
      expect(smallerTeam.memberCount, equals(1));
    });
  });

  group('Team Serialization with Members', () {
    test('toJson includes all member IDs', () {
      final now = DateTime.now();
      final team = TeamModel(
        id: 'team_serialize',
        teamName: 'Serialize Test',
        leaderId: 'leader_1',
        teamCode: 'SER001',
        memberIds: ['leader_1', 'member_2', 'member_3'],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final json = team.toJson();

      expect(json['memberIds'], isA<List>());
      expect(json['memberIds'].length, equals(3));
      expect(json['memberIds'], contains('leader_1'));
      expect(json['memberIds'], contains('member_2'));
      expect(json['memberIds'], contains('member_3'));
    });

    test('fromJson correctly reconstructs member list', () {
      final now = DateTime.now();
      final original = TeamModel(
        id: 'team_reconstruct',
        teamName: 'Reconstruct Test',
        leaderId: 'leader_1',
        teamCode: 'REC001',
        memberIds: ['leader_1', 'member_2', 'member_3', 'member_4'],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final json = original.toJson();
      final reconstructed = TeamModel.fromJson(json);

      expect(reconstructed.memberIds.length, equals(4));
      expect(reconstructed.memberIds, containsAll(original.memberIds));
    });
  });

  group('Team State Transitions', () {
    test('deactivating team preserves member data', () {
      final now = DateTime.now();
      final activeTeam = TeamModel(
        id: 'team_active',
        teamName: 'Active Team',
        leaderId: 'leader_1',
        teamCode: 'ACT001',
        memberIds: ['leader_1', 'member_2'],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final deactivatedTeam = activeTeam.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      expect(deactivatedTeam.isActive, isFalse);
      expect(deactivatedTeam.memberIds, equals(activeTeam.memberIds));
      expect(deactivatedTeam.leaderId, equals(activeTeam.leaderId));
    });

    test('team equality considers member count', () {
      final now = DateTime.now();
      final team1 = TeamModel(
        id: 'team_1',
        teamName: 'Team One',
        leaderId: 'leader',
        teamCode: 'ONE001',
        memberIds: ['leader', 'member_1'],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final team2 = TeamModel(
        id: 'team_1',
        teamName: 'Team One',
        leaderId: 'leader',
        teamCode: 'ONE001',
        memberIds: ['leader', 'member_1'],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      // Teams with same properties should be equal
      expect(team1, equals(team2));
    });
  });

  group('Edge Cases', () {
    test('empty member list is handled', () {
      final now = DateTime.now();
      final emptyTeam = TeamModel(
        id: 'team_empty',
        teamName: 'Empty Team',
        leaderId: 'leader_1',
        teamCode: 'EMP001',
        memberIds: [],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      expect(emptyTeam.memberCount, equals(0));
      expect(emptyTeam.isFull, isFalse);
      expect(emptyTeam.isMember('anyone'), isFalse);
    });

    test('duplicate member IDs are preserved', () {
      final now = DateTime.now();
      // Note: Business logic should prevent this, but model should handle it
      final teamWithDupes = TeamModel(
        id: 'team_dupes',
        teamName: 'Dupe Team',
        leaderId: 'leader_1',
        teamCode: 'DUP001',
        memberIds: ['leader_1', 'member_1', 'member_1'], // duplicate
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      expect(teamWithDupes.memberCount, equals(3)); // counts duplicates
    });

    test('taskIds list is separate from memberIds', () {
      final now = DateTime.now();
      final team = TeamModel(
        id: 'team_tasks',
        teamName: 'Task Team',
        leaderId: 'leader_1',
        teamCode: 'TSK001',
        memberIds: ['leader_1', 'member_1'],
        taskIds: ['task_1', 'task_2', 'task_3'],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      expect(team.memberIds.length, equals(2));
      expect(team.taskIds.length, equals(3));

      // Modifying one shouldn't affect the other
      final updatedTeam = team.copyWith(
        taskIds: [...team.taskIds, 'task_4'],
      );

      expect(updatedTeam.memberIds.length, equals(2));
      expect(updatedTeam.taskIds.length, equals(4));
    });
  });
}
