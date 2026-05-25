import 'package:flutter_test/flutter_test.dart';
import 'package:kapok_app/core/enums/user_role.dart';
import 'package:kapok_app/data/models/user_model.dart';

void main() {
  group('UserModel JSON', () {
    final base = UserModel(
      id: 'u1',
      name: 'Alice Tester',
      email: 'alice@example.com',
      userRole: UserRole.teamLeader,
      role: 'Medical',
      teamId: 'team-42',
      createdAt: DateTime.utc(2026, 1, 1, 12),
      updatedAt: DateTime.utc(2026, 1, 2, 12),
      lastActiveAt: DateTime.utc(2026, 1, 3, 12),
    );

    test('toJson serializes userRole as its string value', () {
      final json = base.toJson();
      expect(json['userRole'], 'teamLeader');
      expect(json['id'], 'u1');
      expect(json['teamId'], 'team-42');
    });

    test('round-trips through toJson / fromJson', () {
      final restored = UserModel.fromJson(base.toJson());
      expect(restored, base);
      expect(restored.userRole, UserRole.teamLeader);
      expect(restored.lastActiveAt, base.lastActiveAt);
    });

    test('fromJson tolerates unknown userRole strings via fallback', () {
      final json = {...base.toJson(), 'userRole': 'guest'};
      final restored = UserModel.fromJson(json);
      expect(restored.userRole, UserRole.teamMember,
          reason: 'unknown roles must fall back, never crash');
    });
  });

  group('UserModel equality', () {
    final a = UserModel(
      id: 'u1',
      name: 'A',
      email: 'a@example.com',
      userRole: UserRole.teamMember,
      role: 'Other',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final b = a.copyWith(name: 'A');
    final c = a.copyWith(name: 'B');

    test('equal when identifying fields match', () {
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('not equal when any identifying field differs', () {
      expect(a, isNot(c));
    });

    test('copyWith preserves untouched fields', () {
      final updated = a.copyWith(userRole: UserRole.admin);
      expect(updated.userRole, UserRole.admin);
      expect(updated.id, a.id);
      expect(updated.email, a.email);
    });
  });
}
