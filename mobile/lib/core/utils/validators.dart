/// Form validation utilities for the Adaptive Assessment Platform.
class AppValidators {
  AppValidators._();

  /// Validates a username field.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  /// Validates a password field.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp('[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp('[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Validates that a confirmation password matches the original.
  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation is required';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  /// Validates a required text field.
  static String? validateRequired(String? value,
      {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates question count (5-50).
  static String? validateQuestionCount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Question count is required';
    }
    final count = int.tryParse(value);
    if (count == null) {
      return 'Enter a valid whole number';
    }
    if (count < 5 || count > 50) {
      return 'Question count must be between 5 and 50';
    }
    return null;
  }

  /// Validates time limit in minutes (5-120).
  static String? validateTimeLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time limit is required';
    }
    final minutes = int.tryParse(value);
    if (minutes == null) {
      return 'Enter a valid whole number';
    }
    if (minutes < 5 || minutes > 120) {
      return 'Time limit must be between 5 and 120 minutes';
    }
    return null;
  }
}
