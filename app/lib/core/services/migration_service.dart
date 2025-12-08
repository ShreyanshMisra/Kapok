import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';
import '../enums/user_role.dart';

/// Service for migrating data from old model structures to new ones
class MigrationService {
  static final MigrationService instance = MigrationService._();
  MigrationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrate all users from old structure to new structure
  Future<void> migrateAllUsers() async {
    try {
      Logger.info('=== STARTING USER MIGRATION ===');

      final usersSnapshot = await _firestore.collection('users').get();
      int migratedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      Logger.info('Found ${usersSnapshot.docs.length} users to process');

      for (final doc in usersSnapshot.docs) {
        try {
          final data = doc.data();
          bool needsMigration = false;
          final updates = <String, dynamic>{};

          // Check if has old accountType instead of userRole
          if (data.containsKey('accountType') && !data.containsKey('userRole')) {
            final accountType = data['accountType'] as String;
            final userRole = _convertAccountTypeToUserRole(accountType);
            updates['userRole'] = userRole;
            needsMigration = true;
            Logger.info(
              'Migrating user ${doc.id}: accountType "$accountType" -> userRole "$userRole"',
            );
          }

          // Ensure userRole exists (default to teamMember if missing)
          if (!data.containsKey('userRole') && !updates.containsKey('userRole')) {
            updates['userRole'] = UserRole.teamMember.value;
            needsMigration = true;
            Logger.info('User ${doc.id}: Adding default userRole "${UserRole.teamMember.value}"');
          }

          // Convert string timestamps to Firestore Timestamps
          if (data['createdAt'] is String) {
            try {
              final dateTime = DateTime.parse(data['createdAt'] as String);
              updates['createdAt'] = Timestamp.fromDate(dateTime);
              needsMigration = true;
              Logger.info('User ${doc.id}: Converting createdAt from string to Timestamp');
            } catch (e) {
              Logger.warning('User ${doc.id}: Failed to parse createdAt: $e');
            }
          }
          if (data['updatedAt'] is String) {
            try {
              final dateTime = DateTime.parse(data['updatedAt'] as String);
              updates['updatedAt'] = Timestamp.fromDate(dateTime);
              needsMigration = true;
              Logger.info('User ${doc.id}: Converting updatedAt from string to Timestamp');
            } catch (e) {
              Logger.warning('User ${doc.id}: Failed to parse updatedAt: $e');
            }
          }
          if (data['lastActiveAt'] is String) {
            try {
              final dateTime = DateTime.parse(data['lastActiveAt'] as String);
              updates['lastActiveAt'] = Timestamp.fromDate(dateTime);
              needsMigration = true;
              Logger.info('User ${doc.id}: Converting lastActiveAt from string to Timestamp');
            } catch (e) {
              Logger.warning('User ${doc.id}: Failed to parse lastActiveAt: $e');
            }
          }

          // Ensure required fields exist
          if (!data.containsKey('role')) {
            updates['role'] = ''; // Empty specialty role
            needsMigration = true;
            Logger.info('User ${doc.id}: Adding default role field');
          }

          // Apply updates if needed
          if (needsMigration) {
            await doc.reference.update(updates);

            // If accountType existed, need to delete it (requires separate operation)
            if (data.containsKey('accountType')) {
              await doc.reference.update({
                'accountType': FieldValue.delete(),
              });
              Logger.info('User ${doc.id}: Deleted old accountType field');
            }

            migratedCount++;
            Logger.info('✅ Migrated user: ${doc.id}');
          } else {
            skippedCount++;
          }
        } catch (e) {
          errorCount++;
          Logger.error('❌ Failed to migrate user ${doc.id}', error: e);
        }
      }

      Logger.info('=== USER MIGRATION COMPLETE ===');
      Logger.info('Migrated: $migratedCount, Skipped: $skippedCount, Errors: $errorCount');
    } catch (e) {
      Logger.error('User migration failed', error: e);
      rethrow;
    }
  }

