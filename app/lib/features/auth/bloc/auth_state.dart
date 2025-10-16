import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

/// Authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Password reset email sent
class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Profile updated
class ProfileUpdated extends AuthState {
  final UserModel user;

  const ProfileUpdated({required this.user});

  @override
  List<Object> get props => [user];
}
