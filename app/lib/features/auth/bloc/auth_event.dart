import 'package:equatable/equatable.dart';
import '../../../core/enums/user_role.dart';
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

/// Permanently delete the current user's account.
///
/// [onComplete] receives null on success or an error message on failure.
/// Failures are reported this way rather than through AuthLoading/AuthError,
/// because returning to AuthAuthenticated from either makes the app's auth
/// listener navigate home.
class DeleteAccountRequested extends AuthEvent {
  /// Current password, used to re-authenticate before deletion.
  final String password;
  final void Function(String? error)? onComplete;

  const DeleteAccountRequested({required this.password, this.onComplete});
}

/// Update user profile
///
/// [onComplete] receives null on success or an error message on failure.
/// Failures are reported this way rather than through [AuthError], because
/// AuthError -> AuthAuthenticated makes the app's auth listener navigate home.
class ProfileUpdateRequested extends AuthEvent {
  final String? name;
  final String? role;
  final UserModel? user; // Optional: if provided, use this user model directly
  final void Function(String? error)? onComplete;

  const ProfileUpdateRequested({
    this.name,
    this.role,
    this.user,
    this.onComplete,
  });

  @override
  List<Object?> get props => [name, role, user];
}

/// Event to switch the signed-in user between team member and team leader.
///
/// [onComplete] receives null on success or an error message on failure.
/// Failures are reported this way rather than through [AuthError], because
/// AuthError -> AuthAuthenticated makes the app's auth listener navigate home.
class UserRoleChangeRequested extends AuthEvent {
  final UserRole newRole;
  final void Function(String? error)? onComplete;

  const UserRoleChangeRequested(this.newRole, {this.onComplete});

  @override
  List<Object?> get props => [newRole];
}
