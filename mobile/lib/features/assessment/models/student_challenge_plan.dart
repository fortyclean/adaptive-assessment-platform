enum StudentChallengeStatus { joinable, joined, completed, locked }

class StudentChallengeState {
  const StudentChallengeState({
    required this.id,
    required this.status,
    required this.progress,
    this.lockedReason,
  });

  final String id;
  final StudentChallengeStatus status;
  final double progress;
  final String? lockedReason;
}

class StudentChallengePlan {
  const StudentChallengePlan({
    required this.streakDays,
    required this.completedThisWeek,
    required this.states,
  });

  final int streakDays;
  final int completedThisWeek;
  final Map<String, StudentChallengeState> states;
}

class StudentChallengePlanSource {
  const StudentChallengePlanSource({
    this.twoDayStreakLockedReason =
        'This challenge unlocks after keeping a two-day streak.',
  });

  final String twoDayStreakLockedReason;

  StudentChallengePlan fromAttemptHistory(List<Map<String, dynamic>> history) {
    final completed = history
        .where((attempt) =>
            attempt['status'] == 'completed' &&
            attempt['scorePercentage'] is num)
        .toList();
    final completedThisWeek = _completedThisWeek(completed);
    final streak = _calculateStreakDays(completed);
    final bestScore = completed.fold<double>(
      0,
      (best, attempt) {
        final score = (attempt['scorePercentage'] as num).toDouble();
        return score > best ? score : best;
      },
    );

    return StudentChallengePlan(
      streakDays: streak,
      completedThisWeek: completedThisWeek,
      states: {
        'math-marathon': StudentChallengeState(
          id: 'math-marathon',
          status: completedThisWeek >= 3
              ? StudentChallengeStatus.completed
              : StudentChallengeStatus.joinable,
          progress: (completedThisWeek / 3).clamp(0.0, 1.0),
        ),
        'arabic-race': StudentChallengeState(
          id: 'arabic-race',
          status: streak >= 2
              ? StudentChallengeStatus.joinable
              : StudentChallengeStatus.locked,
          progress: (streak / 2).clamp(0.0, 1.0),
          lockedReason: twoDayStreakLockedReason,
        ),
        'chemistry-weekly': StudentChallengeState(
          id: 'chemistry-weekly',
          status: completedThisWeek >= 1
              ? StudentChallengeStatus.joined
              : StudentChallengeStatus.joinable,
          progress: (completedThisWeek / 5).clamp(0.0, 1.0),
        ),
        'english-vocab': StudentChallengeState(
          id: 'english-vocab',
          status: bestScore >= 90
              ? StudentChallengeStatus.completed
              : StudentChallengeStatus.joinable,
          progress: (bestScore / 90).clamp(0.0, 1.0),
        ),
      },
    );
  }

  int _completedThisWeek(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return history.where((attempt) {
      final date = _attemptDate(attempt);
      return date != null && !date.isBefore(start);
    }).length;
  }

  int _calculateStreakDays(List<Map<String, dynamic>> history) {
    final days = history
        .map(_attemptDate)
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();

    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  DateTime? _attemptDate(Map<String, dynamic> attempt) => DateTime.tryParse(
        (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
      );
}
