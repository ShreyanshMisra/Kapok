/// Base exception class for all app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'AuthException: $message';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'DatabaseException: $message';
}

/// Location related exceptions
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'LocationException: $message';
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'PermissionException: $message';
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Team related exceptions
class TeamException extends AppException {
  const TeamException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'TeamException: $message';
}

/// Task related exceptions
class TaskException extends AppException {
  const TaskException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'TaskException: $message';
}

/// Offline sync related exceptions
class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'SyncException: $message';
}

