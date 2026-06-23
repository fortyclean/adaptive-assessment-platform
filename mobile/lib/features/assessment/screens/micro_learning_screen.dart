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
import '../models/micro_learning_plan.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/micro_learning_progress_store.dart';

/// Micro-Learning Screen — Design _62
/// Smart micro-learning.
/// Short learning cards per skill weakness with progress tracking.
class MicroLearningScreen extends ConsumerStatefulWidget {
  const MicroLearningScreen({super.key});

  @override
  ConsumerState<MicroLearningScreen> createState() =>
      _MicroLearningScreenState();
}

class _MicroLearningScreenState extends ConsumerState<MicroLearningScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Daily goal progress (0.0 – 1.0)
  double _dailyGoalProgress = 0;

  // Streak days
  int _streakDays = 0;

  // XP points
  int _xpPoints = 0;
  Set<String> _completedLessonIds = {};

  // Daily micro-lessons
  List<MicroLearningLesson> _lessons = const [];

  // AI-recommended weak areas
  List<MicroLearningFocusArea> _weakAreas = const [];

  AppLocalizations get _l10n => AppLocalizations.of(context);

  MicroLearningPlanCopy get _planCopy => MicroLearningPlanCopy(
        completedSuffix: _l10n.completed,
        emptyFocusTitle: _l10n.microLearningDiagnosticAssessment,
        emptyFocusDescription: _l10n.microLearningDiagnosticDescription,
        strongSkillDescription: _l10n.microLearningStrongSkillDescription,
        needsReviewDescription: _l10n.microLearningNeedsReviewDescription,
        diagnosticLessonTitle: _l10n.microLearningDiagnosticLessonTitle,
        diagnosticLessonSubtitle: _l10n.microLearningDiagnosticLessonSubtitle,
        diagnosticSkill: _l10n.microLearningDiagnosticSkill,
        reviewResultsTitle: _l10n.microLearningReviewResultsTitle,
        reviewResultsSubtitle: _l10n.microLearningReviewResultsSubtitle,
        resultsAnalysisSkill: _l10n.microLearningResultsAnalysisSkill,
        skillReviewTitleTemplate:
            _l10n.microLearningSkillReviewTitleTemplate('{skill}'),
        skillReviewSubtitleTemplate:
            _l10n.microLearningSkillReviewSubtitleTemplate('{percent}'),
      );

  @override
  void initState() {
    super.initState();
    _loadLearningPlan();
  }

  Future<void> _loadLearningPlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _completedLessonIds = _loadCompletedLessonIds();
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();
      final plan = const MicroLearningPlanSource().fromAttemptHistory(
        history,
        completedLessonIds: _completedLessonIds,
        copy: _planCopy,
      );
      final completionProgress = plan.lessons.isEmpty
          ? 0.0
          : (_completedLessonIds.length / plan.lessons.length).clamp(0.0, 1.0);

      if (!mounted) return;
      setState(() {
        _xpPoints = plan.xpPoints;
        _dailyGoalProgress = plan.dailyGoalProgress > completionProgress
            ? plan.dailyGoalProgress
            : completionProgress;
        _streakDays = plan.streakDays;
        _weakAreas = plan.focusAreas;
        _lessons = plan.lessons;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _l10n.microLearningLoadFailedMessage;
        _isLoading = false;
      });
    }
  }

  Set<String> _loadCompletedLessonIds() {
    return _progressStore.loadCompletedLessonIds(_studentId);
  }

  Future<void> _markLessonCompleted(MicroLearningLesson lesson) async {
    if (lesson.isLocked || lesson.isCompleted) return;
    final nextCompleted =
        await _progressStore.markCompleted(_studentId, lesson.id);
    if (!mounted) return;
    setState(() {
      _completedLessonIds = nextCompleted;
      _lessons = _lessons
          .map((item) => item.id == lesson.id
              ? item.copyWith(
                  status: MicroLessonStatus.completed,
                  subtitle: _planCopy.completedSubtitle(item.subtitle),
                )
              : item)
          .toList();
      _dailyGoalProgress =
          (_completedLessonIds.length / _lessons.length).clamp(0.0, 1.0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_l10n.microLearningLessonCompletionSaved),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  MicroLearningProgressStore get _progressStore => MicroLearningProgressStore(
        Hive.box<dynamic>(AppConstants.sessionStateBoxName),
      );

  String? get _studentId => ref.read(authProvider).user?.id;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'student'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: StudentStateView(
          icon: Icons.wifi_off_rounded,
          title: _l10n.microLearningLoadFailedTitle,
          message: _errorMessage!,
          actionLabel: _l10n.retry,
          onAction: _loadLearningPlan,
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'student'),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadLearningPlan,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── App Bar ────────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 1,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Refresh button (RTL: left)
                  TextButton.icon(
                    onPressed: _isLoading ? null : _loadLearningPlan,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      _l10n.refresh,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Title + back (RTL: right)
                  Row(
                    children: [
                      Text(
                        _l10n.microLearningTitle,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/student');
                          }
                        },
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Content ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero Section
                  _buildHeroSection(),
                  const SizedBox(height: 24),

                  // Daily Goal Progress
                  _buildDailyGoal(),
                  const SizedBox(height: 24),

                  // Daily Micro-lessons
                  _buildDailyLessons(),
                  const SizedBox(height: 24),

                  // AI Recommendations Bento Grid
                  _buildAIRecommendations(),
                  const SizedBox(height: 24),

                  // Actionable learning path
                  _buildLearningPathCard(),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, role: 'student'),
    );
  }

  // ─── Hero Section ──────────────────────────────────────────────────────

  Widget _buildHeroSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // XP Badge (RTL: left)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_xpPoints XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Greeting + title (RTL: right)
              Column(
                key: ValueKey(
                  ref.watch(authProvider).user?.fullName ?? 'student',
                ),
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _l10n.microLearningWelcomeBack(
                      ref.watch(authProvider).user?.fullName.split(' ').first ??
                          _l10n.studentFallbackName,
                    ),
                    semanticsLabel:
                        ref.watch(authProvider).user?.fullName ?? 'student',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _l10n.microLearningSmartTitle,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak Card
          _buildStreakCard(),
        ],
      );

  Widget _buildStreakCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _l10n.microLearningCurrentStreakTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _l10n.microLearningStreakMessage(_streakDays),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFEA580C),
                size: 32,
              ),
            ),
          ],
        ),
      );
  Widget _buildDailyGoal() {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = (_dailyGoalProgress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _l10n.microLearningPercentComplete(percent),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _l10n.microLearningDailyGoal,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _dailyGoalProgress,
            minHeight: 12,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF10B981),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyLessons() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _l10n.microLearningTodaysQuickLessons,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          ..._lessons.map(_buildLessonCard),
        ],
      );

  Widget _buildLessonCard(MicroLearningLesson lesson) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: !lesson.isLocked,
      enabled: !lesson.isLocked,
      label: lesson.isLocked
          ? _l10n.microLearningLockedLessonSemantics(lesson.title)
          : lesson.isCompleted
              ? _l10n.microLearningCompletedLessonSemantics(lesson.title)
              : _l10n.microLearningOpenLessonSemantics(lesson.title),
      child: Opacity(
        opacity: lesson.isLocked ? 0.62 : 1.0,
        child: InkWell(
          onTap: lesson.isLocked
              ? null
              : () => context.push('/student/assessments-list'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: lesson.isCompleted
                    ? AppColors.success
                    : colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: lesson.isCompleted
                      ? _l10n.microLearningLessonCompletedTooltip
                      : _l10n.microLearningMarkLessonCompleted,
                  onPressed: lesson.isLocked || lesson.isCompleted
                      ? null
                      : () => _markLessonCompleted(lesson),
                  icon: Icon(
                    lesson.isLocked
                        ? Icons.lock_outline_rounded
                        : lesson.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                    color: lesson.isCompleted
                        ? AppColors.success
                        : lesson.isLocked
                            ? colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.55)
                            : AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              lesson.title,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lesson.subtitle,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: lesson.isLocked
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.primaryContainer
                                  .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          lesson.icon,
                          color: lesson.isLocked
                              ? colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.65)
                              : AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendations() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _l10n.microLearningAiRecommendationsTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          _buildFlashcardChallenge(),
          const SizedBox(height: 12),
          Row(
            children: _weakAreas
                .map((area) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: area == _weakAreas.first ? 6 : 0,
                          left: area == _weakAreas.last ? 6 : 0,
                        ),
                        child: _buildWeakAreaCard(area),
                      ),
                    ))
                .toList(),
          ),
        ],
      );

  Widget _buildFlashcardChallenge() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _l10n.microLearningFlashcardChallengeTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _weakAreas.isEmpty
                  ? _l10n.microLearningBasedOnLatestResults
                  : _l10n.microLearningBasedOnFocus(_weakAreas.first.title),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    context.push('/student/micro-learning/flashcards'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _l10n.microLearningStartFlashcardChallenge,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  Widget _buildWeakAreaCard(MicroLearningFocusArea area) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(area.icon, color: area.color, size: 24),
          const SizedBox(height: 8),
          Text(
            area.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            area.description,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: area.progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(area.color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Featured Video ────────────────────────────────────────────────────

  Widget _buildLearningPathCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final focusArea = _weakAreas.isEmpty
        ? _l10n.microLearningWeakestSkillFallback
        : _weakAreas.first.title;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, color: colorScheme.primary),
              const Spacer(),
              Text(
                _l10n.microLearningSuggestedPathTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLearningStep(
            number: '1',
            title: _l10n.microLearningReviewFocusStep(focusArea),
            subtitle: _l10n.microLearningShortestLessonStep,
          ),
          _buildLearningStep(
            number: '2',
            title: _l10n.microLearningSolveShortPracticeStep,
            subtitle: _l10n.microLearningOneAssessmentStep,
          ),
          _buildLearningStep(
            number: '3',
            title: _l10n.microLearningOpenAnalyticsStep,
            subtitle: _l10n.microLearningCompareLatestResultStep,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/student/analytics'),
              icon: const Icon(Icons.insights_rounded),
              label: Text(_l10n.microLearningReviewAnalytics),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStep({
    required String number,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────
