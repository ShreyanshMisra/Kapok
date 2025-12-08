import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  /// Handle sign in request
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      Logger.auth('Sign in requested for: ${event.email}');
      
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      // Check if user needs onboarding
      // Refined onboarding logic: role-specific requirements
      final needsOnboarding = (user.userRole == UserRole.teamLeader && user.teamId == null) ||
          (user.userRole == UserRole.teamMember && user.teamId == null) ||
          (user.role.isEmpty && user.userRole != UserRole.admin);
      
      emit(AuthAuthenticated(
        user: user,
        needsOnboarding: needsOnboarding,
        isNewSignup: false, // Existing user sign-in
      ));
      if (needsOnboarding) {
        Logger.auth('Sign in successful - user needs onboarding');
      } else {
        Logger.auth('Sign in successful');
      }
    } catch (e) {
      Logger.auth('Sign in failed', error: e);
      // Extract user-friendly error message
      String errorMessage;
      if (e is AuthException) {
        errorMessage = e.message;
      } else if (e is DatabaseException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
        // Try to extract a more user-friendly message
        final errorStr = errorMessage.toLowerCase();
        if (errorStr.contains('user not found') || errorStr.contains('not found')) {
          errorMessage = 'User account not found. Please sign up first.';
        } else if (errorStr.contains('wrong password') || errorStr.contains('invalid password')) {
          errorMessage = 'Incorrect password. Please try again.';
        } else if (errorStr.contains('network') || errorStr.contains('connection')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else {
          errorMessage = 'Failed to sign in. Please try again.';
        }
      }
      emit(AuthError(message: errorMessage));
    }
  }

  /// Handle sign up request
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      Logger.auth('Sign up requested for: ${event.email}');
      Logger.info('SignUpRequested event - accountType: "${event.accountType}", role: "${event.role}"');
      
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        accountType: event.accountType,
        role: event.role,
      );
      
      Logger.auth('User created with role: ${user.userRole.value}');
      
      // For new signups, determine navigation based on role
      // Leaders must create team, members must join team, admins go to home
      final needsOnboarding = (user.userRole == UserRole.teamLeader && user.teamId == null) ||
          (user.userRole == UserRole.teamMember && user.teamId == null) ||
          (user.role.isEmpty && user.userRole != UserRole.admin);
      
      emit(AuthAuthenticated(
        user: user,
        needsOnboarding: needsOnboarding,
        isNewSignup: true, // Mark as new signup
      ));
      Logger.auth('Sign up successful - userRole: ${user.userRole.value}, needsOnboarding: $needsOnboarding');
    } catch (e) {
      Logger.auth('Sign up failed', error: e);
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle sign out request
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      Logger.auth('Sign out requested');
      
      await _authRepository.signOut();
      
      emit(const AuthUnauthenticated());
      Logger.auth('Sign out successful');
    } catch (e) {
      Logger.auth('Sign out failed', error: e);
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle password reset request
  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      Logger.auth('Password reset requested for: ${event.email}');
      
      await _authRepository.sendPasswordResetEmail(event.email);
      
      emit(PasswordResetSent(email: event.email));
      Logger.auth('Password reset email sent');
    } catch (e) {
      Logger.auth('Password reset failed', error: e);
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle authentication check request
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      Logger.auth('Auth check requested');
      
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        emit(AuthAuthenticated(user: user));
        Logger.auth('User is authenticated');
      } else {
        emit(const AuthUnauthenticated());
        Logger.auth('User is not authenticated');
      }
    } catch (e) {
      Logger.auth('Auth check failed', error: e);
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle profile update request
  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Don't emit AuthLoading for profile updates - keep user authenticated
      // This prevents navigation issues when updating profile after team creation
      Logger.auth('Profile update requested');
      
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        UserModel updatedUser;
        
        // If user model provided directly, use it; otherwise update fields
        if (event.user != null) {
          updatedUser = event.user!;
        } else {
          updatedUser = currentState.user.copyWith(
            name: event.name ?? currentState.user.name,
            role: event.role ?? currentState.user.role,
            updatedAt: DateTime.now(),
          );
        }
        
        final user = await _authRepository.updateUserProfile(updatedUser);
        
        // Re-evaluate onboarding status after update
        final needsOnboarding = (user.userRole == UserRole.teamLeader && user.teamId == null) ||
            (user.userRole == UserRole.teamMember && user.teamId == null) ||
            (user.role.isEmpty && user.userRole != UserRole.admin);
        
        // Emit new authenticated state without going through loading
        // This prevents navigation issues
        emit(AuthAuthenticated(
          user: user,
          needsOnboarding: needsOnboarding,
          isNewSignup: false,
        ));
        Logger.auth('Profile updated successfully');
      } else {
        // If not authenticated, don't emit error - just log it
        // This prevents navigation to login page
        Logger.auth('Profile update skipped - user not authenticated');
      }
    } catch (e) {
      Logger.auth('Profile update failed', error: e);
      // Don't emit AuthError - keep user authenticated even if update fails
      // This prevents navigation to login page
      // The error is logged but user stays authenticated
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        // Keep the current authenticated state
        emit(currentState);
      }
    }
  }
}
