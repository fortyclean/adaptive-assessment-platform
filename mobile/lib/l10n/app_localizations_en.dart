// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Adaptive Assessment Platform';

  @override
  String get appLanguage => 'App language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get languageArabicSelected => 'Language: Arabic';

  @override
  String get languageEnglishSelected => 'Language: English';

  @override
  String get languageChanged => 'App language changed';

  @override
  String get languageAndAppearance => 'Appearance and language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeEnabled => 'Enabled across supported screens';

  @override
  String get darkModeDisabled => 'Apply dark appearance to app screens';
}
