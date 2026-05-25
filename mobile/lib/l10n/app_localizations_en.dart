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

  @override
  String get settings => 'Settings';

  @override
  String get accountSettings => 'Account settings';

  @override
  String get securityAndPrivacy => 'Security and privacy';

  @override
  String get other => 'Other';

  @override
  String get appearance => 'Appearance';

  @override
  String get notifications => 'Notifications';

  @override
  String get aboutApp => 'About app';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle => 'Update the current account password';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editName => 'Edit name';

  @override
  String get editNameTooltip => 'Edit name';

  @override
  String get profileSubtitle =>
      'Manage your profile and app preferences from one place.';

  @override
  String get fullName => 'Full name';

  @override
  String get nameTooShort => 'Name must contain at least two characters';

  @override
  String get nameUpdated => 'Name updated successfully';

  @override
  String get saveFailed => 'Could not save changes. Please try again.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get adminRole => 'Admin';

  @override
  String get teacherRole => 'Teacher';

  @override
  String get studentRole => 'Student';

  @override
  String get userRole => 'User';

  @override
  String get notificationCenter => 'Notification center';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get notificationSettingsSubtitle =>
      'Assessments, results, reports, and instant alerts';

  @override
  String get assessmentNotifications => 'Assessment notifications';

  @override
  String get assessmentNotificationsSubtitle => 'Alerts for new assessments';

  @override
  String get resultNotifications => 'Result notifications';

  @override
  String get resultNotificationsSubtitle => 'Alerts when results are available';

  @override
  String get resultNotificationSettings => 'Result notification settings';

  @override
  String get darkModeCurrentlyEnabled => 'Currently enabled';

  @override
  String get darkModeCurrentlyDisabled => 'Currently disabled';

  @override
  String get aboutAndChangelog => 'About app and changelog';

  @override
  String versionLabel(Object version) {
    return 'Version $version — EduAssess';
  }

  @override
  String get support => 'Support';

  @override
  String get supportSubtitle => 'Contact the support team';

  @override
  String get helpCenter => 'Help center';

  @override
  String get helpCenterSubtitle => 'Technical support and app information';

  @override
  String get logout => 'Log out';

  @override
  String get logoutQuestion => 'Do you want to log out?';

  @override
  String get logoutAccountQuestion => 'Do you want to log out of your account?';

  @override
  String get logoutConfirm => 'Log out';

  @override
  String get legalese => '© 2026 EduAssess. All rights reserved.';

  @override
  String get smartAssessment => 'Smart assessment';

  @override
  String get studentFallbackName => 'Student';

  @override
  String welcomeName(Object name) {
    return 'Welcome, $name';
  }

  @override
  String registeredSubjectsCount(Object count) {
    return 'You have $count registered subjects this term';
  }

  @override
  String get searchSubjectHint => 'Search for a subject...';

  @override
  String get filterAll => 'All';

  @override
  String get filterFirstTerm => 'First term';

  @override
  String get filterScience => 'Science';

  @override
  String get filterLiterary => 'Literary';

  @override
  String get filterAcademic => 'Academic';

  @override
  String get filterPractical => 'Practical';

  @override
  String get noMatchingSubjects => 'No matching subjects';

  @override
  String get progressAchieved => 'Progress achieved';

  @override
  String get finalExamsPrepTitle => 'Get ready for final exams!';

  @override
  String get finalExamsPrepSubtitle =>
      'Review previous lessons and assess your level through smart assessments.';

  @override
  String get startNow => 'Start now';
}