  /// Migrate all teams to include taskIds field and fix field names
  Future<void> migrateAllTeams() async {
    try {
      Logger.info('=== STARTING TEAM MIGRATION ===');

      final teamsSnapshot = await _firestore.collection('teams').get();
      int migratedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      Logger.info('Found ${teamsSnapshot.docs.length} teams to process');

      for (final doc in teamsSnapshot.docs) {
        try {
          final data = doc.data();
          final updates = <String, dynamic>{};
          bool needsMigration = false;

          // Add taskIds field if missing
          if (!data.containsKey('taskIds')) {
            // Find all tasks for this team
            final tasksSnapshot = await _firestore
                .collection('tasks')
                .where('teamId', isEqualTo: doc.id)
                .get();

            final taskIds = tasksSnapshot.docs.map((task) => task.id).toList();
            updates['taskIds'] = taskIds;
            needsMigration = true;

            Logger.info(
              'Team ${doc.id}: Adding taskIds field with ${taskIds.length} tasks',
            );
          }

          // Convert old 'name' field to 'teamName'
          if (data.containsKey('name') && !data.containsKey('teamName')) {
            updates['teamName'] = data['name'];
            needsMigration = true;
            Logger.info('Team ${doc.id}: Converting "name" to "teamName"');
          }

          // Ensure isActive field exists
          if (!data.containsKey('isActive')) {
            updates['isActive'] = true;
            needsMigration = true;
            Logger.info('Team ${doc.id}: Adding default isActive field');
          }

          // Convert string timestamps
          if (data['createdAt'] is String) {
            try {
              final dateTime = DateTime.parse(data['createdAt'] as String);
              updates['createdAt'] = Timestamp.fromDate(dateTime);
              needsMigration = true;
              Logger.info('Team ${doc.id}: Converting createdAt from string to Timestamp');
            } catch (e) {
              Logger.warning('Team ${doc.id}: Failed to parse createdAt: $e');
            }
          }
          if (data['updatedAt'] is String) {
            try {
              final dateTime = DateTime.parse(data['updatedAt'] as String);
              updates['updatedAt'] = Timestamp.fromDate(dateTime);
              needsMigration = true;
              Logger.info('Team ${doc.id}: Converting updatedAt from string to Timestamp');
            } catch (e) {
              Logger.warning('Team ${doc.id}: Failed to parse updatedAt: $e');
            }
          }

          if (needsMigration) {
            await doc.reference.update(updates);

            // Delete old 'name' field if it existed
            if (data.containsKey('name') && !updates.containsKey('name')) {
              await doc.reference.update({'name': FieldValue.delete()});
              Logger.info('Team ${doc.id}: Deleted old "name" field');
            }

            migratedCount++;
            Logger.info('✅ Migrated team: ${doc.id}');
          } else {
            skippedCount++;
          }
        } catch (e) {
          errorCount++;
          Logger.error('❌ Failed to migrate team ${doc.id}', error: e);
        }
      }

      Logger.info('=== TEAM MIGRATION COMPLETE ===');
      Logger.info('Migrated: $migratedCount, Skipped: $skippedCount, Errors: $errorCount');
    } catch (e) {
      Logger.error('Team migration failed', error: e);
      rethrow;
    }
  }

