import 'package:hive_flutter/hive_flutter.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';

/// Service for handling Hive database operations
class HiveService {
  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();
  
  HiveService._();

  // Box names
  static const String _usersBox = 'users';
  static const String _teamsBox = 'teams';
  static const String _tasksBox = 'tasks';
  static const String _settingsBox = 'settings';
  static const String _syncBox = 'sync';

  // Box instances
  Box? _usersBoxInstance;
  Box? _teamsBoxInstance;
  Box? _tasksBoxInstance;
  Box? _settingsBoxInstance;
  Box? _syncBoxInstance;

  /// Initializes Hive
  Future<void> initialize() async {
    try {
      Logger.hive('Initializing Hive');
      
      // Initialize Hive
      await Hive.initFlutter();
      
      // Open boxes
      _usersBoxInstance = await Hive.openBox(_usersBox);
      _teamsBoxInstance = await Hive.openBox(_teamsBox);
      _tasksBoxInstance = await Hive.openBox(_tasksBox);
      _settingsBoxInstance = await Hive.openBox(_settingsBox);
      _syncBoxInstance = await Hive.openBox(_syncBox);
      
      Logger.hive('Hive initialized successfully');
    } catch (e) {
      Logger.hive('Failed to initialize Hive', error: e);
      throw CacheException(
        message: 'Failed to initialize Hive',
        originalError: e,
      );
    }
  }

  /// Gets users box
  Box get usersBox {
    if (_usersBoxInstance == null) {
      throw CacheException(message: 'Users box not initialized');
    }
    return _usersBoxInstance!;
  }

  /// Gets teams box
  Box get teamsBox {
    if (_teamsBoxInstance == null) {
      throw CacheException(message: 'Teams box not initialized');
    }
    return _teamsBoxInstance!;
  }

  /// Gets tasks box
  Box get tasksBox {
    if (_tasksBoxInstance == null) {
      throw CacheException(message: 'Tasks box not initialized');
    }
    return _tasksBoxInstance!;
  }

  /// Gets settings box
  Box get settingsBox {
    if (_settingsBoxInstance == null) {
      throw CacheException(message: 'Settings box not initialized');
    }
    return _settingsBoxInstance!;
  }

  /// Gets sync box
  Box get syncBox {
    if (_syncBoxInstance == null) {
      throw CacheException(message: 'Sync box not initialized');
    }
    return _syncBoxInstance!;
  }

  /// Stores user data
  Future<void> storeUser(String userId, Map<String, dynamic> userData) async {
    try {
      Logger.hive('Storing user: $userId');
      await usersBox.put(userId, userData);
      Logger.hive('User stored successfully');
    } catch (e) {
      Logger.hive('Error storing user: $userId', error: e);
      throw CacheException(
        message: 'Failed to store user',
        originalError: e,
      );
    }
  }

  /// Gets user data
  Map<String, dynamic>? getUser(String userId) {
    try {
      Logger.hive('Getting user: $userId');
      final userData = usersBox.get(userId);
      Logger.hive('User retrieved successfully');
      return userData;
    } catch (e) {
      Logger.hive('Error getting user: $userId', error: e);
      throw CacheException(
        message: 'Failed to get user',
        originalError: e,
      );
    }
  }

  /// Stores team data
  Future<void> storeTeam(String teamId, Map<String, dynamic> teamData) async {
    try {
      Logger.hive('Storing team: $teamId');
      await teamsBox.put(teamId, teamData);
      Logger.hive('Team stored successfully');
    } catch (e) {
      Logger.hive('Error storing team: $teamId', error: e);
      throw CacheException(
        message: 'Failed to store team',
        originalError: e,
      );
    }
  }

  /// Gets team data
  Map<String, dynamic>? getTeam(String teamId) {
    try {
      Logger.hive('Getting team: $teamId');
      final teamData = teamsBox.get(teamId);
      Logger.hive('Team retrieved successfully');
      return teamData;
    } catch (e) {
      Logger.hive('Error getting team: $teamId', error: e);
      throw CacheException(
        message: 'Failed to get team',
        originalError: e,
      );
    }
  }

