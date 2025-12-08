import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/network_checker.dart';
import '../../core/utils/logger.dart';
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
          teamCode = _generateSecureTeamCode();
          Logger.team(
            'Generated team code: $teamCode (attempt ${attempts + 1}/5)',
          );

          // Verify uniqueness in Firestore
          if (await _networkChecker.isConnected()) {
            try {
              final query = await _firestore
                  .collection('teams')
                  .where('teamCode', isEqualTo: teamCode)
                  .where('isActive', isEqualTo: true)
                  .limit(1)
                  .get();

              isUnique = query.docs.isEmpty;
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

  /// Join a team using team code with transaction-based atomic update
  Future<TeamModel> joinTeam({
    required String teamCode,
    required String userId,
  }) async {
    try {
      Logger.team('Joining team with code: $teamCode for user: $userId');

      if (!await _networkChecker.isConnected()) {
        throw TeamException(message: 'Cannot join team while offline');
      }

      // Query team by code OUTSIDE transaction (queries can't be done inside transactions)
      Logger.team('Querying team by code: ${teamCode.toUpperCase()}');
      final teamQuery = await _firestore
          .collection('teams')
          .where('teamCode', isEqualTo: teamCode.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (teamQuery.docs.isEmpty) {
        Logger.team('No team found with code: ${teamCode.toUpperCase()}');
        throw TeamException(message: 'Invalid team code');
      }

      final teamDoc = teamQuery.docs.first;
      Logger.team('Team found: ${teamDoc.id}');
      final team = TeamModel.fromFirestore(teamDoc);

      // Check if user is already a member
      if (team.memberIds.contains(userId)) {
        Logger.team('User $userId is already a member of team ${team.id}');
        throw TeamException(message: 'Already a member of this team');
      }

      // Check if team is full (max 50 members)
      if (team.memberIds.length >= 50) {
        Logger.team(
          'Team ${team.id} is full (${team.memberIds.length} members)',
        );
        throw TeamException(message: 'Team is full');
      }

      Logger.team('Team validation passed. Starting transaction...');

      // Check if user document exists before transaction
      final userDocCheck = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (!userDocCheck.exists) {
        Logger.team('User document does not exist: $userId');
        throw TeamException(
          message: 'User account not found. Please contact support.',
        );
      }
      Logger.team('User document exists: $userId');

      // Use Firestore transaction for atomic update
      TeamModel updatedTeam;
      try {
        updatedTeam = await _firestore.runTransaction<TeamModel>((
          transaction,
        ) async {
          try {
            // Get fresh team document inside transaction
            Logger.team('Getting fresh team document in transaction');
            final freshTeamDoc = await transaction.get(teamDoc.reference);
            if (!freshTeamDoc.exists) {
              Logger.team('Team document does not exist in transaction');
              throw TeamException(message: 'Team no longer exists');
            }

            TeamModel freshTeam;
            try {
              freshTeam = TeamModel.fromFirestore(freshTeamDoc);
              Logger.team(
                'Fresh team loaded: ${freshTeam.id}, members: ${freshTeam.memberIds.length}',
              );
            } catch (parseError) {
              Logger.team('Failed to parse team document', error: parseError);
              throw TeamException(
                message:
                    'Failed to load team data. The team document may be corrupted.',
                originalError: parseError,
              );
            }

            // Double-check conditions inside transaction
            if (freshTeam.memberIds.contains(userId)) {
              Logger.team('User is already a member (checked in transaction)');
              throw TeamException(message: 'Already a member of this team');
            }

            if (freshTeam.memberIds.length >= 50) {
              Logger.team('Team is full (checked in transaction)');
              throw TeamException(message: 'Team is full');
            }

            // Get fresh user document inside transaction
            Logger.team('Getting fresh user document in transaction');
            final userRef = _firestore.collection('users').doc(userId);
            final freshUserDoc = await transaction.get(userRef);
            if (!freshUserDoc.exists) {
              Logger.team('User document does not exist in transaction');
              throw TeamException(message: 'User account not found');
            }
            Logger.team('Fresh user document loaded');

            // Update team document: add user to memberIds
            Logger.team('Updating team document in transaction');
            try {
              transaction.update(teamDoc.reference, {
                'memberIds': FieldValue.arrayUnion([userId]),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Logger.team('Team document update queued in transaction');
            } catch (updateError) {
              Logger.team('Failed to queue team update', error: updateError);
              throw TeamException(
                message: 'Failed to update team: ${updateError.toString()}',
                originalError: updateError,
              );
            }

            // Update user document: set teamId
            Logger.team('Updating user document in transaction');
            try {
              transaction.update(userRef, {
                'teamId': teamDoc.id,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Logger.team('User document update queued in transaction');
            } catch (updateError) {
              Logger.team('Failed to queue user update', error: updateError);
              throw TeamException(
                message: 'Failed to update user: ${updateError.toString()}',
                originalError: updateError,
              );
            }

            // Return updated team model
            final updatedMemberIds = List<String>.from(freshTeam.memberIds)
              ..add(userId);
            Logger.team('Transaction operations queued successfully');
            return freshTeam.copyWith(
              memberIds: updatedMemberIds,
              updatedAt: DateTime.now(),
            );
          } on TeamException {
            // Re-throw TeamException as-is
            rethrow;
          } catch (innerError) {
            Logger.team(
              'Unexpected error inside transaction',
              error: innerError,
            );
            throw TeamException(
              message: 'Transaction failed: ${innerError.toString()}',
              originalError: innerError,
            );
          }
        });
      } on TeamException catch (transactionError) {
        // Re-throw TeamException as-is
        Logger.team(
          'Transaction failed with TeamException: ${transactionError.message}',
        );
        rethrow;
      } catch (transactionError) {
        Logger.team('Transaction failed', error: transactionError);
        Logger.team('Transaction error type: ${transactionError.runtimeType}');
        Logger.team('Transaction error string: ${transactionError.toString()}');

        // Handle "Dart exception thrown from converted Future" error
        String errorMessage = transactionError.toString();

        // Check if this is the "converted Future" error
        if (errorMessage.contains(
              'Dart exception thrown from converted Future',
            ) ||
            errorMessage.contains('Use the properties')) {
          Logger.team(
            'Detected "converted Future" error - trying to extract actual error',
          );

          // Try to get the actual error from the exception
          // This error usually means there's a nested exception
          try {
            // Check if the error has an 'error' property (from the error message)
            if (transactionError is Exception) {
              final errorStr = transactionError.toString();
              // Try to extract any meaningful error message
              if (errorStr.contains('TeamException')) {
                final match = RegExp(
                  r'TeamException[:\s]+([^.\n]+)',
                  caseSensitive: false,
                ).firstMatch(errorStr);
                if (match != null) {
                  errorMessage =
                      match.group(1)?.trim() ?? 'Failed to join team';
                }
              } else if (errorStr.contains('permission') ||
                  errorStr.contains('denied')) {
                errorMessage =
                    'Permission denied. Please check Firestore security rules.';
              } else if (errorStr.contains('not found') ||
                  errorStr.contains('does not exist')) {
                errorMessage = 'Team or user document not found.';
              } else {
                // Try to find any error message in the string
                final errorMatch = RegExp(
                  r'Error[:\s]+([^.\n]+)',
                  caseSensitive: false,
                ).firstMatch(errorStr);
                if (errorMatch != null) {
                  errorMessage =
                      errorMatch.group(1)?.trim() ?? 'Unknown error occurred';
                } else {
                  errorMessage = 'Transaction failed. Please try again.';
                }
              }
            }
          } catch (extractError) {
            Logger.team('Failed to extract error details', error: extractError);
            errorMessage = 'Failed to join team. Please try again.';
          }
        } else {
          // Try to extract the actual error from the transaction
          if (errorMessage.contains('TeamException')) {
            final match = RegExp(
              r'TeamException[:\s]+([^.\n]+)',
              caseSensitive: false,
            ).firstMatch(errorMessage);
            if (match != null) {
              errorMessage = match.group(1)?.trim() ?? 'Failed to join team';
            }
          } else if (errorMessage.contains('permission') ||
              errorMessage.contains('denied')) {
            errorMessage =
                'Permission denied. Please check Firestore security rules.';
          } else if (errorMessage.contains('not found') ||
              errorMessage.contains('does not exist')) {
            errorMessage = 'Team or user document not found.';
          }
        }

        throw TeamException(
          message: errorMessage,
          originalError: transactionError,
        );
      }

      Logger.team('Transaction completed successfully');

      // Update local cache after transaction succeeds
      try {
        await _hiveSource.saveTeam(updatedTeam);
        Logger.team('Team saved to Hive cache');

        // Update user in Hive cache
        final user = await _hiveSource.getUser(userId);
        if (user != null) {
          await _hiveSource.saveUser(user.copyWith(teamId: updatedTeam.id));
          Logger.team('User updated in Hive cache');
        }
      } catch (cacheError) {
        Logger.team(
          'Failed to update cache, but team join succeeded',
          error: cacheError,
        );
        // Don't fail the operation if cache update fails
      }

      Logger.team('User joined team successfully: ${updatedTeam.id}');
      return updatedTeam;
    } catch (e) {
      Logger.team('Error joining team', error: e);
      Logger.team('Error type: ${e.runtimeType}');
      Logger.team('Error details: ${e.toString()}');

      // Extract error message from nested exceptions
      String errorMessage = e.toString();
      if (e is TeamException) {
        Logger.team('Re-throwing TeamException: ${e.message}');
        rethrow;
      }

      // Check for specific error patterns
      final errorStr = errorMessage.toLowerCase();

      if (errorStr.contains('invalid team code') ||
          errorStr.contains('not found') ||
          errorStr.contains('no team found')) {
        throw TeamException(message: 'Invalid team code');
      }
      if (errorStr.contains('already a member')) {
        throw TeamException(message: 'Already a member of this team');
      }
      if (errorStr.contains('team is full')) {
        throw TeamException(message: 'Team is full');
      }
      if (errorStr.contains('permission') || errorStr.contains('denied')) {
        throw TeamException(
          message: 'Permission denied. Please check your account permissions.',
          originalError: e,
        );
      }
      if (errorStr.contains('network') || errorStr.contains('connection')) {
        throw TeamException(
          message: 'Network error. Please check your connection and try again.',
          originalError: e,
        );
      }

      // Try to extract error from nested exception
      if (errorMessage.contains('error')) {
        // Try to get the actual error message
        final match = RegExp(
          r'error[:\s]+([^.\n]+)',
          caseSensitive: false,
        ).firstMatch(errorMessage);
        if (match != null) {
          errorMessage = match.group(1) ?? errorMessage;
        }
      }

      throw TeamException(
        message: 'Failed to join team: $errorMessage',
        originalError: e,
      );
    }
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

  /// Get team by code
  Future<TeamModel> getTeamByCode(String teamCode) async {
    try {
      Logger.team('Getting team by code: $teamCode');

      if (!await _networkChecker.isConnected()) {
        throw TeamException(message: 'Cannot get team by code while offline');
      }

      final team = await _firebaseSource.getTeamByCode(teamCode.toUpperCase());

      // Cache locally
      await _hiveSource.saveTeam(team);

      return team;
    } catch (e) {
      Logger.team('Error getting team by code', error: e);
      if (e is TeamException) {
        rethrow;
      }
      throw TeamException(
        message: 'Failed to get team by code',
        originalError: e,
      );
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

      // Firestore 'in' query limit is 10, so batch if needed
      final List<UserModel> members = [];
      final batchSize = 10;

      for (int i = 0; i < team.memberIds.length; i += batchSize) {
        final batch = team.memberIds.skip(i).take(batchSize).toList();

        if (await _networkChecker.isConnected()) {
          final query = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: batch)
              .get();

          members.addAll(query.docs.map((doc) => UserModel.fromFirestore(doc)));
        } else {
          // Get from Hive cache
          for (final memberId in batch) {
            final user = await _hiveSource.getUser(memberId);
            if (user != null) {
              members.add(user);
            }
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

      // Use batch write for better reliability than transaction
      Logger.team('Creating Firestore batch write...');
      final batch = _firestore.batch();

      // Soft delete team (set isActive: false instead of deleting)
      final teamRef = _firestore.collection('teams').doc(teamId);
      batch.update(teamRef, {
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Logger.team('Team soft delete queued in batch');

      // Clear teamId from all members (including leader)
      final allMemberIds = [team.leaderId, ...team.memberIds].toSet().toList();

      Logger.team('Clearing teamId from ${allMemberIds.length} members');
      for (final memberId in allMemberIds) {
        final userRef = _firestore.collection('users').doc(memberId);
        batch.update(userRef, {
          'teamId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      Logger.team('All member updates queued in batch');

      // Commit batch
      Logger.team('Committing batch write to Firestore...');
      await batch.commit();
      Logger.team('Batch write committed successfully');

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

      // Use transaction
      await _firestore.runTransaction((transaction) async {
        final teamDoc = await _firestore.collection('teams').doc(teamId).get();

        if (!teamDoc.exists) {
          throw TeamException(message: 'Team not found');
        }

        final team = TeamModel.fromFirestore(teamDoc);

        // Check if user is the leader
        if (team.leaderId != leaderId) {
          throw TeamException(message: 'Only team leader can remove members');
        }

        // Check if member exists
        if (!team.memberIds.contains(memberId)) {
          throw TeamException(message: 'Member not found in team');
        }

        // Remove member from team
        transaction.update(teamDoc.reference, {
          'memberIds': FieldValue.arrayRemove([memberId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Clear member's teamId
        transaction.update(_firestore.collection('users').doc(memberId), {
          'teamId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Update local cache
      final team = await _firebaseSource.getTeam(teamId);
      final updatedTeam = team.copyWith(
        memberIds: team.memberIds.where((id) => id != memberId).toList(),
        updatedAt: DateTime.now(),
      );
      await _hiveSource.saveTeam(updatedTeam);

      // Update user in Hive
      final user = await _hiveSource.getUser(memberId);
      if (user != null) {
        await _hiveSource.saveUser(user.copyWith(teamId: null));
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

  /// Generate secure random team code (6 characters: A-Z, 0-9)
  String _generateSecureTeamCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
