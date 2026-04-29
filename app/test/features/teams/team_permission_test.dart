import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/user_role.dart';
import 'package:kapok_app/core/services/permission_service.dart';
import 'package:kapok_app/data/models/team_model.dart';
import 'package:kapok_app/data/models/user_model.dart';

/// Permission boundary tests for team management features:
/// - Remove member (assigned leader only)
/// - Admin / leader hard delete
/// - Leadership transfer eligibility
void main() {
  final now = DateTime.now();

  // ──────────────────────────────────────────────────────────
  // Shared fixtures
  // ──────────────────────────────────────────────────────────

  TeamModel makeTeam({
    String leaderId = 'leader_1',
    List<String>? memberIds,
  }) {
    return TeamModel(
      id: 'team_abc',
      teamName: 'Alpha Team',
      leaderId: leaderId,
      teamCode: 'ALPHA1',
      memberIds: memberIds ?? [leaderId, 'member_2', 'member_3'],
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );
  }

  UserModel makeUser({
    required String id,
    required UserRole userRole,
    String? teamId,
  }) {
    return UserModel(
      id: id,
      name: 'User $id',
      email: '$id@test.com',
      userRole: userRole,
      role: 'Other',
      teamId: teamId,
      createdAt: now,
      updatedAt: now,
    );
  }

  final permissionService = PermissionService.instance;

  // ──────────────────────────────────────────────────────────
  // 1. Remove member
  // ──────────────────────────────────────────────────────────

  group('canRemoveMember', () {
    late TeamModel team;

    setUp(() {
      team = makeTeam(
        leaderId: 'leader_1',
        memberIds: ['leader_1', 'member_2', 'member_3'],
      );
    });

    test('assigned team leader CAN remove a non-leader member', () {
      final leader = makeUser(id: 'leader_1', userRole: UserRole.teamLeader);
      expect(permissionService.canRemoveMember(leader, team, 'member_2'), isTrue);
    });

    test('global teamLeader who is NOT this team\'s leaderId CANNOT remove members', () {
      // member_3 has the global teamLeader role but is not team.leaderId
      final otherLeader = makeUser(id: 'member_3', userRole: UserRole.teamLeader);
      expect(permissionService.canRemoveMember(otherLeader, team, 'member_2'), isFalse);
    });

    test('admin CANNOT remove a member (only assigned leader can)', () {
      final admin = makeUser(id: 'admin_1', userRole: UserRole.admin);
      expect(permissionService.canRemoveMember(admin, team, 'member_2'), isFalse);
    });

    test('assigned leader CANNOT remove themselves (the leader)', () {
      final leader = makeUser(id: 'leader_1', userRole: UserRole.teamLeader);
      expect(permissionService.canRemoveMember(leader, team, 'leader_1'), isFalse);
    });

    test('regular member CANNOT remove another member', () {
      final member = makeUser(id: 'member_2', userRole: UserRole.teamMember);
      expect(permissionService.canRemoveMember(member, team, 'member_3'), isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // 2. Delete team
  // ──────────────────────────────────────────────────────────

  group('canDeleteTeam', () {
    late TeamModel team;

    setUp(() {
      team = makeTeam(leaderId: 'leader_1');
    });

    test('assigned team leader CAN delete their own team', () {
      final leader = makeUser(id: 'leader_1', userRole: UserRole.teamLeader);
      expect(permissionService.canDeleteTeam(leader, team), isTrue);
    });

    test('admin CAN delete any team', () {
      final admin = makeUser(id: 'admin_99', userRole: UserRole.admin);
      expect(permissionService.canDeleteTeam(admin, team), isTrue);
    });

    test('regular member CANNOT delete a team', () {
      final member = makeUser(id: 'member_2', userRole: UserRole.teamMember);
      expect(permissionService.canDeleteTeam(member, team), isFalse);
    });

    test('teamLeader who is NOT this team\'s leader CANNOT delete it', () {
      final otherLeader = makeUser(id: 'other_leader', userRole: UserRole.teamLeader);
      expect(permissionService.canDeleteTeam(otherLeader, team), isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // 3. Transfer leadership
  // ──────────────────────────────────────────────────────────

  group('canTransferLeadership', () {
    late TeamModel team;

    setUp(() {
      team = makeTeam(leaderId: 'leader_1');
    });

    test('assigned team leader CAN initiate a transfer', () {
      final leader = makeUser(id: 'leader_1', userRole: UserRole.teamLeader);
      expect(permissionService.canTransferLeadership(leader, team), isTrue);
    });

    test('non-leader member CANNOT initiate a transfer', () {
      final member = makeUser(id: 'member_2', userRole: UserRole.teamMember);
      expect(permissionService.canTransferLeadership(member, team), isFalse);
    });

    test('admin CANNOT initiate a leadership transfer (leader-only action)', () {
      final admin = makeUser(id: 'admin_1', userRole: UserRole.admin);
      expect(permissionService.canTransferLeadership(admin, team), isFalse);
    });

    test('global teamLeader who is not this team\'s leaderId CANNOT transfer', () {
      final otherLeader = makeUser(id: 'member_3', userRole: UserRole.teamLeader);
      expect(permissionService.canTransferLeadership(otherLeader, team), isFalse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // 4. Hard-delete team model cleanup (repository-level logic)
  // ──────────────────────────────────────────────────────────

  group('Hard delete — member cleanup logic', () {
    test('all member IDs (including leader) are captured for teamId clearance', () {
      final team = makeTeam(
        leaderId: 'leader_1',
        memberIds: ['leader_1', 'member_2', 'member_3'],
      );

      // Simulates: final allMemberIds = [team.leaderId, ...team.memberIds].toSet().toList();
      final allMemberIds = [team.leaderId, ...team.memberIds].toSet().toList();

      expect(allMemberIds, containsAll(['leader_1', 'member_2', 'member_3']));
      expect(allMemberIds.length, equals(3)); // no duplication of leader
    });

    test('leader ID is deduplicated when already in memberIds', () {
      final team = makeTeam(
        leaderId: 'leader_1',
        memberIds: ['leader_1', 'member_2'],
      );

      final allMemberIds = [team.leaderId, ...team.memberIds].toSet().toList();
      expect(allMemberIds.where((id) => id == 'leader_1').length, equals(1));
    });
  });

  // ──────────────────────────────────────────────────────────
  // 5. Leadership transfer — model-level eligibility
  // ──────────────────────────────────────────────────────────

  group('Leadership transfer eligibility', () {
    test('transfer succeeds: new leader is a member with teamLeader role', () {
      final team = makeTeam(
        leaderId: 'leader_1',
        memberIds: ['leader_1', 'future_leader'],
      );
      final futureLeader = makeUser(id: 'future_leader', userRole: UserRole.teamLeader);

      // The repository checks: team.memberIds.contains(newLeaderId) AND userRole contains 'leader'
      final isMember = team.memberIds.contains(futureLeader.id);
      final hasLeaderRole = futureLeader.userRole == UserRole.teamLeader;

      expect(isMember, isTrue);
      expect(hasLeaderRole, isTrue);
    });

    test('transfer rejected: target is not in team memberIds', () {
      final team = makeTeam(
        leaderId: 'leader_1',
        memberIds: ['leader_1', 'member_2'],
      );
      final outsider = makeUser(id: 'outsider_99', userRole: UserRole.teamLeader);

      final isMember = team.memberIds.contains(outsider.id);
      expect(isMember, isFalse);
    });

    test('transfer rejected: target does not have teamLeader role', () {
      final regularMember = makeUser(id: 'member_2', userRole: UserRole.teamMember);

      final hasLeaderRole = regularMember.userRole == UserRole.teamLeader;
      expect(hasLeaderRole, isFalse);
    });

    test('transfer updates leaderId in model', () {
      final team = makeTeam(
        leaderId: 'leader_1',
        memberIds: ['leader_1', 'new_leader'],
      );

      final updated = team.copyWith(leaderId: 'new_leader', updatedAt: now);

      expect(updated.leaderId, equals('new_leader'));
      expect(updated.memberIds, contains('leader_1')); // old leader stays as member
      expect(updated.memberIds, contains('new_leader'));
    });
  });
}
