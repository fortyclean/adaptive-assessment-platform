/// Form validation utilities for the Adaptive Assessment Platform.
class AppValidators {
  AppValidators._();

  /// Validates a username field.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم المستخدم مطلوب';
    }
    if (value.trim().length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }

  /// Validates a password field.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير';
    }
    if (!value.contains(RegExp('[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير';
    }
    if (!value.contains(RegExp('[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم';
    }
    return null;
  }

  /// Validates that a confirmation password matches the original.
  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != original) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  /// Validates a required text field.
  static String? validateRequired(String? value, {String fieldName = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validates question count (5-50).
  static String? validateQuestionCount(String? value) {
    if (value == null || value.isEmpty) {
      return 'عدد الأسئلة مطلوب';
    }
    final count = int.tryParse(value);
    if (count == null) {
      return 'يجب أن يكون رقماً صحيحاً';
    }
    if (count < 5 || count > 50) {
      return 'عدد الأسئلة يجب أن يكون بين 5 و 50';
    }
    return null;
  }

  /// Validates time limit in minutes (5-120).
  static String? validateTimeLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'الوقت المحدد مطلوب';
    }
    final minutes = int.tryParse(value);
    if (minutes == null) {
      return 'يجب أن يكون رقماً صحيحاً';
    }
    if (minutes < 5 || minutes > 120) {
      return 'الوقت يجب أن يكون بين 5 و 120 دقيقة';
    }
    return null;
  }
}
