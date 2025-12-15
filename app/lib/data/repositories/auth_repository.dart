import 'package:firebase_auth/firebase_auth.dart';
import '../../core/error/exceptions.dart';
import '../../core/enums/user_role.dart';
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
      UserModel? user;
      try {
        user = await _firebaseSource.getUser(credential.user!.uid);
        Logger.auth('User document found in Firestore: ${user.id}');
      } catch (e) {
        // If user document doesn't exist, create a temporary user for onboarding
        // Check for DatabaseException or string-based error messages
        final errorString = e.toString().toLowerCase();
        final isUserNotFound =
            e is DatabaseException &&
                (e.message.toLowerCase().contains('user not found') ||
                    e.message.toLowerCase().contains('not found')) ||
            errorString.contains('user not found') ||
            errorString.contains('not found') ||
            errorString.contains('no document');

        if (isUserNotFound) {
          Logger.auth(
            'User document not found - creating temporary user for onboarding',
          );

          // Create temporary user model (will be updated during onboarding)
          user = UserModel(
            id: credential.user!.uid,
            name:
                credential.user!.displayName ??
                credential.user!.email?.split('@')[0] ??
                'User',
            email: credential.user!.email ?? email,
            userRole:
                UserRole.teamMember, // Default, will be set during onboarding
            role: '', // Will be set during onboarding
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Don't save to Firestore yet - will be saved after role selection
          // Just cache locally for now
          await _hiveSource.saveUser(user);

          Logger.auth('Temporary user created for onboarding');
          return user;
        } else {
          // Re-throw other errors (like parsing errors)
          Logger.auth('Unexpected error getting user', error: e);
          rethrow;
        }
      }

      // Cache user locally
      await _hiveSource.saveUser(user);

      Logger.auth('User signed in successfully: ${user.id}');
      return user;
    } catch (e) {
      Logger.auth('Error signing in user', error: e);
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(message: 'Failed to sign in', originalError: e);
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
        throw AuthException(
          message: 'Account creation failed - no user returned',
        );
      }

      // Convert accountType string to UserRole enum
      Logger.auth('Converting accountType: "$accountType" to UserRole');
      Logger.info(
        'Converting accountType: "$accountType" to role: ${UserRole.fromString(accountType).value}',
      );
      final userRole = UserRole.fromString(accountType);
      Logger.auth(
        'Converted to UserRole: ${userRole.value} (${userRole.displayName})',
      );
      Logger.info(
        'UserRole conversion result: input="$accountType", output="${userRole.value}"',
      );

      // Create user model
      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        userRole: userRole,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to Firestore
      Logger.auth(
        'Saving user to Firestore with userRole: ${user.userRole.value}',
      );
      final createdUser = await _firebaseSource.createUser(user);
      Logger.auth('User saved to Firestore successfully');

      // Verify the write by reading back from Firestore
      try {
        final verification = await _firebaseSource.getUser(user.id);
        Logger.auth(
          'User created in Firestore - verification read-back: userRole=${verification.userRole.value}',
        );
        Logger.info(
          'Created user role in Firestore: ${verification.userRole.value}',
        );
        if (verification.userRole != userRole) {
          Logger.error(
            'ROLE MISMATCH: Expected ${userRole.value}, but Firestore has ${verification.userRole.value}',
          );
          throw AuthException(
            message:
                'Role mismatch after creation. Expected ${userRole.value}, got ${verification.userRole.value}',
          );
        }
        Logger.auth('VERIFICATION SUCCESS: User found in Firebase');
      } catch (e) {
        Logger.error('Failed to verify user creation', error: e);
        // If verification fails, it might be a permission issue - throw error
        if (e.toString().toLowerCase().contains('permission') ||
            e.toString().toLowerCase().contains('denied')) {
          throw AuthException(
            message: 'Permission denied: Check Firestore security rules',
            originalError: e,
          );
        }
        // Don't throw for other verification errors, as the user was created
      }

      // Cache user locally (save both original and created user data)
      await _hiveSource.saveUser(createdUser);

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
      throw AuthException(message: 'Failed to sign out', originalError: e);
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

      // Try to get user from Firestore first
      if (await _networkChecker.isConnected()) {
        try {
          final user = await _firebaseSource.getUser(firebaseUser.uid);
          await _hiveSource.saveUser(user);
          return user;
        } catch (e) {
          // If user doesn't exist in Firestore, check if they need onboarding
          if (e.toString().contains('User not found') ||
              e.toString().contains('not found')) {
            Logger.auth(
              'User document not found in Firestore - may need onboarding',
            );
            // Return null to trigger onboarding flow
            return null;
          }
          // Fallback to local cache for other errors
          Logger.auth('Firebase error, trying local cache', error: e);
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
      } else {
        // Queue for sync when offline
        await _hiveSource.queueForSync({
          'operation': 'update_profile',
          'data': updatedUser.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });
        Logger.auth('Profile update queued for sync (offline)');
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
  Stream<User?> get authStateChanges => _firebaseSource.authStateChanges;
}
