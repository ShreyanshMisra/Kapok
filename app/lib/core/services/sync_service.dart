import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/task_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/user_model.dart';
import '../../data/sources/firebase_source.dart';
import '../../data/sources/hive_source.dart';
import '../utils/logger.dart';
import 'hive_service.dart';

/// Service for syncing local changes to Firebase when online
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();

  SyncService._();

  final HiveSource _hiveSource = HiveSource();
  final FirebaseSource _firebaseSource = FirebaseSource();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Initialize sync service and listen to connectivity changes
  Future<void> initialize() async {
    try {
      Logger.sync('Initializing SyncService');

      // Check connectivity and sync immediately if online
      final connectivityResults = await Connectivity().checkConnectivity();
      final isConnected = !connectivityResults.contains(ConnectivityResult.none);
      if (isConnected) {
        Logger.sync('Device is online, syncing pending changes on startup');
        // Delay slightly to ensure Firebase is fully initialized
        Future.delayed(const Duration(seconds: 2), () async {
          await syncPendingChanges();
        });
      }

      // Listen to connectivity changes
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          final isConnected = !results.contains(ConnectivityResult.none);
          if (isConnected && !_isSyncing) {
            Logger.sync('Device came online, starting sync');
            await syncPendingChanges();
          }
        },
      );

      Logger.sync('SyncService initialized successfully');
    } catch (e) {
      Logger.sync('Error initializing SyncService', error: e);
    }
  }

  /// Sync all pending changes from the queue
  Future<void> syncPendingChanges() async {
    if (_isSyncing) {
      Logger.sync('Sync already in progress, skipping');
      return;
    }

    try {
      _isSyncing = true;
      Logger.sync('Starting sync of pending changes');

      // Get all queued operations
      final syncQueue = await _hiveSource.getSyncQueue();

      if (syncQueue.isEmpty) {
        Logger.sync('No pending changes to sync');
        return;
      }

      Logger.sync('Found ${syncQueue.length} operations to sync');

      // Process each queued operation
      for (final syncData in syncQueue) {
        try {
          await _processSyncItem(syncData);

          // Remove from sync queue after successful sync
          final key = _getSyncKey(syncData);
          if (key != null) {
            await HiveService.instance.syncBox.delete(key);
            Logger.sync('Removed synced operation from queue: $key');
          }
        } catch (e) {
          Logger.sync('Error syncing operation: ${syncData['operation']}', error: e);
          // Continue with next operation even if this one failed
          continue;
        }
      }

      Logger.sync('Sync completed successfully');
    } catch (e) {
      Logger.sync('Error during sync', error: e);
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single sync item
  Future<void> _processSyncItem(Map<String, dynamic> syncData) async {
    final operation = syncData['operation'] as String?;
    final type = syncData['type'] as String?;

    Logger.sync('Processing sync operation: $operation (type: $type)');

    if (operation == null) {
      Logger.sync('Invalid sync data: missing operation');
      return;
    }

    try {
      // Handle task operations
      if (operation == 'create' || operation == 'create_task') {
        final taskData = syncData['data'] as Map<String, dynamic>?;
        if (taskData != null) {
          final task = TaskModel.fromJson(taskData);
          // Use the repository's createTask method to ensure team is updated
          // But we need to use firebase_source directly since we're in sync service
          // The transaction will be handled by the repository if we call it
          // For now, use firebase_source and manually update team
          await _firebaseSource.createTask(task);
          
          // Update team's taskIds array
          try {
            final firestore = FirebaseFirestore.instance;
            final teamRef = firestore.collection('teams').doc(task.teamId);
            await teamRef.update({
              'taskIds': FieldValue.arrayUnion([task.id]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            Logger.sync('Team updated with task ID: ${task.id}');
          } catch (teamError) {
            Logger.sync('Failed to update team with task ID', error: teamError);
            // Don't fail the sync if team update fails - task is already created
          }
          
          Logger.sync('Successfully synced task creation: ${task.id}');
        }
      } else if (operation == 'update' || operation == 'update_task') {
        final taskData = syncData['data'] as Map<String, dynamic>?;
        if (taskData != null) {
          final task = TaskModel.fromJson(taskData);
          await _firebaseSource.updateTask(task);
          Logger.sync('Successfully synced task update: ${task.id}');
        }
      } else if (operation == 'delete' || operation == 'delete_task') {
        final taskId = syncData['taskId'] as String?;
        if (taskId != null) {
          await _firebaseSource.deleteTask(taskId);
          Logger.sync('Successfully synced task deletion: $taskId');
        }
      }
      // Handle team operations
      else if (operation == 'create_team') {
        final teamData = syncData['data'] as Map<String, dynamic>?;
        if (teamData != null) {
          final team = TeamModel.fromJson(teamData);
          await _firebaseSource.createTeam(team);
          Logger.sync('Successfully synced team creation: ${team.id}');
        }
      } else if (operation == 'update_team') {
        final teamData = syncData['data'] as Map<String, dynamic>?;
        if (teamData != null) {
          final team = TeamModel.fromJson(teamData);
          await _firebaseSource.updateTeam(team);
          Logger.sync('Successfully synced team update: ${team.id}');
        }
      } else if (operation == 'delete_team') {
        final teamId = syncData['teamId'] as String?;
        if (teamId != null) {
          final firestore = FirebaseFirestore.instance;
          final teamRef = firestore.collection('teams').doc(teamId);

          // Mark team as inactive (soft delete)
          await teamRef.update({
            'isActive': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          Logger.sync('Successfully synced team deletion: $teamId');
        }
      }
      // Handle user profile operations
      else if (operation == 'update_profile') {
        final userData = syncData['data'] as Map<String, dynamic>?;
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          await _firebaseSource.updateUser(user);
          Logger.sync('Successfully synced user profile update: ${user.id}');
        }
      }
      // Handle team membership operations
      else if (operation == 'join_team') {
        final teamId = syncData['teamId'] as String?;
        final userId = syncData['userId'] as String?;
        if (teamId != null && userId != null) {
          final firestore = FirebaseFirestore.instance;
          final teamRef = firestore.collection('teams').doc(teamId);

          await teamRef.update({
            'memberIds': FieldValue.arrayUnion([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          Logger.sync('Successfully synced team join: user $userId to team $teamId');
        }
      } else if (operation == 'leave_team') {
        final teamId = syncData['teamId'] as String?;
        final userId = syncData['userId'] as String?;
        if (teamId != null && userId != null) {
          final firestore = FirebaseFirestore.instance;
          final teamRef = firestore.collection('teams').doc(teamId);

          await teamRef.update({
            'memberIds': FieldValue.arrayRemove([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          Logger.sync('Successfully synced team leave: user $userId from team $teamId');
        }
      } else if (operation == 'remove_member') {
        final teamId = syncData['teamId'] as String?;
        final memberId = syncData['memberId'] as String?;
        final leaderId = syncData['leaderId'] as String?;
        if (teamId != null && memberId != null) {
          final firestore = FirebaseFirestore.instance;
          final teamRef = firestore.collection('teams').doc(teamId);

          // Verify leader permissions (optional - can be server-side)
          if (leaderId != null) {
            final teamDoc = await teamRef.get();
            if (teamDoc.exists && teamDoc.data()?['leaderId'] == leaderId) {
              await teamRef.update({
                'memberIds': FieldValue.arrayRemove([memberId]),
                'updatedAt': FieldValue.serverTimestamp(),
              });

              Logger.sync('Successfully synced member removal: $memberId from team $teamId');
            } else {
              Logger.sync('Permission denied: user $leaderId is not team leader');
            }
          } else {
            // If no leaderId provided, trust the queued operation
            await teamRef.update({
              'memberIds': FieldValue.arrayRemove([memberId]),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            Logger.sync('Successfully synced member removal: $memberId from team $teamId');
          }
        }
      } else {
        Logger.sync('Unknown operation type: $operation');
      }
    } catch (e) {
      Logger.sync('Error processing sync item: $operation', error: e);
      rethrow;
    }
  }

  /// Get the sync key from sync data
  String? _getSyncKey(Map<String, dynamic> syncData) {
    // The key is stored in the sync box, we need to find it
    // by matching the data
    try {
      for (final key in HiveService.instance.syncBox.keys) {
        final data = HiveService.instance.syncBox.get(key);
        if (data != null && _isSameSyncData(data, syncData)) {
          return key.toString();
        }
      }
    } catch (e) {
      Logger.sync('Error getting sync key', error: e);
    }
    return null;
  }

  /// Check if two sync data objects are the same
  bool _isSameSyncData(dynamic data1, dynamic data2) {
    if (data1 is! Map || data2 is! Map) return false;

    final map1 = Map<String, dynamic>.from(data1);
    final map2 = Map<String, dynamic>.from(data2);

    return map1['operation'] == map2['operation'] &&
        map1['timestamp'] == map2['timestamp'];
  }

  /// Manually trigger sync
  Future<void> manualSync() async {
    Logger.sync('Manual sync triggered');
    await syncPendingChanges();
  }

  /// Get count of pending sync operations
  Future<int> getPendingSyncCount() async {
    try {
      final syncQueue = await _hiveSource.getSyncQueue();
      return syncQueue.length;
    } catch (e) {
      Logger.sync('Error getting pending sync count', error: e);
      return 0;
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    try {
      Logger.sync('Disposing SyncService');
      await _connectivitySubscription?.cancel();
      _connectivitySubscription = null;
      Logger.sync('SyncService disposed successfully');
    } catch (e) {
      Logger.sync('Error disposing SyncService', error: e);
    }
  }
}
