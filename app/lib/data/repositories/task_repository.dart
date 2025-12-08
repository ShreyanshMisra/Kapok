import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/task_priority.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/user_role.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/network_checker.dart';
import '../../core/services/sync_service.dart';
import '../../core/utils/logger.dart';
import '../models/task_model.dart';
import '../sources/firebase_source.dart';
import '../sources/hive_source.dart';

/// Repository for task operations
class TaskRepository {
  final FirebaseSource _firebaseSource;
  final HiveSource _hiveSource;
  final NetworkChecker _networkChecker;

  TaskRepository({
    required FirebaseSource firebaseSource,
    required HiveSource hiveSource,
    required NetworkChecker networkChecker,
  }) : _firebaseSource = firebaseSource,
       _hiveSource = hiveSource,
       _networkChecker = networkChecker;

  /// Create a new task
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      Logger.task('=== TASK CREATION START ===');
      Logger.task('Task ID: ${task.id}');
      Logger.task('Task Title: ${task.title}');
      Logger.task('Task TeamId: ${task.teamId}');
      Logger.task('Task CreatedBy: ${task.createdBy}');
      Logger.task(
        'Task GeoLocation: ${task.geoLocation.latitude}, ${task.geoLocation.longitude}',
      );
      Logger.task('Task Status: ${task.status.value}');
      Logger.task('Task Priority: ${task.priority.value}');

      // Validate required fields
      if (task.title.trim().isEmpty) {
        throw TaskException(message: 'Task title is required');
      }
      if (task.teamId.isEmpty) {
        throw TaskException(message: 'Task must be assigned to a team');
      }
      if (task.geoLocation.latitude == 0.0 &&
          task.geoLocation.longitude == 0.0) {
        Logger.task('Warning: Task location is 0,0 - may be invalid');
      }
      if (task.createdBy.isEmpty) {
        throw TaskException(message: 'Task creator is required');
      }

      final isConnected = await _networkChecker.isConnected();
      Logger.task('Network Connected: $isConnected');

      // Always save locally first (offline-first)
      Logger.task('Saving task to Hive cache...');
      await _hiveSource.saveTask(task);
      Logger.task('Task saved to Hive cache successfully');

