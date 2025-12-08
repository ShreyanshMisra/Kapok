import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/task_model.dart';
import '../../data/models/team_model.dart';
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
          await _firebaseSource.createTask(task);
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
