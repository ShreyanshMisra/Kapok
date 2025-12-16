import '../../core/error/exceptions.dart';
import '../../core/services/hive_service.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/task_model.dart';

/// Hive data source for local operations
class HiveSource {
  // User operations
  Future<void> saveUser(UserModel user) async {
    try {
      Logger.hive('Saving user: ${user.id}');
      await HiveService.instance.storeUser(user.id, user.toJson());
      Logger.hive('User saved successfully');
    } catch (e) {
      Logger.hive('Error saving user', error: e);
      throw CacheException(message: 'Failed to save user', originalError: e);
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      Logger.hive('Getting user: $userId');
      final userData = HiveService.instance.getUser(userId);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      Logger.hive('Error getting user', error: e);
      throw CacheException(message: 'Failed to get user', originalError: e);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      Logger.hive('Deleting user: $userId');
      await HiveService.instance.usersBox.delete(userId);
      Logger.hive('User deleted successfully');
    } catch (e) {
      Logger.hive('Error deleting user', error: e);
      throw CacheException(message: 'Failed to delete user', originalError: e);
    }
  }

  // Team operations
  Future<void> saveTeam(TeamModel team) async {
    try {
      Logger.hive('Saving team: ${team.id}');
      await HiveService.instance.storeTeam(team.id, team.toJson());
      Logger.hive('Team saved successfully');
    } catch (e) {
      Logger.hive('Error saving team', error: e);
      throw CacheException(message: 'Failed to save team', originalError: e);
    }
  }

  Future<TeamModel?> getTeam(String teamId) async {
    try {
      Logger.hive('Getting team: $teamId');
      final teamData = HiveService.instance.getTeam(teamId);
      if (teamData != null) {
        return TeamModel.fromJson(teamData);
      }
      return null;
    } catch (e) {
      Logger.hive('Error getting team', error: e);
      throw CacheException(message: 'Failed to get team', originalError: e);
    }
  }

  Future<List<TeamModel>> getUserTeams(String userId) async {
    try {
      Logger.hive('Getting teams for user: $userId');
      final teams = HiveService.instance.teamsBox.values
          .map((data) => TeamModel.fromJson(Map<String, dynamic>.from(data)))
          .where(
            (team) =>
                team.memberIds.contains(userId) || team.leaderId == userId,
          )
          .toList();
      return teams;
    } catch (e) {
      Logger.hive('Error getting user teams', error: e);
      throw CacheException(
        message: 'Failed to get user teams',
        originalError: e,
      );
    }
  }

  /// Get all teams (for admin users)
  Future<List<TeamModel>> getAllTeams() async {
    try {
      Logger.hive('Getting all teams');
      final teams = HiveService.instance.teamsBox.values
          .map((data) => TeamModel.fromJson(Map<String, dynamic>.from(data)))
          .where((team) => team.isActive) // Only active teams
          .toList();
      return teams;
    } catch (e) {
      Logger.hive('Error getting all teams', error: e);
      throw CacheException(
        message: 'Failed to get all teams',
        originalError: e,
      );
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      Logger.hive('Deleting team: $teamId');
      await HiveService.instance.teamsBox.delete(teamId);
      Logger.hive('Team deleted successfully');
    } catch (e) {
      Logger.hive('Error deleting team', error: e);
      throw CacheException(message: 'Failed to delete team', originalError: e);
    }
  }

  // Task operations
  Future<void> saveTask(TaskModel task) async {
    try {
      Logger.hive('Saving task: ${task.id}');
      await HiveService.instance.storeTask(task.id, task.toJson());
      Logger.hive('Task saved successfully');
    } catch (e) {
      Logger.hive('Error saving task', error: e);
      throw CacheException(message: 'Failed to save task', originalError: e);
    }
  }

