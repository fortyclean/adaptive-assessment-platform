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

  @override
  String get back => 'Back';

  @override
  String get retry => 'Retry';

  @override
  String get openAssessments => 'Open assessments';

  @override
  String get flashcardPracticeTitle => 'Flashcard practice';

  @override
  String get flashcardLoadFailedTitle => 'Could not load flashcards';

  @override
  String get flashcardLoadFailedMessage =>
      'Could not prepare practice cards. Check your connection and try again.';

  @override
  String get flashcardEmptyTitle => 'No flashcards yet';

  @override
  String get flashcardEmptyMessage =>
      'Complete one assessment so we can build cards based on your performance.';

  @override
  String flashcardSemanticsAnswerVisible(Object skill) {
    return '$skill card. The answer is visible.';
  }

  @override
  String flashcardSemanticsTapToReveal(Object skill) {
    return '$skill card. Tap to reveal the answer.';
  }

  @override
  String get needReview => 'Need review';

  @override
  String get masteredIt => 'Mastered it';

  @override
  String get showAnswer => 'Show answer';

  @override
  String get answer => 'Answer';

  @override
  String get flashcardSummaryTitle => 'Flashcard practice complete';

  @override
  String flashcardSummaryMessage(Object correctCount, Object totalCount) {
    return 'You mastered $correctCount of $totalCount cards. Schedule a short review for the cards you repeated.';
  }

  @override
  String get mastery => 'Mastery';

  @override
  String get forReview => 'For review';

  @override
  String get restartPractice => 'Restart practice';

  @override
  String get backToLearningPlan => 'Back to learning plan';

  @override
  String get teacherFallbackName => 'Teacher';

  @override
  String teacherWelcome(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get search => 'Search';

  @override
  String get teacherDashboardLoadFailed =>
      'Could not load the teacher dashboard. Check your connection and try again.';

  @override
  String get totalStudents => 'Total students';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed';

  @override
  String get draft => 'Draft';

  @override
  String get average => 'Average';

  @override
  String get createNewAssessment => 'Create new assessment';

  @override
  String get recentAssessments => 'Recent assessments';

  @override
  String get viewAll => 'View all';

  @override
  String get noAssessmentsCreatedYet =>
      'You have not created any assessment yet';

  @override
  String get additionalTools => 'Additional tools';

  @override
  String get taskManagement => 'Task management';

  @override
  String get certificates => 'Certificates';

  @override
  String get classSchedule => 'Class schedule';

  @override
  String get myClasses => 'My classes';

  @override
  String get assessmentReport => 'Assessment report';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get teacherReportLoadFailed => 'Could not load the report';

  @override
  String get nameHeader => 'Name';

  @override
  String get scoreHeader => 'Score';

  @override
  String get statusHeader => 'Status';

  @override
  String get timeMinutesHeader => 'Time (minutes)';

  @override
  String get timeout => 'Timed out';

  @override
  String get resultsSummary => 'Results summary';

  @override
  String get classAverage => 'Class average';

  @override
  String get highestScore => 'Highest score';

  @override
  String get lowestScore => 'Lowest score';

  @override
  String get scoreDistribution => 'Score distribution';

  @override
  String get skillMasteryLevels => 'Skill mastery levels';

  @override
  String get studentResults => 'Student results';

  @override
  String get noResultsYet => 'No results yet';

  @override
  String get coreConceptAnalysis => 'Detailed core concept analysis';

  @override
  String get goodMastery => 'Good mastery';

  @override
  String get needsImprovement => 'Needs improvement';

  @override
  String targetPercent(Object percent) {
    return 'Target: $percent%';
  }

  @override
  String minutesSeconds(Object minutes, Object seconds) {
    return '$minutes min $seconds sec';
  }
}
