import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../error/exceptions.dart';
import '../utils/logger.dart';

/// Firebase service for managing Firebase operations
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  /// Initializes Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      Logger.firebase('Firebase initialized successfully');
    } catch (e) {
      Logger.firebase('Failed to initialize Firebase', error: e);
      throw DatabaseException(
        message: 'Failed to initialize Firebase',
        originalError: e,
      );
    }
  }

  /// Gets current user
  User? get currentUser => auth.currentUser;

  /// Checks if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Signs in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.auth('Attempting to sign in with email: $email');
      
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      Logger.auth('Successfully signed in user: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      Logger.auth('Firebase auth error during sign in', error: e);
      throw AuthException(
        message: _getAuthErrorMessage(e),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.auth('Unexpected error during sign in', error: e);
      throw AuthException(
        message: 'An unexpected error occurred during sign in',
        originalError: e,
      );
    }
  }

  /// Creates user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      Logger.auth('Attempting to create user with email: $email');
      
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      Logger.auth('Successfully created user: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      Logger.auth('Firebase auth error during user creation', error: e);
      throw AuthException(
        message: _getAuthErrorMessage(e),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.auth('Unexpected error during user creation', error: e);
      throw AuthException(
        message: 'An unexpected error occurred during user creation',
        originalError: e,
      );
    }
  }

  /// Signs out current user
  Future<void> signOut() async {
    try {
      Logger.auth('Signing out user: ${currentUser?.uid}');
      await auth.signOut();
      Logger.auth('Successfully signed out');
    } catch (e) {
      Logger.auth('Error during sign out', error: e);
      throw AuthException(
        message: 'Failed to sign out',
        originalError: e,
      );
    }
  }

  /// Sends password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Logger.auth('Sending password reset email to: $email');
      await auth.sendPasswordResetEmail(email: email);
      Logger.auth('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      Logger.auth('Firebase auth error during password reset', error: e);
      throw AuthException(
        message: _getAuthErrorMessage(e),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.auth('Unexpected error during password reset', error: e);
      throw AuthException(
        message: 'An unexpected error occurred while sending password reset email',
        originalError: e,
      );
    }
  }

  /// Updates user password
  Future<void> updatePassword(String newPassword) async {
    try {
      Logger.auth('Updating password for user: ${currentUser?.uid}');
      await currentUser?.updatePassword(newPassword);
      Logger.auth('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      Logger.auth('Firebase auth error during password update', error: e);
      throw AuthException(
        message: _getAuthErrorMessage(e),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.auth('Unexpected error during password update', error: e);
      throw AuthException(
        message: 'An unexpected error occurred while updating password',
        originalError: e,
      );
    }
  }

  /// Deletes current user account
  Future<void> deleteUser() async {
    try {
      Logger.auth('Deleting user account: ${currentUser?.uid}');
      await currentUser?.delete();
      Logger.auth('User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      Logger.auth('Firebase auth error during account deletion', error: e);
      throw AuthException(
        message: _getAuthErrorMessage(e),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      Logger.auth('Unexpected error during account deletion', error: e);
      throw AuthException(
        message: 'An unexpected error occurred while deleting account',
        originalError: e,
      );
    }
  }

  /// Gets Firestore document
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      Logger.database('Getting document: $collection/$docId');
      final doc = await firestore.collection(collection).doc(docId).get();
      Logger.database('Document retrieved successfully');
      return doc;
    } catch (e) {
      Logger.database('Error getting document: $collection/$docId', error: e);
      throw DatabaseException(
        message: 'Failed to get document',
        originalError: e,
      );
    }
  }

  /// Sets Firestore document
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      Logger.database('Setting document: $collection/$docId');
      await firestore.collection(collection).doc(docId).set(data);
      Logger.database('Document set successfully');
    } catch (e) {
      Logger.database('Error setting document: $collection/$docId', error: e);
      throw DatabaseException(
        message: 'Failed to set document',
        originalError: e,
      );
    }
  }

  /// Updates Firestore document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      Logger.database('Updating document: $collection/$docId');
      await firestore.collection(collection).doc(docId).update(data);
      Logger.database('Document updated successfully');
    } catch (e) {
      Logger.database('Error updating document: $collection/$docId', error: e);
      throw DatabaseException(
        message: 'Failed to update document',
        originalError: e,
      );
    }
  }

  /// Deletes Firestore document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      Logger.database('Deleting document: $collection/$docId');
      await firestore.collection(collection).doc(docId).delete();
      Logger.database('Document deleted successfully');
    } catch (e) {
      Logger.database('Error deleting document: $collection/$docId', error: e);
      throw DatabaseException(
        message: 'Failed to delete document',
        originalError: e,
      );
    }
  }

  /// Gets Firestore collection
  Future<QuerySnapshot> getCollection(String collection, {Query? query}) async {
    try {
      Logger.database('Getting collection: $collection');
      final snapshot = query != null 
          ? await query.get()
          : await firestore.collection(collection).get();
      Logger.database('Collection retrieved successfully');
      return snapshot;
    } catch (e) {
      Logger.database('Error getting collection: $collection', error: e);
      throw DatabaseException(
        message: 'Failed to get collection',
        originalError: e,
      );
    }
  }

  /// Listens to Firestore document changes
  Stream<DocumentSnapshot> listenToDocument(String collection, String docId) {
    Logger.database('Listening to document: $collection/$docId');
    return firestore.collection(collection).doc(docId).snapshots();
  }

  /// Listens to Firestore collection changes
  Stream<QuerySnapshot> listenToCollection(String collection, {Query? query}) {
    Logger.database('Listening to collection: $collection');
    return query != null 
        ? query.snapshots()
        : firestore.collection(collection).snapshots();
  }

  /// Uploads file to Firebase Storage
  Future<String> uploadFile(String path, List<int> data) async {
    try {
      Logger.firebase('Uploading file to: $path');
      final ref = storage.ref().child(path);
      final uploadTask = ref.putData(Uint8List.fromList(data));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      Logger.firebase('File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      Logger.firebase('Error uploading file to: $path', error: e);
      throw DatabaseException(
        message: 'Failed to upload file',
        originalError: e,
      );
    }
  }

  /// Downloads file from Firebase Storage
  Future<List<int>> downloadFile(String path) async {
    try {
      Logger.firebase('Downloading file from: $path');
      final ref = storage.ref().child(path);
      final data = await ref.getData();
      Logger.firebase('File downloaded successfully');
      return data ?? [];
    } catch (e) {
      Logger.firebase('Error downloading file from: $path', error: e);
      throw DatabaseException(
        message: 'Failed to download file',
        originalError: e,
      );
    }
  }

  /// Deletes file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      Logger.firebase('Deleting file from: $path');
      final ref = storage.ref().child(path);
      await ref.delete();
      Logger.firebase('File deleted successfully');
    } catch (e) {
      Logger.firebase('Error deleting file from: $path', error: e);
      throw DatabaseException(
        message: 'Failed to delete file',
        originalError: e,
      );
    }
  }

  /// Converts Firebase Auth error to user-friendly message
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}

