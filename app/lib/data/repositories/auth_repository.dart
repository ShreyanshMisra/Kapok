import 'package:firebase_auth/firebase_auth.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/network_checker.dart';
import '../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../sources/firebase_source.dart';
import '../sources/hive_source.dart';

/// Repository for authentication operations
class AuthRepository {
  final FirebaseSource _firebaseSource;
  final HiveSource _hiveSource;
  final NetworkChecker _networkChecker;

  AuthRepository({
    required FirebaseSource firebaseSource,
    required HiveSource hiveSource,
    required NetworkChecker networkChecker,
  }) : _firebaseSource = firebaseSource,
       _hiveSource = hiveSource,
       _networkChecker = networkChecker;

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.auth('Signing in user: $email');
      
      // Sign in with Firebase
      final credential = await _firebaseSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException(message: 'Sign in failed - no user returned');
      }
      
      // Get user data from Firestore
      final user = await _firebaseSource.getUser(credential.user!.uid);
      
      // Cache user locally
      await _hiveSource.saveUser(user);
      
      Logger.auth('User signed in successfully: ${user.id}');
      return user;
    } catch (e) {
      Logger.auth('Error signing in user', error: e);
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        message: 'Failed to sign in',
        originalError: e,
      );
    }
  }

  /// Create user account with email and password
  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String accountType,
    required String role,
  }) async {
    try {
      Logger.auth('Creating user account: $email');
      
      // Create Firebase user
      final credential = await _firebaseSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException(message: 'Account creation failed - no user returned');
      }
      
      // Create user model
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        accountType: accountType,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save user to Firestore
      await _firebaseSource.createUser(user);
      
      // Cache user locally
      await _hiveSource.saveUser(user);
      
      Logger.auth('User account created successfully: ${user.id}');
      return user;
    } catch (e) {
      Logger.auth('Error creating user account', error: e);
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        message: 'Failed to create account',
        originalError: e,
      );
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      Logger.auth('Signing out user');
      
      // Sign out from Firebase
      await _firebaseSource.signOut();
      
      // Clear local cache
      // TODO: Implement local cache clearing
      // await _hiveSource.clearUserData();
      
      Logger.auth('User signed out successfully');
    } catch (e) {
      Logger.auth('Error signing out user', error: e);
      throw AuthException(
        message: 'Failed to sign out',
        originalError: e,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.auth('Sending password reset email: $email');
      
      await _firebaseSource.sendPasswordResetEmail(email);
      
      Logger.auth('Password reset email sent successfully');
    } catch (e) {
      Logger.auth('Error sending password reset email', error: e);
      throw AuthException(
        message: 'Failed to send password reset email',
        originalError: e,
      );
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseSource.currentUser;
      if (firebaseUser == null) {
        return null;
      }
      
      // Try to get user from local cache first
      if (await _networkChecker.isConnected()) {
        try {
          final user = await _firebaseSource.getUser(firebaseUser.uid);
          await _hiveSource.saveUser(user);
          return user;
        } catch (e) {
          // Fallback to local cache
          return await _hiveSource.getUser(firebaseUser.uid);
        }
      } else {
        // Offline: get from local cache
        return await _hiveSource.getUser(firebaseUser.uid);
      }
    } catch (e) {
      Logger.auth('Error getting current user', error: e);
      return null;
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      Logger.auth('Updating user profile: ${user.id}');
      
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      
      if (await _networkChecker.isConnected()) {
        // Update on Firebase
        await _firebaseSource.updateUser(updatedUser);
      }
      
      // Always update local cache
      await _hiveSource.saveUser(updatedUser);
      
      Logger.auth('User profile updated successfully');
      return updatedUser;
    } catch (e) {
      Logger.auth('Error updating user profile', error: e);
      throw AuthException(
        message: 'Failed to update profile',
        originalError: e,
      );
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _firebaseSource.currentUser != null;

  /// Get current Firebase user
  User? get currentFirebaseUser => _firebaseSource.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseSource.auth.authStateChanges();
}
