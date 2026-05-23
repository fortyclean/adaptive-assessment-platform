import 'package:adaptive_assessment/features/assessment/models/student_learning_insights.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentLearningInsightsSource', () {
    test('uses the latest completed skill breakdown for recommendations', () {
      final now = DateTime.now();
      final recommendation =
          const StudentLearningInsightsSource().recommendationFor([
        {
          'status': 'completed',
          'submittedAt':
              now.subtract(const Duration(days: 2)).toIso8601String(),
          'skillBreakdown': [
            {'mainSkill': 'الهندسة', 'correctAnswers': 1, 'totalQuestions': 5},
          ],
        },
        {
          'status': 'completed',
          'submittedAt': now.toIso8601String(),
          'skillBreakdown': [
            {'mainSkill': 'الجبر', 'correctAnswers': 2, 'totalQuestions': 5},
            {'mainSkill': 'النحو', 'correctAnswers': 5, 'totalQuestions': 5},
          ],
        },
      ]);

      expect(recommendation.focusSkill, 'الجبر');
      expect(recommendation.message, contains('40%'));
      expect(recommendation.route, '/student/micro-learning');
    });

    test('falls back to assessment action when no breakdown exists', () {
      final recommendation =
          const StudentLearningInsightsSource().recommendationFor([]);

      expect(recommendation.route, '/student/assessments-list');
      expect(recommendation.focusSkill, isNull);
    });
  });
}
