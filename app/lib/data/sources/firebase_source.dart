import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/task_model.dart';

/// Firebase data source for remote operations
class FirebaseSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User operations
  Future<UserModel> createUser(UserModel user) async {
    try {
      Logger.firebase('Creating user: ${user.id}');
      final firestoreData = user.toFirestore();
      Logger.firebase(
        'User model userRole before toFirestore(): ${user.userRole.value}',
      );
      Logger.firebase('Firestore data userRole: ${firestoreData['userRole']}');
      Logger.firebase(
        'Firestore data includes id: ${firestoreData.containsKey('id')}',
      );

      // Use set() with merge: false to create new document
      // Note: The document ID is user.id, and we also include id in the data for backward compatibility
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(firestoreData, SetOptions(merge: false));

      Logger.firebase('User created successfully in Firestore');
      Logger.info('User created with userRole: ${firestoreData['userRole']}');
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
        try {
          return UserModel.fromFirestore(doc);
        } catch (e) {
          Logger.firebase('Error parsing user document', error: e);
          throw DatabaseException(
            message:
                'Failed to parse user data. The user document may be corrupted.',
            originalError: e,
          );
        }
      } else {
        throw DatabaseException(message: 'User not found');
      }
    } catch (e) {
      Logger.firebase('Error getting user', error: e);
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException(message: 'Failed to get user', originalError: e);
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      Logger.firebase('Updating user: ${user.id}');
      // Check if document exists first
      final docRef = _firestore.collection('users').doc(user.id);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Document doesn't exist, create it instead
        Logger.firebase('User document does not exist, creating it');
        await docRef.set(user.toFirestore(), SetOptions(merge: false));
      } else {
        // Document exists, update it
        await docRef.update(user.toFirestore());
      }

      Logger.firebase('User updated successfully');
      return user;
    } catch (e) {
      Logger.firebase('Error updating user', error: e);
      // If update fails because document doesn't exist, try to create it
      if (e.toString().contains('No document to update') ||
          e.toString().contains('not found')) {
        try {
          Logger.firebase('Attempting to create user document instead');
          await _firestore
              .collection('users')
              .doc(user.id)
              .set(user.toFirestore(), SetOptions(merge: false));
          Logger.firebase('User created successfully');
          return user;
        } catch (createError) {
          Logger.firebase('Error creating user', error: createError);
          throw DatabaseException(
            message: 'Failed to create/update user',
            originalError: createError,
          );
        }
      }
      throw DatabaseException(
        message: 'Failed to update user',
        originalError: e,
      );
    }
  }

  // Team operations
  Future<TeamModel> createTeam(TeamModel team) async {
    try {
      Logger.firebase('Creating team: ${team.teamName}');
      Logger.firebase('Team ID: ${team.id}, Team Code: ${team.teamCode}');

      // Use team's ID if provided, otherwise generate new one
      final docRef = team.id.isNotEmpty
          ? _firestore.collection('teams').doc(team.id)
          : _firestore.collection('teams').doc();

      Logger.firebase('Firestore document reference: ${docRef.path}');

      try {
        final teamData = team.toFirestore();
        Logger.firebase(
          'Team data serialized successfully. Keys: ${teamData.keys.join(", ")}',
        );
        Logger.firebase('Team data: $teamData');
      } catch (serializeError) {
        Logger.firebase('Error serializing team data', error: serializeError);
        throw DatabaseException(
          message:
              'Failed to serialize team data: ${serializeError.toString()}',
          originalError: serializeError,
        );
      }

      final teamData = team.toFirestore();
      Logger.firebase('Writing team to Firestore...');
      await docRef.set(teamData);
      Logger.firebase('Team document written to Firestore');

      // Read back to verify creation
      final doc = await docRef.get();
      if (!doc.exists) {
        throw DatabaseException(
          message: 'Team document was not created in Firestore',
        );
      }

      Logger.firebase('Team created successfully: ${docRef.id}');
      Logger.firebase('Verifying team data in Firestore...');
      final createdTeam = TeamModel.fromFirestore(doc);
      Logger.firebase('Team verification successful: ${createdTeam.teamName}');
      return createdTeam;
    } catch (e) {
      Logger.firebase('Error creating team in Firestore', error: e);
      Logger.firebase('Error type: ${e.runtimeType}');
      Logger.firebase('Error details: ${e.toString()}');

      // Check for specific Firestore errors
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('permission-denied')) {
        throw DatabaseException(
          message: 'Permission denied. Please check Firestore security rules.',
          originalError: e,
        );
      } else if (e.toString().contains('index') ||
          e.toString().contains('INDEX')) {
        throw DatabaseException(
          message:
              'Firestore index required. Please create the required index in Firebase Console.',
          originalError: e,
        );
      }

      throw DatabaseException(
        message: 'Failed to create team: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<TeamModel> getTeam(String teamId) async {
    try {
      Logger.firebase('Getting team: $teamId');
      final doc = await _firestore.collection('teams').doc(teamId).get();
      if (doc.exists) {
        return TeamModel.fromFirestore(doc);
      } else {
        throw DatabaseException(message: 'Team not found');
      }
    } catch (e) {
      Logger.firebase('Error getting team', error: e);
      throw DatabaseException(message: 'Failed to get team', originalError: e);
    }
  }

  Future<TeamModel> getTeamByCode(String teamCode) async {
    try {
      Logger.firebase('Getting team by code: $teamCode');
      final query = await _firestore
          .collection('teams')
          .where('teamCode', isEqualTo: teamCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return TeamModel.fromFirestore(query.docs.first);
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

  Future<void> joinTeamByCode(String teamCode, String userId) async {
    try {
      Logger.firebase('Joining team with code: $teamCode for user: $userId');

      final team = await getTeamByCode(teamCode);

      if (team.memberIds.contains(userId)) {
        Logger.firebase('User already in team');
        return;
      }

      await _firestore.collection('teams').doc(team.id).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.firebase('User joined team successfully');
    } catch (e) {
      Logger.firebase('Error joining team', error: e);
      throw DatabaseException(message: 'Failed to join team', originalError: e);
    }
  }

  Future<List<TeamModel>> getUserTeams(String userId) async {
    try {
      Logger.firebase('Getting teams for user: $userId');

      // Query teams where user is a member OR the leader
      // Firestore doesn't support OR queries directly, so we need to do two queries
      final memberQuery = await _firestore
          .collection('teams')
          .where('memberIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final leaderQuery = await _firestore
          .collection('teams')
          .where('leaderId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      // Combine results and remove duplicates
      final allDocs = <String, DocumentSnapshot>{};
      for (final doc in memberQuery.docs) {
        allDocs[doc.id] = doc;
      }
      for (final doc in leaderQuery.docs) {
        allDocs[doc.id] = doc;
      }

      final teams = allDocs.values
          .map((doc) => TeamModel.fromFirestore(doc))
          .toList();
      Logger.firebase(
        'Found ${teams.length} teams for user (${memberQuery.docs.length} as member, ${leaderQuery.docs.length} as leader)',
      );

      return teams;
    } catch (e) {
      Logger.firebase('Error getting user teams', error: e);
      throw DatabaseException(
        message: 'Failed to get user teams',
        originalError: e,
      );
    }
  }

  /// Get all teams (for admin users)
  Future<List<TeamModel>> getAllTeams() async {
    try {
      Logger.firebase('Getting all teams (admin)');

      final snapshot = await _firestore
          .collection('teams')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final teams = snapshot.docs
          .map((doc) => TeamModel.fromFirestore(doc))
          .toList();

      Logger.firebase('Found ${teams.length} teams');
      return teams;
    } catch (e) {
      Logger.firebase('Error getting all teams', error: e);
      throw DatabaseException(
        message: 'Failed to get all teams',
        originalError: e,
      );
    }
  }

  Future<TeamModel> updateTeam(TeamModel team) async {
    try {
      Logger.firebase('Updating team: ${team.id}');
      await _firestore
          .collection('teams')
          .doc(team.id)
          .update(team.toFirestore());
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
      Logger.firebase('Creating task: ${task.title}');
      Logger.firebase('Task ID: ${task.id}');
      Logger.firebase('Task teamId: ${task.teamId}');
      Logger.firebase('Task createdBy: ${task.createdBy}');

      // Use task's ID if provided, otherwise generate new one
      final docRef = task.id.isNotEmpty
          ? _firestore.collection('tasks').doc(task.id)
          : _firestore.collection('tasks').doc();
      final taskData = task.toFirestore();
      Logger.firebase('Task data keys: ${taskData.keys.join(", ")}');

      await docRef.set(taskData);
      Logger.firebase('Task document written to Firestore');

      // Read back to verify creation
      final doc = await docRef.get();
      if (!doc.exists) {
        Logger.firebase('ERROR: Task document was not created in Firestore');
        throw DatabaseException(
          message: 'Task document was not created in Firestore',
        );
      }

      Logger.firebase('Task created successfully: ${docRef.id}');
      Logger.firebase('Verifying task data in Firestore...');
      final createdTask = TaskModel.fromFirestore(doc);
      Logger.firebase('Task verification successful: ${createdTask.title}');
      return createdTask;
    } catch (e) {
      Logger.firebase('Error creating task', error: e);
      Logger.firebase('Error type: ${e.runtimeType}');
      Logger.firebase('Error details: ${e.toString()}');

      // Check for permission errors
      if (e.toString().toLowerCase().contains('permission') ||
          e.toString().toLowerCase().contains('denied')) {
        throw DatabaseException(
          message: 'Permission denied: Check Firestore security rules',
          originalError: e,
        );
      }

      throw DatabaseException(
        message: 'Failed to create task: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Stream<List<TaskModel>> getTasksStream({String? teamId, String? userId}) {
    try {
      Logger.firebase('Getting tasks stream');
      var query = _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true);

      if (teamId != null) {
        query = query.where('teamId', isEqualTo: teamId);
      }

      if (userId != null) {
        query = query.where('assignedTo', isEqualTo: userId);
      }

      return query.snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
      );
    } catch (e) {
      Logger.firebase('Error getting tasks stream', error: e);
      return Stream.error(
        DatabaseException(
          message: 'Failed to get tasks stream',
          originalError: e,
        ),
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
      throw DatabaseException(message: 'Failed to get task', originalError: e);
    }
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      Logger.firebase('Getting all tasks');
      final query = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.firebase('Error getting tasks', error: e);
      throw DatabaseException(message: 'Failed to get tasks', originalError: e);
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

      return query.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
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

      return query.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      Logger.firebase('Error getting user tasks', error: e);
      throw DatabaseException(
        message: 'Failed to get user tasks',
        originalError: e,
      );
    }
  }

  /// Get all tasks (for admin users)
  Future<List<TaskModel>> getAllTasks() async {
    try {
      Logger.firebase('Getting all tasks (admin)');

      final snapshot = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .limit(1000) // Reasonable limit for performance
          .get();

      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();

      Logger.firebase('Found ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      Logger.firebase('Error getting all tasks', error: e);
      throw DatabaseException(
        message: 'Failed to get all tasks',
        originalError: e,
      );
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      Logger.firebase('Updating task: ${task.id}');
      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(task.toFirestore());
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
    } on FirebaseAuthException catch (e) {
      Logger.firebase('Firebase auth error during sign in', error: e);
      // Provide user-friendly error messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Sign in is not allowed. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to sign in. Please try again.';
      }
      throw AuthException(
        message: errorMessage,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.firebase('Error signing in user', error: e);
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        message: 'An unexpected error occurred. Please try again.',
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
      throw AuthException(message: 'Failed to sign out', originalError: e);
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
