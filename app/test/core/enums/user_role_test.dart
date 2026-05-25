import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/user_role.dart';

void main() {
  group('UserRole', () {
    test('round-trips through value', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromString(role.value), role);
      }
    });

    test('case-insensitive exact match', () {
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('TeamLeader'), UserRole.teamLeader);
      expect(UserRole.fromString('teammember'), UserRole.teamMember);
    });

    test('tolerates legacy underscored variants', () {
      expect(UserRole.fromString('team_leader'), UserRole.teamLeader);
      expect(UserRole.fromString('team_member'), UserRole.teamMember);
    });

    test('matches substrings as a last resort', () {
      expect(UserRole.fromString('SUPERADMIN'), UserRole.admin);
      expect(UserRole.fromString('squad-leader'), UserRole.teamLeader);
      expect(UserRole.fromString('crew member'), UserRole.teamMember);
    });

    test('defaults to teamMember for null, empty, or unknown', () {
      expect(UserRole.fromString(null), UserRole.teamMember);
      expect(UserRole.fromString(''), UserRole.teamMember);
      expect(UserRole.fromString('viewer'), UserRole.teamMember);
    });

    test('has stable display names', () {
      expect(UserRole.admin.displayName, 'Admin');
      expect(UserRole.teamLeader.displayName, 'Team Leader');
      expect(UserRole.teamMember.displayName, 'Team Member');
    });
  });
}
