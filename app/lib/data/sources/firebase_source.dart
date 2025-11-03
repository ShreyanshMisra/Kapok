import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/task_model.dart';

/// Firebase data source for remote operations
class FirebaseSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User operations
  Future<UserModel> createUser(UserModel user) async {
    try {
      Logger.firebase('Creating user: ${user.id}');
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      Logger.firebase('User created successfully');
      return user;
    } catch (e) {
      Logger.firebase('Error creating user', error: e);
      throw DatabaseException(
        message: 'Failed to create user',
        originalError: e,
      );
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      Logger.firebase('Getting user: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        throw DatabaseException(message: 'User not found');
      }
    } catch (e) {
      Logger.firebase('Error getting user', error: e);
      throw DatabaseException(
        message: 'Failed to get user',
        originalError: e,
      );
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      Logger.firebase('Updating user: ${user.id}');
      await _firestore.collection('users').doc(user.id).update(user.toJson());
      Logger.firebase('User updated successfully');
      return user;
    } catch (e) {
      Logger.firebase('Error updating user', error: e);
      throw DatabaseException(
        message: 'Failed to update user',
        originalError: e,
      );
    }
  }

  // Team operations
  Future<TeamModel> createTeam(TeamModel team) async {
    try {
      Logger.firebase('Creating team: ${team.id}');
      await _firestore.collection('teams').doc(team.id).set(team.toJson());
      Logger.firebase('Team created successfully');
      return team;
    } catch (e) {
      Logger.firebase('Error creating team', error: e);
      throw DatabaseException(
        message: 'Failed to create team',
        originalError: e,
      );
    }
  }

  Future<TeamModel> getTeam(String teamId) async {
    try {
      Logger.firebase('Getting team: $teamId');
      final doc = await _firestore.collection('teams').doc(teamId).get();
      if (doc.exists) {
        return TeamModel.fromJson(doc.data()!);
      } else {
        throw DatabaseException(message: 'Team not found');
      }
    } catch (e) {
      Logger.firebase('Error getting team', error: e);
      throw DatabaseException(
        message: 'Failed to get team',
        originalError: e,
      );
    }
  }

  Future<TeamModel> getTeamByCode(String teamCode) async {
    try {
      Logger.firebase('Getting team by code: $teamCode');
      final query = await _firestore
          .collection('teams')
          .where('teamCode', isEqualTo: teamCode)
          .where('isActive', isEqualTo: true)
          .get();
      
      if (query.docs.isNotEmpty) {
        return TeamModel.fromJson(query.docs.first.data());
      } else {
        throw DatabaseException(message: 'Team code not found');
      }
    } catch (e) {
      Logger.firebase('Error getting team by code', error: e);
      throw DatabaseException(
        message: 'Failed to get team by code',
        originalError: e,
      );
    }
  }

  Future<List<TeamModel>> getUserTeams(String userId) async {
    try {
      Logger.firebase('Getting teams for user: $userId');
      final query = await _firestore
          .collection('teams')
          .where('memberIds', arrayContains: userId)
          .get();
      
      return query.docs
          .map((doc) => TeamModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Logger.firebase('Error getting user teams', error: e);
      throw DatabaseException(
        message: 'Failed to get user teams',
        originalError: e,
      );
    }
  }

  Future<TeamModel> updateTeam(TeamModel team) async {
    try {
      Logger.firebase('Updating team: ${team.id}');
      await _firestore.collection('teams').doc(team.id).update(team.toJson());
      Logger.firebase('Team updated successfully');
      return team;
    } catch (e) {
      Logger.firebase('Error updating team', error: e);
      throw DatabaseException(
        message: 'Failed to update team',
        originalError: e,
      );
    }
  }

  // Task operations
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      Logger.firebase('Creating task: ${task.id}');
      final docRef = await _firestore.collection('tasks').add(task.toJson());
      final doc = await docRef.get();
      Logger.firebase('Task created successfully');
      return TaskModel.fromFirestore(doc);
    } catch (e) {
      Logger.firebase('Error creating task', error: e);
      throw DatabaseException(
        message: 'Failed to create task',
        originalError: e,
      );
    }
  }

  Future<TaskModel> getTask(String taskId) async {
    try {
      Logger.firebase('Getting task: $taskId');
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (doc.exists) {
        return TaskModel.fromFirestore(doc);
      } else {
        throw DatabaseException(message: 'Task not found');
      }
    } catch (e) {
      Logger.firebase('Error getting task', error: e);
      throw DatabaseException(
        message: 'Failed to get task',
        originalError: e,
      );
    }
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      Logger.firebase('Getting all tasks');
      final query = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.firebase('Error getting tasks', error: e);
      throw DatabaseException(
        message: 'Failed to get tasks',
        originalError: e,
      );
    }
  }

  Future<List<TaskModel>> getTasksByTeam(String teamId) async {
    try {
      Logger.firebase('Getting tasks for team: $teamId');
      final query = await _firestore
          .collection('tasks')
          .where('teamId', isEqualTo: teamId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.firebase('Error getting team tasks', error: e);
      throw DatabaseException(
        message: 'Failed to get team tasks',
        originalError: e,
      );
    }
  }

  Future<List<TaskModel>> getTasksByUser(String userId) async {
    try {
      Logger.firebase('Getting tasks for user: $userId');
      final query = await _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Logger.firebase('Error getting user tasks', error: e);
      throw DatabaseException(
        message: 'Failed to get user tasks',
        originalError: e,
      );
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      Logger.firebase('Updating task: ${task.id}');
      await _firestore.collection('tasks').doc(task.id).update(task.toJson());
      Logger.firebase('Task updated successfully');
      return task;
    } catch (e) {
      Logger.firebase('Error updating task', error: e);
      throw DatabaseException(
        message: 'Failed to update task',
        originalError: e,
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      Logger.firebase('Deleting task: $taskId');
      await _firestore.collection('tasks').doc(taskId).delete();
      Logger.firebase('Task deleted successfully');
    } catch (e) {
      Logger.firebase('Error deleting task', error: e);
      throw DatabaseException(
        message: 'Failed to delete task',
        originalError: e,
      );
    }
  }

  // Authentication operations
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.firebase('Signing in user: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.firebase('User signed in successfully');
      return credential;
    } catch (e) {
      Logger.firebase('Error signing in user', error: e);
      throw AuthException(
        message: 'Failed to sign in',
        originalError: e,
      );
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.firebase('Creating user account: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.firebase('User account created successfully');
      return credential;
    } catch (e) {
      Logger.firebase('Error creating user account', error: e);
      throw AuthException(
        message: 'Failed to create account',
        originalError: e,
      );
    }
  }

  Future<void> signOut() async {
    try {
      Logger.firebase('Signing out user');
      await _auth.signOut();
      Logger.firebase('User signed out successfully');
    } catch (e) {
      Logger.firebase('Error signing out user', error: e);
      throw AuthException(
        message: 'Failed to sign out',
        originalError: e,
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.firebase('Sending password reset email: $email');
      await _auth.sendPasswordResetEmail(email: email);
      Logger.firebase('Password reset email sent successfully');
    } catch (e) {
      Logger.firebase('Error sending password reset email', error: e);
      throw AuthException(
        message: 'Failed to send password reset email',
        originalError: e,
      );
    }
  }

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
