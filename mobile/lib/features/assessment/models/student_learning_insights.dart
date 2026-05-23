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
    List<Map<String, dynamic>> history,
  ) {
    final latestSkills = latestSkillBreakdown(history);
    if (latestSkills.isEmpty) {
      return const LearningRecommendation(
        title: 'ابدأ ببناء توصياتك',
        message:
            'أكمل اختبارًا قصيرًا حتى تظهر توصيات مبنية على أحدث تفصيل مهاراتك.',
        actionLabel: 'ابدأ اختبارًا',
        route: '/student/assessments-list',
      );
    }

    final weakest = latestSkills.first;
    final percent = (weakest.mastery * 100).round();
    if (weakest.mastery < 0.7) {
      return LearningRecommendation(
        title: 'ركز على ${weakest.skill}',
        message:
            'آخر نتيجة أظهرت إتقان $percent% في ${weakest.skill}. ابدأ بدرس قصير ثم جرّب بطاقات التدريب.',
        actionLabel: 'افتح خطة التعلم',
        route: '/student/micro-learning',
        focusSkill: weakest.skill,
      );
    }

    return LearningRecommendation(
      title: 'حافظ على مستواك',
      message:
          'أضعف مهارة في آخر اختبار هي ${weakest.skill} بنسبة $percent%. تدريب قصير يكفي للحفاظ على الإتقان.',
      actionLabel: 'تدريب بطاقات',
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
