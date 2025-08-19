class TValidator {
  TValidator._();

  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the $fieldName.';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the email address.';
    }
    
    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the password.';
    }

    // Check for minimum password length
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for lowercase letters
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the confirmation password';
    }

    // 确保确认密码与原始密码相同
    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the phone number.';
    }

    // Regular expression for phone number validation
    final phoneRegExp = RegExp(r'^01\d{1}-\d{7,8}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format.';
    }

    return null;
  }
}