      if (isConnected) {
        try {
          // Convert to Firestore format and log
          final firestoreData = task.toFirestore();
          Logger.task('Firestore data keys: ${firestoreData.keys.join(", ")}');
          Logger.task('Firestore data: $firestoreData');

          // Save to Firebase using transaction to atomically create task and update team
          Logger.task('Saving task to Firebase with transaction...');
          Logger.task('Task ID: ${task.id}');
          Logger.task('Team ID: ${task.teamId}');
          Logger.task('Created By: ${task.createdBy}');

          final firestore = FirebaseFirestore.instance;

          // First, verify team exists and user is in it (outside transaction for better error messages)
          try {
            final teamDoc = await firestore
                .collection('teams')
                .doc(task.teamId)
                .get();
            if (!teamDoc.exists) {
              Logger.task(
                'ERROR: Team document does not exist: ${task.teamId}',
              );
              throw TaskException(message: 'Team not found: ${task.teamId}');
            }

            final teamData = teamDoc.data()!;
            final memberIds = List<String>.from(teamData['memberIds'] ?? []);
            final leaderId = teamData['leaderId'] as String? ?? '';

            Logger.task('Team found: ${teamDoc.id}');
            Logger.task('Team leader: $leaderId');
            Logger.task('Team members: ${memberIds.join(", ")}');
            Logger.task(
              'User ${task.createdBy} is in team: ${memberIds.contains(task.createdBy) || leaderId == task.createdBy}',
            );

            if (!memberIds.contains(task.createdBy) &&
                leaderId != task.createdBy) {
              Logger.task(
                'ERROR: User ${task.createdBy} is not a member of team ${task.teamId}',
              );
              throw TaskException(
                message:
                    'You are not a member of this team. Please join the team first.',
              );
            }
          } catch (e) {
            if (e is TaskException) {
              rethrow;
            }
            Logger.task('Error checking team membership', error: e);
            throw TaskException(
              message: 'Failed to verify team membership: ${e.toString()}',
              originalError: e,
            );
          }

          // Now run the transaction
          Logger.task('Starting Firestore transaction...');
          try {
            await firestore.runTransaction((transaction) async {
              // Update team document FIRST to add task ID (before creating task)
              // This ensures the team update happens atomically with task creation
              final teamRef = firestore.collection('teams').doc(task.teamId);
              Logger.task('Team document path: ${teamRef.path}');

              // Get team document inside transaction (for consistency)
              final teamDoc = await transaction.get(teamRef);
              if (!teamDoc.exists) {
                Logger.task(
                  'ERROR: Team not found in transaction: ${task.teamId}',
                );
                throw TaskException(message: 'Team not found: ${task.teamId}');
              }

              final teamData = teamDoc.data() ?? {};
              final currentTaskIds = List<String>.from(
                teamData['taskIds'] ?? [],
              );
              Logger.task(
                'Team current taskIds: ${currentTaskIds.length} tasks',
              );
              Logger.task(
                'Team has taskIds field: ${teamData.containsKey('taskIds')}',
              );

              // Ensure taskIds field exists (for old teams that might not have it)
              final updateData = <String, dynamic>{
                'updatedAt': FieldValue.serverTimestamp(),
              };

              // If taskIds field doesn't exist, set it; otherwise use arrayUnion
              if (!teamData.containsKey('taskIds') || currentTaskIds.isEmpty) {
                Logger.task('Initializing taskIds field for team');
                updateData['taskIds'] = [task.id];
              } else {
                Logger.task('Adding task ID to existing taskIds array');
                updateData['taskIds'] = FieldValue.arrayUnion([task.id]);
              }

              transaction.update(teamRef, updateData);
              Logger.task('Team update queued in transaction');

              // Create task document AFTER team update
              final taskRef = firestore.collection('tasks').doc(task.id);
              final taskData = task.toFirestore();
              Logger.task('Task data to write: ${taskData.keys.join(", ")}');
              Logger.task('Task document path: ${taskRef.path}');
              Logger.task('Task createdBy: ${task.createdBy}');
              Logger.task('Task teamId: ${task.teamId}');

              // Don't check if task exists - just create it
              // This avoids unnecessary read that might cause permission issues
              transaction.set(taskRef, taskData);
              Logger.task('Task document set in transaction');
            });

            Logger.task('Transaction committed successfully');
          } catch (transactionError) {
            Logger.task('TRANSACTION FAILED');
            Logger.task(
              'Transaction error type: ${transactionError.runtimeType}',
            );
            Logger.task('Transaction error: ${transactionError.toString()}');
            Logger.task('Transaction error details: $transactionError');

            // Try to extract the actual Firestore error
            String actualError = transactionError.toString();
            try {
              // For web, the error might be wrapped in NativeError
              // Try to get the underlying error message
              if (transactionError.toString().contains('error')) {
                // Try to extract error code/message from the string
                final errorMatch = RegExp(
                  r'(permission-denied|PERMISSION_DENIED|failed|error)[:\s]+([^.\n]+)',
                  caseSensitive: false,
                ).firstMatch(transactionError.toString());
                if (errorMatch != null) {
                  actualError = errorMatch.group(2)?.trim() ?? actualError;
                }
              }
            } catch (e) {
              // Ignore extraction errors
            }

            // Check if it's a permission error
            final errorString = actualError.toLowerCase();
            if (errorString.contains('permission') ||
                errorString.contains('denied') ||
                errorString.contains('permission-denied')) {
              Logger.task(
                'PERMISSION ERROR in transaction - check Firestore rules',
              );
              Logger.task(
                'This usually means the user does not have permission to:',
              );
              Logger.task('1. Create the task document');
              Logger.task('2. Update the team document (taskIds field)');
              Logger.task('3. Read the team document to verify membership');
              Logger.task('Actual error: $actualError');
            }

            // Re-throw to be caught by outer catch block
            rethrow;
          }

          // Read back the created task to get server-generated fields
          // Add retry logic in case of permission issues
          TaskModel createdTask = task; // Default to original task
          int retries = 3;
          bool readSuccess = false;
          for (int i = 0; i < retries; i++) {
            try {
              await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
              createdTask = await _firebaseSource.getTask(task.id);
              Logger.task(
                'Firebase save successful, task ID: ${createdTask.id}',
              );
              readSuccess = true;
              break;
            } catch (readError) {
              Logger.task(
                'Failed to read back task (attempt ${i + 1}/$retries)',
                error: readError,
              );
              if (i == retries - 1) {
                // Last attempt failed - use the original task
                Logger.task(
                  'WARNING: Could not read back task from Firebase, using original task data',
                );
                Logger.task(
                  'Task was created in transaction but read failed - this may be a permission issue',
                );
                Logger.task(
                  'Task should still be in Firebase - check Firestore Console',
                );
                createdTask = task;
              }
            }
          }

          if (!readSuccess) {
            Logger.task(
              'Using original task data as fallback - task should still be in Firebase',
            );
          }

          // Update local team cache
          try {
            final team = await _hiveSource.getTeam(task.teamId);
            if (team != null) {
              final updatedTeam = team.copyWith(
                taskIds: [...team.taskIds, task.id],
                updatedAt: DateTime.now(),
              );
              await _hiveSource.saveTeam(updatedTeam);
              Logger.task('Team cache updated with new task ID');
            }
          } catch (cacheError) {
            Logger.task('Failed to update team cache', error: cacheError);
            // Don't fail the operation if cache update fails
          }

          // Verification: Read back from Firebase (with retry and graceful failure)
          Logger.task('Verifying task exists in Firebase...');
          try {
            // Wait a bit for Firestore to propagate
            await Future.delayed(const Duration(milliseconds: 200));
            final verifySnapshot = await _firebaseSource.getTask(
              createdTask.id,
            );
            Logger.task('VERIFICATION SUCCESS: Task found in Firebase');
            Logger.task('Verified task ID: ${verifySnapshot.id}');
            Logger.task('Verified teamId: ${verifySnapshot.teamId}');
            Logger.task('Verified title: ${verifySnapshot.title}');
          } catch (verifyError) {
            Logger.task(
              'VERIFICATION FAILED: Could not read task back from Firebase',
              error: verifyError,
            );
            final errorString = verifyError.toString().toLowerCase();
            if (errorString.contains('permission') ||
                errorString.contains('denied')) {
              Logger.task(
                'Permission error during verification - task may still be saved',
              );
              Logger.task(
                'This is often a timing issue - task should appear in Firebase shortly',
              );
              Logger.task(
                'Check Firestore Console to confirm task was created',
              );
              // Don't throw - task was created, just can't verify due to permissions
            } else {
              // For other errors, log but don't fail - transaction succeeded
              Logger.task(
                'Verification failed but transaction succeeded - task should be in Firebase',
              );
            }
          }

          // Update local cache with Firebase data
          await _hiveSource.saveTask(createdTask);
          Logger.task('Local cache updated with Firebase data');

          // Trigger immediate sync of any queued items (in case there were previous failures)
          try {
            final syncService = SyncService.instance;
            await syncService.syncPendingChanges();
            Logger.task('Triggered sync of pending changes');
          } catch (syncError) {
            Logger.task('Failed to trigger sync', error: syncError);
            // Don't fail task creation if sync trigger fails
          }

          Logger.task('=== TASK CREATION SUCCESS ===');
          return createdTask;
        } catch (e) {
          // Firebase failed, but local save succeeded
          Logger.task('=== FIREBASE SAVE FAILED ===');
          Logger.task('Error type: ${e.runtimeType}');
          Logger.task('Error message: ${e.toString()}');
          Logger.task('Error details: $e');

          // Provide specific error messages
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('permission') ||
              errorString.contains('denied') ||
              errorString.contains('permission-denied')) {
            Logger.task(
              'ERROR: Permission denied - check Firestore security rules',
            );
            Logger.task('This usually means:');
            Logger.task('1. Firestore rules are not deployed');
            Logger.task('2. User is not in team memberIds');
            Logger.task('3. Team document does not exist');

            // Queue for sync but still throw error
            await _hiveSource.queueForSync({
              'operation': 'create_task',
              'type': 'task',
              'data': task.toJson(),
              'timestamp': DateTime.now().toIso8601String(),
            });

            throw TaskException(
              message:
                  'Permission denied: Check Firestore security rules. Make sure you are a member of the selected team. Task saved locally and will sync when permissions are fixed.',
              originalError: e,
            );
          } else if (errorString.contains('invalid_argument') ||
              errorString.contains('invalid')) {
            Logger.task(
              'ERROR: Invalid argument - check GeoPoint and field types',
            );
            throw TaskException(
              message: 'Invalid data: Check GeoPoint and field types',
              originalError: e,
            );
          } else if (errorString.contains('network') ||
              errorString.contains('connection') ||
              errorString.contains('unavailable')) {
            Logger.task('ERROR: Network error - queueing for sync');
            // Queue for sync and return task (offline mode)
            await _hiveSource.queueForSync({
              'operation': 'create_task',
              'type': 'task',
              'data': task.toJson(),
              'timestamp': DateTime.now().toIso8601String(),
            });
            Logger.task(
              'Task queued for sync - will save to Firebase when online',
            );
            // Try to trigger sync immediately in case connection is restored
            try {
              final syncService = SyncService.instance;
              await syncService.syncPendingChanges();
            } catch (syncError) {
              Logger.task(
                'Failed to trigger sync after queueing',
                error: syncError,
              );
            }
            // Return task for offline mode
            return task;
          } else if (errorString.contains('not found') ||
              errorString.contains('team not found')) {
            Logger.task('ERROR: Team not found');
            throw TaskException(
              message: 'Team not found. Please select a valid team.',
              originalError: e,
            );
          }

          // For other errors, throw to show user (don't silently fail)
          Logger.task('ERROR: Unknown error - throwing exception');
          // Still queue for sync in case it's a transient error
          await _hiveSource.queueForSync({
            'operation': 'create_task',
            'type': 'task',
            'data': task.toJson(),
            'timestamp': DateTime.now().toIso8601String(),
          });

          throw TaskException(
            message:
                'Failed to save task to Firebase: ${e.toString()}. Task saved locally and will sync when online.',
            originalError: e,
          );
        }
      } else {
        // Offline: queue for sync
        Logger.task('Device offline, queueing task for sync');
        await _hiveSource.queueForSync({
          'operation': 'create_task',
          'type': 'task',
          'data': task.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Try to trigger sync in case connection is restored
        try {
          final syncService = SyncService.instance;
          await syncService.syncPendingChanges();
        } catch (syncError) {
          Logger.task('Failed to trigger sync (offline)', error: syncError);
        }

        Logger.task('=== TASK CREATION SUCCESS (OFFLINE) ===');
        return task;
      }
    } catch (e, stackTrace) {
      Logger.task('=== TASK CREATION FAILED ===');
      Logger.task('Error type: ${e.runtimeType}');
      Logger.task('Error message: ${e.toString()}');
      Logger.task('Stack trace: $stackTrace');

      if (e is TaskException) {
        rethrow;
      }
      throw TaskException(
        message: 'Failed to create task: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get task by ID
  Future<TaskModel> getTask(String taskId) async {
    try {
      Logger.task('Getting task: $taskId');

      TaskModel? task;

      if (await _networkChecker.isConnected()) {
        try {
          // Get from Firebase
          task = await _firebaseSource.getTask(taskId);

          // Cache locally
          await _hiveSource.saveTask(task);
        } catch (e) {
          // Firebase failed, try local cache
          task = await _hiveSource.getTask(taskId);
        }
      } else {
        // Offline: get from local cache
        task = await _hiveSource.getTask(taskId);
      }

      if (task == null) {
        throw TaskException(message: 'Task not found');
      }

      return task;
    } catch (e) {
      Logger.task('Error getting task', error: e);
      if (e is TaskException) {
        rethrow;
      }
      throw TaskException(message: 'Failed to get task', originalError: e);
    }
  }

  /// Get all tasks (or all tasks if admin)
  Future<List<TaskModel>> getTasks({String? userId}) async {
    try {
      Logger.task('Getting tasks${userId != null ? " for user: $userId" : ""}');

      // If userId provided, check if admin
      if (userId != null) {
        final user = await _hiveSource.getUser(userId);
        if (user != null && user.userRole == UserRole.admin) {
          Logger.task('User is admin, loading all tasks');
          return await _getAllTasks();
        }
      }

      List<TaskModel> tasks;

      if (await _networkChecker.isConnected()) {
        try {
          // Get from Firebase
          tasks = await _firebaseSource.getTasks();
          Logger.task('Loaded ${tasks.length} tasks from Firebase');

          // Cache locally
          await _hiveSource.cacheTasks(tasks);
        } catch (e) {
          // Firebase failed, get from local cache
          Logger.task(
            'Firebase query failed, falling back to local cache',
            error: e,
          );
          Logger.task('Error details: ${e.toString()}');
          // Check if it's an index error
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('index') ||
              errorString.contains('requires an index')) {
            Logger.task(
              'ERROR: Missing Firestore index! The query requires an index on tasks(createdAt). '
              'Check Firebase Console for index creation link or deploy firestore.indexes.json',
            );
          }
          tasks = await _hiveSource.getTasks();
          Logger.task(
            'Loaded ${tasks.length} tasks from local cache (fallback)',
          );
        }
      } else {
        // Offline: get from local cache
        tasks = await _hiveSource.getTasks();
      }

      Logger.task('Found ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      Logger.task('Error getting tasks', error: e);
      throw TaskException(message: 'Failed to get tasks', originalError: e);
    }
  }

  /// Get all tasks (for admin users)
  Future<List<TaskModel>> _getAllTasks() async {
    try {
      Logger.task('Loading all tasks (admin)');

      if (await _networkChecker.isConnected()) {
        try {
          final tasks = await _firebaseSource.getAllTasks();

          // Cache locally
          await _hiveSource.cacheTasks(tasks);

          Logger.task('Loaded ${tasks.length} tasks from Firebase');
          return tasks;
        } catch (e) {
          Logger.task(
            'Error loading all tasks from Firebase, trying local cache',
            error: e,
          );
          // Fallback to local cache if Firebase fails
          final tasks = await _hiveSource.getTasks();
          Logger.task(
            'Loaded ${tasks.length} tasks from local cache (fallback)',
          );
          return tasks;
        }
      } else {
        // Offline: get from local cache
        final tasks = await _hiveSource.getTasks();
        Logger.task('Loaded ${tasks.length} tasks from local cache');
        return tasks;
      }
    } catch (e) {
      Logger.task('Error loading all tasks', error: e);
      // Return empty list instead of throwing to prevent UI errors
      Logger.task('Returning empty list due to error');
      return [];
    }
  }

  /// Get tasks stream
  Stream<List<TaskModel>> getTasksStream({String? teamId, String? userId}) {
    try {
      Logger.task('Starting tasks stream');
      return _firebaseSource
          .getTasksStream(teamId: teamId, userId: userId)
          .handleError((error) {
            Logger.task('Error in tasks stream', error: error);
            throw TaskException(
              message: 'Failed to stream tasks',
              originalError: error,
            );
          });
    } catch (e) {
      Logger.task('Error creating tasks stream', error: e);
      return Stream.error(
        TaskException(
          message: 'Failed to create tasks stream',
          originalError: e,
        ),
      );
    }
  }

  /// Get tasks by team
  Future<List<TaskModel>> getTasksByTeam(String teamId) async {
    try {
      Logger.task('Getting tasks for team: $teamId');

      List<TaskModel> tasks;

      if (await _networkChecker.isConnected()) {
        try {
          // Get from Firebase
          tasks = await _firebaseSource.getTasksByTeam(teamId);

          // Cache locally
          await _hiveSource.cacheTasks(tasks);
        } catch (e) {
          // Firebase failed, get from local cache
          tasks = await _hiveSource.getTasksByTeam(teamId);
        }
      } else {
        // Offline: get from local cache
        tasks = await _hiveSource.getTasksByTeam(teamId);
      }

      Logger.task('Found ${tasks.length} tasks for team');
      return tasks;
    } catch (e) {
      Logger.task('Error getting team tasks', error: e);
      throw TaskException(
        message: 'Failed to get team tasks',
        originalError: e,
      );
    }
  }

  /// Get tasks by user
  Future<List<TaskModel>> getTasksByUser(String userId) async {
    try {
      Logger.task('Getting tasks for user: $userId');

      List<TaskModel> tasks;

      if (await _networkChecker.isConnected()) {
        try {
          // Get from Firebase
          tasks = await _firebaseSource.getTasksByUser(userId);

          // Cache locally
          await _hiveSource.cacheTasks(tasks);
        } catch (e) {
          // Firebase failed, get from local cache
          tasks = await _hiveSource.getTasksByUser(userId);
        }
      } else {
        // Offline: get from local cache
        tasks = await _hiveSource.getTasksByUser(userId);
      }

      Logger.task('Found ${tasks.length} tasks for user');
      return tasks;
    } catch (e) {
      Logger.task('Error getting user tasks', error: e);
      throw TaskException(
        message: 'Failed to get user tasks',
        originalError: e,
      );
    }
  }

  /// Update task
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      Logger.task('Updating task: ${task.id}');

      final updatedTask = task.copyWith(updatedAt: DateTime.now());

      // Always update locally first
      await _hiveSource.saveTask(updatedTask);

      if (await _networkChecker.isConnected()) {
        try {
          // Update on Firebase
          final firebaseTask = await _firebaseSource.updateTask(updatedTask);

          // Update local cache with Firebase data
          await _hiveSource.saveTask(firebaseTask);

          Logger.task('Task updated successfully');
          return firebaseTask;
        } catch (e) {
          // Firebase failed, but local update succeeded
          Logger.task('Firebase update failed, task updated locally', error: e);
          return updatedTask;
        }
      } else {
        // Offline: queue for sync
        await _hiveSource.queueForSync({
          'operation': 'update',
          'data': updatedTask.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });

        Logger.task('Task updated offline');
        return updatedTask;
      }
    } catch (e) {
      Logger.task('Error updating task', error: e);
      throw TaskException(message: 'Failed to update task', originalError: e);
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      Logger.task('=== TASK DELETION START ===');
      Logger.task('Task ID: $taskId');

      // Get task first to know which team it belongs to
      final task = await getTask(taskId);
      Logger.task('Task found: ${task.title}, Team ID: ${task.teamId}');

      // Always delete locally first
      await _hiveSource.deleteTask(taskId);
      Logger.task('Task deleted from Hive cache');

      if (await _networkChecker.isConnected()) {
        try {
          // Use Firestore transaction to atomically delete task and update team
          Logger.task('Deleting task from Firebase with transaction...');
          final firestore = FirebaseFirestore.instance;

          await firestore.runTransaction((transaction) async {
            // Delete task document
            final taskRef = firestore.collection('tasks').doc(taskId);
            transaction.delete(taskRef);

            // Remove task ID from team's taskIds array
            if (task.teamId.isNotEmpty) {
              final teamRef = firestore.collection('teams').doc(task.teamId);

              // Get team document first to verify it exists
              final teamDoc = await transaction.get(teamRef);
              if (teamDoc.exists) {
                transaction.update(teamRef, {
                  'taskIds': FieldValue.arrayRemove([taskId]),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Logger.task('Team taskIds update queued in transaction');
              } else {
                Logger.task(
                  'Warning: Team ${task.teamId} not found, skipping taskIds update',
                );
              }
            }

            Logger.task('Task deletion and team update queued in transaction');
          });

          Logger.task('Transaction committed successfully');

          // Update local team cache
          if (task.teamId.isNotEmpty) {
            try {
              final team = await _hiveSource.getTeam(task.teamId);
              if (team != null) {
                final updatedTeam = team.copyWith(
                  taskIds: team.taskIds.where((id) => id != taskId).toList(),
                  updatedAt: DateTime.now(),
                );
                await _hiveSource.saveTeam(updatedTeam);
                Logger.task('Team cache updated, removed task ID');
              }
            } catch (cacheError) {
              Logger.task('Failed to update team cache', error: cacheError);
              // Don't fail the operation if cache update fails
            }
          }

          Logger.task('=== TASK DELETION SUCCESS ===');
        } catch (e) {
          // Firebase failed, but local delete succeeded
          Logger.task('=== FIREBASE DELETE FAILED ===');
          Logger.task('Error: ${e.toString()}');

          // Queue for sync
          await _hiveSource.queueForSync({
            'operation': 'delete_task_and_update_team',
            'type': 'task',
            'taskId': taskId,
            'teamId': task.teamId,
            'timestamp': DateTime.now().toIso8601String(),
          });
          Logger.task('Task deletion queued for sync');
        }
      } else {
        // Offline: queue for sync
        Logger.task('Device offline, queueing task deletion for sync');
        await _hiveSource.queueForSync({
          'operation': 'delete_task_and_update_team',
          'type': 'task',
          'taskId': taskId,
          'teamId': task.teamId,
          'timestamp': DateTime.now().toIso8601String(),
        });

        Logger.task('=== TASK DELETION SUCCESS (OFFLINE) ===');
      }
    } catch (e) {
      Logger.task('=== TASK DELETION FAILED ===');
      Logger.task('Error: ${e.toString()}');
      throw TaskException(
        message: 'Failed to delete task: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Mark task as completed
  Future<TaskModel> markTaskCompleted(String taskId, bool completed) async {
    try {
      Logger.task('Marking task as completed: $taskId');

      // Get current task
      final task = await getTask(taskId);

      // Update completion status
      final updatedTask = task.copyWith(
        status: completed ? TaskStatus.completed : TaskStatus.pending,
        updatedAt: DateTime.now(),
        completedAt: completed ? DateTime.now() : null,
      );

      // Update task
      return await updateTask(updatedTask);
    } catch (e) {
      Logger.task('Error marking task as completed', error: e);
      throw TaskException(
        message: 'Failed to mark task as completed',
        originalError: e,
      );
    }
  }

  /// Assign task to user
  Future<TaskModel> assignTask(String taskId, String userId) async {
    try {
      Logger.task('Assigning task to user: $taskId -> $userId');

      // Get current task
      final task = await getTask(taskId);

      // Update assignment
      final updatedTask = task.copyWith(
        assignedTo: userId,
        updatedAt: DateTime.now(),
      );

      // Update task
      return await updateTask(updatedTask);
    } catch (e) {
      Logger.task('Error assigning task', error: e);
      throw TaskException(message: 'Failed to assign task', originalError: e);
    }
  }

  /// Get sync queue
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    try {
      Logger.task('Getting sync queue');
      return await _hiveSource.getSyncQueue();
    } catch (e) {
      Logger.task('Error getting sync queue', error: e);
      throw TaskException(
        message: 'Failed to get sync queue',
        originalError: e,
      );
    }
  }

  /// Get tasks for user's teams (permission-aware)
  /// Only returns tasks from teams the user belongs to (or all tasks if admin)
  Future<List<TaskModel>> getTasksForUserTeams(
    List<String> teamIds, {
    String? userId,
  }) async {
    try {
      Logger.task('Getting tasks for ${teamIds.length} teams');

      // If userId provided, check if admin
      if (userId != null) {
        final user = await _hiveSource.getUser(userId);
        if (user != null && user.userRole == UserRole.admin) {
          Logger.task('User is admin, loading all tasks instead');
          return await _getAllTasks();
        }
      }

      List<TaskModel> allTasks = [];

      if (await _networkChecker.isConnected()) {
        try {
          // Get tasks from Firebase for each team
          for (final teamId in teamIds) {
            final teamTasks = await _firebaseSource.getTasksByTeam(teamId);
            allTasks.addAll(teamTasks);
          }

          // Cache all tasks locally
          await _hiveSource.cacheTasks(allTasks);

          Logger.task('Loaded ${allTasks.length} tasks from Firebase');
        } catch (e) {
          // Firebase failed, get from local cache
          Logger.task('Firebase failed, loading from cache', error: e);
          allTasks = await _getLocalTasksForTeams(teamIds);
        }
      } else {
        // Offline: get from local cache
        allTasks = await _getLocalTasksForTeams(teamIds);
      }

      Logger.task('Found ${allTasks.length} tasks for user teams');
      return allTasks;
    } catch (e) {
      Logger.task('Error getting tasks for user teams', error: e);
      throw TaskException(
        message: 'Failed to get tasks for user teams',
        originalError: e,
      );
    }
  }

  /// Get tasks from local cache for specific teams
  Future<List<TaskModel>> _getLocalTasksForTeams(List<String> teamIds) async {
    final List<TaskModel> allTasks = [];

    for (final teamId in teamIds) {
      final teamTasks = await _hiveSource.getTasksByTeam(teamId);
      allTasks.addAll(teamTasks);
    }

    Logger.task('Loaded ${allTasks.length} tasks from local cache');
    return allTasks;
  }

  /// Check if user has permission to edit task
  /// User can edit if they created the task or it's assigned to them
  bool canEditTask(TaskModel task, String userId) {
    return task.createdBy == userId || task.assignedTo == userId;
  }

  /// Edit task (with permission check)
  Future<TaskModel> editTask({
    required String taskId,
    required String userId,
    String? taskName,
    int? taskSeverity,
    String? taskDescription,
    bool? taskCompleted,
    String? assignedTo,
  }) async {
    try {
      Logger.task('Editing task: $taskId by user: $userId');

      // Get current task
      final currentTask = await getTask(taskId);

      // Check permissions
      if (!canEditTask(currentTask, userId)) {
        throw TaskException(
          message: 'User does not have permission to edit this task',
        );
      }

      // Convert old field names to new structure
      final priority = taskSeverity != null
          ? _convertSeverityToPriority(taskSeverity)
          : currentTask.priority;
      final status = taskCompleted != null
          ? (taskCompleted ? TaskStatus.completed : TaskStatus.pending)
          : currentTask.status;

      // Create updated task
      final updatedTask = currentTask.copyWith(
        title: taskName ?? currentTask.title,
        description: taskDescription ?? currentTask.description,
        assignedTo: assignedTo ?? currentTask.assignedTo,
        status: status,
        priority: priority,
        updatedAt: DateTime.now(),
        completedAt: taskCompleted == true
            ? DateTime.now()
            : currentTask.completedAt,
      );

      // Update task
      return await updateTask(updatedTask);
    } catch (e) {
      Logger.task('Error editing task', error: e);
      if (e is TaskException) {
        rethrow;
      }
      throw TaskException(message: 'Failed to edit task', originalError: e);
    }
  }

  /// Convert old severity int (1-5) to TaskPriority enum
  TaskPriority _convertSeverityToPriority(int severity) {
    if (severity >= 4) {
      return TaskPriority.high;
    } else if (severity >= 3) {
      return TaskPriority.medium;
    } else {
      return TaskPriority.low;
    }
  }
}
