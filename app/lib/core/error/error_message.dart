import 'exceptions.dart';

/// Fallback shown when an error has no message written for users.
const String genericErrorMessage = 'Something went wrong. Please try again.';

/// Text that is safe to show a user for [error].
///
/// App exceptions carry a message written for users; anything else (Firebase,
/// platform, or programming errors) gets [fallback] instead of its raw
/// `toString()`, which would read like "DatabaseException: …" or
/// "[cloud_firestore/permission-denied] …". Log the raw error separately.
String userMessageFor(Object error, {String fallback = genericErrorMessage}) {
  if (error is AppException && error.message.trim().isNotEmpty) {
    return error.message;
  }
  return fallback;
}
