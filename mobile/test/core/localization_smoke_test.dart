import 'package:adaptive_assessment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads Arabic localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('ar', 'SA'),
        labelBuilder: (context) =>
            '${AppLocalizations.of(context).appLanguage} / ${AppLocalizations.of(context).logout}',
      ),
    );

    expect(find.text('لغة التطبيق / تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('loads English localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) =>
            '${AppLocalizations.of(context).appLanguage} / ${AppLocalizations.of(context).logout}',
      ),
    );

    expect(find.text('App language / Log out'), findsOneWidget);
  });

  testWidgets('formats localized version labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) =>
            AppLocalizations.of(context).versionLabel('1.0.70'),
      ),
    );

    expect(find.text('Version 1.0.70 — EduAssess'), findsOneWidget);
  });

  testWidgets('loads shared admin and question localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.adminAccount,
            l10n.home,
            l10n.fillBlankAnswerHint,
            l10n.essayManualReviewNotice,
            l10n.passwordRequirementMin8,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Admin account / Home / Type your answer here... / '
        'This question requires manual review by the teacher / '
        'At least 8 characters',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads result screen localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.resultScreenTitle,
            l10n.skillAnalysis,
            l10n.wrongQuestions,
            l10n.pointsEarnedLabel(42),
            l10n.bonusPointsLabel(50),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Assessment result / Skill analysis / Wrong questions / '
        '+42 points / +50 bonus',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads student assessments localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.availableAssessments,
            l10n.upcomingAssessments,
            l10n.previousResults,
            l10n.noAvailableAssessmentsTitle,
            l10n.questionCountLabel(10),
            l10n.minuteCountLabel(30),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Available assessments / Upcoming / Previous results / '
        'No available assessments / 10 questions / 30 minutes',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads assessment start and exam localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.assessmentStartTitle,
            l10n.assessmentTypeAdaptive,
            l10n.questionProgress(3, 10),
            l10n.submitAssessment,
            l10n.questionTypeTrueFalse,
            l10n.writeEssayAnswerHere,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Start assessment / Adaptive / Question 3 of 10 / '
        'Submit assessment / True or false / Type your essay answer here...',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads marketplace localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.marketplaceTabAll,
            l10n.myCollection,
            l10n.insufficientBalance,
            l10n.purchaseConfirmMessage(250, l10n.marketItemXpBoosterTitle),
            l10n.activationSuccessMessage(l10n.marketItemExtraTimeTitle),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'All / My collection / Insufficient balance / '
        '250 points will be deducted from your balance to buy '
        '"1-hour XP booster". / '
        '"Extra time reward" has been activated in your collection.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads teacher classes localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.myClassesTitle,
            l10n.addNewClass,
            l10n.classCreated('Grade 7 A'),
            l10n.studentCountCompact(24),
            l10n.averageScoreCompact('82'),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'My classes / Add new class / Class created: Grade 7 A / '
        '24 students / 82% average',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads teacher assessment management localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.manageAssessmentsTitle,
            l10n.editAssessment,
            l10n.assessmentPublishedSuccessfully,
            l10n.deleteAssessmentTitle,
            l10n.questionsCount(12),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Assessments / Edit assessment / Assessment published successfully / '
        'Delete assessment / 12 questions',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads create assessment localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.createNewAssessment,
            l10n.assessmentTitleHint,
            l10n.adaptiveAssessment,
            l10n.publishImmediatelyTitle,
            l10n.saveAssessmentAsDraft,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Create new assessment / Example: Unit 1 assessment / '
        'Adaptive assessment / Publish assessment immediately after creation / '
        'Save assessment as draft',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads class schedule localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.classScheduleTitle,
            l10n.currentWeek,
            l10n.addLessonForDay('Sunday'),
            l10n.lessonAdded('Math'),
            l10n.noLessonsForDay('Sunday'),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Class schedule / Current week / Add lesson - Sunday / '
        'Lesson added: Math / No lessons for Sunday',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads task management localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.taskManagementTitle,
            l10n.newTask,
            l10n.deleteTaskConfirmation('Algebra homework'),
            l10n.noTasksInTab(l10n.activeTasks),
            l10n.createTask,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Task management / New task / "Algebra homework" will be removed '
        'from the local list only. Background sync is not available until the '
        'task API is connected. / No tasks in "Active tasks" / Create task',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads shared navigation and question widget localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.navHome,
            l10n.navAssessments,
            l10n.navQuestionBank,
            l10n.navUsers,
            l10n.navClassrooms,
            l10n.mcqOptionSemanticLabel('A', 'Answer'),
            l10n.questionImageAlt,
            l10n.trueLabel,
            l10n.falseLabel,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Home / Assessments / Question bank / Users / Classes / '
        'Option A: Answer / Question image / True / False',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads download and share helper localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.couldNotOpenLink,
            l10n.downloadingFile('report.csv'),
            l10n.downloadFailedWithReason(l10n.connectionTimeout),
            l10n.exportFailedWithReason(l10n.fileNotFound),
            l10n.questionTemplateImportSubject,
            l10n.completionCertificateSubject('Sara'),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Could not open the link / Downloading report.csv... / '
        'Download failed: Connection timed out / '
        'Export failed: File not found / '
        'Question import template - EduAssess / Completion certificate - Sara',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads question bank quality localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.questionBankQualityTitle,
            l10n.qualityDataLoadFailed,
            l10n.totalQuestionsLabel,
            l10n.balancedStatus,
            l10n.insufficientStatus,
            l10n.questionDifficultyDistribution,
            l10n.questionCountCompact(7),
            l10n.minimumQuestionsRequired(3),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Question bank quality / Could not load data / Total questions / '
        'Balanced / Insufficient / Question distribution by difficulty / '
        '7 questions / Minimum: 3 questions',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads add question localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.addNewQuestionTitle,
            l10n.questionClassification,
            l10n.chooseSubject,
            l10n.gradeSeven,
            l10n.questionTypeMcq,
            l10n.questionTypeEssay,
            l10n.optionHint('A'),
            l10n.chooseDifficultyError,
            l10n.saveQuestion,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Add new question / Question classification / Choose subject / '
        'Grade 7 / Multiple choice / Essay / Option A / '
        'Please choose a difficulty level / Save question',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads Excel import localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.importFromExcelTitle,
            l10n.downloadTemplate,
            l10n.importInstructions,
            l10n.excelFileTooLarge,
            l10n.uploadInProgress(42),
            l10n.importResult,
            l10n.rowNumberLabel('5'),
            l10n.doneAddedQuestions(12),
            l10n.importHistorySummary('12', '2', '1'),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Import from Excel / Download template / Import instructions / '
        'File size exceeds 10MB / Uploading... 42% / Import result / '
        'Row 5 / Done — added 12 questions / '
        '12 imported • 2 skipped • 1 failed',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads notification localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.notifications,
            l10n.markAllAsRead,
            l10n.noNotificationsTitle,
            l10n.notificationsToday,
            l10n.notificationsYesterday,
            l10n.notificationsPrevious,
            l10n.notificationSettings,
            l10n.studentPerformanceNotificationsGroup,
            l10n.pushNotificationsTitle,
            l10n.unreadNotificationsCount(3),
            l10n.noUnreadNotifications,
            l10n.noOlderNotificationsToShow,
            l10n.notificationSettingsSaved,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Notifications / Mark all as read / No notifications / Today / '
        'Yesterday / Previous / Notification settings / Student performance / '
        'Instant alerts (Push) / You have 3 new unread notifications / '
        'No unread notifications / No older notifications to show / '
        'Notification settings saved successfully',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads question bank screen localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.questionBankTitle,
            l10n.subjectMathematics,
            l10n.subjectScience,
            l10n.generalSkillFallback,
            l10n.editQuestionTitle,
            l10n.deleteQuestionConfirmation,
            l10n.activeFilters,
            l10n.unitOrChapter,
            l10n.noQuestionsTitle,
            l10n.filterQuestionsTitle,
            l10n.applyFilters,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Question bank / Mathematics / Science / General skill / '
        'Edit question / Do you want to permanently delete this question? / '
        'Active filters / Unit / chapter / No questions / Filter questions / '
        'Apply filters',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads advanced question editor localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.advancedQuestionTitle,
            l10n.assignUnit,
            l10n.essayQuestionEditor,
            l10n.wordLimitLabel,
            l10n.autoGradingEnabled,
            l10n.matchingQuestionInterface,
            l10n.addAnotherPair,
            l10n.questionSavedAsDraft,
            l10n.publishQuestionConfirmation,
            l10n.aiQuestionAssistant,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Create advanced question / Assign unit / Essay question editor / '
        'Word limit: / Auto-grading enabled / Matching question interface / '
        'Add another pair / Question saved as draft / '
        'Do you want to publish this question to the question bank? / '
        'Question generation assistant',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads classroom list localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.classroomManagementTitle,
            l10n.classroomSearchHint,
            l10n.demoClassroomGradeTenA,
            l10n.demoSubjectMathAdvanced,
            l10n.viewStudentsForClass('Grade 10 (A)'),
            l10n.urgentAlerts,
            l10n.academicPerformanceOverview,
            l10n.completionRate,
            l10n.downloadFullReport,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Classroom management / Search for a classroom... / Grade 10 (A) / '
        'Mathematics - advanced level / View students: Grade 10 (A) / '
        'Urgent alerts / Academic performance overview / Completion rate / '
        'Download full report',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads support center localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.supportCenterTitle,
            l10n.supportSearchHint,
            l10n.supportGeneralCategory,
            l10n.supportTechnicalCategory,
            l10n.supportBillingCategory,
            l10n.supportStartLiveChat,
            l10n.supportOpenTicket,
            l10n.supportTutorialFirstDuration,
            l10n.supportBulletItem('Sample'),
            l10n.navResources,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Technical support and help / How can we help you today? / General / '
        'Technical / Billing / Start live chat / Open support ticket / '
        '3 minutes • Video / • Sample / Resources',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads UI feedback localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.uiFeedbackTitle,
            l10n.uiFeedbackSuccessTitle,
            l10n.uiFeedbackErrorTitle,
            l10n.uiFeedbackDeleteConfirm,
            l10n.uiFeedbackSyncStatus,
            l10n.uiFeedbackPendingAlerts,
            l10n.uiFeedbackSafeStatus,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'System message components / Data imported successfully / '
        'Could not save question / Delete permanently / Current sync status / '
        'Pending alerts / Secure',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads login localization labels and messages', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.login,
            l10n.username,
            l10n.password,
            l10n.signInWithGoogle,
            l10n.loginServerStarting(7),
            l10n.loginInvalidCredentials,
            l10n.googlePendingApprovalMessage,
            l10n.tryDemoMode,
            l10n.demoStudentFullName,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Sign in / Username / Password / Sign in with Google / '
        'Starting the server... (7s) / Username or password is incorrect / '
        'Your Google join request has been sent. An admin must approve it '
        'before you can sign in. / Or try demo mode / '
        'Ahmed Mohammed Student',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads onboarding localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.skip,
            l10n.next,
            l10n.getStarted,
            l10n.onboardingAdaptiveTitle,
            l10n.onboardingAnalyticsTitle,
            l10n.onboardingRewardsTitle,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Skip / Next / Get started / Adaptive assessment / '
        'Advanced analytics / Points and achievements',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads extended onboarding localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.onboardingStepLabel(2, 4),
            l10n.extendedOnboardingWelcomeTitle,
            l10n.extendedOnboardingAssessmentTitle,
            l10n.extendedOnboardingAnalyticsTitle,
            l10n.extendedOnboardingTeacherRoleTitle,
            l10n.extendedOnboardingStudentRoleTitle,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Step 2 of 4 / Welcome to the future of smart education / '
        'Smart personalized assessments / Deep analytics reports / '
        'I am a teacher / I am a student',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads signup localization labels and messages', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.signupCreateTitle,
            l10n.signupFullNameRequired,
            l10n.signupUsernameAllowedChars,
            l10n.signupRequestSubmitted,
            l10n.termsAndConditions,
            l10n.signupCreateAccountError('timeout'),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Create a new account / Full name is required / '
        'Only English letters, numbers, and _ are allowed / '
        'Join request submitted. It will appear for the admin to approve '
        'before sign-in. / Terms and conditions / '
        'An error occurred while creating the account: timeout',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads about screen localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.aboutApp,
            l10n.aboutAppSubtitle,
            l10n.currentVersion,
            l10n.versionHistory,
            l10n.versionTypeRelease,
            l10n.versionTypeFeature,
            l10n.versionTypeFix,
            l10n.versionTypeHotfix,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'About app / Smart adaptive assessment platform / Current version / '
        'Version history / Release / Feature / Fix / Hotfix',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads forgot password and admin dashboard localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.forgotPasswordTitle,
            l10n.forgotPasswordResetTitle,
            l10n.forgotPasswordSendCode,
            l10n.forgotPasswordSentTitle,
            l10n.adminDashboardTitle,
            l10n.adminDashboardSchoolStats,
            l10n.adminDashboardPendingStudentsSubtitle(4),
            l10n.adminDashboardMonthlyPerformanceChange('Improved', 12),
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Forgot password / Reset password / Send verification code / '
        'Sent successfully / Admin dashboard / School statistics / '
        '4 students have not submitted the latest assessment / '
        'Improved by 12% this month',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads advanced admin dashboard localization labels',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.adminDashboardV2Subtitle,
            l10n.adminDashboardTotalStudents,
            l10n.adminDashboardSubjectPerformance,
            l10n.adminDashboardTopTeachersThisMonth,
            l10n.adminDashboardReportsReadyTitle,
            l10n.quickAccess,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Welcome back. Here is today\'s school performance summary. / '
        'Total students / Subject performance / Top teachers this month / '
        'Reports ready / Quick access',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads user management localization labels and messages',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.userManagement,
            l10n.addUser,
            l10n.userManagementSearchHint,
            l10n.disableAccountQuestion('Mona'),
            l10n.accountActivated('Mona'),
            l10n.classroomsCount(3),
            l10n.addNewUser,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'User management / Add user / Search by name, email, or identifier... / '
        'Do you want to disable Mona\'s account? / Mona\'s account activated / '
        '3 classrooms / Add new user',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads classroom management localization labels and messages',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.classroomManagementTitle,
            l10n.classroomManagementAdminSubtitle,
            l10n.classroomManagementSearchHint,
            l10n.deleteClassroomQuestion('Grade 10-A'),
            l10n.classroomDeleted('Grade 10-A'),
            l10n.noMatchingClassrooms,
            l10n.addClass,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Classroom management / Manage classrooms and assign teachers and students / '
        'Search by class name, grade, or teacher / '
        'Do you want to delete class "Grade 10-A"? / '
        'Class "Grade 10-A" deleted / No matching classrooms / Add class',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads institution settings localization labels and messages',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.institutionSettings,
            l10n.academicStructure,
            l10n.academicYearsSubtitle,
            l10n.institutionSettingsLoadFailed,
            l10n.lastSavedAt('2026/6/5 - 17:20'),
            l10n.archiveDataWarning,
            l10n.requestIntegrationSupport,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Institution settings / Academic structure / '
        'Manage classrooms and academic dates / '
        'Could not load institution settings from the server. Showing the last saved copy. / '
        'Last saved: 2026/6/5 - 17:20 / '
        'Warning: data archiving / Request integration support',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads performance alert localization labels and messages',
      (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) {
          final l10n = AppLocalizations.of(context);
          return [
            l10n.smartCoaching,
            l10n.performanceDropAlertTitle,
            l10n.performanceDropReason(15),
            l10n.currentAverage,
            l10n.attendanceRate,
            l10n.sendMessageToStudent,
            l10n.weekNumber(4),
            l10n.fullReport,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Smart coaching / Alert: noticeable performance drop / '
        '15% drop in unit 2 test scores (advanced algebra) compared with '
        'the student\'s average in the first term. / Current average / '
        'Attendance rate / Send message to student / Week 4 / Full report',
      ),
      findsOneWidget,
    );
  });
}

class _LocalizedLabelApp extends StatelessWidget {
  const _LocalizedLabelApp({
    required this.locale,
    required this.labelBuilder,
  });

  final Locale locale;
  final String Function(BuildContext context) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Directionality(
          textDirection: Directionality.of(context),
          child: Text(labelBuilder(context)),
        ),
      ),
    );
  }
}
