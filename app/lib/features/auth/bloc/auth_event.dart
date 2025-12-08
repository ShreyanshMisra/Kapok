import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Sign in with email and password
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Create user account
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String accountType; // Keep for backward compatibility, will be converted to UserRole
  final String role;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.accountType,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, name, accountType, role];
}

/// Sign out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Send password reset email
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Check authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Update user profile
class ProfileUpdateRequested extends AuthEvent {
  final String? name;
  final String? role;
  final UserModel? user; // Optional: if provided, use this user model directly

  const ProfileUpdateRequested({
    this.name,
    this.role,
    this.user,
  });

  @override
  List<Object?> get props => [name, role, user];
}
