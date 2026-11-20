import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/network_checker.dart';
import '../../core/utils/logger.dart';
import '../models/task_model.dart';
import '../models/team_model.dart';
import '../models/user_model.dart';
import '../sources/firebase_source.dart';
import '../sources/hive_source.dart';

/// Repository for team operations with permission checks
class TeamRepository {
  final FirebaseSource _firebaseSource;
  final HiveSource _hiveSource;
  final NetworkChecker _networkChecker;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TeamRepository({
    required FirebaseSource firebaseSource,
    required HiveSource hiveSource,
    required NetworkChecker networkChecker,
  }) : _firebaseSource = firebaseSource,
       _hiveSource = hiveSource,
       _networkChecker = networkChecker;

  /// Create a new team with secure code generation and uniqueness verification
  Future<TeamModel> createTeam({
    required String teamName,
    required String leaderId,
    String? description,
  }) async {
    try {
      Logger.team('Creating team: $teamName for leader: $leaderId');

      // Generate unique team code (up to 5 attempts)
      String teamCode = '';
      int attempts = 0;
      bool isUnique = false;

      try {
        Logger.team('Generating unique team code...');
        while (!isUnique && attempts < 5) {
          teamCode = FirebaseSource.generateTeamCode();
          Logger.team(
            'Generated team code: $teamCode (attempt ${attempts + 1}/5)',
          );

          // Verify uniqueness in Firestore
          if (await _networkChecker.isConnected()) {
            try {
              isUnique = !await _firebaseSource.isTeamCodeTaken(teamCode);
              if (!isUnique) {
                Logger.team(
                  'Team code $teamCode already exists, regenerating...',
                );
              }
            } catch (queryError) {
              Logger.team(
                'Error checking team code uniqueness',
                error: queryError,
              );
              // If query fails, assume unique and continue (will fail later if duplicate)
              isUnique = true;
            }
          } else {
            // Offline: assume unique (will verify on sync)
            Logger.team('Offline mode: assuming team code is unique');
            isUnique = true;
          }

          attempts++;
        }

        if (!isUnique) {
          throw TeamException(
            message: 'Failed to generate unique team code after 5 attempts',
          );
        }
        Logger.team('Unique team code generated: $teamCode');
      } catch (e) {
        Logger.team('Error during team code generation', error: e);
        if (e is TeamException) {
          rethrow;
        }
        throw TeamException(
          message: 'Failed to generate team code: ${e.toString()}',
          originalError: e,
        );
      }

      // Create team model with proper ID format
      final teamId = 'team_${DateTime.now().millisecondsSinceEpoch}';
      Logger.team('Creating team model with ID: $teamId');
      final team = TeamModel(
        id: teamId,
        teamName: teamName,
        leaderId: leaderId,
        teamCode: teamCode,
        memberIds: [leaderId], // Leader is first member
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      // Always save locally first
      try {
        Logger.team('Saving team to local Hive cache...');
        await _hiveSource.saveTeam(team);
        Logger.team('Team saved to Hive cache successfully');
      } catch (hiveError) {
        Logger.team('Failed to save team to Hive cache', error: hiveError);
        throw TeamException(
          message: 'Failed to save team locally: ${hiveError.toString()}',
          originalError: hiveError,
        );
      }

      if (await _networkChecker.isConnected()) {
        try {
          // Save to Firebase
          Logger.team('Saving team to Firestore: ${team.id}');
          final createdTeam = await _firebaseSource.createTeam(team);
          Logger.team('Team saved to Firestore successfully');

          // Verify team exists in Firebase
          try {
            final verifyTeam = await _firebaseSource.getTeam(team.id);
            Logger.team('VERIFICATION SUCCESS: Team found in Firebase');
            Logger.team('Verified team ID: ${verifyTeam.id}');
            Logger.team('Verified team name: ${verifyTeam.teamName}');
          } catch (verifyError) {
            Logger.team(
              'VERIFICATION FAILED: Team not found in Firebase',
              error: verifyError,
            );
            throw TeamException(
              message:
                  'Team creation verification failed: Team not found in Firebase',
              originalError: verifyError,
            );
          }

          // Update user's teamId in Firestore
          try {
            Logger.team(
              'Updating user teamId in Firestore: $leaderId -> $teamId',
            );
            await _firestore.collection('users').doc(leaderId).update({
              'teamId': teamId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            Logger.team('User teamId updated in Firestore successfully');
          } catch (updateError) {
            Logger.team(
              'Failed to update user teamId in Firestore',
              error: updateError,
            );
            // Try to get the user document first to see if it exists
            final userDoc = await _firestore
                .collection('users')
                .doc(leaderId)
                .get();
            if (!userDoc.exists) {
              Logger.team('User document does not exist, creating it');
              // Create user document if it doesn't exist
              await _firestore.collection('users').doc(leaderId).set({
                'teamId': teamId,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            } else {
              // Re-throw if document exists but update failed
              rethrow;
            }
          }

          // Update user in Hive cache
          final user = await _hiveSource.getUser(leaderId);
          if (user != null) {
            await _hiveSource.saveUser(user.copyWith(teamId: teamId));
            Logger.team('User teamId updated in Hive cache');
          }

          // Update local cache with Firebase data
          await _hiveSource.saveTeam(createdTeam);
          Logger.team('Local cache updated with Firebase data');

          Logger.team('Team created successfully: ${team.id}');
          return createdTeam;
        } catch (e) {
          // Firebase failed, but local save succeeded
          Logger.team('=== FIREBASE SAVE FAILED ===');
          Logger.team('Error type: ${e.runtimeType}');
          Logger.team('Error message: ${e.toString()}');
          Logger.team('Team creation Firebase error details: ${e.toString()}');

          // Check error type
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('permission') ||
              errorString.contains('denied') ||
              errorString.contains('permission-denied')) {
            Logger.team(
              'ERROR: Permission denied - check Firestore security rules',
            );
            // Queue for sync but throw error
            await _hiveSource.queueForSync({
              'operation': 'create_team',
              'type': 'team',
              'data': team.toJson(),
              'timestamp': DateTime.now().toIso8601String(),
            });
            throw TeamException(
              message:
                  'Permission denied: Check Firestore security rules. Team saved locally and will sync when permissions are fixed.',
              originalError: e,
            );
          } else if (errorString.contains('network') ||
              errorString.contains('connection') ||
              errorString.contains('unavailable')) {
            Logger.team('ERROR: Network error - queueing for sync');
            // Queue for sync and return team (offline mode)
            await _hiveSource.queueForSync({
              'operation': 'create_team',
              'type': 'team',
              'data': team.toJson(),
              'timestamp': DateTime.now().toIso8601String(),
            });
            Logger.team(
              'Team queued for sync - will save to Firebase when online',
            );
            return team;
          }

          // For other errors, throw to show user
          Logger.team('ERROR: Unknown error - throwing exception');
          // Still queue for sync
          await _hiveSource.queueForSync({
            'operation': 'create_team',
            'type': 'team',
            'data': team.toJson(),
            'timestamp': DateTime.now().toIso8601String(),
          });

          throw TeamException(
            message:
                'Failed to save team to Firebase: ${e.toString()}. Team saved locally and will sync when online.',
            originalError: e,
          );
        }
      } else {
        // Offline: queue for sync
        await _hiveSource.queueForSync({
          'operation': 'create_team',
          'type': 'team',
          'data': team.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });

        Logger.team('Team created offline: ${team.id}');
        return team;
      }
    } catch (e) {
      Logger.team(
        'Error creating team - caught in outer catch block',
        error: e,
      );
      Logger.team('Error type: ${e.runtimeType}');
      Logger.team('Error message: ${e.toString()}');
      if (e is TeamException) {
        Logger.team('Re-throwing TeamException: ${e.message}');
        rethrow;
      }
      // Wrap any unexpected errors
      final errorMessage = 'Failed to create team: ${e.toString()}';
      Logger.team('Wrapping error as TeamException: $errorMessage');
      throw TeamException(message: errorMessage, originalError: e);
    }
  }

  /// Join a team using its invite code.
  ///
  /// Non-members can't read team documents, so the code is resolved through
  /// `teamCodes/{code}` and the join is written without reading the team.
  /// Security rules check that the caller adds only themselves, that the team
  /// is active with fewer than 50 members, and that `users/{uid}.joinCode`
  /// (written in the same batch) matches the team's code.
  Future<TeamModel> joinTeam({
    required String teamCode,
    required String userId,
  }) async {
    final code = teamCode.trim().toUpperCase();
    Logger.team('Joining team with code: $code for user: $userId');

    if (!await _networkChecker.isConnected()) {
      throw TeamException(message: 'Cannot join team while offline');
    }

    final String? teamId;
    try {
      teamId = await _firebaseSource.lookupTeamIdByCode(code);
    } catch (e) {
      Logger.team('Team code lookup failed', error: e);
      throw TeamException(
        message: 'Network error. Please check your connection and try again.',
        originalError: e,
      );
    }
    if (teamId == null) {
      throw TeamException(message: 'Invalid team code');
    }

    // Only members (and admins) can read a team, so a readable team that
    // lists this user means they've already joined.
    try {
      final existing = await _firebaseSource.getTeam(teamId);
      if (existing.memberIds.contains(userId) || existing.leaderId == userId) {
        throw TeamException(message: 'Already a member of this team');
      }
    } on TeamException {
      rethrow;
    } catch (_) {
      // Not readable yet — expected for a new member.
    }

    try {
      final batch = _firestore.batch();
      batch.update(_firestore.collection('users').doc(userId), {
        'teamId': teamId,
        'joinCode': code,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_firestore.collection('teams').doc(teamId), {
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      Logger.team('Join batch failed: ${e.code}', error: e);
      if (e.code == 'permission-denied') {
        throw TeamException(
          message: 'Could not join this team. It may be closed or full.',
          originalError: e,
        );
      }
      if (e.code == 'not-found') {
        throw TeamException(
          message: 'User account not found. Please contact support.',
          originalError: e,
        );
      }
      throw TeamException(
        message: 'Failed to join team. Please try again.',
        originalError: e,
      );
    }

    final team = await _firebaseSource.getTeam(teamId);
    try {
      await _hiveSource.saveTeam(team);
      final user = await _hiveSource.getUser(userId);
      if (user != null) {
        await _hiveSource.saveUser(user.copyWith(teamId: team.id));
      }
    } catch (cacheError) {
      Logger.team('Joined team but failed to update cache', error: cacheError);
    }

    Logger.team('User joined team successfully: ${team.id}');
    return team;
  }

  /// Leave a team
  Future<void> leaveTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      Logger.team('Leaving team: $teamId');

      if (!await _networkChecker.isConnected()) {
        throw TeamException(message: 'Cannot leave team while offline');
      }

      // Query tasks assigned to this user in this team BEFORE the transaction
      // (Firestore transactions don't support queries)
      final assignedTasksQuery = await _firestore
          .collection('tasks')
          .where('teamId', isEqualTo: teamId)
          .where('assignedTo', isEqualTo: userId)
          .get();

      // Use transaction for atomic update
      await _firestore.runTransaction((transaction) async {
        final teamDoc = await _firestore.collection('teams').doc(teamId).get();

        if (!teamDoc.exists) {
          throw TeamException(message: 'Team not found');
        }

        final team = TeamModel.fromFirestore(teamDoc);

        // Check if user is a member
        if (!team.memberIds.contains(userId)) {
          throw TeamException(message: 'User is not a member of this team');
        }

        // Check if user is the leader
        if (team.leaderId == userId) {
          throw TeamException(message: 'Team leader cannot leave the team');
        }

        // Remove user from team
        transaction.update(teamDoc.reference, {
          'memberIds': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Clear user's teamId
        transaction.update(_firestore.collection('users').doc(userId), {
          'teamId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Unassign tasks that were assigned to the leaving member
        for (final taskDoc in assignedTasksQuery.docs) {
          transaction.update(taskDoc.reference, {
            'assignedTo': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // Update local cache
      final team = await _firebaseSource.getTeam(teamId);
      final updatedTeam = team.copyWith(
        memberIds: team.memberIds.where((id) => id != userId).toList(),
        updatedAt: DateTime.now(),
      );
      await _hiveSource.saveTeam(updatedTeam);

      // Update user in Hive
      final user = await _hiveSource.getUser(userId);
      if (user != null) {
        await _hiveSource.saveUser(user.copyWith(teamId: null));
      }

      Logger.team('User left team successfully');
    } catch (e) {
      Logger.team('Error leaving team', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(message: 'Failed to leave team', originalError: e);
    }
  }

  /// Get teams for a user (or all teams if admin)
  Future<List<TeamModel>> getUserTeams(String userId) async {
    try {
      Logger.team('Getting teams for user: $userId');

      // Get current user to check role
      final user = await _hiveSource.getUser(userId);
      if (user == null) {
        Logger.team('User not found in cache, loading user teams normally');
      } else {
        Logger.team('User role: ${user.userRole.value}');

        // If admin, load ALL teams
        if (user.userRole == UserRole.admin) {
          Logger.team('User is admin, loading all teams');
          return await _getAllTeams();
        }
      }

      List<TeamModel> teams;

      if (await _networkChecker.isConnected()) {
        // Get from Firebase
        teams = await _firebaseSource.getUserTeams(userId);

        // Cache locally
        await _hiveSource.cacheTeams(teams);

        // Teams created before /teamCodes existed can't be joined until their
        // code is indexed; only the leader may do that.
        for (final team in teams.where((t) => t.leaderId == userId)) {
          unawaited(_firebaseSource.ensureTeamCodeIndexed(team));
        }
      } else {
        // Get from local cache
        teams = await _hiveSource.getUserTeams(userId);
      }

      Logger.team('Found ${teams.length} teams for user');
      return teams;
    } catch (e) {
      Logger.team('Error getting user teams', error: e);
      throw TeamException(
        message: 'Failed to get user teams',
        originalError: e,
      );
    }
  }

  /// Get all teams (for admin users)
  Future<List<TeamModel>> _getAllTeams() async {
    try {
      Logger.team('Loading all teams (admin)');

      if (await _networkChecker.isConnected()) {
        try {
          final teams = await _firebaseSource.getAllTeams();
          Logger.team('Firebase getAllTeams returned ${teams.length} teams');

          // Cache locally
          for (final team in teams) {
            await _hiveSource.saveTeam(team);
          }

          Logger.team('Loaded ${teams.length} teams from Firebase');
          if (teams.isEmpty) {
            Logger.team(
              'WARNING: getAllTeams returned empty list - checking local cache',
            );
            // If Firebase returns empty, check local cache as backup
            final localTeams = await _hiveSource.getAllTeams();
            Logger.team('Local cache has ${localTeams.length} teams');
            return localTeams;
          }
          return teams;
        } catch (e) {
          Logger.team(
            'Error loading all teams from Firebase, trying local cache',
            error: e,
          );
          // Fallback to local cache if Firebase fails
          try {
            final teams = await _hiveSource.getAllTeams();
            Logger.team(
              'Loaded ${teams.length} teams from local cache (fallback)',
            );
            return teams;
          } catch (cacheError) {
            Logger.team('Error loading from local cache', error: cacheError);
            // If both fail, throw the original Firebase error
            throw TeamException(
              message: 'Failed to load teams: ${e.toString()}',
              originalError: e,
            );
          }
        }
      } else {
        // Offline: get from local cache (all teams)
        final teams = await _hiveSource.getAllTeams();
        Logger.team('Loaded ${teams.length} teams from local cache (offline)');
        return teams;
      }
    } catch (e) {
      Logger.team('Error loading all teams', error: e);
      // Re-throw to show error in UI
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to load all teams: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get team by ID
  Future<TeamModel> getTeam(String teamId) async {
    try {
      Logger.team('Getting team: $teamId');

      TeamModel? team;

      if (await _networkChecker.isConnected()) {
        // Get from Firebase
        team = await _firebaseSource.getTeam(teamId);

        // Cache locally
        await _hiveSource.saveTeam(team);
      } else {
        // Get from local cache
        team = await _hiveSource.getTeam(teamId);
      }

      if (team == null) {
        throw TeamException(message: 'Team not found');
      }

      return team;
    } catch (e) {
      Logger.team('Error getting team', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(message: 'Failed to get team', originalError: e);
    }
  }

  /// Get team members (users) by team ID
  Future<List<UserModel>> getTeamMembers(String teamId) async {
    try {
      Logger.team('Getting team members: $teamId');

      final team = await getTeam(teamId);

      if (team.memberIds.isEmpty) {
        return [];
      }

      // Member profiles are readable only by teammates, which security rules
      // can check per document but not for a whereIn query, so fetch each doc.
      final List<UserModel> members = [];
      if (await _networkChecker.isConnected()) {
        final docs = await Future.wait(
          team.memberIds.map(
            (id) => _firestore.collection('users').doc(id).get().then<
                DocumentSnapshot<Map<String, dynamic>>?>(
              (doc) => doc,
              onError: (Object e) {
                Logger.team('Could not load member $id', error: e);
                return null;
              },
            ),
          ),
        );
        for (final doc in docs) {
          if (doc != null && doc.exists) {
            final member = UserModel.fromFirestore(doc);
            members.add(member);
            await _hiveSource.saveUser(member);
          }
        }
      } else {
        for (final memberId in team.memberIds) {
          final user = await _hiveSource.getUser(memberId);
          if (user != null) {
            members.add(user);
          }
        }
      }

      Logger.team('Found ${members.length} team members');
      return members;
    } catch (e) {
      Logger.team('Error getting team members', error: e);
      throw TeamException(
        message: 'Failed to get team members',
        originalError: e,
      );
    }
  }

  /// Stream team updates
  Stream<TeamModel> streamTeam(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .snapshots()
        .map((doc) => TeamModel.fromFirestore(doc));
  }

  /// Update team
  Future<TeamModel> updateTeam(TeamModel team) async {
    try {
      Logger.team('Updating team: ${team.id}');

      final updatedTeam = team.copyWith(updatedAt: DateTime.now());

      // Always update local cache first
      await _hiveSource.saveTeam(updatedTeam);

      if (await _networkChecker.isConnected()) {
        try {
          // Update on Firebase
          await _firebaseSource.updateTeam(updatedTeam);

          Logger.team('Team updated successfully');
          return updatedTeam;
        } catch (e) {
          // Firebase failed, but local update succeeded
          Logger.team('Firebase update failed, team updated locally', error: e);

          // Queue for sync
          await _hiveSource.queueForSync({
            'operation': 'update_team',
            'type': 'team',
            'data': updatedTeam.toJson(),
            'timestamp': DateTime.now().toIso8601String(),
          });

          return updatedTeam;
        }
      } else {
        // Offline: queue for sync
        await _hiveSource.queueForSync({
          'operation': 'update_team',
          'type': 'team',
          'data': updatedTeam.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });

        Logger.team('Team updated offline');
        return updatedTeam;
      }
    } catch (e) {
      Logger.team('Error updating team', error: e);
      throw TeamException(message: 'Failed to update team', originalError: e);
    }
  }

  /// Close a team (deactivate)
  Future<void> closeTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      Logger.team('Closing team: $teamId');

      final team = await getTeam(teamId);

      // Check if user is the leader
      if (team.leaderId != userId) {
        throw TeamException(message: 'Only team leader can close the team');
      }

      // Deactivate team
      final updatedTeam = team.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      await updateTeam(updatedTeam);

      Logger.team('Team closed successfully');
    } catch (e) {
      Logger.team('Error closing team', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(message: 'Failed to close team', originalError: e);
    }
  }

  /// Delete a team permanently (only team leader or admin)
  Future<void> deleteTeam({
    required String teamId,
    required String userId,
  }) async {
    try {
      Logger.team('=== STARTING TEAM DELETION ===');
      Logger.team('Team ID: $teamId');
      Logger.team('User ID: $userId');

      if (!await _networkChecker.isConnected()) {
        throw TeamException(message: 'Cannot delete team while offline');
      }

      // Get team and verify it exists
      final team = await getTeam(teamId);
      Logger.team('Team found: ${team.teamName}, Leader: ${team.leaderId}');

      // Get current user to check role
      final currentUser = await _hiveSource.getUser(userId);
      if (currentUser == null) {
        throw TeamException(message: 'User not found');
      }

      // Check if user has permission (leader or admin)
      final isLeader = team.leaderId == userId;
      final isAdmin = currentUser.userRole == UserRole.admin;

      Logger.team(
        'Permission check - Is Leader: $isLeader, Is Admin: $isAdmin',
      );

      if (!isLeader && !isAdmin) {
        throw TeamException(
          message: 'Only team leader or admin can delete the team',
        );
      }

      // Step 1: Clear teamId on each member's user doc while the team still
      // exists (security rules check that the caller leads that team).
      // Individual writes so one failure doesn't block the others.
      final teamRef = _firestore.collection('teams').doc(teamId);
      final allMemberIds = [team.leaderId, ...team.memberIds].toSet().toList();
      Logger.team('Clearing teamId from ${allMemberIds.length} members');
      for (final memberId in allMemberIds) {
        try {
          await _firestore.collection('users').doc(memberId).update({
            'teamId': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (rulesError) {
          Logger.team('Could not clear teamId for user $memberId: $rulesError');
        }
      }

      // Step 2: Delete the team and release its invite code.
      Logger.team('Hard-deleting team document...');
      final batch = _firestore.batch();
      batch.delete(teamRef);
      if (team.teamCode.isNotEmpty) {
        final codeRef = _firestore.collection('teamCodes').doc(team.teamCode);
        final codeDoc = await codeRef.get();
        if (codeDoc.exists && codeDoc.data()?['teamId'] == teamId) {
          batch.delete(codeRef);
        }
      }
      await batch.commit();
      Logger.team('Team document deleted');

      // Delete from local cache
      Logger.team('Deleting team from local Hive cache...');
      await _hiveSource.deleteTeam(teamId);
      Logger.team('Team deleted from Hive cache');

      // Update all members in local cache
      for (final memberId in allMemberIds) {
        final member = await _hiveSource.getUser(memberId);
        if (member != null && member.teamId == teamId) {
          await _hiveSource.saveUser(member.copyWith(teamId: null));
        }
      }
      Logger.team('All members updated in local cache');

      Logger.team('=== TEAM DELETION SUCCESS ===');
    } catch (e) {
      Logger.team('=== TEAM DELETION FAILED ===');
      Logger.team('Error type: ${e.runtimeType}');
      Logger.team('Error message: ${e.toString()}');

      // Provide specific error messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        throw TeamException(
          message: 'Permission denied. Check Firestore security rules.',
          originalError: e,
        );
      } else if (errorString.contains('not found') ||
          errorString.contains('missing')) {
        throw TeamException(
          message: 'Team not found in database.',
          originalError: e,
        );
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        throw TeamException(
          message: 'Network error. Please check your connection and try again.',
          originalError: e,
        );
      }

      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to delete team: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Remove member from team
  Future<void> removeMember({
    required String teamId,
    required String memberId,
    required String leaderId,
  }) async {
    try {
      Logger.team('Removing member from team: $teamId');

      if (!await _networkChecker.isConnected()) {
        throw TeamException(message: 'Cannot remove member while offline');
      }

      final teamRef = _firestore.collection('teams').doc(teamId);
      final memberRef = _firestore.collection('users').doc(memberId);

      // Pre-query tasks assigned to the removed member in this team.
      // Must be done outside the transaction (Firestore doesn't allow queries
      // inside transactions).
      final assignedTasksQuery = await _firestore
          .collection('tasks')
          .where('teamId', isEqualTo: teamId)
          .where('assignedTo', isEqualTo: memberId)
          .get();

      // Step 1: Transaction on the team doc + task unassignment.
      // The cross-user write (clearing users/{memberId}.teamId) is kept outside
      // the transaction because the deployed Firestore rules require the acting
      // user to be the document owner for that collection. Moving it outside
      // lets the core removal succeed even before updated rules are deployed.
      await _firestore.runTransaction((transaction) async {
        final teamDoc = await transaction.get(teamRef);

        if (!teamDoc.exists) {
          throw TeamException(message: 'Team not found');
        }

        final team = TeamModel.fromFirestore(teamDoc);

        if (team.leaderId != leaderId) {
          throw TeamException(message: 'Only team leader can remove members');
        }

        if (!team.memberIds.contains(memberId)) {
          throw TeamException(message: 'Member not found in team');
        }

        // Cannot remove the current team leader
        if (memberId == team.leaderId) {
          throw TeamException(
            message: 'Cannot remove the team leader. Transfer leadership first.',
          );
        }

        // Remove member from team
        transaction.update(teamRef, {
          'memberIds': FieldValue.arrayRemove([memberId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Unassign tasks that were assigned to the removed member (same as
        // leaveTeam behaviour — tasks are preserved, only assignedTo is cleared).
        for (final taskDoc in assignedTasksQuery.docs) {
          transaction.update(taskDoc.reference, {
            'assignedTo': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      Logger.team(
        'Member removed and ${assignedTasksQuery.docs.length} task(s) unassigned',
      );

      // Step 2: Clear teamId on the removed member's user doc.
      // Requires the updated Firestore rules (allow leader/admin to write
      // teamId+updatedAt on other users). Fails gracefully until rules are
      // deployed — local Hive cache is always cleaned up below.
      try {
        await memberRef.update({
          'teamId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (rulesError) {
        Logger.team(
          'Could not clear teamId on removed member Firestore doc '
          '(deploy updated firestore.rules to fix): $rulesError',
        );
      }

      // Update local Hive cache — team
      final team = await _firebaseSource.getTeam(teamId);
      final updatedTeam = team.copyWith(
        memberIds: team.memberIds.where((id) => id != memberId).toList(),
        updatedAt: DateTime.now(),
      );
      await _hiveSource.saveTeam(updatedTeam);

      // Update local Hive cache — removed member's user record
      final user = await _hiveSource.getUser(memberId);
      if (user != null) {
        await _hiveSource.saveUser(user.copyWith(teamId: null));
      }

      // Update local Hive cache — unassigned tasks.
      // TaskModel.copyWith cannot null out assignedTo due to ?? fallback,
      // so rebuild from the Firestore snapshot which already has no assignedTo.
      for (final taskDoc in assignedTasksQuery.docs) {
        try {
          final freshDoc = await _firestore
              .collection('tasks')
              .doc(taskDoc.id)
              .get();
          if (freshDoc.exists) {
            await _hiveSource.saveTask(TaskModel.fromFirestore(freshDoc));
          }
        } catch (_) {
          // Non-fatal: Firestore write already cleared assignedTo;
          // cache will reconcile on next full sync.
        }
      }

      Logger.team('Member removed successfully');
    } catch (e) {
      Logger.team('Error removing member', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(message: 'Failed to remove member', originalError: e);
    }
  }

  /// Transfer team leadership to another member with userRole == teamLeader
  Future<TeamModel> transferLeadership({
    required String teamId,
    required String currentLeaderId,
    required String newLeaderId,
  }) async {
    try {
      Logger.team(
        'Transferring leadership of team $teamId from $currentLeaderId to $newLeaderId',
      );

      if (!await _networkChecker.isConnected()) {
        throw TeamException(
          message: 'Cannot transfer leadership while offline',
        );
      }

      if (currentLeaderId == newLeaderId) {
        throw TeamException(
          message: 'New leader must be a different member',
        );
      }

      final teamRef = _firestore.collection('teams').doc(teamId);

      // Fetch new leader's user document to verify userRole BEFORE the transaction
      final newLeaderDoc = await _firestore
          .collection('users')
          .doc(newLeaderId)
          .get();

      if (!newLeaderDoc.exists) {
        throw TeamException(message: 'New leader user not found');
      }

      final newLeaderData = newLeaderDoc.data();
      if (newLeaderData == null) {
        throw TeamException(message: 'New leader user data missing');
      }
      final newLeaderAccountRole = UserRole.fromString(
        newLeaderData['userRole'] as String? ??
            newLeaderData['accountType'] as String?,
      );
      if (newLeaderAccountRole != UserRole.teamLeader) {
        throw TeamException(
          message:
              'Cannot transfer leadership: only users with the Team Leader account type can become team leader',
        );
      }

      // Run transaction to atomically update leaderId
      final updatedTeam = await _firestore.runTransaction<TeamModel>((
        transaction,
      ) async {
        final teamDoc = await transaction.get(teamRef);

        if (!teamDoc.exists) {
          throw TeamException(message: 'Team not found');
        }

        final team = TeamModel.fromFirestore(teamDoc);

        // Only the current assigned leader may transfer
        if (team.leaderId != currentLeaderId) {
          throw TeamException(
            message: 'Only the current team leader can transfer leadership',
          );
        }

        // New leader must be a member of this team
        if (!team.memberIds.contains(newLeaderId)) {
          throw TeamException(
            message: 'The new leader must be a member of this team',
          );
        }

        transaction.update(teamRef, {
          'leaderId': newLeaderId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return team.copyWith(
          leaderId: newLeaderId,
          updatedAt: DateTime.now(),
        );
      });

      // Update local Hive cache
      await _hiveSource.saveTeam(updatedTeam);
      Logger.team('Leadership transferred successfully. New leader: $newLeaderId');

      return updatedTeam;
    } catch (e) {
      Logger.team('Error transferring leadership', error: e);
      if (e is TeamException) rethrow;
      throw TeamException(
        message: 'Failed to transfer leadership: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Change a team member's specialty role
  Future<void> changeMemberRole({
    required String teamId,
    required String memberId,
    required String leaderId,
    required String newRole,
  }) async {
    try {
      Logger.team('Changing member $memberId role to $newRole in team $teamId');

      // Verify the requester is the team leader
      final team = await getTeam(teamId);
      if (team.leaderId != leaderId) {
        throw TeamException(message: 'Only team leaders can change member roles');
      }

      if (await _networkChecker.isConnected()) {
        // Update user's role field in Firestore
        final userRef = _firestore.collection('users').doc(memberId);
        await userRef.update({
          'role': newRole,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        Logger.team('Member role updated in Firestore');
      }

      // Update local cache
      final user = await _hiveSource.getUser(memberId);
      if (user != null) {
        final updatedUser = user.copyWith(role: newRole);
        await _hiveSource.saveUser(updatedUser);
        Logger.team('Member role updated in local cache');
      }
    } catch (e) {
      Logger.team('Error changing member role', error: e);
      if (e is TeamException) rethrow;
      throw TeamException(message: 'Failed to change member role', originalError: e);
    }
  }
}
