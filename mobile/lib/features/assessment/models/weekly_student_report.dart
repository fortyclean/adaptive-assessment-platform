class WeeklyStudentReport {
  const WeeklyStudentReport({
    required this.completedAttempts,
    required this.averageScore,
    required this.pointsEarned,
    required this.streakDays,
    required this.bestSkill,
    required this.focusSkill,
    required this.summary,
  });

  final int completedAttempts;
  final double averageScore;
  final int pointsEarned;
  final int streakDays;
  final String? bestSkill;
  final String? focusSkill;
  final String summary;
}

class WeeklyStudentReportSource {
  const WeeklyStudentReportSource();

  WeeklyStudentReport fromAttemptHistory(
    List<Map<String, dynamic>> history, {
    String Function(int attempts, double average, String? focusSkill)?
        summaryBuilder,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final completed = history.where((attempt) {
      if (attempt['status'] != 'completed' ||
          attempt['scorePercentage'] is! num) {
        return false;
      }
      final date = _attemptDate(attempt);
      return date != null && !date.isBefore(start);
    }).toList();

    final scores = completed
        .map((attempt) => (attempt['scorePercentage'] as num).toDouble())
        .toList();
    final average =
        scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
    final points = completed.fold<int>(
      0,
      (sum, attempt) => sum + ((attempt['pointsEarned'] as num?)?.toInt() ?? 0),
    );
    final skills = _rankSkills(completed);
    final bestSkill = skills.isEmpty ? null : skills.last.key;
    final focusSkill = skills.isEmpty ? null : skills.first.key;
    final streak = _calculateStreakDays(history);

    return WeeklyStudentReport(
      completedAttempts: completed.length,
      averageScore: average,
      pointsEarned: points,
      streakDays: streak,
      bestSkill: bestSkill,
      focusSkill: focusSkill,
      summary: _summaryFor(
        attempts: completed.length,
        average: average,
        focusSkill: focusSkill,
        summaryBuilder: summaryBuilder,
      ),
    );
  }

  String _summaryFor({
    required int attempts,
    required double average,
    required String? focusSkill,
    required String Function(int attempts, double average, String? focusSkill)?
        summaryBuilder,
  }) {
    if (summaryBuilder != null) {
      return summaryBuilder(attempts, average, focusSkill);
    }
    if (attempts == 0) {
      return 'No results this week yet. Start a short assessment to unlock your weekly report.';
    }
    if (average >= 85) {
      return 'Strong week. Keep your pace and review ${focusSkill ?? 'your weakest skill'} to maintain your level.';
    }
    if (average >= 70) {
      return 'Good progress. One micro-learning session on ${focusSkill ?? 'your weakest skill'} will improve consistency.';
    }
    return 'This week needs more focus. Start a short plan on ${focusSkill ?? 'your weakest skill'}, then retake one assessment.';
  }

  List<MapEntry<String, double>> _rankSkills(
    List<Map<String, dynamic>> history,
  ) {
    final skills = <String, List<double>>{};
    for (final attempt in history) {
      final breakdown = attempt['skillBreakdown'];
      if (breakdown is! List) continue;
      for (final item in breakdown) {
        if (item is! Map) continue;
        final skill = (item['mainSkill'] ?? item['skill'] ?? '').toString();
        final total = (item['totalQuestions'] as num?)?.toDouble() ?? 0;
        final correct = (item['correctAnswers'] as num?)?.toDouble() ?? 0;
        if (skill.isEmpty || total <= 0) continue;
        skills.putIfAbsent(skill, () => []).add(correct / total);
      }
    }

    final ranked = skills.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, average.clamp(0.0, 1.0));
    }).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return ranked;
  }

  int _calculateStreakDays(List<Map<String, dynamic>> history) {
    final days = history
        .where((attempt) => attempt['status'] == 'completed')
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