  Future<TaskModel?> getTask(String taskId) async {
    try {
      Logger.hive('Getting task: $taskId');
      final taskData = HiveService.instance.getTask(taskId);
      if (taskData != null) {
        return TaskModel.fromJson(taskData);
      }
      return null;
    } catch (e) {
      Logger.hive('Error getting task', error: e);
      throw CacheException(message: 'Failed to get task', originalError: e);
    }
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      Logger.hive('Getting all tasks');
      final tasks = HiveService.instance
          .getAllTasks()
          .map((data) => TaskModel.fromJson(data))
          .toList();
      return tasks;
    } catch (e) {
      Logger.hive('Error getting tasks', error: e);
      throw CacheException(message: 'Failed to get tasks', originalError: e);
    }
  }

  Future<List<TaskModel>> getTasksByTeam(String teamId) async {
    try {
      Logger.hive('Getting tasks for team: $teamId');
      final rawTasks = HiveService.instance.getTasksByTeam(teamId);
      final tasks = <TaskModel>[];
      
      for (final data in rawTasks) {
        try {
          tasks.add(TaskModel.fromJson(data));
        } catch (parseError) {
          // Skip malformed task data, log the error but don't fail
          Logger.hive('Warning: Failed to parse task data, skipping', error: parseError);
        }
      }
      
      Logger.hive('Got ${tasks.length} tasks for team $teamId');
      return tasks;
    } catch (e) {
      // Return empty list instead of throwing - this allows the UI to show "no tasks"
      // rather than an error when cache is empty or not initialized
      Logger.hive('Error getting team tasks, returning empty list', error: e);
      return [];
    }
  }

  Future<List<TaskModel>> getTasksByUser(String userId) async {
    try {
      Logger.hive('Getting tasks for user: $userId');
      final tasks = HiveService.instance
          .getTasksByUser(userId)
          .map((data) => TaskModel.fromJson(data))
          .toList();
      return tasks;
    } catch (e) {
      Logger.hive('Error getting user tasks', error: e);
      throw CacheException(
        message: 'Failed to get user tasks',
        originalError: e,
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      Logger.hive('Deleting task: $taskId');
      await HiveService.instance.deleteTask(taskId);
      Logger.hive('Task deleted successfully');
    } catch (e) {
      Logger.hive('Error deleting task', error: e);
      throw CacheException(message: 'Failed to delete task', originalError: e);
    }
  }

  // Cache operations
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      Logger.hive('Caching ${tasks.length} tasks');
      for (final task in tasks) {
        await HiveService.instance.storeTask(task.id, task.toJson());
      }
      Logger.hive('Tasks cached successfully');
    } catch (e) {
      Logger.hive('Error caching tasks', error: e);
      throw CacheException(message: 'Failed to cache tasks', originalError: e);
    }
  }

  Future<void> cacheTeams(List<TeamModel> teams) async {
    try {
      Logger.hive('Caching ${teams.length} teams');
      for (final team in teams) {
        await HiveService.instance.storeTeam(team.id, team.toJson());
      }
      Logger.hive('Teams cached successfully');
    } catch (e) {
      Logger.hive('Error caching teams', error: e);
      throw CacheException(message: 'Failed to cache teams', originalError: e);
    }
  }

  // Sync operations
  Future<void> queueForSync(Map<String, dynamic> syncData) async {
    try {
      Logger.hive('Queuing for sync: ${syncData['operation']}');
      await HiveService.instance.storeSyncData(
        'sync_${DateTime.now().millisecondsSinceEpoch}',
        syncData,
      );
      Logger.hive('Queued for sync successfully');
    } catch (e) {
      Logger.hive('Error queuing for sync', error: e);
      throw CacheException(
        message: 'Failed to queue for sync',
        originalError: e,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    try {
      Logger.hive('Getting sync queue');
      return HiveService.instance.getAllSyncData();
    } catch (e) {
      Logger.hive('Error getting sync queue', error: e);
      throw CacheException(
        message: 'Failed to get sync queue',
        originalError: e,
      );
    }
  }
}
