/// TFormatException 处理的是 多样化的格式错误，可能会有更多的自定义需求。
/// 用户可以通过 fromMessage 自定义消息
/// 可以通过 code 或直接传递自定义消息
class TFormatException implements Exception {
  final String message;

  const TFormatException([this.message = 'An unexpected format error occurred. Please check your input.']);

  /// Create a format exception from a specific error message
  factory TFormatException.fromMessage(String message) {
    return TFormatException(message);
  }

  /// Get the corresponding error message
  String get formattedMessage => message;

  /// Create a format exception from a specific error code
  factory TFormatException.fromCode(String code) {
    switch (code) {
      case 'invalid-email-format':
        return const TFormatException('The email address format is invalid. Please enter a valid email.');
      case 'invalid-phone-number-format':
        return const TFormatException('The provided phone number format is invalid. Please enter a valid number.');
      case 'invalid-date-format':
        return const TFormatException('The date format is invalid. Please enter a valid date.');
      case 'invalid-url-format':
        return const TFormatException('The url format is invalid. Please enter a valid URL.');
      case 'invalid-credit-card-format':
        return const TFormatException('The credit card format is invalid. Please enter a valid credit card number.');
      case 'invalid-numeric-format':
        return const TFormatException('The input should be a valid numeric format.');
      default:
        return TFormatException();
    }
  }
}