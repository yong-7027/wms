class TPlatformException implements Exception {
  /// The error code associated with the exception
  final String code;

  /// Constructor
  TPlatformException(this.code);

  /// Get the corresponding error message based on the error code
  String get message {
    switch (code) {
      case 'invalid-login-credentials':
        return 'Invalid login credentials. Please ensure your username and password are correct and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please wait and try again later.';
      case 'network-error':
        return 'Network error. Please check your internet connection.';
      case 'service-unavailable':
        return 'Service unavailable. Please try again later.';
      case 'permission-denied':
        return 'Permission denied. You do not have the required access.';
      case 'resource-not-found':
        return 'Requested resource not found.';
      case 'invalid-argument':
        return 'Invalid argument provided. Please check your input.';
      case 'authentication-failed':
        return 'Authentication failed. Please try again.';
      case 'timeout':
        return 'The operation timed out. Please try again later.';
      case 'operation-not-supported':
        return 'This operation is not supported.';
      case 'data-corruption':
        return 'Data corruption detected. Please contact support.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }
}
