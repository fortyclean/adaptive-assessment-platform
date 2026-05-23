import 'package:adaptive_assessment/features/assessment/models/student_challenge_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentChallengePlanSource', () {
    test('unlocks and completes challenges from weekly activity and streak',
        () {
      final now = DateTime.now();
      final history = List.generate(3, (index) {
        final date = now.subtract(Duration(days: index));
        return {
          'status': 'completed',
          'scorePercentage': index == 0 ? 95 : 80,
          'submittedAt': date.toIso8601String(),
        };
      });

      final plan = const StudentChallengePlanSource().fromAttemptHistory(
        history,
      );

      expect(plan.streakDays, greaterThanOrEqualTo(3));
      expect(plan.completedThisWeek, 3);
      expect(
        plan.states['math-marathon']!.status,
        StudentChallengeStatus.completed,
      );
      expect(
        plan.states['arabic-race']!.status,
        StudentChallengeStatus.joinable,
      );
      expect(
        plan.states['english-vocab']!.status,
        StudentChallengeStatus.completed,
      );
    });

    test('locks streak-based challenge when activity is insufficient', () {
      final plan = const StudentChallengePlanSource().fromAttemptHistory([]);

      expect(plan.streakDays, 0);
      expect(
        plan.states['arabic-race']!.status,
        StudentChallengeStatus.locked,
      );
    });
  });
}
