// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'منصة التقييم التكيفي';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get chooseLanguage => 'اختيار اللغة';

  @override
  String get languageArabicSelected => 'اللغة: العربية';

  @override
  String get languageEnglishSelected => 'Language: English';

  @override
  String get languageChanged => 'تم تغيير لغة التطبيق';

  @override
  String get languageAndAppearance => 'المظهر واللغة';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get darkModeEnabled => 'مفعل على كل الشاشات المدعومة';

  @override
  String get darkModeDisabled => 'تطبيق المظهر الداكن على واجهات التطبيق';
}
