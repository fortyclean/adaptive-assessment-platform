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
            l10n.notificationsPrevious,
            l10n.notificationSettings,
            l10n.studentPerformanceNotificationsGroup,
            l10n.pushNotificationsTitle,
            l10n.notificationSettingsSaved,
          ].join(' / ');
        },
      ),
    );

    expect(
      find.text(
        'Notifications / Mark all as read / No notifications / Today / '
        'Previous / Notification settings / Student performance / '
        'Instant alerts (Push) / Notification settings saved successfully',
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
