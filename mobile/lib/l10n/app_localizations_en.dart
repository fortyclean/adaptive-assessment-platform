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
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get enterCurrentPassword => 'Please enter your current password';

  @override
  String get enterNewPassword => 'Please enter your new password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordMinLength => 'Must be at least 8 characters';

  @override
  String get passwordNeedsUppercase => 'Must contain an uppercase letter';

  @override
  String get passwordNeedsDigit => 'Must contain a number';

  @override
  String get passwordRequirements => 'Password requirements:';

  @override
  String get passwordRequirementMin8 => 'At least 8 characters';

  @override
  String get passwordRequirementUppercase => 'At least one uppercase letter';

  @override
  String get passwordRequirementDigit => 'At least one number';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get genericRetryError => 'Something went wrong. Please try again';

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
  String get home => 'Home';

  @override
  String get adminAccount => 'Admin account';

  @override
  String get fillBlankAnswerSemantics => 'Enter your answer';

  @override
  String get fillBlankAnswerHint => 'Type your answer here...';

  @override
  String get essayAnswerSemantics => 'Write your essay answer';

  @override
  String get essayManualReviewNotice =>
      'This question requires manual review by the teacher';

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

  @override
  String get studentPerformanceReportType => 'Student performance';

  @override
  String get questionQualityReportType => 'Question bank quality';

  @override
  String get classroomComparisonReportType => 'Classroom comparison';

  @override
  String get skillAnalysisReportType => 'Skill analysis report';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get reportSchedulesLoadFailed =>
      'Could not load report schedules. Check your connection and try again.';

  @override
  String get addAtLeastOneEmail => 'Add at least one email address';

  @override
  String get scheduleSavedSuccessfully => 'Schedule saved successfully';

  @override
  String scheduleSaveFailed(Object error) {
    return 'Could not save schedule: $error';
  }

  @override
  String get scheduleSavedDemo => 'Schedule saved successfully (demo mode)';

  @override
  String get deleteScheduleTitle => 'Delete schedule';

  @override
  String get deleteScheduleConfirmation =>
      'Are you sure you want to delete this schedule?';

  @override
  String get delete => 'Delete';

  @override
  String get scheduleDeletedSuccessfully => 'Schedule deleted successfully';

  @override
  String scheduleDeleteFailed(Object error) {
    return 'Could not delete: $error';
  }

  @override
  String scheduleToggleFailed(Object error) {
    return 'Could not change status: $error';
  }

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get reportScheduling => 'Report scheduling';

  @override
  String get reportSchedulingSubtitle =>
      'Set up recurring reports that are sent automatically to your email.';

  @override
  String get newScheduleSetup => 'Set up a new schedule';

  @override
  String get reportType => 'Report type';

  @override
  String get selectClasses => 'Select classes';

  @override
  String get frequency => 'Frequency';

  @override
  String get deliveryTime => 'Delivery time';

  @override
  String get recipientEmails => 'Recipient email addresses';

  @override
  String get fileFormat => 'File format';

  @override
  String get saving => 'Saving...';

  @override
  String get saveSchedule => 'Save schedule';

  @override
  String get enable => 'Enable';

  @override
  String get addClassSoon => 'Adding a new class will be available soon';

  @override
  String get addClass => 'Add class';

  @override
  String get activeSchedules => 'Active schedules';

  @override
  String reportsCount(Object count) {
    return '$count reports';
  }

  @override
  String get noActiveSchedules => 'No active schedules';

  @override
  String get createScheduleUsingForm =>
      'Create a new schedule using the form above';

  @override
  String get paused => 'Paused';

  @override
  String get pendingEssaysTitle => 'Essay questions — pending grading';

  @override
  String get pendingEssaysLoadFailed => 'Could not load pending sessions';

  @override
  String get noPendingEssaysTitle => 'No essay questions pending grading';

  @override
  String get noPendingEssaysMessage => 'All essay sessions have been graded';

  @override
  String get assessmentFallbackTitle => 'Assessment';

  @override
  String get startGrading => 'Start grading';

  @override
  String questionsCount(Object count) {
    return '$count questions';
  }

  @override
  String get resultScreenTitle => 'Assessment result';

  @override
  String get resultLoadFailed => 'Could not load the result. Please try again.';

  @override
  String get skillAnalysis => 'Skill analysis';

  @override
  String get wrongQuestions => 'Wrong questions';

  @override
  String get pendingReviewTitle => 'Pending review';

  @override
  String pendingReviewMessage(Object countText) {
    return 'Your assessment was submitted successfully. It includes $countText essay questions that need manual teacher review.\n\nYou will receive a notification when grading is complete.';
  }

  @override
  String get someQuestions => 'some';

  @override
  String get backToHome => 'Back to home';

  @override
  String get scoreExcellent => 'Excellent';

  @override
  String get scoreGood => 'Good';

  @override
  String get scoreNeedsImprovement => 'Needs improvement';

  @override
  String get greatAchievement => 'Great achievement!';

  @override
  String get earnedExcellenceBadge => 'You earned the excellence badge';

  @override
  String pointsEarnedLabel(Object points) {
    return '+$points points';
  }

  @override
  String bonusPointsLabel(Object points) {
    return '+$points bonus';
  }

  @override
  String get strengthPoint => 'Strength';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get studentAssessmentsLoadFailed =>
      'Could not load assessments. Check your connection and try again.';

  @override
  String studentAssessmentsGreeting(Object name) {
    return 'Welcome, $name';
  }

  @override
  String studentAssessmentsAvailableToday(Object count, Object label) {
    return 'You have $count $label available today.';
  }

  @override
  String get availableAssessmentSingular => 'assessment';

  @override
  String get availableAssessmentPlural => 'assessments';

  @override
  String get availableAssessments => 'Available assessments';

  @override
  String get upcomingAssessments => 'Upcoming';

  @override
  String get previousResults => 'Previous results';

  @override
  String get noAvailableAssessmentsTitle => 'No available assessments';

  @override
  String get noAvailableAssessmentsMessage =>
      'Available assessments will appear here when your teacher publishes them.';

  @override
  String get noUpcomingAssessmentsTitle => 'No upcoming assessments';

  @override
  String get noUpcomingAssessmentsMessage =>
      'Scheduled future assessments will appear here.';

  @override
  String get noPreviousResultsTitle => 'No previous results';

  @override
  String get noPreviousResultsMessage =>
      'Your completed assessment results will appear here.';

  @override
  String get assessmentFallback => 'Assessment';

  @override
  String get notStartedYet => 'Not started yet';

  @override
  String questionCountLabel(Object count) {
    return '$count questions';
  }

  @override
  String minuteCountLabel(Object count) {
    return '$count minutes';
  }

  @override
  String get finalReviewTitle => 'Final review';

  @override
  String get finalReviewSubtitle =>
      'Get ready for end-of-year exams with our smart practice models.';

  @override
  String get recentResults => 'Recent results';

  @override
  String get day => 'day';

  @override
  String completedOn(Object day, Object month) {
    return 'Completed: $day $month';
  }

  @override
  String get review => 'Review';

  @override
  String get unexpectedError => 'Something went wrong';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get assessmentStartTitle => 'Start assessment';

  @override
  String get assessmentLoadFailed =>
      'Could not load assessment details. Check your connection and try again.';

  @override
  String get assessmentStartFailed =>
      'Could not start the assessment. Please try again.';

  @override
  String get assessmentTypeAdaptive => 'Adaptive';

  @override
  String get assessmentTypeRandom => 'Random';

  @override
  String get questionCount => 'Question count';

  @override
  String get timeLimit => 'Time limit';

  @override
  String get teacher => 'Teacher';

  @override
  String get previousScore => 'Previous score';

  @override
  String get navigationWarning =>
      'Any attempt to leave the assessment screen will be logged';

  @override
  String get startAssessmentNow => 'Start assessment now';

  @override
  String get assessmentUnavailable => 'Assessment unavailable';

  @override
  String get answerSubmitFailed =>
      'Could not submit the answer. Check your connection and try again.';

  @override
  String get assessmentSubmitFailed =>
      'Could not submit the assessment. Please try again.';

  @override
  String get questionLoadFailed =>
      'Could not load the question from the server. Please retry or go back.';

  @override
  String get confirmExit => 'Confirm exit';

  @override
  String get exitAssessmentPrompt =>
      'Do you want to leave the assessment? Your answers will be saved.';

  @override
  String get exit => 'Exit';

  @override
  String questionProgress(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get submitAssessment => 'Submit assessment';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get noQuestions => 'No questions available';

  @override
  String get chooseCorrectAnswer => 'Choose the correct answer:';

  @override
  String get trueLabel => 'True';

  @override
  String get falseLabel => 'False';

  @override
  String get questionTypeMcq => 'Multiple choice';

  @override
  String get questionTypeTrueFalse => 'True or false';

  @override
  String get questionTypeFillBlank => 'Fill in the blank';

  @override
  String get questionTypeEssay => 'Essay';

  @override
  String get questionTypeGeneric => 'Question';

  @override
  String get writeAnswerHere => 'Type your answer here...';

  @override
  String get confirmAnswer => 'Confirm answer';

  @override
  String get essayReviewNotice =>
      'Your answer will be reviewed by the teacher and graded later';

  @override
  String get writeEssayAnswerHere => 'Type your essay answer here...';

  @override
  String get submitAnswer => 'Submit answer';

  @override
  String get marketplaceTabAll => 'All';

  @override
  String get marketplaceTabAvatars => 'Avatars';

  @override
  String get marketplaceTabThemes => 'Themes';

  @override
  String get marketplaceTabGuides => 'Guides';

  @override
  String get marketplaceNotificationsTooltip => 'Notifications';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get marketplaceLevelLabel => 'Level 14: Math genius';

  @override
  String get myCollection => 'My collection';

  @override
  String get ownedActive => 'Active';

  @override
  String get emptyCollectionMessage =>
      'You have not added any collectibles yet. Buy your first reward and it will appear here.';

  @override
  String get marketplaceEmptyTitle => 'No items in this section';

  @override
  String get marketplaceEmptyMessage =>
      'Try another section or come back later when new rewards are added.';

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String get activate => 'Activate';

  @override
  String get purchase => 'Buy';

  @override
  String get confirmPurchase => 'Confirm purchase';

  @override
  String purchaseConfirmMessage(Object price, Object title) {
    return '$price points will be deducted from your balance to buy \"$title\".';
  }

  @override
  String purchaseNeedMorePoints(Object points, Object title) {
    return 'You need $points more points to buy \"$title\".';
  }

  @override
  String get ok => 'OK';

  @override
  String get addedToCollection => 'Added to your collection';

  @override
  String purchaseSuccessMessage(Object title, Object balance) {
    return '\"$title\" was purchased successfully. Remaining balance: $balance points.';
  }

  @override
  String get activated => 'Activated';

  @override
  String activationSuccessMessage(Object title) {
    return '\"$title\" has been activated in your collection.';
  }

  @override
  String get emptyCollectionTitle => 'No collectibles';

  @override
  String get emptyCollectionSheetMessage =>
      'Buy an item from the marketplace to see it here.';

  @override
  String get activeNow => 'Active now';

  @override
  String get availableToActivate => 'Available to activate';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get done => 'Done';

  @override
  String get owned => 'Owned';

  @override
  String get extraTimeShortTitle => 'Extra time';

  @override
  String get marketItemExplorerAvatarTitle => 'Avatar: Explorer';

  @override
  String get marketItemExplorerAvatarDescription =>
      'A special avatar shown in your profile and challenge board.';

  @override
  String get marketItemRareBadge => 'Rare';

  @override
  String get marketItemGoldenThemeTitle => 'Theme: Golden sunset';

  @override
  String get marketItemGoldenThemeDescription =>
      'A special color theme to personalize your learning experience.';

  @override
  String get marketItemExclusiveBadge => 'Exclusive';

  @override
  String get marketItemAlgebraGuideTitle => 'Advanced algebra secrets';

  @override
  String get marketItemAlgebraGuideDescription =>
      'A complete guide with interactive exercises and concise solutions.';

  @override
  String get marketItemStudyGuideBadge => 'Study guide';

  @override
  String get marketItemTopStudentAvatarTitle => 'Avatar: Top student';

  @override
  String get marketItemTopStudentAvatarDescription =>
      'A celebratory avatar for high-achieving students.';

  @override
  String get marketItemXpBoosterTitle => '1-hour XP booster';

  @override
  String get marketItemXpBoosterDescription =>
      'Increases experience points earned in your next session.';

  @override
  String get marketItemExtraTimeTitle => 'Extra time reward';

  @override
  String get marketItemExtraTimeDescription =>
      'An active demo collectible that shows how owned items appear.';

  @override
  String get myClassesTitle => 'My classes';

  @override
  String get addNewClass => 'Add new class';

  @override
  String get className => 'Class name';

  @override
  String get classNameHint => 'Example: Grade 7 (A)';

  @override
  String get gradeLevel => 'Grade level';

  @override
  String get gradeLevelHint => 'Example: Grade 7';

  @override
  String get create => 'Create';

  @override
  String get unspecified => 'Unspecified';

  @override
  String classCreated(Object name) {
    return 'Class created: $name';
  }

  @override
  String get createClassForbidden =>
      'You do not have permission to create a class';

  @override
  String get serverConnectionFailed => 'Could not connect to the server';

  @override
  String get students => 'Students';

  @override
  String get activeAssessments => 'Active assessments';

  @override
  String get averagePerformance => 'Average performance';

  @override
  String get createAssessmentForClass => 'Create assessment for this class';

  @override
  String get viewClassReport => 'View class report';

  @override
  String get classCertificates => 'Class certificates';

  @override
  String get addClassTooltip => 'Add class';

  @override
  String get newClass => 'New class';

  @override
  String get classes => 'Classes';

  @override
  String studentCountCompact(Object count) {
    return '$count students';
  }

  @override
  String activeAssessmentCountCompact(Object count) {
    return '$count active';
  }

  @override
  String averageScoreCompact(Object score) {
    return '$score% average';
  }

  @override
  String get report => 'Report';

  @override
  String get assessment => 'Assessment';

  @override
  String get noClassesYet => 'No classes yet';

  @override
  String get noClassesMessage =>
      'Start by creating a class to organize your students and manage their assessments.';

  @override
  String get manageAssessmentsLoadFailed =>
      'Could not load assessments from the server. Check your connection and try again.';

  @override
  String get editAssessment => 'Edit assessment';

  @override
  String get assessmentTitle => 'Assessment title';

  @override
  String get subject => 'Subject';

  @override
  String get status => 'Status';

  @override
  String get archived => 'Archived';

  @override
  String get editQuestionsFromBank => 'Edit questions from question bank';

  @override
  String get changesSavedSuccessfully => 'Changes saved successfully';

  @override
  String get savedLocally => 'Saved locally';

  @override
  String get assessmentPublishedSuccessfully =>
      'Assessment published successfully';

  @override
  String get assessmentPublishFailed =>
      'Could not publish the assessment. Check your connection and try again.';

  @override
  String get manageAssessmentsTitle => 'Assessments';

  @override
  String get manageAssessmentsSubtitle =>
      'Manage and track all of your assessments.';

  @override
  String get noTeacherAssessmentsTitle => 'No assessments';

  @override
  String get noTeacherAssessmentsMessage =>
      'Start by creating your first assessment.';

  @override
  String get questionsCountUnknown => '-- questions';

  @override
  String get edit => 'Edit';

  @override
  String get deleteAssessmentTitle => 'Delete assessment';

  @override
  String get deleteAssessmentConfirmation =>
      'Do you want to delete this assessment?';

  @override
  String get assessmentDeletedLocally => 'Assessment deleted';

  @override
  String get publish => 'Publish';

  @override
  String get reports => 'Reports';

  @override
  String get live => 'Live';

  @override
  String get assessmentCreatedAndPublishedSuccessfully =>
      'Assessment created and published successfully';

  @override
  String get assessmentSavedAsDraftSuccessfully =>
      'Assessment saved as a draft successfully';

  @override
  String get insufficientQuestionsWarning =>
      'Warning: available questions are fewer than requested';

  @override
  String get assessmentCreatedDemoMode =>
      'Assessment created successfully (demo mode)';

  @override
  String get assessmentCreateFailed =>
      'Could not create the assessment. Check your connection and data, then try again.';

  @override
  String get assessmentTitleHint => 'Example: Unit 1 assessment';

  @override
  String get requiredField => 'Required';

  @override
  String get chooseSubject => 'Choose subject';

  @override
  String get unitOrChapter => 'Unit / chapter';

  @override
  String get unitHint => 'Example: Unit 1';

  @override
  String get assessmentType => 'Assessment type';

  @override
  String get randomAssessment => 'Random assessment';

  @override
  String get randomAssessmentDescription =>
      'Questions are selected randomly from the question bank.';

  @override
  String get adaptiveAssessment => 'Adaptive assessment';

  @override
  String get adaptiveAssessmentDescription =>
      'Question difficulty changes based on the student\'s answers.';

  @override
  String get questionUnit => 'questions';

  @override
  String get timeInMinutes => 'Time (minutes)';

  @override
  String get minuteUnit => 'min';

  @override
  String get chooseGradeLevel => 'Choose a grade level...';

  @override
  String get classrooms => 'Classrooms';

  @override
  String get noLinkedClassroomsMessage =>
      'No linked classes yet. You can save the assessment as a draft, but publishing requires at least one class.';

  @override
  String get availabilityWindow => 'Availability window';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get publishImmediatelyTitle =>
      'Publish assessment immediately after creation';

  @override
  String get publishImmediatelySubtitle =>
      'Requires selecting at least one class so students receive notifications.';

  @override
  String get confirmCreateAndPublishAssessment =>
      'Confirm, create, and publish assessment';

  @override
  String get saveAssessmentAsDraft => 'Save assessment as draft';

  @override
  String get classScheduleTitle => 'Class schedule';

  @override
  String get scheduleOptions => 'Schedule options';

  @override
  String get currentWeek => 'Current week';

  @override
  String get weeklySchedule => 'Weekly schedule';

  @override
  String get scheduleLocalOnlyMessage =>
      'No timetable API is connected yet. Real lessons will appear here after integration. For now, you can add local lessons for the selected day without showing fake data.';

  @override
  String get addOrEditLesson => 'Add / edit lesson';

  @override
  String addLessonForDay(Object day) {
    return 'Add lesson - $day';
  }

  @override
  String get subjectRequired => 'Subject *';

  @override
  String get teacherName => 'Teacher name';

  @override
  String get roomOrLocation => 'Room / location';

  @override
  String get lessonTime => 'Lesson time:';

  @override
  String get enterSubjectName => 'Please enter the subject name';

  @override
  String lessonAdded(Object subject) {
    return 'Lesson added: $subject';
  }

  @override
  String get addLesson => 'Add lesson';

  @override
  String noLessonsForDay(Object day) {
    return 'No lessons for $day';
  }

  @override
  String get emptyScheduleMessage =>
      'Lessons will appear here automatically when the timetable API is connected. You can add a local lesson now for review and testing.';

  @override
  String get addLessonForThisDay => 'Add lesson for this day';

  @override
  String get activeTasks => 'Active tasks';

  @override
  String get drafts => 'Drafts';

  @override
  String get completedTasks => 'Completed tasks';

  @override
  String get activeSummaryLabel => 'Active';

  @override
  String get draftsSummaryLabel => 'Drafts';

  @override
  String get completedSummaryLabel => 'Completed';

  @override
  String get newTask => 'New task';

  @override
  String get taskManagementTitle => 'Task management';

  @override
  String get taskManagementSubtitle =>
      'Track student assignments and completion rates, and create local tasks for review during testing.';

  @override
  String get taskManagementLocalOnlyMessage =>
      'Task management currently uses clear local state. Permanent saving and student sync require connecting the task API in a later phase.';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String deleteTaskConfirmation(Object title) {
    return '\"$title\" will be removed from the local list only. Background sync is not available until the task API is connected.';
  }

  @override
  String get taskOptions => 'Task options';

  @override
  String get editTask => 'Edit task';

  @override
  String get publishDraft => 'Publish draft';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get completionRate => 'Completion rate';

  @override
  String get dueWithinWeek => 'Due: within a week';

  @override
  String get createNewTask => 'Create new task';

  @override
  String get taskEditorLocalOnlyMessage =>
      'Choose the target class so the task is linked to the expected student count. Changes are saved only in this session until the task API is connected.';

  @override
  String get taskTitle => 'Task title';

  @override
  String get enterClearTaskTitle => 'Write a clear task title';

  @override
  String get classLabel => 'Class';

  @override
  String get selectTargetClass => 'Select the target class';

  @override
  String get chooseSuggestedClass =>
      'Choose one of the suggested classes so students are assigned accurately';

  @override
  String get dueDate => 'Due date';

  @override
  String get enterDueDate => 'Enter the due date';

  @override
  String get createTask => 'Create task';

  @override
  String noTasksInTab(Object tab) {
    return 'No tasks in \"$tab\"';
  }

  @override
  String get emptyTasksMessage =>
      'Change the filter or create a new task for students.';

  @override
  String get navHome => 'Home';

  @override
  String get navAssessments => 'Assessments';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get navQuestionBank => 'Question bank';

  @override
  String get navReports => 'Reports';

  @override
  String get navUsers => 'Users';

  @override
  String get navClassrooms => 'Classes';

  @override
  String mcqOptionSemanticLabel(Object optionKey, Object value) {
    return 'Option $optionKey: $value';
  }

  @override
  String get questionImageAlt => 'Question image';

  @override
  String get couldNotOpenLink => 'Could not open the link';

  @override
  String downloadingFile(Object fileName) {
    return 'Downloading $fileName...';
  }

  @override
  String downloadFailedWithReason(Object reason) {
    return 'Download failed: $reason';
  }

  @override
  String exportFailedWithReason(Object reason) {
    return 'Export failed: $reason';
  }

  @override
  String get shareFailed => 'Sharing failed';

  @override
  String get downloadingQuestionTemplate => 'Downloading question template...';

  @override
  String get questionTemplateImportSubject =>
      'Question import template - EduAssess';

  @override
  String get questionTemplateSubject => 'Question import template';

  @override
  String completionCertificateSubject(Object studentName) {
    return 'Completion certificate - $studentName';
  }

  @override
  String completionCertificateContent(Object studentName, Object classroomName,
      Object score, Object grade, Object issueDate) {
    return 'Completion Certificate\n═══════════════════════════════\n\nThis certificate is awarded to:\n$studentName\n\nFor successfully completing: $classroomName\n\nScore: $score%\nGrade: $grade\n\nAcademic year: 2024-2025\nIssue date: $issueDate\n\n═══════════════════════════════\nEduAssess Adaptive Assessment Platform\n';
  }

  @override
  String get connectionTimeout => 'Connection timed out';

  @override
  String get unauthorizedError => 'Unauthorized';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get connectionError => 'Connection error';

  @override
  String get schoolReportExportSection => 'Section';

  @override
  String get schoolReportExportMetric => 'Metric';

  @override
  String get schoolReportExportValue => 'Value';

  @override
  String get schoolReportExportReport => 'Report';

  @override
  String get schoolReportExportGeneratedAt => 'Generated at';

  @override
  String get schoolReportExportFilterScope => 'Filter scope';

  @override
  String get schoolReportExportSummary => 'Summary';

  @override
  String get schoolReportExportClassroomComparison => 'Classroom comparison';

  @override
  String get schoolReportExportWeakSkills => 'Skills needing support';

  @override
  String schoolReportExportComparisonValue(
      Object averageScore, Object completionRate, Object topSkill) {
    return 'Average: $averageScore | Completion: $completionRate | Skill: $topSkill';
  }

  @override
  String get schoolReportExportFailure =>
      'Could not export the school report. Check the connection and try again.';

  @override
  String get questionBankQualityTitle => 'Question bank quality';

  @override
  String get qualityDataLoadFailed => 'Could not load data';

  @override
  String get totalQuestionsLabel => 'Total questions';

  @override
  String get qualityStatusLabel => 'Status';

  @override
  String get balancedStatus => 'Balanced';

  @override
  String get insufficientStatus => 'Insufficient';

  @override
  String get questionDifficultyDistribution =>
      'Question distribution by difficulty';

  @override
  String get easyDifficulty => 'Easy';

  @override
  String get mediumDifficulty => 'Medium';

  @override
  String get hardDifficulty => 'Hard';

  @override
  String get addQuestions => 'Add questions';

  @override
  String questionCountCompact(int count) {
    return '$count questions';
  }

  @override
  String minimumQuestionsRequired(int count) {
    return 'Minimum: $count questions';
  }

  @override
  String get addNewQuestionTitle => 'Add new question';

  @override
  String get questionClassification => 'Question classification';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get gradeLevelLabel => 'Grade level';

  @override
  String get chooseGrade => 'Choose grade';

  @override
  String get gradeSeven => 'Grade 7';

  @override
  String get gradeEight => 'Grade 8';

  @override
  String get gradeNine => 'Grade 9';

  @override
  String get gradeTen => 'Grade 10';

  @override
  String get gradeEleven => 'Grade 11';

  @override
  String get gradeTwelve => 'Grade 12';

  @override
  String get unitLabel => 'Unit';

  @override
  String get mainSkillLabel => 'Main skill';

  @override
  String get mainSkillHint => 'Example: addition and subtraction';

  @override
  String get questionTypeSection => 'Question type';

  @override
  String get questionTypeTrueFalseShort => 'True / False';

  @override
  String get questionContent => 'Question content';

  @override
  String get questionTextLabel => 'Question text';

  @override
  String get questionTextHint => 'Write the question text here...';

  @override
  String get answerOptions => 'Answer options';

  @override
  String optionHint(Object optionLabel) {
    return 'Option $optionLabel';
  }

  @override
  String get selectCorrectAnswerHint =>
      'Tap an option to mark the correct answer';

  @override
  String get chooseDifficultyError => 'Please choose a difficulty level';

  @override
  String get saveQuestion => 'Save question';

  @override
  String get questionSavedSuccessfully => 'Question saved successfully';

  @override
  String get questionSavedInDemoBank =>
      'Question saved successfully in the demo bank';

  @override
  String get returningMessage => 'Returning...';

  @override
  String get difficultyLevel => 'Difficulty level';

  @override
  String get importFromExcelTitle => 'Import from Excel';

  @override
  String get downloadTemplate => 'Download template';

  @override
  String get importHistory => 'Import history';

  @override
  String get importInstructions => 'Import instructions';

  @override
  String get importInstructionDownloadTemplate =>
      'Download the template from the button above';

  @override
  String get importInstructionFillColumns =>
      'Enter questions in the specified columns';

  @override
  String get importInstructionSaveFile => 'Save the file as .xlsx or .xls';

  @override
  String get importInstructionTapUpload =>
      'Tap the upload area to choose the file';

  @override
  String get importRequiredColumns =>
      'Required columns: question text, subject, level, difficulty, options (A-D), correct answer';

  @override
  String get excelFileAccessFailed => 'Could not access the file';

  @override
  String get excelFileTooLarge => 'File size exceeds 10MB';

  @override
  String get excelUploadFailed => 'File upload failed — check the connection';

  @override
  String unexpectedImportError(Object error) {
    return 'Unexpected error: $error';
  }

  @override
  String get demoMissingSubjectError => 'Subject field is missing in row 5';

  @override
  String get demoDuplicateQuestionError => 'Duplicate question in row 12';

  @override
  String uploadInProgress(int percent) {
    return 'Uploading... $percent%';
  }

  @override
  String get processingFile => 'Processing file...';

  @override
  String get tapToChooseExcelFile => 'Tap to choose an Excel file';

  @override
  String get excelAllowedTypes => '.xlsx, .xls, or .csv (up to 10MB)';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get importResult => 'Import result';

  @override
  String get importedLabel => 'Imported';

  @override
  String get skippedLabel => 'Skipped';

  @override
  String get failedLabel => 'Failed';

  @override
  String get errorDetails => 'Error details:';

  @override
  String rowNumberLabel(Object row) {
    return 'Row $row';
  }

  @override
  String doneAddedQuestions(int count) {
    return 'Done — added $count questions';
  }

  @override
  String get excelFileFallbackName => 'Excel file';

  @override
  String importHistorySummary(Object imported, Object skipped, Object failed) {
    return '$imported imported • $skipped skipped • $failed failed';
  }

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotificationsTitle => 'No notifications';

  @override
  String get noNotificationsSubtitle =>
      'Your new notifications will appear here';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsPrevious => 'Previous';

  @override
  String get demoNotificationAssessmentTitle => 'New assessment available';

  @override
  String get demoNotificationAssessmentBody =>
      'The periodic mathematics assessment has been published. You can start now.';

  @override
  String get demoNotificationGradeTitle => 'Your assessment result';

  @override
  String get demoNotificationGradeBody =>
      'You scored 78% in the Arabic language assessment. Well done!';

  @override
  String get demoNotificationAlertTitle => 'Performance alert';

  @override
  String get demoNotificationAlertBody =>
      'Ahmed\'s average performance dropped in physics.';

  @override
  String get demoNotificationMessageTitle => 'Message from teacher';

  @override
  String get demoNotificationMessageBody =>
      'Please review unit three before the upcoming assessment.';

  @override
  String get smartAssessmentTitle => 'Smart assessment';

  @override
  String get enableOneChannelPerNotificationGroup =>
      'Enable at least one channel for each notification group';

  @override
  String get notificationSettingsSaved =>
      'Notification settings saved successfully';

  @override
  String get notificationSettingsSavedLocally => 'Settings saved locally';

  @override
  String get studentPerformanceNotificationsGroup => 'Student performance';

  @override
  String get pushNotificationsTitle => 'Instant alerts (Push)';

  @override
  String get studentPerformancePushSubtitle =>
      'Receive instant notifications when student performance levels change.';

  @override
  String get emailNotificationTitle => 'Email';

  @override
  String get studentPerformanceEmailSubtitle =>
      'Weekly summary of academic performance.';

  @override
  String get questionBankNotificationsGroup => 'Question bank';

  @override
  String get contentUpdatesNotificationTitle => 'Content updates';

  @override
  String get questionBankContentUpdatesSubtitle =>
      'Notifications when new questions are added or assessment criteria are updated.';

  @override
  String get smsNotificationTitle => 'Text messages (SMS)';

  @override
  String get questionBankSmsSubtitle =>
      'For urgent alerts related to final assessments.';

  @override
  String get periodicReportsNotificationsGroup => 'Periodic reports';

  @override
  String get periodicReportsEmailSubtitle =>
      'Send comprehensive monthly reports to supervisors.';

  @override
  String get notificationSettingsPageSubtitle =>
      'Choose how you want to stay informed about the latest updates.';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String unreadNotificationsCount(int count) {
    return 'You have $count new unread notifications';
  }

  @override
  String get noUnreadNotifications => 'No unread notifications';

  @override
  String get noOlderNotificationsToShow => 'No older notifications to show';

  @override
  String get yesterdayDatePrefix => 'Yesterday,';

  @override
  String get questionBankTitle => 'Question bank';

  @override
  String get subjectMathematics => 'Mathematics';

  @override
  String get subjectScience => 'Science';

  @override
  String get subjectArabic => 'Arabic';

  @override
  String get subjectEnglish => 'English';

  @override
  String get generalSkillFallback => 'General skill';

  @override
  String get editQuestionTitle => 'Edit question';

  @override
  String get questionUpdated => 'Question updated';

  @override
  String get saveEdits => 'Save edits';

  @override
  String get deleteQuestionTitle => 'Delete question';

  @override
  String get deleteQuestionConfirmation =>
      'Do you want to permanently delete this question?';

  @override
  String get questionDeleted => 'Question deleted';

  @override
  String get activeFilters => 'Active filters';

  @override
  String get addQuestion => 'Add question';

  @override
  String get importExcel => 'Import Excel';

  @override
  String get noQuestionsTitle => 'No questions';

  @override
  String get noQuestionsSubtitle =>
      'Start by adding questions to the question bank';

  @override
  String get filterQuestionsTitle => 'Filter questions';

  @override
  String get unitNameHint => 'Type the unit name...';

  @override
  String get applyFilters => 'Apply filters';

  @override
  String get advancedQuestionTitle => 'Create advanced question';

  @override
  String get advancedQuestionSubtitle =>
      'Design advanced assessment questions with rich media and interactive elements.';

  @override
  String get advancedUnitQuantum => 'Unit 4: Advanced quantum mechanics';

  @override
  String get advancedUnitThermodynamics => 'Unit 5: Thermodynamics and entropy';

  @override
  String get advancedUnitParticles => 'Unit 6: Particle physics fundamentals';

  @override
  String get assignUnit => 'Assign unit';

  @override
  String get essayQuestionEditor => 'Essay question editor';

  @override
  String get wordLimitLabel => 'Word limit:';

  @override
  String get autoGradingEnabled => 'Auto-grading enabled';

  @override
  String get matchingQuestionInterface => 'Matching question interface';

  @override
  String get addAnotherPair => 'Add another pair';

  @override
  String get matchingItemA => 'Item A';

  @override
  String get matchingMatchB => 'Match B';

  @override
  String get questionSavedAsDraft => 'Question saved as draft';

  @override
  String get saveAsDraft => 'Save as draft';

  @override
  String get writeQuestionFirst => 'Please write the question text first';

  @override
  String get publishQuestionTitle => 'Publish question';

  @override
  String get publishQuestionConfirmation =>
      'Do you want to publish this question to the question bank?';

  @override
  String get questionPublishedToBank =>
      'Question published to the question bank';

  @override
  String get publishQuestion => 'Publish question';

  @override
  String get plannedStatus => 'Planned';

  @override
  String get aiQuestionAssistant => 'Question generation assistant';

  @override
  String get aiQuestionAssistantDisabledMessage =>
      'This feature is not enabled in this release until a safe generation service, question quality review, and source logging are connected before publishing.';

  @override
  String get autoGenerationPlanned => 'Auto-generation is planned';

  @override
  String get classroomManagementTitle => 'Classroom management';

  @override
  String get classroomSearchHint => 'Search for a classroom...';

  @override
  String get demoClassroomGradeTenA => 'Grade 10 (A)';

  @override
  String get demoClassroomGradeTwelveC => 'Grade 12 (C)';

  @override
  String get demoClassroomIntermediateB => 'Intermediate level (B)';

  @override
  String get demoSubjectMathAdvanced => 'Mathematics - advanced level';

  @override
  String get demoSubjectPhysicsScienceTrack => 'Physics - science track';

  @override
  String get demoSubjectEnglishLanguage => 'English language';

  @override
  String viewStudentsForClass(Object name) {
    return 'View students: $name';
  }

  @override
  String reportsForClass(Object name) {
    return 'Reports: $name';
  }

  @override
  String get urgentAlerts => 'Urgent alerts';

  @override
  String get missingAssessmentSubmissionsAlert =>
      '5 students have not submitted the assessment';

  @override
  String get mathGradeTenASubtitle => 'Mathematics - Grade 10 (A)';

  @override
  String get newJoinRequestAlert => 'New join request';

  @override
  String get englishClassSubtitle => 'English class';

  @override
  String get viewAllAlerts => 'View all alerts';

  @override
  String get academicPerformanceOverview => 'Academic performance overview';

  @override
  String get academicPerformanceOverviewSubtitle =>
      'The data shows a 12% improvement in students\' average scores during the current month.';

  @override
  String get loadingFullReport => 'Loading the full report...';

  @override
  String get downloadFullReport => 'Download full report';

  @override
  String get viewStudents => 'View students';

  @override
  String get assessments => 'Assessments';

  @override
  String get close => 'Close';

  @override
  String get navResources => 'Resources';

  @override
  String get supportCenterTitle => 'Technical support and help';

  @override
  String get supportCenterSubtitle =>
      'We are here to answer your questions and support your learning journey.';

  @override
  String get supportSearchHint => 'How can we help you today?';

  @override
  String get supportMainSections => 'Main sections';

  @override
  String get supportGeneralCategory => 'General';

  @override
  String get supportGeneralCategorySubtitle =>
      'Frequently asked questions about the platform';

  @override
  String get supportGeneralDialogTitle => 'General section';

  @override
  String get supportGeneralDialogHeading => 'Frequently asked questions:';

  @override
  String get supportGeneralFaqStart => 'How do I start using the platform?';

  @override
  String get supportGeneralFaqCreateAssessment =>
      'How do I create a new assessment?';

  @override
  String get supportGeneralFaqAddStudents =>
      'How do I add students to a class?';

  @override
  String get supportGeneralFaqReports => 'How do I view reports?';

  @override
  String get supportGeneralDialogFooter =>
      'For more help, contact the support team.';

  @override
  String get supportTechnicalCategory => 'Technical';

  @override
  String get supportTechnicalCategorySubtitle =>
      'Solutions for technical issues';

  @override
  String get supportTechnicalDialogTitle => 'Technical section';

  @override
  String get supportTechnicalDialogHeading => 'Common technical issues:';

  @override
  String get supportTechnicalIssueLogin => 'Problem signing in';

  @override
  String get supportTechnicalIssueSlowPages => 'Pages loading slowly';

  @override
  String get supportTechnicalIssueSaveError => 'Error saving data';

  @override
  String get supportTechnicalIssueUpload => 'Problem uploading files';

  @override
  String get supportTechnicalDialogFooter =>
      'If the problem continues, contact technical support.';

  @override
  String get supportBillingCategory => 'Billing';

  @override
  String get supportBillingCategorySubtitle => 'Subscriptions and payments';

  @override
  String get supportBillingDialogTitle => 'Billing section';

  @override
  String get supportBillingDialogHeading => 'Subscription information:';

  @override
  String get supportBillingCurrentPlan => 'Current plan: Free';

  @override
  String get supportBillingExpiry => 'Expiry date: Not specified';

  @override
  String get supportBillingUsers => 'Users: Unlimited';

  @override
  String get supportBillingDialogFooter =>
      'For upgrades or billing questions, contact sales.';

  @override
  String supportBulletItem(Object item) {
    return '• $item';
  }

  @override
  String get supportContactTitle => 'Contact support';

  @override
  String get supportContactSubtitle => 'Our team is available 24/7 to help you';

  @override
  String get supportStartLiveChat => 'Start live chat';

  @override
  String get supportLiveDialogTitle => 'Live technical support';

  @override
  String get supportTeamAvailable => 'The support team is available 24/7';

  @override
  String get supportDirectContact =>
      'Direct contact: support@adaptive-mastery.com';

  @override
  String get supportOpenTicket => 'Open support ticket';

  @override
  String get supportTicketHint => 'Describe your issue in detail...';

  @override
  String get supportTicketSent =>
      'Your support ticket has been sent. We will contact you within 24 hours.';

  @override
  String get supportSubmitTicket => 'Submit ticket';

  @override
  String get supportTutorialFirstAssessment =>
      'How to start your first assessment';

  @override
  String get supportTutorialFirstDuration => '3 minutes • Video';

  @override
  String get supportTutorialReports => 'Understanding performance reports';

  @override
  String get supportTutorialReportsDuration => '5 minutes • Article';

  @override
  String get supportTutorialsTitle => 'Learning tutorials';

  @override
  String get supportAllTutorialsTitle => 'All learning tutorials';

  @override
  String get supportAvailableTutorials => 'Available tutorials:';

  @override
  String get supportTutorialClassrooms => 'Managing classrooms';

  @override
  String get supportTutorialQuestionBank => 'Creating a question bank';

  @override
  String get supportTutorialAdaptiveAssessment => 'Using adaptive assessment';

  @override
  String get supportMoreTutorialsSoon => 'More tutorials coming soon...';

  @override
  String get supportTutorialDialogMessage =>
      'This tutorial will help you understand how to use the platform better.';

  @override
  String get supportTutorialDialogFooter =>
      'To access the full content, please visit the help center.';

  @override
  String get uiFeedbackTitle => 'System message components';

  @override
  String get uiFeedbackSubtitle =>
      'Review alert and modal designs across the platform interface.';

  @override
  String get uiFeedbackSuccessTitle => 'Data imported successfully';

  @override
  String get uiFeedbackSuccessMessage =>
      '32 new adaptive questions were added to the advanced biology question bank.';

  @override
  String get uiFeedbackErrorTitle => 'Could not save question';

  @override
  String get uiFeedbackErrorMessage =>
      'The network connection was interrupted. Your progress on item 402 was not synchronized.';

  @override
  String get uiFeedbackDeleteTitle => 'Delete assessment';

  @override
  String get uiFeedbackDeleteMessage =>
      'This action cannot be undone. Student progress data and analytics linked to the midterm physics assessment will be permanently deleted.';

  @override
  String get uiFeedbackDeleteConfirm => 'Delete permanently';

  @override
  String get uiFeedbackSyncStatus => 'Current sync status';

  @override
  String get uiFeedbackPendingAlerts => 'Pending alerts';

  @override
  String get uiFeedbackSafeStatus => 'Secure';

  @override
  String get uiFeedbackAccessLogged => 'Access logged';

  @override
  String get login => 'Sign in';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginLoading => 'Signing in...';

  @override
  String loginServerStarting(int seconds) {
    return 'Starting the server... (${seconds}s)';
  }

  @override
  String get loginServerWaking => 'Please wait, the server is waking up...';

  @override
  String get loginServerWakeRetry =>
      'The server is waking up. Please wait 30 seconds and try again.';

  @override
  String get loginPendingApproval =>
      'Your account is waiting for admin approval. Contact your institution administration.';

  @override
  String get loginInvalidCredentials => 'Username or password is incorrect';

  @override
  String get loginForbiddenOrDisabled =>
      'Your account is waiting for admin approval or has been disabled. Contact the admin.';

  @override
  String get loginNoInternet => 'No internet connection';

  @override
  String get loginGenericError => 'Something went wrong. Please try again.';

  @override
  String get loginUnexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get forgotPasswordQuestion => 'Forgot password?';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get createNewAccount => 'Create new account';

  @override
  String get noAccountQuestion => 'Do not have an account?';

  @override
  String get adaptiveAssessmentPlatformShort => 'Adaptive Assessment Platform';

  @override
  String get signInToYourAccount => 'Sign in to your account';

  @override
  String get enterUsernameHint => 'Enter username';

  @override
  String get enterUsernameRequired => 'Please enter your username';

  @override
  String get enterPasswordHint => 'Enter password';

  @override
  String get enterPasswordRequired => 'Please enter your password';

  @override
  String get or => 'Or';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get googleLoginLoading => 'Signing in with Google...';

  @override
  String get googlePendingApprovalMessage =>
      'Your Google join request has been sent. An admin must approve it before you can sign in.';

  @override
  String get googleLoginDisabledOnServer =>
      'Google sign-in is not enabled on the server right now';

  @override
  String get googleLoginFailedRetry =>
      'Google sign-in failed. Please try again.';

  @override
  String get loginCancelled => 'Sign-in cancelled';

  @override
  String get googleLoginFailed => 'Google sign-in failed';

  @override
  String get tryDemoMode => 'Or try demo mode';

  @override
  String get demoDataOfflineNotice =>
      'Demo data - no internet connection required';

  @override
  String get demoStudentFullName => 'Ahmed Mohammed Student';

  @override
  String get demoTeacherFullName => 'Sarah Ahmed Teacher';

  @override
  String get demoAdminFullName => 'Mohammed Ali Admin';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingAdaptiveTitle => 'Adaptive assessment';

  @override
  String get onboardingAdaptiveSubtitle =>
      'Assessments that adapt to your level';

  @override
  String get onboardingAdaptiveDescription =>
      'The smart assessment system adapts to your actual performance level, choosing questions that fit your abilities precisely so the result reflects your true understanding.';

  @override
  String get onboardingAnalyticsTitle => 'Advanced analytics';

  @override
  String get onboardingAnalyticsSubtitle =>
      'Understand your strengths and weaknesses';

  @override
  String get onboardingAnalyticsDescription =>
      'Get detailed visual reports that show your performance in each skill and clearly classify strengths and weaknesses so you know exactly what to review.';

  @override
  String get onboardingRewardsTitle => 'Points and achievements';

  @override
  String get onboardingRewardsSubtitle =>
      'Learn and stay motivated at the same time';

  @override
  String get onboardingRewardsDescription =>
      'Earn points for every completed assessment and unlock achievement badges when you excel. Track your progress and challenge yourself toward higher mastery.';

  @override
  String onboardingStepLabel(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get extendedOnboardingChooseRoleWarning =>
      'Please choose a role to continue';

  @override
  String get extendedOnboardingWelcomeTitle =>
      'Welcome to the future of smart education';

  @override
  String get extendedOnboardingWelcomeDescription =>
      'Discover a personalized learning experience powered by AI to achieve better academic outcomes.';

  @override
  String get extendedOnboardingAssessmentTitle =>
      'Smart personalized assessments';

  @override
  String get extendedOnboardingAssessmentDescription =>
      'Advanced algorithms design assessments that fit each student level and identify strengths and weaknesses accurately.';

  @override
  String get extendedOnboardingAveragePerformance =>
      'Average academic performance';

  @override
  String get extendedOnboardingStudentGrowth => 'Student growth';

  @override
  String get extendedOnboardingAnalyticsTitle => 'Deep analytics reports';

  @override
  String get extendedOnboardingAnalyticsDescription =>
      'Turn student data into clear insights that help you make better teaching decisions and track progress moment by moment.';

  @override
  String get extendedOnboardingRoleTitle =>
      'Let us start your learning journey';

  @override
  String get extendedOnboardingRoleSubtitle =>
      'Choose your role to personalize your experience';

  @override
  String get extendedOnboardingTeacherRoleTitle => 'I am a teacher';

  @override
  String get extendedOnboardingTeacherRoleSubtitle =>
      'Create assessments and manage classes';

  @override
  String get extendedOnboardingStudentRoleTitle => 'I am a student';

  @override
  String get extendedOnboardingStudentRoleSubtitle =>
      'Take assessments and track progress';

  @override
  String get signupCreateTitle => 'Create a new account';

  @override
  String get signupCreateSubtitle =>
      'Join the smart learning community and start your learning journey';

  @override
  String get signupFullNameHint => 'Enter your full name';

  @override
  String get signupFullNameRequired => 'Full name is required';

  @override
  String get email => 'Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Email is not valid';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String get signupTermsRequired => 'Please agree to the terms and conditions';

  @override
  String get signupRequestSubmitted =>
      'Join request submitted. It will appear for the admin to approve before sign-in.';

  @override
  String get signupUsernameTaken =>
      'Username is already taken. Choose another one.';

  @override
  String get signupEmailAlreadyRegistered =>
      'This email is already registered. Sign in or contact the admin.';

  @override
  String get signupRequestFailed =>
      'Could not create the join request. Check the information and try again.';

  @override
  String signupCreateAccountError(Object error) {
    return 'An error occurred while creating the account: $error';
  }

  @override
  String get signupUsernameRequired => 'Username is required';

  @override
  String get signupUsernameMinLength =>
      'Username must be at least 3 characters';

  @override
  String get signupUsernameAllowedChars =>
      'Only English letters, numbers, and _ are allowed';

  @override
  String get signupTeacherAccountsManagedByAdmin =>
      'Teacher accounts are added by the admin from user management.';

  @override
  String get signupAgreePrefix => 'I agree to ';

  @override
  String get signupPrivacySuffix => ' and the platform privacy policy.';

  @override
  String get signupTermsDialogBody =>
      'By using the adaptive assessment platform, you agree to:\n\n1. Use the platform for educational purposes only.\n2. Keep sign-in credentials confidential.\n3. Not share assessment content with others.\n4. Follow academic integrity rules.\n5. Accept the platform privacy policy.\n\nFor inquiries: support@adaptive-mastery.com';

  @override
  String get aboutAppSubtitle => 'Smart adaptive assessment platform';

  @override
  String get versionHistory => 'Version history';

  @override
  String get currentVersion => 'Current version';

  @override
  String get versionTypeRelease => 'Release';

  @override
  String get versionTypeFeature => 'Feature';

  @override
  String get versionTypeFix => 'Fix';

  @override
  String get versionTypeHotfix => 'Hotfix';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordResetTitle => 'Reset password';

  @override
  String get forgotPasswordResetSubtitle =>
      'Enter your email and we will send you a reset code';

  @override
  String get forgotPasswordGenericError =>
      'Something went wrong. Please try again';

  @override
  String get forgotPasswordSendCode => 'Send verification code';

  @override
  String get forgotPasswordSentTitle => 'Sent successfully';

  @override
  String get forgotPasswordSentSubtitle =>
      'Check your email for the reset code';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get adminDashboardLoadFailed =>
      'Could not load admin dashboard data. Check your connection and try again.';

  @override
  String adminDashboardGreeting(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get adminDashboardTitle => 'Admin dashboard';

  @override
  String get adminDashboardSchoolStats => 'School statistics';

  @override
  String get adminDashboardTeachers => 'Teachers';

  @override
  String get adminDashboardAdminAlerts => 'Administrative alerts';

  @override
  String get adminDashboardPendingStudentsTitle =>
      'Students missed the assessment';

  @override
  String adminDashboardPendingStudentsSubtitle(Object count) {
    return '$count students have not submitted the latest assessment';
  }

  @override
  String get adminDashboardPendingRequestsTitle => 'New join requests';

  @override
  String adminDashboardPendingRequestsSubtitle(Object count) {
    return '$count join requests are waiting for approval';
  }

  @override
  String get adminDashboardPerformanceDropTitle => 'Performance drop';

  @override
  String get adminDashboardMathClassLevelTen => 'Mathematics class - level ten';

  @override
  String get quickLinks => 'Quick links';

  @override
  String get userManagement => 'User management';

  @override
  String get adminDashboardUserManagementSubtitle =>
      'Add and edit teacher and student accounts';

  @override
  String get classroomManagement => 'Classroom management';

  @override
  String get adminDashboardClassroomManagementSubtitle =>
      'View and organize classrooms';

  @override
  String get schoolReports => 'School reports';

  @override
  String get adminDashboardSchoolReportsSubtitle =>
      'Comprehensive analytics for school performance';

  @override
  String get adminDashboardAdvancedDashboard => 'Advanced dashboard';

  @override
  String get adminDashboardAdvancedDashboardSubtitle =>
      'Detailed statistics and analytics for admins';

  @override
  String get adminDashboardSupervisorDashboard =>
      'Advanced supervisor dashboard';

  @override
  String get adminDashboardSupervisorDashboardSubtitle =>
      'Detailed statistics and analytics';

  @override
  String get institutionSettings => 'Institution settings';

  @override
  String get adminDashboardInstitutionSettingsSubtitle =>
      'Configure educational institution settings';

  @override
  String get performanceOverview => 'Performance overview';

  @override
  String get adminDashboardPerformanceOverviewSubtitle =>
      'School average performance this month';

  @override
  String adminDashboardMonthlyPerformanceChange(
      Object direction, Object percentage) {
    return '$direction by $percentage% this month';
  }

  @override
  String get adminDashboardSchoolAverage => 'School average performance';

  @override
  String get improvement => 'Improved';

  @override
  String get decline => 'Declined';

  @override
  String get math => 'Mathematics';

  @override
  String get adminDashboardV2Subtitle =>
      'Welcome back. Here is today\'s school performance summary.';

  @override
  String get adminDashboardTotalStudents => 'Total students';

  @override
  String get adminDashboardActiveTeachers => 'Active teachers';

  @override
  String get adminDashboardOverallAverage => 'Overall average performance';

  @override
  String get adminDashboardRunningAssessments => 'Running assessments';

  @override
  String get currentTerm => 'Current term';

  @override
  String get adminDashboardSubjectPerformance => 'Subject performance';

  @override
  String get science => 'Science';

  @override
  String get arabicSubject => 'Arabic';

  @override
  String get englishSubject => 'English';

  @override
  String get historySubject => 'History';

  @override
  String get adminDashboardTopTeacherOneName => 'Mr. Mohammed Ahmed';

  @override
  String get adminDashboardTopTeacherOneRole =>
      'Science teacher - high engagement (98%)';

  @override
  String get adminDashboardTopTeacherOneInitials => 'M.A';

  @override
  String get adminDashboardTopTeacherTwoName => 'Ms. Sarah Khaled';

  @override
  String get adminDashboardTopTeacherTwoRole =>
      'Mathematics teacher - student progress (92%)';

  @override
  String get adminDashboardTopTeacherTwoInitials => 'S.K';

  @override
  String get adminDashboardTopTeachersThisMonth => 'Top teachers this month';

  @override
  String get adminDashboardReviewRequiredTitle => 'Review required';

  @override
  String get adminDashboardReviewRequiredBody =>
      'Class 10-A needs science assessment grades reviewed.';

  @override
  String get adminDashboardReportsReadyTitle => 'Reports ready';

  @override
  String get adminDashboardReportsReadyBody =>
      'Monthly student performance reports are now available for download.';

  @override
  String get adminDashboardScheduleUpdateTitle => 'Schedule update';

  @override
  String get adminDashboardScheduleUpdateBody =>
      'The high school class schedule was updated for Tuesday.';

  @override
  String get adminDashboardManagementAlerts => 'Management alerts';

  @override
  String get adminDashboardSchedules => 'Schedules';

  @override
  String get adminDashboardAddStudent => 'Add student';

  @override
  String get quickAccess => 'Quick access';

  @override
  String get userManagementLoadFailed =>
      'Could not load users. Check your connection and try again.';

  @override
  String get disableAccount => 'Disable account';

  @override
  String disableAccountQuestion(Object name) {
    return 'Do you want to disable $name\'s account?';
  }

  @override
  String get disable => 'Disable';

  @override
  String get accountDisabled => 'Account disabled';

  @override
  String get accountDisableFailed =>
      'Could not disable the account. Please try again.';

  @override
  String accountActivated(Object name) {
    return '$name\'s account activated';
  }

  @override
  String get accountActivateFailed =>
      'Could not activate the account. Please try again.';

  @override
  String get selectedClassroom => 'Selected classroom';

  @override
  String get addUser => 'Add user';

  @override
  String get userManagementSubtitle =>
      'Control teacher and student accounts and permissions';

  @override
  String get userManagementSearchHint =>
      'Search by name, email, or identifier...';

  @override
  String get allRoles => 'All roles';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get filterByClassroom => 'Filter by classroom';

  @override
  String get clearClassroomFilter => 'Clear classroom filter';

  @override
  String get allClassrooms => 'All classrooms';

  @override
  String get noResults => 'No results';

  @override
  String get tryChangingSearchCriteria => 'Try changing the search criteria';

  @override
  String classroomsCount(Object count) {
    return '$count classrooms';
  }

  @override
  String get listSeparator => ', ';

  @override
  String get grade => 'Grade';

  @override
  String get lastActivity => 'Last activity';

  @override
  String get stop => 'Stop';

  @override
  String get approve => 'Approve';

  @override
  String get disabled => 'Disabled';

  @override
  String get addNewUser => 'Add new user';

  @override
  String get role => 'Role';

  @override
  String get userCreateFailed => 'Could not create the user. Please try again.';

  @override
  String userCreated(Object name) {
    return 'Account \"$name\" created successfully';
  }

  @override
  String get classroom => 'Classroom';

  @override
  String get classroomManagementLoadFailed =>
      'Could not load classrooms. Check your connection and try again.';

  @override
  String get deleteClassroom => 'Delete classroom';

  @override
  String deleteClassroomQuestion(Object name) {
    return 'Do you want to delete class \"$name\"?';
  }

  @override
  String get classroomDeleteFailed =>
      'Could not delete the classroom. Please try again.';

  @override
  String classroomDeleted(Object name) {
    return 'Class \"$name\" deleted';
  }

  @override
  String get classroomManagementAdminSubtitle =>
      'Manage classrooms and assign teachers and students';

  @override
  String get totalClassrooms => 'Total classrooms';

  @override
  String get classroomManagementSearchHint =>
      'Search by class name, grade, or teacher';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get withoutTeacher => 'Without teacher';

  @override
  String get withStudents => 'Has students';

  @override
  String get withoutStudents => 'Without students';

  @override
  String get noMatchingClassrooms => 'No matching classrooms';

  @override
  String get clearSearchAndFilters => 'Clear search and filters';

  @override
  String get noClassrooms => 'No classrooms';

  @override
  String get addClassToStart => 'Add a new class to start';

  @override
  String get institutionDemoLocalSaveStatus =>
      'Demo mode: settings are saved on this device';

  @override
  String get syncedWithServer => 'Synced with server';

  @override
  String get institutionSettingsLoadFailed =>
      'Could not load institution settings from the server. Showing the last saved copy.';

  @override
  String get savingSettings => 'Saving settings...';

  @override
  String get savedLocallyOnly => 'Saved locally only';

  @override
  String get institutionSettingsServerSaveFailed =>
      'Settings were saved locally, but the institution settings could not be updated on the server.';

  @override
  String get institutionEmailInvalid => 'Institution email is invalid';

  @override
  String get institutionPhoneInvalid =>
      'Contact phone must contain at least 7 digits';

  @override
  String get noSavedSyncRecorded => 'No saved sync recorded';

  @override
  String get unknownTime => 'Unknown time';

  @override
  String get academicStructure => 'Academic structure';

  @override
  String get academicYears => 'Academic years';

  @override
  String get academicYearsSubtitle => 'Manage classrooms and academic dates';

  @override
  String get gradeScales => 'Grade scales';

  @override
  String get gradeScalesSubtitle => 'Set grade scales and marks';

  @override
  String get rolesAndPermissions => 'Roles and permissions';

  @override
  String get rolesAndPermissionsSubtitle =>
      'Customize teacher and administrator access';

  @override
  String get activityLogs => 'Activity logs';

  @override
  String get activityLogsSubtitle => 'Track logins and system changes';

  @override
  String get systemPreferences => 'System preferences';

  @override
  String get alertSettings => 'Alert settings';

  @override
  String get alertSettingsSubtitle => 'Email and instant notifications';

  @override
  String get languageAndRegion => 'Language and region';

  @override
  String get languageAndRegionSubtitle => 'Arabic language and local time';

  @override
  String get systemIntegrations => 'System integrations';

  @override
  String get systemIntegrationsSubtitle =>
      'Connect APIs and external providers';

  @override
  String get accountAndSupport => 'Account and support';

  @override
  String get accountSettingsInstitutionSubtitle =>
      'Profile, password, and account preferences';

  @override
  String get supportAndHelpSubtitle => 'Contact support and help';

  @override
  String get logoutAdminSessionSubtitle => 'End the current admin session';

  @override
  String lastSavedAt(Object time) {
    return 'Last saved: $time';
  }

  @override
  String get syncSettings => 'Sync settings';

  @override
  String get institutionSettingsSynced => 'Institution settings synced';

  @override
  String get institutionSettingsSubtitle =>
      'Manage academic identity and system permissions';

  @override
  String get schoolProfile => 'School profile';

  @override
  String get logoUploadStorageNotice =>
      'The logo can be changed from storage integration once file uploads are enabled.';

  @override
  String get logo => 'Logo';

  @override
  String get institutionName => 'Institution name';

  @override
  String get contactInformation => 'Contact information';

  @override
  String get archiveInstitutionData => 'Archive institution data';

  @override
  String get logoutAdminQuestion =>
      'Do you want to log out of the admin account?';

  @override
  String get editSchoolProfile => 'Edit school profile';

  @override
  String get contactPhone => 'Contact phone';

  @override
  String get emailAlerts => 'Email alerts';

  @override
  String get emailAlertsSubtitle =>
      'Send important summaries and alerts by email';

  @override
  String get institutionProfileSaved => 'Institution profile saved';

  @override
  String get currentAcademicYear => 'Current academic year';

  @override
  String get classroomManagementSettingsSubtitle =>
      'Open classrooms to edit grades and assign teachers and students.';

  @override
  String get openClassroomManagement => 'Open classroom management';

  @override
  String get gradeScale => 'Grade scale';

  @override
  String get saveGradeScale => 'Save grade scale';

  @override
  String get gradeScaleSaved => 'Grade scale saved';

  @override
  String get auditLog => 'Audit log';

  @override
  String get auditLogLoadFailed => 'Could not load audit log';

  @override
  String get auditLogLoadFailedMessage =>
      'Check the connection or admin permissions, then try again. Demo data is not shown outside demo mode.';

  @override
  String get noAuditEvents => 'No audit events yet';

  @override
  String get noAuditEventsMessage =>
      'Actions such as disabling accounts, changing permissions, assigning classrooms, and archive requests will appear here.';

  @override
  String get sensitiveActions => 'Sensitive actions';

  @override
  String get sensitiveActionsSubtitle =>
      'Shows recent admin changes that affect accounts, classrooms, and settings.';

  @override
  String get openAdvancedSupervisorDashboard =>
      'Open advanced supervisor dashboard';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsInstitutionSubtitle =>
      'In-app alerts for admins and teachers';

  @override
  String get weeklyDigest => 'Weekly digest';

  @override
  String get weeklyDigestSubtitle =>
      'Institution performance summary every week';

  @override
  String get advancedSettings => 'Advanced settings';

  @override
  String get interfaceLanguage => 'Interface language';

  @override
  String get timezone => 'Time zone';

  @override
  String get saveLanguageAndRegion => 'Save language and region';

  @override
  String get languageAndRegionSaved => 'Language and region saved';

  @override
  String get currentApiEndpoint => 'Current API endpoint';

  @override
  String get sisIntegration => 'Student information system SIS';

  @override
  String get sisIntegrationSubtitle =>
      'Prepare connection with student record systems';

  @override
  String get lmsIntegration => 'Learning management system LMS';

  @override
  String get lmsIntegrationSubtitle =>
      'Prepare connection with external learning platforms';

  @override
  String get requestIntegrationSupport => 'Request integration support';

  @override
  String get archiveDataWarning => 'Warning: data archiving';

  @override
  String get archiveDataWarningMessage =>
      'An institution data archive request will be sent for administrative review before execution. Data will not be deleted immediately from this button.';

  @override
  String get archiveRequestSubmitted => 'Archive request submitted for review';

  @override
  String get submitRequest => 'Submit request';

  @override
  String get unknownAction => 'Unknown action';

  @override
  String get system => 'System';

  @override
  String get smartCoaching => 'Smart coaching';

  @override
  String get performanceAlertDemoStudentName => 'Ahmed Mohammed Al-Otaibi';

  @override
  String get performanceAlertDemoClassName => 'Grade 10 - B';

  @override
  String get performanceAlertDemoSubject => 'Mathematics';

  @override
  String get currentAverage => 'Current average';

  @override
  String get attendanceRate => 'Attendance rate';

  @override
  String get sendMessageToStudent => 'Send message to student';

  @override
  String get writeMessageHere => 'Write your message here...';

  @override
  String get messageSentToStudent => 'Message sent to the student';

  @override
  String get send => 'Send';

  @override
  String get scheduleReview => 'Schedule review';

  @override
  String get reviewScheduledNextWeek =>
      'A review with the student will be scheduled during the next week.';

  @override
  String get reviewScheduled => 'Review scheduled successfully';

  @override
  String get confirm => 'Confirm';

  @override
  String get openingFullReport => 'Opening the full report...';

  @override
  String get performanceDropAlertTitle => 'Alert: noticeable performance drop';

  @override
  String get performanceDropAlertSubtitle =>
      'A sudden decline was detected and needs educational intervention';

  @override
  String get mainReason => 'Main reason';

  @override
  String performanceDropReason(Object drop) {
    return '$drop% drop in unit 2 test scores (advanced algebra) compared with the student\'s average in the first term.';
  }

  @override
  String get academicAchievementPath => 'Academic achievement path';

  @override
  String get now => 'Now';

  @override
  String weekNumber(Object number) {
    return 'Week $number';
  }

  @override
  String get contactStudent => 'Contact student';

  @override
  String get fullReport => 'Full report';
}
