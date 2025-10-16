import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/logger.dart';
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
      
      emit(AuthAuthenticated(user: user));
      Logger.auth('Sign in successful');
    } catch (e) {
      Logger.auth('Sign in failed', error: e);
      emit(AuthError(message: e.toString()));
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
      
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
        accountType: event.accountType,
        role: event.role,
      );
      
      emit(AuthAuthenticated(user: user));
      Logger.auth('Sign up successful');
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
      emit(const AuthLoading());
      Logger.auth('Profile update requested');
      
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        final updatedUser = currentState.user.copyWith(
          name: event.name,
          role: event.role,
        );
        
        final user = await _authRepository.updateUserProfile(updatedUser);
        
        emit(ProfileUpdated(user: user));
        Logger.auth('Profile updated successfully');
      } else {
        emit(const AuthError(message: 'User not authenticated'));
      }
    } catch (e) {
      Logger.auth('Profile update failed', error: e);
      emit(AuthError(message: e.toString()));
    }
  }
}
