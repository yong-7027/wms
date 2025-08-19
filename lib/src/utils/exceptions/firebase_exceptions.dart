class TFirebaseException implements Exception {
  /// The error code associated with the exception
  final String code;

  /// Constructor
  TFirebaseException(this.code);

  /// Get the corresponding error message based on the error code
  String get message {
    switch (code) {
      case 'unknown':
        return 'An unknown Firebase error occurred. Please try again.';
      case 'invalid-custom-token':
        return 'The custom token format is incorrect. Please check your custom token.';
      case 'custom-token-mismatch':
        return 'The custom token corresponds to a different audience.';
      case 'invalid-email':
        return 'The email address provided is invalid. Please enter a valid email.';
      case 'email-already-in-use':
        return 'The email address is already registered. Please use a different email.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'user-disabled':
        return 'This user account has been disabled. Please contact support for assistance.';
      case 'user-not-found':
        return 'No user found with the provided credentials. Please sign up or check your login details.';
      case 'wrong-password':
        return 'Incorrect password. Please check your password and try again.';
      case 'invalid-verification-code':
        return 'The verification code provided is invalid. Please enter the correct code.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid. Please request a new verification code.';
      case 'quota-exceeded':
        return 'The quota for this operation has been exceeded. Please try again later.';
      case 'provider-already-linked':
        return 'This account is already linked with another provider.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'user-mismatch':
        return 'The supplied credentials do not match the previously signed-in user.';
      case 'too-many-requests':
        return 'Too many requests have been made. Please try again later.';
      case 'invalid-argument':
        return 'An invalid argument was provided. Please check your input and try again.';
      case 'invalid-phone-number':
        return 'The phone number provided is invalid. Please provide a valid phone number.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support for assistance.';
      case 'invalid-credential':
        return 'The supplied credential is malformed or has expired.';
      case 'captcha-check-failed':
        return 'The reCAPTCHA response is invalid. Please try again.';
      case 'keychain-error':
        return 'A keychain error occurred. Please check the keychain and try again.';
      case 'session-cookie-expired':
        return 'The session cookie has expired. Please log in again.';
      case 'uid-already-exists':
        return 'The provided UID is already in use by another user.';
      case 'expired-action-code':
        return 'The action code has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'The action code is invalid. Please check and try again.';
      case 'missing-email':
        return 'The email address is missing. Please provide an email address.';
      case 'missing-phone-number':
        return 'The phone number is missing. Please provide a phone number.';
      case 'unverified-email':
        return 'The email address has not been verified. Please verify your email before proceeding.';
      case 'network-request-failed':
        return 'A network error occurred. Please check your internet connection and try again.';
      case 'internal-error':
        return 'An internal error occurred. Please try again later.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication. Please check your configuration.';
      case 'invalid-api-key':
        return 'The API key provided is invalid. Please verify your Firebase project settings.';
      case 'app-not-installed':
        return 'The requested app is not installed on this device.';
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'The server is currently unavailable. Please try again later.';
      case 'invalid-sender':
        return 'The sender information is invalid. Please verify and try again.';
      case 'message-payload-too-large':
        return 'The message payload exceeds the allowed size. Please reduce the size and try again.';
      case 'invalid-iframe':
        return 'The iframe configuration is invalid. Please check your setup.';
      case 'unsupported-domain':
        return 'The domain is not supported. Please verify the domain settings.';
      case 'auth-domain-config-required':
        return 'Authentication domain configuration is required. Please set it up in your Firebase console.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }
}
