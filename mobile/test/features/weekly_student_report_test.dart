import 'package:adaptive_assessment/features/assessment/models/weekly_student_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyStudentReportSource', () {
    test('summarizes attempts in the last seven days', () {
      final now = DateTime.now();
      final report = const WeeklyStudentReportSource().fromAttemptHistory([
        {
          'status': 'completed',
          'scorePercentage': 80,
          'pointsEarned': 40,
          'submittedAt': now.toIso8601String(),
          'skillBreakdown': [
            {'mainSkill': 'الجبر', 'correctAnswers': 2, 'totalQuestions': 5},
            {'mainSkill': 'الهندسة', 'correctAnswers': 5, 'totalQuestions': 5},
          ],
        },
        {
          'status': 'completed',
          'scorePercentage': 60,
          'pointsEarned': 20,
          'submittedAt':
              now.subtract(const Duration(days: 8)).toIso8601String(),
        },
      ]);

      expect(report.completedAttempts, 1);
      expect(report.averageScore, 80);
      expect(report.pointsEarned, 40);
      expect(report.focusSkill, 'الجبر');
      expect(report.bestSkill, 'الهندسة');
    });

    test('returns an empty-week message when there is no activity', () {
      final report = const WeeklyStudentReportSource().fromAttemptHistory([]);

      expect(report.completedAttempts, 0);
      expect(report.summary, contains('No results this week yet'));
    });
  });
}
