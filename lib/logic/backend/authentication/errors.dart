import 'package:firebase_auth/firebase_auth.dart';

/// From reautenticateWithCredential documentation:
///
/// A [FirebaseAuthException] maybe thrown with the following error code:
/// - **user-mismatch**:
///  - Thrown if the credential given does not correspond to the user.
/// - **user-not-found**:
///  - Thrown if the credential given does not correspond to any existing
///    user.
/// - **invalid-credential**:
///  - Thrown if the provider's credential is not valid. This can happen if it
///    has already expired when calling link, or if it used invalid token(s).
///    See the Firebase documentation for your provider, and make sure you
///    pass in the correct parameters to the credential method.
/// - **invalid-email**:
///  - Thrown if the email used in a [EmailAuthProvider.credential] is
///    invalid.
/// - **wrong-password**:
///  - Thrown if the password used in a [EmailAuthProvider.credential] is not
///    correct or when the user associated with the email does not have a
///    password.
/// - **invalid-verification-code**:
///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
///    verification code of the credential is not valid.
/// - **invalid-verification-id**:
///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
///    verification ID of the credential is not valid.
enum ReauthenticationError {
  userMismatch('user-mismatch'),
  userNotFound('user-not-found'),
  invalidCredential('invalid-credential'),
  invalidEmail('invalid-email'),
  wrongPassword('wrong-password'),
  invalidVerificationCode('invalid-verification-code'),
  invalidVerificationId('invalid-verification-id'),
  tooManyRequests('too-many-requests'),
  unknownError('unknown-error');

  final String string;
  const ReauthenticationError(this.string);

  factory ReauthenticationError.fromString(String from) {
    return ReauthenticationError.values.firstWhere(
      (element) => element.string == from,
      orElse: () => ReauthenticationError.unknownError,
    );
  }
}

/// From signInWithEmailAndPassword documentation:
///
/// A [FirebaseAuthException] maybe thrown with the following error code:
/// - **invalid-email**:
///  - Thrown if the email address is not valid.
/// - **user-disabled**:
///  - Thrown if the user corresponding to the given email has been disabled.
/// - **user-not-found**:
///  - Thrown if there is no user corresponding to the given email.
/// - **wrong-password**:
///  - Thrown if the password is invalid for the given email, or the account
///    corresponding to the email does not have a password set.
enum SignInError {
  invalidEmail('invalid-email'),
  userDisabled('user-disabled'),
  userNotFound('user-not-found'),
  wrongPassword('wrong-password'),
  tooManyRequests('too-many-requests'),
  unknownError('unknown-error');

  final String string;
  const SignInError(this.string);

  factory SignInError.fromString(String from) {
    return SignInError.values.firstWhere(
      (element) => element.string == from,
      orElse: () => SignInError.unknownError,
    );
  }
}

/// From signUpWithEmailAndPassword documentation:
/// A [FirebaseAuthException] maybe thrown with the following error code:
/// - **email-already-in-use**:
///  - Thrown if there already exists an account with the given email address.
/// - **invalid-email**:
///  - Thrown if the email address is not valid.
/// - **operation-not-allowed**:
///  - Thrown if email/password accounts are not enabled. Enable
///    email/password accounts in the Firebase Console, under the Auth tab.
/// - **weak-password**:
///  - Thrown if the password is not strong enough.
enum SignUpError {
  emailAlreadyInUse('email-already-in-use'),
  invalidEmail('invalid-email'),
  operationNotAllowed('operation-not-allowed'),
  weakPassword('weak-password'),
  unknownError('unknown-error');

  final String string;
  const SignUpError(this.string);

  factory SignUpError.fromString(String from) {
    return SignUpError.values.firstWhere(
      (element) => element.string == from,
      orElse: () => SignUpError.unknownError,
    );
  }
}

/// From updateEmail documentation:
///
/// A [FirebaseAuthException] maybe thrown with the following error code:
/// - **invalid-email**:
///  - Thrown if the email used is invalid.
/// - **email-already-in-use**:
///  - Thrown if the email is already used by another user.
/// - **requires-recent-login**:
///  - Thrown if the user's last sign-in time does not meet the security
///    threshold. Use [User.reauthenticateWithCredential] to resolve. This
///    does not apply if the user is anonymous.
enum UpdateEmailError {
  invalidEmail('invalid-email'),
  emailAlreadyInUse('email-already-in-use'),
  requiresRecentLogin('requires-recent-login'),
  unknownError('unknown-error');

  final String string;
  const UpdateEmailError(this.string);

  factory UpdateEmailError.fromString(String from) {
    return UpdateEmailError.values.firstWhere(
      (element) => element.string == from,
      orElse: () => UpdateEmailError.unknownError,
    );
  }
}
