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
}
