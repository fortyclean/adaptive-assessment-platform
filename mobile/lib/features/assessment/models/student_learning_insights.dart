class SkillInsight {
  const SkillInsight({
    required this.skill,
    required this.mastery,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  final String skill;
  final double mastery;
  final int correctAnswers;
  final int totalQuestions;
}

class LearningRecommendation {
  const LearningRecommendation({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.route,
    this.focusSkill,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String route;
  final String? focusSkill;
}

class StudentLearningInsightsSource {
  const StudentLearningInsightsSource();

  List<SkillInsight> latestSkillBreakdown(
    List<Map<String, dynamic>> history,
  ) {
    final latest = _latestCompletedAttempt(history);
    if (latest == null) return const [];

    final breakdown = latest['skillBreakdown'];
    if (breakdown is! List) return const [];

    final insights = <SkillInsight>[];
    for (final item in breakdown) {
      if (item is! Map) continue;
      final skill = (item['mainSkill'] ?? item['skill'] ?? '').toString();
      final total = (item['totalQuestions'] as num?)?.toInt() ?? 0;
      final correct = (item['correctAnswers'] as num?)?.toInt() ?? 0;
      if (skill.isEmpty || total <= 0) continue;
      insights.add(
        SkillInsight(
          skill: skill,
          mastery: (correct / total).clamp(0.0, 1.0),
          correctAnswers: correct,
          totalQuestions: total,
        ),
      );
    }

    insights.sort((a, b) => a.mastery.compareTo(b.mastery));
    return insights;
  }

  LearningRecommendation recommendationFor(
    List<Map<String, dynamic>> history, {
    LearningRecommendation Function(SkillInsight? weakest)? builder,
  }) {
    final latestSkills = latestSkillBreakdown(history);
    if (latestSkills.isEmpty) {
      if (builder != null) return builder(null);
      return const LearningRecommendation(
        title: 'Start building your recommendations',
        message:
            'Complete a short assessment so recommendations can use your latest skill breakdown.',
        actionLabel: 'Start assessment',
        route: '/student/assessments-list',
      );
    }

    final weakest = latestSkills.first;
    if (builder != null) return builder(weakest);
    final percent = (weakest.mastery * 100).round();
    if (weakest.mastery < 0.7) {
      return LearningRecommendation(
        title: 'Focus on ${weakest.skill}',
        message:
            'Your latest result showed $percent% mastery in ${weakest.skill}. Start with a short lesson, then try practice cards.',
        actionLabel: 'Open learning plan',
        route: '/student/micro-learning',
        focusSkill: weakest.skill,
      );
    }

    return LearningRecommendation(
      title: 'Keep your level',
      message:
          'The weakest skill in your latest assessment is ${weakest.skill} at $percent%. A short practice is enough to maintain mastery.',
      actionLabel: 'Practice cards',
      route: '/student/micro-learning/flashcards',
      focusSkill: weakest.skill,
    );
  }

  Map<String, dynamic>? _latestCompletedAttempt(
    List<Map<String, dynamic>> history,
  ) {
    final completed = history
        .where((attempt) =>
            attempt['status'] == 'completed' &&
            attempt['skillBreakdown'] is List)
        .toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => _attemptDate(b).compareTo(_attemptDate(a)));
    return completed.first;
  }

  DateTime _attemptDate(Map<String, dynamic> attempt) =>
      DateTime.tryParse(
        (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
      ) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