  /// Migrate all tasks to ensure proper structure
  Future<void> migrateAllTasks() async {
    try {
      Logger.info('=== STARTING TASK MIGRATION ===');

      final tasksSnapshot = await _firestore.collection('tasks').get();
      int migratedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      Logger.info('Found ${tasksSnapshot.docs.length} tasks to process');

      for (final doc in tasksSnapshot.docs) {
        try {
          final data = doc.data();
          final updates = <String, dynamic>{};
          bool needsMigration = false;

          // Convert old field names to new ones
          if (data.containsKey('taskName') && !data.containsKey('title')) {
            updates['title'] = data['taskName'];
            needsMigration = true;
            Logger.info('Task ${doc.id}: Converting "taskName" to "title"');
          }

          if (data.containsKey('taskDescription') &&
              !data.containsKey('description')) {
            updates['description'] = data['taskDescription'];
            needsMigration = true;
            Logger.info('Task ${doc.id}: Converting "taskDescription" to "description"');
          }

          // Convert latitude/longitude to geoLocation if needed
          if (data.containsKey('latitude') &&
              data.containsKey('longitude') &&
              !data.containsKey('geoLocation')) {
            final lat = (data['latitude'] as num).toDouble();
            final lng = (data['longitude'] as num).toDouble();
            updates['geoLocation'] = GeoPoint(lat, lng);
            needsMigration = true;
            Logger.info('Task ${doc.id}: Converting latitude/longitude to geoLocation');
          }

          // Convert taskSeverity to priority if needed
          if (data.containsKey('taskSeverity') && !data.containsKey('priority')) {
            final severity = data['taskSeverity'] as int;
            String priority;
            if (severity <= 2) {
              priority = 'low';
            } else if (severity <= 3) {
              priority = 'medium';
            } else {
              priority = 'high';
            }
            updates['priority'] = priority;
            needsMigration = true;
            Logger.info('Task ${doc.id}: Converting taskSeverity to priority');
          }

          // Convert taskCompleted to status if needed
          if (data.containsKey('taskCompleted') && !data.containsKey('status')) {
            final completed = data['taskCompleted'] as bool;
            updates['status'] = completed ? 'completed' : 'pending';
            needsMigration = true;
            Logger.info('Task ${doc.id}: Converting taskCompleted to status');
          }

          // Convert string timestamps
          if (data['createdAt'] is String) {
            try {
              final dateTime = DateTime.parse(data['createdAt'] as String);
              updates['createdAt'] = Timestamp.fromDate(dateTime);
              needsMigration = true;
            } catch (e) {
              Logger.warning('Task ${doc.id}: Failed to parse createdAt: $e');
            }
          }
          if (data['updatedAt'] is String) {
            try {
              final dateTime = DateTime.parse(data['updatedAt'] as String);
              updates['updatedAt'] = Timestamp.fromDate(dateTime);
              needsMigration = true;
            } catch (e) {
              Logger.warning('Task ${doc.id}: Failed to parse updatedAt: $e');
            }
          }

          if (needsMigration) {
            await doc.reference.update(updates);

            // Delete old fields if they existed
            if (data.containsKey('taskName')) {
              await doc.reference.update({'taskName': FieldValue.delete()});
            }
            if (data.containsKey('taskDescription')) {
              await doc.reference.update({'taskDescription': FieldValue.delete()});
            }
            if (data.containsKey('taskSeverity')) {
              await doc.reference.update({'taskSeverity': FieldValue.delete()});
            }
            if (data.containsKey('taskCompleted')) {
              await doc.reference.update({'taskCompleted': FieldValue.delete()});
            }
            if (data.containsKey('latitude')) {
              await doc.reference.update({
                'latitude': FieldValue.delete(),
                'longitude': FieldValue.delete(),
              });
            }

            migratedCount++;
            Logger.info('✅ Migrated task: ${doc.id}');
          } else {
            skippedCount++;
          }
        } catch (e) {
          errorCount++;
          Logger.error('❌ Failed to migrate task ${doc.id}', error: e);
        }
      }

      Logger.info('=== TASK MIGRATION COMPLETE ===');
      Logger.info('Migrated: $migratedCount, Skipped: $skippedCount, Errors: $errorCount');
    } catch (e) {
      Logger.error('Task migration failed', error: e);
      rethrow;
    }
  }

  /// Run all migrations
  Future<void> runAllMigrations() async {
    Logger.info('========================================');
    Logger.info('=== STARTING FULL DATA MIGRATION ===');
    Logger.info('========================================');

    try {
      await migrateAllUsers();
      await migrateAllTeams();
      await migrateAllTasks();

      Logger.info('========================================');
      Logger.info('=== MIGRATION COMPLETE ===');
      Logger.info('========================================');
    } catch (e) {
      Logger.error('=== MIGRATION FAILED ===', error: e);
      rethrow;
    }
  }

  /// Convert old accountType string to UserRole enum value
  String _convertAccountTypeToUserRole(String accountType) {
    final normalized = accountType.toLowerCase().replaceAll(' ', '');

    if (normalized.contains('leader')) {
      return UserRole.teamLeader.value;
    }
    if (normalized.contains('member')) {
      return UserRole.teamMember.value;
    }
    if (normalized.contains('admin')) {
      return UserRole.admin.value;
    }

    // Default to teamMember
    return UserRole.teamMember.value;
  }
}

