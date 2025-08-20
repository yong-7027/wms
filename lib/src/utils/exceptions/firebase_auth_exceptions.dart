/// TAuthFirebaseException 主要用于处理 Firebase 提供的标准化错误代码，这些代码是一个 固定集合，它的逻辑更封闭，用户不需要自定义消息。
/// 固定在类内部的 switch-case 中
/// 只能通过 code 传入并生成对应消息
class TFirebaseAuthException implements Exception {
  final String code;

  TFirebaseAuthException(this.code);

  String get message {
    switch (code) {
      case 'unknown':
        return 'An unknown firebase error occurred. Please try again.';
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
        return 'Invalid login details. Please create an account before login.';
      case 'wrong-password':
        return 'Incorrect password. Please check your password and try again.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please enter a valid code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new verification code.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      case 'email-already-exists':
        return 'The email address already exists. Please use a different email.';
      case 'provider-already-linked':
        return 'The account is already linked with another provider.';
      case 'request-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please log in again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      case 'user-mismatch':
        return 'The supplied credentials do not match the previously signed-in user.';
      case 'too-many-requests':
        return 'Too many requests have been made. Please try again later.';
      case 'invalid-argument':
        return 'An invalid argument was provided to an authentication method.';
      case 'invalid-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-phone-number':
        return 'The provided phone number is invalid.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support for assistance.';
      case 'session-cookie-expired':
        return 'The session cookie has expired. Please log in again.';
      case 'uid-already-exists':
        return 'The provided UID is already in use by another user.';
      case 'expired-action-code':
        return 'The action code has expired. Please try again.';
      case 'invalid-action-code':
        return 'The action code is invalid. Please check and try again.';
      case 'missing-email':
        return 'The email address is missing. Please provide an email.';
      case 'missing-phone-number':
        return 'The phone number is missing. Please provide a phone number.';
      case 'unverified-email':
        return 'The email address has not been verified. Please verify your email.';
      case 'requires-recent-login':
        return 'This operation requires recent login. Please log in again.';
      case 'network-request-failed':
        return 'A network error occurred. Please check your internet connection and try again.';
      case 'internal-error':
        return 'An internal error occurred. Please try again later.';
      case 'app-not-authorized':
        return 'The app is not authorized to use Firebase Authentication.';
      case 'invalid-api-key':
        return 'The provided API key is invalid.';
      case 'app-not-installed':
        return 'The application is not installed.';
      case 'invalid-sender':
        return 'The sender ID is invalid. Please check your configuration.';
      case 'message-payload-too-large':
        return 'The message payload is too large. Please reduce its size and try again.';
      case 'invalid-iframe':
        return 'The iframe content is invalid or unsupported.';
      case 'unsupported-domain':
        return 'The domain is unsupported. Please check your settings.';
      case 'invalid-recipient':
        return 'The recipient information is invalid. Please verify the recipient details.';
      case 'timeout':
        return 'The request timed out. Please try again later.';
      case 'invalid-auth-event':
        return 'An invalid authentication event occurred. Please retry the operation.';
      case 'popup-blocked':
        return 'The popup was blocked by the browser. Please allow popups and try again.';
      case 'popup-closed-by-user':
        return 'The popup was closed before completing the operation. Please try again.';
      case 'invalid-credential':
        return 'The supplied credential is malformed or has expired. Please try again.';
      case 'missing-iframe':
        return 'An iframe is required for this operation but is missing. Please check your setup.';
      case 'missing-api-key':
        return 'The API key is missing. Please provide a valid API key.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }
}
