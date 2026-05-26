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
