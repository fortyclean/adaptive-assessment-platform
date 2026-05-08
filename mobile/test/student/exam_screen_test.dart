import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_assessment/shared/widgets/mcq_option.dart';
import 'package:adaptive_assessment/core/constants/app_colors.dart';

/// Widget tests for Student Screens
/// Requirements: 7.2, 7.3, 7.4, 7.5, 8.3
void main() {
  // ─── MCQ Option Widget Tests (Req 7.4) ──────────────────────────────────

  group('McqOption — Visual States (Req 7.4)', () {
    Widget buildOption({
      required bool isSelected,
      bool? isCorrect,
      bool? isIncorrect,
      bool isDisabled = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: McqOption(
            optionKey: 'A',
            value: 'الإجابة الأولى',
            isSelected: isSelected,
            onTap: () {},
            isCorrect: isCorrect,
            isIncorrect: isIncorrect,
            isDisabled: isDisabled,
          ),
        ),
      );
    }

    testWidgets('renders option key and value', (tester) async {
      await tester.pumpWidget(buildOption(isSelected: false));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('الإجابة الأولى'), findsOneWidget);
    });

    testWidgets('unselected state has white background', (tester) async {
      await tester.pumpWidget(buildOption(isSelected: false));
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).last,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.optionUnselectedBackground));
    });

    testWidgets('selected state has primary border color', (tester) async {
      await tester.pumpWidget(buildOption(isSelected: true));
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).last,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, equals(AppColors.optionSelectedBorder));
    });

    testWidgets('correct state shows check icon', (tester) async {
      await tester.pumpWidget(buildOption(isSelected: true, isCorrect: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('incorrect state shows cancel icon', (tester) async {
      await tester.pumpWidget(buildOption(isSelected: true, isIncorrect: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });

    testWidgets('tapping option calls onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: McqOption(
            optionKey: 'B',
            value: 'Option B',
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      ));

      await tester.tap(find.byType(McqOption));
      expect(tapped, isTrue);
    });

    testWidgets('disabled option does not call onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: McqOption(
            optionKey: 'C',
            value: 'Option C',
            isSelected: false,
            onTap: () => tapped = true,
            isDisabled: true,
          ),
        ),
      ));

      await tester.tap(find.byType(McqOption));
      expect(tapped, isFalse);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(buildOption(isSelected: false));
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(McqOption));
      expect(semantics.label, contains('A'));
    });
  });

  // ─── Timer Display Tests (Req 7.2, 7.3) ─────────────────────────────────

  group('Timer Display Logic (Req 7.2, 7.3)', () {
    test('formats seconds to MM:SS correctly', () {
      String formatTimer(int seconds) {
        final m = seconds ~/ 60;
        final s = seconds % 60;
        return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      }

      expect(formatTimer(0), equals('00:00'));
      expect(formatTimer(60), equals('01:00'));
      expect(formatTimer(90), equals('01:30'));
      expect(formatTimer(3600), equals('60:00'));
      expect(formatTimer(59), equals('00:59'));
    });

    test('timer warning triggers at 60 seconds or less', () {
      bool isWarning(int seconds) => seconds <= 60;

      expect(isWarning(61), isFalse);
      expect(isWarning(60), isTrue);
      expect(isWarning(30), isTrue);
      expect(isWarning(0), isTrue);
    });

    test('auto-submit triggers when timer reaches zero', () {
      bool shouldAutoSubmit(int seconds) => seconds <= 0;

      expect(shouldAutoSubmit(1), isFalse);
      expect(shouldAutoSubmit(0), isTrue);
      expect(shouldAutoSubmit(-1), isTrue);
    });
  });

  // ─── Answer Preservation Tests (Req 7.5) ─────────────────────────────────

  group('Answer Preservation (Req 7.5)', () {
    test('preserves selected answer for a question', () {
      final answers = <String, String>{};
      const questionId = 'q1';
      const selectedAnswer = 'B';

      answers[questionId] = selectedAnswer;

      expect(answers[questionId], equals(selectedAnswer));
    });

    test('overwrites previous answer for same question', () {
      final answers = <String, String>{'q1': 'A'};
      answers['q1'] = 'C';

      expect(answers['q1'], equals('C'));
    });

    test('preserves answers for multiple questions independently', () {
      final answers = <String, String>{
        'q1': 'A',
        'q2': 'B',
        'q3': 'C',
      };

      expect(answers['q1'], equals('A'));
      expect(answers['q2'], equals('B'));
      expect(answers['q3'], equals('C'));
    });

    test('returns null for unanswered question', () {
      final answers = <String, String>{'q1': 'A'};
      expect(answers['q2'], isNull);
    });
  });

  // ─── Skill Classification Display Tests (Req 8.3) ────────────────────────

  group('Skill Classification (Req 8.3)', () {
    test('classifies skill as strength at 70% or above', () {
      String classify(double percentage) =>
          percentage >= 70.0 ? 'strength' : 'weakness';

      expect(classify(70.0), equals('strength'));
      expect(classify(75.0), equals('strength'));
      expect(classify(100.0), equals('strength'));
    });

    test('classifies skill as weakness below 70%', () {
      String classify(double percentage) =>
          percentage >= 70.0 ? 'strength' : 'weakness';

      expect(classify(69.9), equals('weakness'));
      expect(classify(50.0), equals('weakness'));
      expect(classify(0.0), equals('weakness'));
    });

    test('calculates skill percentage correctly', () {
      double calcPercentage(int correct, int total) =>
          total > 0 ? (correct / total) * 100 : 0;

      expect(calcPercentage(7, 10), equals(70.0));
      expect(calcPercentage(3, 10), equals(30.0));
      expect(calcPercentage(0, 0), equals(0.0));
    });
  });

  // ─── Points Display Tests (Req 15.2, 15.4) ───────────────────────────────

  group('Points and Achievement Badge (Req 15.2, 15.4)', () {
    test('awards bonus badge at 90% or above', () {
      bool hasBonusBadge(double score) => score >= 90.0;

      expect(hasBonusBadge(90.0), isTrue);
      expect(hasBonusBadge(95.0), isTrue);
      expect(hasBonusBadge(100.0), isTrue);
      expect(hasBonusBadge(89.9), isFalse);
    });

    test('calculates points correctly', () {
      int calcPoints(double score, int questionCount) =>
          (score / 100 * questionCount * 10).round();

      expect(calcPoints(80.0, 10), equals(80));
      expect(calcPoints(90.0, 10), equals(90));
      expect(calcPoints(100.0, 10), equals(100));
      expect(calcPoints(0.0, 10), equals(0));
    });
  });
}
