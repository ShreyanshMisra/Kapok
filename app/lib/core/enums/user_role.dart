import '../utils/logger.dart';

/// User role enum for permission management
enum UserRole {
  teamLeader('teamLeader', 'Team Leader'),
  teamMember('teamMember', 'Team Member'),
  admin('admin', 'Admin');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  static UserRole fromString(String? value) {
    if (value == null || value.isEmpty) {
      Logger.debug(
        'UserRole.fromString: null or empty input, defaulting to teamMember',
      );
      return UserRole.teamMember;
    }

    // Normalize the value to lowercase for case-insensitive matching
    final normalizedValue = value.toLowerCase();
    Logger.debug(
      'UserRole.fromString: input="$value", normalized="$normalizedValue"',
    );

    // Try exact match first (case-insensitive)
    for (final role in UserRole.values) {
      if (role.value.toLowerCase() == normalizedValue) {
        Logger.debug('UserRole.fromString: exact match found: ${role.value}');
        return role;
      }
    }

    // If exact match fails, try matching against common variations
    if (normalizedValue == 'teamleader' ||
        normalizedValue == 'team_leader' ||
        normalizedValue.contains('leader')) {
      Logger.debug(
        'UserRole.fromString: matched leader variation, returning teamLeader',
      );
      return UserRole.teamLeader;
    } else if (normalizedValue == 'teammember' ||
        normalizedValue == 'team_member' ||
        normalizedValue.contains('member')) {
      Logger.debug(
        'UserRole.fromString: matched member variation, returning teamMember',
      );
      return UserRole.teamMember;
    } else if (normalizedValue == 'admin' ||
        normalizedValue.contains('admin')) {
      Logger.debug(
        'UserRole.fromString: matched admin variation, returning admin',
      );
      return UserRole.admin;
    }

    // Default fallback
    Logger.warning(
      'UserRole.fromString: no match found for "$value", defaulting to teamMember',
    );
    return UserRole.teamMember;
  }
}
