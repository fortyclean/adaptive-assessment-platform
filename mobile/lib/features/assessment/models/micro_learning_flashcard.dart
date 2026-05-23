import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class MicroLearningFlashcard {
  const MicroLearningFlashcard({
    required this.id,
    required this.skill,
    required this.prompt,
    required this.answer,
    required this.hint,
    required this.color,
    required this.icon,
  });

  final String id;
  final String skill;
  final String prompt;
  final String answer;
  final String hint;
  final Color color;
  final IconData icon;
}

class MicroLearningFlashcardDeck {
  const MicroLearningFlashcardDeck({
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  final String title;
  final String subtitle;
  final List<MicroLearningFlashcard> cards;
}

class MicroLearningFlashcardSource {
  const MicroLearningFlashcardSource();

  MicroLearningFlashcardDeck fromAttemptHistory(
    List<Map<String, dynamic>> history,
  ) {
    final rankedSkills = _rankWeakSkills(history);
    if (rankedSkills.isEmpty) {
      return const MicroLearningFlashcardDeck(
        title: 'تدريب تشخيصي سريع',
        subtitle: 'ابدأ بهذه البطاقات حتى تظهر توصيات أدق بعد أول اختبار.',
        cards: [
          MicroLearningFlashcard(
            id: 'diagnostic-goal',
            skill: 'تشخيص',
            prompt: 'ما هدف الاختبار التشخيصي الأول؟',
            answer:
                'تحديد مستوى الإتقان الحالي واكتشاف المهارات التي تحتاج مراجعة قصيرة.',
            hint: 'فكر في سبب ظهور خطة تعلم شخصية بعد الاختبار.',
            color: AppColors.primary,
            icon: Icons.psychology_outlined,
          ),
          MicroLearningFlashcard(
            id: 'diagnostic-next-step',
            skill: 'خطة التعلم',
            prompt: 'ماذا تفعل بعد ظهور أول نتيجة؟',
            answer:
                'راجع المهارة الأضعف في التعلم المصغر، ثم حل تدريبًا قصيرًا لقياس التحسن.',
            hint: 'التحسين يبدأ من أضعف مهارة، وليس من أعلى نتيجة.',
            color: AppColors.success,
            icon: Icons.route_outlined,
          ),
        ],
      );
    }

    final cards = <MicroLearningFlashcard>[];
    for (final entry in rankedSkills.take(4)) {
      final skill = entry.key;
      final mastery = (entry.value * 100).round().clamp(0, 100);
      final color = entry.value < 0.5 ? AppColors.error : AppColors.warning;
      cards.addAll([
        MicroLearningFlashcard(
          id: 'concept-$skill',
          skill: skill,
          prompt: 'ما أول خطوة لتحسين مهارة $skill؟',
          answer:
              'ابدأ بسؤال واحد بسيط يحدد سبب الخطأ، ثم راجع القاعدة المرتبطة به قبل التدريب.',
          hint: 'لا تبدأ بحل كثير من الأسئلة قبل معرفة سبب الخطأ.',
          color: color,
          icon: Icons.lightbulb_outline_rounded,
        ),
        MicroLearningFlashcard(
          id: 'review-$skill',
          skill: skill,
          prompt: 'إتقانك الحالي في $skill هو $mastery%. ماذا يعني ذلك؟',
          answer:
              'هذه مهارة تحتاج مراجعة مركزة اليوم، ثم اختبارًا قصيرًا للتأكد من التحسن.',
          hint: 'النسبة الأقل تعني أولوية أعلى في خطة التعلم.',
          color: color,
          icon: Icons.trending_down_rounded,
        ),
      ]);
    }

    final weakest = rankedSkills.first.key;
    return MicroLearningFlashcardDeck(
      title: 'بطاقات تقوية $weakest',
      subtitle: 'تدريب قصير مبني على أضعف مهاراتك في آخر النتائج.',
      cards: cards,
    );
  }

  List<MapEntry<String, double>> _rankWeakSkills(
    List<Map<String, dynamic>> history,
  ) {
    final skills = <String, List<double>>{};
    for (final attempt in history) {
      if (attempt['status'] != 'completed') continue;
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
}
