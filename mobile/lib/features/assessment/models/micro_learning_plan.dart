import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum MicroLessonStatus { available, locked }

class MicroLearningLesson {
  const MicroLearningLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.skill,
    required this.estimatedMinutes,
    required this.mastery,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final MicroLessonStatus status;
  final String skill;
  final int estimatedMinutes;
  final double mastery;

  bool get isLocked => status == MicroLessonStatus.locked;
}

class MicroLearningFocusArea {
  const MicroLearningFocusArea({
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
    required this.icon,
  });

  final String title;
  final String description;
  final double progress;
  final Color color;
  final IconData icon;
}

class MicroLearningPlan {
  const MicroLearningPlan({
    required this.dailyGoalProgress,
    required this.streakDays,
    required this.xpPoints,
    required this.lessons,
    required this.focusAreas,
  });

  final double dailyGoalProgress;
  final int streakDays;
  final int xpPoints;
  final List<MicroLearningLesson> lessons;
  final List<MicroLearningFocusArea> focusAreas;
}

class MicroLearningPlanSource {
  const MicroLearningPlanSource();

  MicroLearningPlan fromAttemptHistory(List<Map<String, dynamic>> history) {
    final completed = history
        .where((attempt) =>
            attempt['status'] == 'completed' &&
            attempt['scorePercentage'] is num)
        .toList();
    final focusAreas = _buildFocusAreas(completed);

    return MicroLearningPlan(
      xpPoints: completed.fold<int>(
        0,
        (sum, attempt) =>
            sum + ((attempt['pointsEarned'] as num?)?.toInt() ?? 0),
      ),
      dailyGoalProgress: (_todayAttemptCount(completed) / 3).clamp(0.0, 1.0),
      streakDays: _calculateStreakDays(completed),
      focusAreas: focusAreas,
      lessons: _buildLessons(focusAreas, completed.isEmpty),
    );
  }

  int _todayAttemptCount(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return history.where((attempt) {
      final date = DateTime.tryParse(
        (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
      );
      if (date == null) return false;
      return DateTime(date.year, date.month, date.day) == today;
    }).length;
  }

  int _calculateStreakDays(List<Map<String, dynamic>> history) {
    final days = history
        .map((attempt) => DateTime.tryParse(
              (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
            ))
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

  List<MicroLearningFocusArea> _buildFocusAreas(
    List<Map<String, dynamic>> history,
  ) {
    final skills = <String, List<double>>{};
    for (final attempt in history) {
      final breakdown = attempt['skillBreakdown'];
      if (breakdown is! List) continue;
      for (final item in breakdown) {
        if (item is! Map) continue;
        final total = (item['totalQuestions'] as num?)?.toDouble() ?? 0;
        final correct = (item['correctAnswers'] as num?)?.toDouble() ?? 0;
        final skill = (item['mainSkill'] ?? item['skill'] ?? '').toString();
        if (skill.isEmpty || total <= 0) continue;
        skills.putIfAbsent(skill, () => []).add(correct / total);
      }
    }

    if (skills.isEmpty) {
      return const [
        MicroLearningFocusArea(
          title: 'اختبار تشخيصي',
          description: 'ابدأ اختبارا لفتح توصيات مبنية على أدائك',
          progress: 0,
          color: AppColors.primary,
          icon: Icons.route_outlined,
        ),
      ];
    }

    final ranked = skills.entries.map((entry) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, avg);
    }).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return ranked.take(2).map((entry) {
      final progress = entry.value.clamp(0.0, 1.0);
      return MicroLearningFocusArea(
        title: entry.key,
        description: progress >= 0.75
            ? 'مهارة قوية، حافظ على مستواك'
            : 'تحتاج مراجعة قصيرة اليوم',
        progress: progress,
        color: progress >= 0.75 ? AppColors.success : AppColors.warning,
        icon: progress >= 0.75
            ? Icons.auto_awesome_rounded
            : Icons.trending_down_rounded,
      );
    }).toList();
  }

  List<MicroLearningLesson> _buildLessons(
    List<MicroLearningFocusArea> focusAreas,
    bool hasEmptyHistory,
  ) {
    if (hasEmptyHistory) {
      return const [
        MicroLearningLesson(
          id: 'diagnostic-start',
          title: 'ابدأ بأول اختبار تشخيصي',
          subtitle: '3 دقائق - يفتح توصياتك الشخصية',
          icon: Icons.psychology_outlined,
          status: MicroLessonStatus.available,
          skill: 'تشخيص',
          estimatedMinutes: 3,
          mastery: 0,
        ),
        MicroLearningLesson(
          id: 'review-after-first-result',
          title: 'راجع نتائجك بعد الاختبار',
          subtitle: 'مغلق حتى تظهر أول نتيجة',
          icon: Icons.insights_outlined,
          status: MicroLessonStatus.locked,
          skill: 'تحليل النتائج',
          estimatedMinutes: 4,
          mastery: 0,
        ),
      ];
    }

    return focusAreas.map((area) {
      final percent = (area.progress * 100).round();
      return MicroLearningLesson(
        id: 'skill-${area.title.hashCode}',
        title: 'مراجعة قصيرة: ${area.title}',
        subtitle: '4 دقائق - مستوى الإتقان $percent%',
        icon: area.icon,
        status: MicroLessonStatus.available,
        skill: area.title,
        estimatedMinutes: 4,
        mastery: area.progress,
      );
    }).toList();
  }
}
