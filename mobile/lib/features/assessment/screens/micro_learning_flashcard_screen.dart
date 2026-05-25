import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/student_state_view.dart';
import '../models/micro_learning_flashcard.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/micro_learning_progress_store.dart';

class MicroLearningFlashcardScreen extends ConsumerStatefulWidget {
  const MicroLearningFlashcardScreen({super.key});

  @override
  ConsumerState<MicroLearningFlashcardScreen> createState() =>
      _MicroLearningFlashcardScreenState();
}

class _MicroLearningFlashcardScreenState
    extends ConsumerState<MicroLearningFlashcardScreen> {
  bool _isLoading = true;
  bool _isRevealed = false;
  bool _isFinished = false;
  String? _errorMessage;
  MicroLearningFlashcardDeck? _deck;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isRevealed = false;
      _isFinished = false;
      _currentIndex = 0;
      _correctCount = 0;
      _reviewCount = 0;
    });

    try {
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();
      final deck = const MicroLearningFlashcardSource().fromAttemptHistory(
        history,
      );
      if (!mounted) return;
      setState(() {
        _deck = deck;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errorMessage = l10n.flashcardLoadFailedMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _answerCard({required bool isCorrect}) async {
    final deck = _deck;
    if (deck == null || deck.cards.isEmpty) return;

    final nextIndex = _currentIndex + 1;
    final nextCorrect = _correctCount + (isCorrect ? 1 : 0);
    final nextReview = _reviewCount + (isCorrect ? 0 : 1);
    final isLast = nextIndex >= deck.cards.length;

    if (isLast) {
      await _progressStore.recordFlashcardSession(
        userId: _studentId,
        correctCount: nextCorrect,
        totalCount: deck.cards.length,
        focusSkill: deck.cards.first.skill,
      );
    }

    if (!mounted) return;
    setState(() {
      _correctCount = nextCorrect;
      _reviewCount = nextReview;
      _isRevealed = false;
      if (isLast) {
        _isFinished = true;
      } else {
        _currentIndex = nextIndex;
      }
    });
  }

  MicroLearningProgressStore get _progressStore => MicroLearningProgressStore(
        Hive.box<dynamic>(AppConstants.sessionStateBoxName),
      );

  String? get _studentId => ref.read(authProvider).user?.id;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(l10n.flashcardPracticeTitle),
        leading: IconButton(
          tooltip: l10n.back,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/student/micro-learning');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, role: 'student'),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return StudentStateView(
        icon: Icons.wifi_off_rounded,
        title: l10n.flashcardLoadFailedTitle,
        message: _errorMessage!,
        actionLabel: l10n.retry,
        onAction: _loadDeck,
      );
    }

    final deck = _deck;
    if (deck == null || deck.cards.isEmpty) {
      return StudentStateView(
        icon: Icons.style_outlined,
        title: l10n.flashcardEmptyTitle,
        message: l10n.flashcardEmptyMessage,
        actionLabel: l10n.openAssessments,
        onAction: () => context.go('/student/assessments-list'),
      );
    }

    if (_isFinished) {
      return _buildSummary(deck);
    }

    return _buildPractice(deck);
  }

  Widget _buildPractice(MicroLearningFlashcardDeck deck) {
    final card = deck.cards[_currentIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final progress = (_currentIndex + 1) / deck.cards.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              deck.title,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              deck.subtitle,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  '${_currentIndex + 1}/${deck.cards.length}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: _isRevealed
                  ? l10n.flashcardSemanticsAnswerVisible(card.skill)
                  : l10n.flashcardSemanticsTapToReveal(card.skill),
              child: InkWell(
                onTap: () => setState(() => _isRevealed = true),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(22),
                  constraints: const BoxConstraints(minHeight: 260),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          _isRevealed ? card.color : colorScheme.outlineVariant,
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: card.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(card.icon, color: card.color),
                          ),
                          const Spacer(),
                          Text(
                            card.skill,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        card.prompt,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 23,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_isRevealed)
                        _buildAnswerBlock(card)
                      else
                        Text(
                          card.hint,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_isRevealed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _answerCard(isCorrect: false),
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(l10n.needReview),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _answerCard(isCorrect: true),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.masteredIt),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () => setState(() => _isRevealed = true),
                icon: const Icon(Icons.visibility_rounded),
                label: Text(l10n.showAnswer),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerBlock(MicroLearningFlashcard card) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.answer,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.answer,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(MicroLearningFlashcardDeck deck) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final percent = ((_correctCount / deck.cards.length) * 100).round();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.flashcardSummaryTitle,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.flashcardSummaryMessage(
                      _correctCount,
                      deck.cards.length,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryStat(
                          label: l10n.mastery,
                          value: '$percent%',
                          icon: Icons.insights_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryStat(
                          label: l10n.forReview,
                          value: '$_reviewCount',
                          icon: Icons.replay_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDeck,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.restartPractice),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.go('/student/micro-learning'),
              icon: const Icon(Icons.route_rounded),
              label: Text(l10n.backToLearningPlan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
