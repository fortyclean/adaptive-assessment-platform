import 'package:adaptive_assessment/features/assessment/models/micro_learning_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MicroLearningPlanSource', () {
    test('builds diagnostic starter lessons when the student has no history',
        () {
      final plan = const MicroLearningPlanSource().fromAttemptHistory([]);

      expect(plan.xpPoints, 0);
      expect(plan.dailyGoalProgress, 0);
      expect(plan.streakDays, 0);
      expect(plan.focusAreas, hasLength(1));
      expect(plan.lessons, hasLength(2));
      expect(plan.lessons.first.status, MicroLessonStatus.available);
      expect(plan.lessons.last.status, MicroLessonStatus.locked);
    });

    test('creates focused lessons from weakest skills first', () {
      final now = DateTime.now().toIso8601String();
      final plan = const MicroLearningPlanSource().fromAttemptHistory([
        {
          'status': 'completed',
          'scorePercentage': 70,
          'pointsEarned': 35,
          'submittedAt': now,
          'skillBreakdown': [
            {
              'mainSkill': 'الجبر',
              'correctAnswers': 1,
              'totalQuestions': 5,
            },
            {
              'mainSkill': 'الهندسة',
              'correctAnswers': 4,
              'totalQuestions': 5,
            },
          ],
        },
      ]);

      expect(plan.xpPoints, 35);
      expect(plan.dailyGoalProgress, closeTo(1 / 3, 0.001));
      expect(plan.streakDays, 1);
      expect(plan.focusAreas.first.title, 'الجبر');
      expect(plan.lessons.first.skill, 'الجبر');
      expect(plan.lessons.first.status, MicroLessonStatus.available);
      expect(plan.lessons.first.mastery, closeTo(0.2, 0.001));
    });

    test('marks persisted lessons as completed', () {
      final plan = const MicroLearningPlanSource().fromAttemptHistory(
        [
          {
            'status': 'completed',
            'scorePercentage': 80,
            'pointsEarned': 40,
            'submittedAt': DateTime.now().toIso8601String(),
            'skillBreakdown': [
              {
                'mainSkill': 'الجبر',
                'correctAnswers': 2,
                'totalQuestions': 5,
              },
            ],
          },
        ],
        completedLessonIds: {'skill-الجبر'},
      );

      expect(plan.lessons.single.status, MicroLessonStatus.completed);
      expect(plan.lessons.single.isCompleted, isTrue);
      expect(plan.lessons.single.subtitle, contains('Completed'));
    });

    test('ignores incomplete attempts and malformed skill entries', () {
      final plan = const MicroLearningPlanSource().fromAttemptHistory([
        {
          'status': 'in_progress',
          'scorePercentage': 90,
          'pointsEarned': 90,
          'skillBreakdown': [
            {
              'mainSkill': 'القراءة',
              'correctAnswers': 5,
              'totalQuestions': 5,
            },
          ],
        },
        {
          'status': 'completed',
          'scorePercentage': 65,
          'pointsEarned': 20,
          'skillBreakdown': [
            {'mainSkill': '', 'correctAnswers': 1, 'totalQuestions': 5},
            {'mainSkill': 'النحو', 'correctAnswers': 0, 'totalQuestions': 0},
          ],
        },
      ]);

      expect(plan.xpPoints, 20);
      expect(plan.focusAreas.single.title, 'Diagnostic assessment');
      expect(plan.lessons.first.status, MicroLessonStatus.available);
    });
  });
}
