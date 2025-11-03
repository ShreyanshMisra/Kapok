import '../../core/error/exceptions.dart';
import '../../core/services/network_checker.dart';
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
      Logger.task('Creating task: ${task.taskName}');
      
      // Always save locally first
      await _hiveSource.saveTask(task);
      
      if (await _networkChecker.isConnected()) {
        try {
          // Save to Firebase
          final createdTask = await _firebaseSource.createTask(task);
          
          // Update local cache with Firebase data
          await _hiveSource.saveTask(createdTask);
          
          Logger.task('Task created successfully: ${createdTask.id}');
          return createdTask;
        } catch (e) {
          // Firebase failed, but local save succeeded
          Logger.task('Firebase save failed, task saved locally', error: e);
          return task;
        }
      } else {
        // Offline: queue for sync
        await _hiveSource.queueForSync({
          'operation': 'create',
          'data': task.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        Logger.task('Task created offline: ${task.id}');
        return task;
      }
    } catch (e) {
      Logger.task('Error creating task', error: e);
      throw TaskException(
        message: 'Failed to create task',
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
      throw TaskException(
        message: 'Failed to get task',
        originalError: e,
      );
    }
  }

  /// Get all tasks
  Future<List<TaskModel>> getTasks() async {
    try {
      Logger.task('Getting all tasks');
      
      List<TaskModel> tasks;
      
      if (await _networkChecker.isConnected()) {
        try {
          // Get from Firebase
          tasks = await _firebaseSource.getTasks();
          
          // Cache locally
          await _hiveSource.cacheTasks(tasks);
        } catch (e) {
          // Firebase failed, get from local cache
          tasks = await _hiveSource.getTasks();
        }
      } else {
        // Offline: get from local cache
        tasks = await _hiveSource.getTasks();
      }
      
      Logger.task('Found ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      Logger.task('Error getting tasks', error: e);
      throw TaskException(
        message: 'Failed to get tasks',
        originalError: e,
      );
    }
  }

  /// Get tasks stream
  Stream<List<TaskModel>> getTasksStream({String? teamId, String? userId}) {
    try {
      Logger.task('Starting tasks stream');
      return _firebaseSource.getTasksStream(teamId: teamId, userId: userId).handleError((error) {
        Logger.task('Error in tasks stream', error: error);
        throw TaskException(
          message: 'Failed to stream tasks',
          originalError: error,
        );
      });
    } catch (e) {
      Logger.task('Error creating tasks stream', error: e);
      return Stream.error(TaskException(
        message: 'Failed to create tasks stream',
        originalError: e,
      ));
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
      throw TaskException(
        message: 'Failed to update task',
        originalError: e,
      );
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      Logger.task('Deleting task: $taskId');
      
      // Always delete locally first
      await _hiveSource.deleteTask(taskId);
      
      if (await _networkChecker.isConnected()) {
        try {
          // Delete from Firebase
          await _firebaseSource.deleteTask(taskId);
          
          Logger.task('Task deleted successfully');
        } catch (e) {
          // Firebase failed, but local delete succeeded
          Logger.task('Firebase delete failed, task deleted locally', error: e);
          
          // Queue for sync
          await _hiveSource.queueForSync({
            'operation': 'delete',
            'taskId': taskId,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      } else {
        // Offline: queue for sync
        await _hiveSource.queueForSync({
          'operation': 'delete',
          'taskId': taskId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        Logger.task('Task deleted offline');
      }
    } catch (e) {
      Logger.task('Error deleting task', error: e);
      throw TaskException(
        message: 'Failed to delete task',
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
        taskCompleted: completed,
        updatedAt: DateTime.now(),
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
      throw TaskException(
        message: 'Failed to assign task',
        originalError: e,
      );
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
}
