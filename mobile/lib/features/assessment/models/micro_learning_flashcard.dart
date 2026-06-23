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

class MicroLearningFlashcardCopy {
  const MicroLearningFlashcardCopy({
    this.diagnosticDeckTitle = 'Quick diagnostic practice',
    this.diagnosticDeckSubtitle =
        'Start with these cards so recommendations become more precise after your first assessment.',
    this.diagnosticSkill = 'Diagnostic',
    this.diagnosticGoalPrompt =
        'What is the goal of the first diagnostic assessment?',
    this.diagnosticGoalAnswer =
        'Identify your current mastery level and discover the skills that need a short review.',
    this.diagnosticGoalHint =
        'Think about why a personal learning plan appears after the assessment.',
    this.learningPlanSkill = 'Learning plan',
    this.diagnosticNextStepPrompt =
        'What should you do after the first result appears?',
    this.diagnosticNextStepAnswer =
        'Review the weakest skill in micro-learning, then complete a short practice to measure improvement.',
    this.diagnosticNextStepHint =
        'Improvement starts with the weakest skill, not the highest score.',
    this.conceptPromptTemplate = 'What is the first step to improve {skill}?',
    this.conceptAnswer =
        'Start with one simple question that identifies the reason for the mistake, then review the related rule before practicing.',
    this.conceptHint =
        'Do not start by solving many questions before knowing the reason for the mistake.',
    this.reviewPromptTemplate =
        'Your current mastery in {skill} is {mastery}%. What does that mean?',
    this.reviewAnswer =
        'This skill needs focused review today, then a short assessment to confirm improvement.',
    this.reviewHint =
        'The lower percentage means higher priority in the learning plan.',
    this.deckTitleTemplate = '{skill} booster cards',
    this.deckSubtitle =
        'Short practice built from your weakest skills in the latest results.',
  });

  final String diagnosticDeckTitle;
  final String diagnosticDeckSubtitle;
  final String diagnosticSkill;
  final String diagnosticGoalPrompt;
  final String diagnosticGoalAnswer;
  final String diagnosticGoalHint;
  final String learningPlanSkill;
  final String diagnosticNextStepPrompt;
  final String diagnosticNextStepAnswer;
  final String diagnosticNextStepHint;
  final String conceptPromptTemplate;
  final String conceptAnswer;
  final String conceptHint;
  final String reviewPromptTemplate;
  final String reviewAnswer;
  final String reviewHint;
  final String deckTitleTemplate;
  final String deckSubtitle;

  String conceptPrompt(String skill) =>
      conceptPromptTemplate.replaceAll('{skill}', skill);

  String reviewPrompt(String skill, int mastery) => reviewPromptTemplate
      .replaceAll('{skill}', skill)
      .replaceAll('{mastery}', mastery.toString());

  String deckTitle(String skill) =>
      deckTitleTemplate.replaceAll('{skill}', skill);
}

class MicroLearningFlashcardSource {
  const MicroLearningFlashcardSource();

  MicroLearningFlashcardDeck fromAttemptHistory(
    List<Map<String, dynamic>> history, {
    MicroLearningFlashcardCopy copy = const MicroLearningFlashcardCopy(),
  }) {
    final rankedSkills = _rankWeakSkills(history);
    if (rankedSkills.isEmpty) {
      return MicroLearningFlashcardDeck(
        title: copy.diagnosticDeckTitle,
        subtitle: copy.diagnosticDeckSubtitle,
        cards: [
          MicroLearningFlashcard(
            id: 'diagnostic-goal',
            skill: copy.diagnosticSkill,
            prompt: copy.diagnosticGoalPrompt,
            answer: copy.diagnosticGoalAnswer,
            hint: copy.diagnosticGoalHint,
            color: AppColors.primary,
            icon: Icons.psychology_outlined,
          ),
          MicroLearningFlashcard(
            id: 'diagnostic-next-step',
            skill: copy.learningPlanSkill,
            prompt: copy.diagnosticNextStepPrompt,
            answer: copy.diagnosticNextStepAnswer,
            hint: copy.diagnosticNextStepHint,
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
          prompt: copy.conceptPrompt(skill),
          answer: copy.conceptAnswer,
          hint: copy.conceptHint,
          color: color,
          icon: Icons.lightbulb_outline_rounded,
        ),
        MicroLearningFlashcard(
          id: 'review-$skill',
          skill: skill,
          prompt: copy.reviewPrompt(skill, mastery),
          answer: copy.reviewAnswer,
          hint: copy.reviewHint,
          color: color,
          icon: Icons.trending_down_rounded,
        ),
      ]);
    }

    final weakest = rankedSkills.first.key;
    return MicroLearningFlashcardDeck(
      title: copy.deckTitle(weakest),
      subtitle: copy.deckSubtitle,
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