  /// Stores task data
  Future<void> storeTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      Logger.hive('Storing task: $taskId');
      await tasksBox.put(taskId, taskData);
      Logger.hive('Task stored successfully');
    } catch (e) {
      Logger.hive('Error storing task: $taskId', error: e);
      throw CacheException(
        message: 'Failed to store task',
        originalError: e,
      );
    }
  }

  /// Gets task data
  Map<String, dynamic>? getTask(String taskId) {
    try {
      Logger.hive('Getting task: $taskId');
      final taskData = tasksBox.get(taskId);
      Logger.hive('Task retrieved successfully');
      return taskData;
    } catch (e) {
      Logger.hive('Error getting task: $taskId', error: e);
      throw CacheException(
        message: 'Failed to get task',
        originalError: e,
      );
    }
  }

  /// Gets all tasks
  List<Map<String, dynamic>> getAllTasks() {
    try {
      Logger.hive('Getting all tasks');
      final tasks = tasksBox.values
          .map((task) => Map<String, dynamic>.from(task))
          .toList();
      Logger.hive('All tasks retrieved successfully: ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      Logger.hive('Error getting all tasks', error: e);
      throw CacheException(
        message: 'Failed to get all tasks',
        originalError: e,
      );
    }
  }

  /// Gets tasks by team
  List<Map<String, dynamic>> getTasksByTeam(String teamId) {
    try {
      Logger.hive('Getting tasks for team: $teamId');
      final tasks = tasksBox.values
          .map((task) => Map<String, dynamic>.from(task))
          .where((task) => task['teamId'] == teamId)
          .toList();
      Logger.hive('Team tasks retrieved successfully: ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      Logger.hive('Error getting tasks for team: $teamId', error: e);
      throw CacheException(
        message: 'Failed to get tasks for team',
        originalError: e,
      );
    }
  }

  /// Gets tasks by user
  List<Map<String, dynamic>> getTasksByUser(String userId) {
    try {
      Logger.hive('Getting tasks for user: $userId');
      final tasks = tasksBox.values
          .map((task) => Map<String, dynamic>.from(task))
          .where((task) => task['assignedTo'] == userId || task['createdBy'] == userId)
          .toList();
      Logger.hive('User tasks retrieved successfully: ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      Logger.hive('Error getting tasks for user: $userId', error: e);
      throw CacheException(
        message: 'Failed to get tasks for user',
        originalError: e,
      );
    }
  }

  /// Deletes task
  Future<void> deleteTask(String taskId) async {
    try {
      Logger.hive('Deleting task: $taskId');
      await tasksBox.delete(taskId);
      Logger.hive('Task deleted successfully');
    } catch (e) {
      Logger.hive('Error deleting task: $taskId', error: e);
      throw CacheException(
        message: 'Failed to delete task',
        originalError: e,
      );
    }
  }

  /// Stores setting
  Future<void> storeSetting(String key, dynamic value) async {
    try {
      Logger.hive('Storing setting: $key');
      await settingsBox.put(key, value);
      Logger.hive('Setting stored successfully');
    } catch (e) {
      Logger.hive('Error storing setting: $key', error: e);
      throw CacheException(
        message: 'Failed to store setting',
        originalError: e,
      );
    }
  }

  /// Gets setting
  T? getSetting<T>(String key) {
    try {
      Logger.hive('Getting setting: $key');
      final value = settingsBox.get(key);
      Logger.hive('Setting retrieved successfully');
      return value;
    } catch (e) {
      Logger.hive('Error getting setting: $key', error: e);
      throw CacheException(
        message: 'Failed to get setting',
        originalError: e,
      );
    }
  }

  /// Stores sync data
  Future<void> storeSyncData(String key, Map<String, dynamic> data) async {
    try {
      Logger.hive('Storing sync data: $key');
      await syncBox.put(key, data);
      Logger.hive('Sync data stored successfully');
    } catch (e) {
      Logger.hive('Error storing sync data: $key', error: e);
      throw CacheException(
        message: 'Failed to store sync data',
        originalError: e,
      );
    }
  }

  /// Gets sync data
  Map<String, dynamic>? getSyncData(String key) {
    try {
      Logger.hive('Getting sync data: $key');
      final data = syncBox.get(key);
      Logger.hive('Sync data retrieved successfully');
      return data;
    } catch (e) {
      Logger.hive('Error getting sync data: $key', error: e);
      throw CacheException(
        message: 'Failed to get sync data',
        originalError: e,
      );
    }
  }

  /// Gets all sync data
  List<Map<String, dynamic>> getAllSyncData() {
    try {
      Logger.hive('Getting all sync data');
      final data = syncBox.values
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      Logger.hive('All sync data retrieved successfully: ${data.length} items');
      return data;
    } catch (e) {
      Logger.hive('Error getting all sync data', error: e);
      throw CacheException(
        message: 'Failed to get all sync data',
        originalError: e,
      );
    }
  }

  /// Clears all data
  Future<void> clearAllData() async {
    try {
      Logger.hive('Clearing all data');
      await usersBox.clear();
      await teamsBox.clear();
      await tasksBox.clear();
      await settingsBox.clear();
      await syncBox.clear();
      Logger.hive('All data cleared successfully');
    } catch (e) {
      Logger.hive('Error clearing all data', error: e);
      throw CacheException(
        message: 'Failed to clear all data',
        originalError: e,
      );
    }
  }

  /// Clears specific box
  Future<void> clearBox(String boxName) async {
    try {
      Logger.hive('Clearing box: $boxName');
      Box box;
      switch (boxName) {
        case _usersBox:
          box = usersBox;
          break;
        case _teamsBox:
          box = teamsBox;
          break;
        case _tasksBox:
          box = tasksBox;
          break;
        case _settingsBox:
          box = settingsBox;
          break;
        case _syncBox:
          box = syncBox;
          break;
        default:
          throw CacheException(message: 'Unknown box name: $boxName');
      }
      
      await box.clear();
      Logger.hive('Box cleared successfully: $boxName');
    } catch (e) {
      Logger.hive('Error clearing box: $boxName', error: e);
      throw CacheException(
        message: 'Failed to clear box',
        originalError: e,
      );
    }
  }

  /// Gets box size
  int getBoxSize(String boxName) {
    try {
      Box box;
      switch (boxName) {
        case _usersBox:
          box = usersBox;
          break;
        case _teamsBox:
          box = teamsBox;
          break;
        case _tasksBox:
          box = tasksBox;
          break;
        case _settingsBox:
          box = settingsBox;
          break;
        case _syncBox:
          box = syncBox;
          break;
        default:
          throw CacheException(message: 'Unknown box name: $boxName');
      }
      
      return box.length;
    } catch (e) {
      Logger.hive('Error getting box size: $boxName', error: e);
      throw CacheException(
        message: 'Failed to get box size',
        originalError: e,
      );
    }
  }

  /// Closes all boxes
  Future<void> close() async {
    try {
      Logger.hive('Closing all boxes');
      await Hive.close();
      Logger.hive('All boxes closed successfully');
    } catch (e) {
      Logger.hive('Error closing boxes', error: e);
      throw CacheException(
        message: 'Failed to close boxes',
        originalError: e,
      );
    }
  }
}
