import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../models/student_challenge_plan.dart';
import '../repositories/assessment_repository.dart';

/// Student challenges screen.
///
/// Backend challenge persistence is not available yet, so the screen uses a
/// transparent local state model instead of SnackBar-only actions. Every action
/// changes visible challenge state or opens a clear unavailable-state dialog.
class StudentChallengesScreen extends ConsumerStatefulWidget {
  const StudentChallengesScreen({super.key});

  @override
  ConsumerState<StudentChallengesScreen> createState() =>
      _StudentChallengesScreenState();
}

class _StudentChallengesScreenState
    extends ConsumerState<StudentChallengesScreen> {
  final List<_Challenge> _challenges = [
    const _Challenge(
      id: 'math-marathon',
      title: 'ماراثون الرياضيات الذهنية',
      subtitle: 'المستوى المتقدم • الجبر والهندسة',
      reward: 500,
      participants: 1240,
      timeLeft: '14:25 دقيقة',
      progress: 0.75,
      status: ChallengeStatus.joinable,
      accentColor: AppColors.primaryContainer,
      subjectIcon: Icons.calculate_outlined,
    ),
    const _Challenge(
      id: 'arabic-race',
      title: 'مسابقة اللغة العربية الفصحى',
      subtitle: 'النحو والصرف • البلاغة',
      reward: 350,
      participants: 850,
      timeLeft: '05:10 دقيقة',
      progress: 0,
      status: ChallengeStatus.locked,
      accentColor: Color(0xFF611E00),
      subjectIcon: Icons.menu_book_outlined,
      lockedReason: 'يفتح هذا التحدي بعد إكمال اختبار اللغة العربية الحالي.',
    ),
    const _Challenge(
      id: 'chemistry-weekly',
      title: 'تحدي الكيمياء الأسبوعي',
      subtitle: 'ينتهي غدًا، 10:00 صباحًا',
      reward: 280,
      participants: 420,
      timeLeft: 'غدًا',
      progress: 0.35,
      status: ChallengeStatus.joined,
      accentColor: AppColors.success,
      subjectIcon: Icons.science_outlined,
    ),
    const _Challenge(
      id: 'english-vocab',
      title: 'المفردات الإنجليزية',
      subtitle: 'اكتمل • 90% دقة',
      reward: 200,
      participants: 690,
      timeLeft: 'مكتمل',
      progress: 1,
      status: ChallengeStatus.completed,
      accentColor: AppColors.success,
      subjectIcon: Icons.language_outlined,
    ),
  ];

  final int _completedCount = 12;
  int _createdCount = 0;
  int _streakDays = 0;
  int _completedThisWeek = 0;

  List<_Challenge> get _liveChallenges =>
      _challenges.where((c) => c.status != ChallengeStatus.completed).toList();

  List<_Challenge> get _myChallenges =>
      _challenges.where((c) => c.status != ChallengeStatus.joinable).toList();

  @override
  void initState() {
    super.initState();
    _loadChallengePlan();
  }

  Future<void> _loadChallengePlan() async {
    try {
      final twoDayStreakLockedReason =
          AppLocalizations.of(context).studentChallengeTwoDayStreakLocked;
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();
      final plan = StudentChallengePlanSource(
        twoDayStreakLockedReason: twoDayStreakLockedReason,
      ).fromAttemptHistory(
        history,
      );
      if (!mounted) return;
      setState(() {
        _streakDays = plan.streakDays;
        _completedThisWeek = plan.completedThisWeek;
        for (var index = 0; index < _challenges.length; index++) {
          final state = plan.states[_challenges[index].id];
          if (state == null) continue;
          _challenges[index] = _challenges[index].copyWith(
            status: _mapStatus(state.status),
            progress: state.progress,
            lockedReason: state.lockedReason,
          );
        }
      });
    } catch (_) {
      // Keep the local demo challenges visible when history cannot be loaded.
    }
  }

  ChallengeStatus _mapStatus(StudentChallengeStatus status) {
    switch (status) {
      case StudentChallengeStatus.joinable:
        return ChallengeStatus.joinable;
      case StudentChallengeStatus.joined:
        return ChallengeStatus.joined;
      case StudentChallengeStatus.completed:
        return ChallengeStatus.completed;
      case StudentChallengeStatus.locked:
        return ChallengeStatus.locked;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildStreakSummary(),
              const SizedBox(height: 24),
              _buildLiveChallenges(),
              const SizedBox(height: 24),
              _buildLeaderboard(),
              const SizedBox(height: 24),
              _buildMyChallenges(),
              const SizedBox(height: 24),
              _buildBadges(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateChallengeSheet,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context).studentChallengesNew),
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'student'),
      );

  Widget _buildStreakSummary() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _MiniMetric(
            icon: Icons.local_fire_department_rounded,
            value: '$_streakDays',
            label: l10n.studentChallengesStreakDays,
          ),
          const SizedBox(width: 12),
          _MiniMetric(
            icon: Icons.task_alt_rounded,
            value: '$_completedThisWeek',
            label: l10n.studentChallengesAssessmentsThisWeek,
          ),
          const Spacer(),
          Text(
            _streakDays >= 2
                ? l10n.studentChallengesUnlocked
                : l10n.studentChallengesUnlockHint,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.surface,
      scrolledUnderElevation: 1,
      title: Text(
        AppLocalizations.of(context).studentChallengesTitle,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: AppLocalizations.of(context).studentChallengesNotifications,
          onPressed: () => context.push(AppRoutes.studentNotifications),
        ),
      ],
    );
  }

  Widget _buildLiveChallenges() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            title: AppLocalizations.of(context).studentChallengesLive,
            icon: Icons.rocket_launch_outlined,
            trailing: const _LiveBadge(),
          ),
          const SizedBox(height: 12),
          ..._liveChallenges.map(
            (challenge) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChallengeCard(
                challenge: challenge,
                onPrimaryAction: () => _handleChallengeAction(challenge),
              ),
            ),
          ),
        ],
      );

  Widget _buildLeaderboard() {
    const leaders = [
      _Leader(rank: 1, name: 'سارة العتيبي', level: 'المستوى 42', points: 4850),
      _Leader(rank: 2, name: 'عمر خالد', level: 'المستوى 39', points: 4200),
      _Leader(rank: 3, name: 'علي حسن', level: 'المستوى 37', points: 3950),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).studentChallengesCurrentWeek,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).studentChallengesLeaderboard,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.emoji_events,
                      color: Color(0xFFFFDBCE), size: 28),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...leaders.map(
            (leader) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LeaderRow(leader: leader),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: Color(0xFFFFDBCE), size: 20),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context).studentChallengesMovedUp,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).studentChallengesCurrentRank,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDBCE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '#12',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF380D00),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyChallenges() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            title: AppLocalizations.of(context).studentChallengesMyChallenges,
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.primary,
                  value: '$_completedCount',
                  label:
                      AppLocalizations.of(context).studentChallengesCompleted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.event_outlined,
                  iconColor: AppColors.onSurfaceVariant,
                  value: '${_myChallenges.length}',
                  label: AppLocalizations.of(context)
                      .studentChallengesActiveUpcoming,
                ),
              ),
            ],
          ),
          if (_createdCount > 0) ...[
            const SizedBox(height: 12),
            _InfoBanner(
              icon: Icons.add_task_outlined,
              text: AppLocalizations.of(context)
                  .studentChallengesLocalCreated(_createdCount),
            ),
          ],
          const SizedBox(height: 12),
          ..._myChallenges.map(
            (challenge) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MyChallengeTile(
                challenge: challenge,
                onTap: () => _handleChallengeAction(challenge),
              ),
            ),
          ),
        ],
      );

  Widget _buildBadges() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context).studentChallengesEarnedBadges,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              runSpacing: 16,
              children: [
                _Badge(
                    icon: Icons.workspace_premium_outlined,
                    label: AppLocalizations.of(context)
                        .studentChallengesBadgeLegend,
                    isLocked: true),
                _Badge(
                    icon: Icons.bolt,
                    label: AppLocalizations.of(context)
                        .studentChallengesBadgeFast),
                _Badge(
                    icon: Icons.psychology,
                    label: AppLocalizations.of(context)
                        .studentChallengesBadgeThinker),
                _Badge(
                    icon: Icons.star,
                    label: AppLocalizations.of(context)
                        .studentChallengesBadgeRisingStar),
              ],
            ),
          ],
        ),
      );

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    Widget? trailing,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          trailing ?? const SizedBox.shrink(),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: AppColors.primary, size: 22),
            ],
          ),
        ],
      );

  Future<void> _handleChallengeAction(_Challenge challenge) async {
    switch (challenge.status) {
      case ChallengeStatus.joinable:
        await _joinChallenge(challenge);
      case ChallengeStatus.joined:
        context.push(AppRoutes.studentAssessmentsList);
      case ChallengeStatus.completed:
        await _showInfoDialog(
          title: AppLocalizations.of(context).studentChallengesCompletedTitle,
          message: AppLocalizations.of(context)
              .studentChallengesCompletedMessage(challenge.title),
        );
      case ChallengeStatus.locked:
        await _showInfoDialog(
          title: AppLocalizations.of(context).studentChallengesLockedTitle,
          message: challenge.lockedReason ??
              AppLocalizations.of(context).studentChallengesLockedMessage,
        );
    }
  }

  Future<void> _joinChallenge(_Challenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)
            .studentChallengesJoinTitle(challenge.title)),
        content: Text(
          AppLocalizations.of(ctx)
              .studentChallengesJoinMessage(challenge.reward),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx).studentChallengesJoinNow),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      final index = _challenges.indexWhere((item) => item.id == challenge.id);
      if (index == -1) return;
      _challenges[index] = challenge.copyWith(status: ChallengeStatus.joined);
    });

    await _showInfoDialog(
      title: AppLocalizations.of(context).studentChallengesJoinedTitle,
      message: AppLocalizations.of(context)
          .studentChallengesJoinedMessage(challenge.title),
    );
  }

  Future<void> _showCreateChallengeSheet() async {
    final subjectController = TextEditingController();
    final titleController = TextEditingController();
    try {
      final created = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(ctx).studentChallengesCreateTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(ctx).studentChallengesCreateDescription,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(ctx).studentChallengesTitleLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(ctx).studentChallengesSubjectLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  icon: const Icon(Icons.add_task_outlined),
                  label:
                      Text(AppLocalizations.of(ctx).studentChallengesAddToMine),
                ),
              ],
            ),
          ),
        ),
      );

      if (created != true || !mounted) return;

      final title = titleController.text.trim().isEmpty
          ? AppLocalizations.of(context).studentChallengesDefaultTitle
          : titleController.text.trim();
      final subject = subjectController.text.trim().isEmpty
          ? AppLocalizations.of(context).studentChallengesDefaultSubject
          : subjectController.text.trim();

      setState(() {
        _createdCount++;
        _challenges.insert(
          0,
          _Challenge(
            id: 'local-created-$_createdCount',
            title: title,
            subtitle: subject,
            reward: 150,
            participants: 1,
            timeLeft: AppLocalizations.of(context).studentChallengesThisWeek,
            progress: 0,
            status: ChallengeStatus.joined,
            accentColor: AppColors.primary,
            subjectIcon: Icons.flag_outlined,
          ),
        );
      });

      await _showInfoDialog(
        title: AppLocalizations.of(context).studentChallengesCreatedTitle,
        message:
            AppLocalizations.of(context).studentChallengesCreatedMessage(title),
      );
    } finally {
      subjectController.dispose();
      titleController.dispose();
    }
  }

  Future<void> _showInfoDialog({
    required String title,
    required String message,
  }) =>
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(ctx).studentChallengesDone),
            ),
          ],
        ),
      );
}

enum ChallengeStatus { joinable, joined, completed, locked }

class _Challenge {
  const _Challenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.participants,
    required this.timeLeft,
    required this.progress,
    required this.status,
    required this.accentColor,
    required this.subjectIcon,
    this.lockedReason,
  });

  final String id;
  final String title;
  final String subtitle;
  final int reward;
  final int participants;
  final String timeLeft;
  final double progress;
  final ChallengeStatus status;
  final Color accentColor;
  final IconData subjectIcon;
  final String? lockedReason;

  _Challenge copyWith({
    ChallengeStatus? status,
    double? progress,
    String? lockedReason,
  }) =>
      _Challenge(
        id: id,
        title: title,
        subtitle: subtitle,
        reward: reward,
        participants: participants,
        timeLeft: timeLeft,
        progress: progress ?? this.progress,
        status: status ?? this.status,
        accentColor: accentColor,
        subjectIcon: subjectIcon,
        lockedReason: lockedReason ?? this.lockedReason,
      );
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.onPrimaryAction,
  });

  final _Challenge challenge;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locked = challenge.status == ChallengeStatus.locked;
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _RewardBadge(points: challenge.reward),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      challenge.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: challenge.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.timer_outlined,
                  size: 18,
                  color:
                      locked ? colorScheme.onSurfaceVariant : AppColors.error),
              const SizedBox(width: 4),
              Text(
                challenge.timeLeft,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:
                      locked ? colorScheme.onSurfaceVariant : AppColors.error,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.group_outlined,
                  size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)
                    .studentChallengesParticipants(challenge.participants),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (challenge.progress > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: challenge.progress,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(challenge.accentColor),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onPrimaryAction,
            icon: Icon(_actionIcon(challenge.status)),
            label: Text(_actionLabel(context, challenge.status)),
          ),
        ],
      ),
    );
  }

  IconData _actionIcon(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.joinable:
        return Icons.login_rounded;
      case ChallengeStatus.joined:
        return Icons.play_arrow_rounded;
      case ChallengeStatus.completed:
        return Icons.verified_rounded;
      case ChallengeStatus.locked:
        return Icons.lock_outline_rounded;
    }
  }

  String _actionLabel(BuildContext context, ChallengeStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case ChallengeStatus.joinable:
        return l10n.studentChallengesJoinAction;
      case ChallengeStatus.joined:
        return l10n.studentChallengesStartAction;
      case ChallengeStatus.completed:
        return l10n.studentChallengesViewResultAction;
      case ChallengeStatus.locked:
        return l10n.studentChallengesNotOpenAction;
    }
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppLocalizations.of(context).studentChallengesPoints(points),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _Leader {
  const _Leader({
    required this.rank,
    required this.name,
    required this.level,
    required this.points,
  });

  final int rank;
  final String name;
  final String level;
  final int points;
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.leader});

  final _Leader leader;

  @override
  Widget build(BuildContext context) {
    final highlighted = leader.rank == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: highlighted
            ? Border.all(color: Colors.white.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${leader.points}',
                style: TextStyle(
                  fontSize: highlighted ? 22 : 18,
                  fontWeight: FontWeight.w800,
                  color: highlighted ? const Color(0xFFFFDBCE) : Colors.white,
                ),
              ),
              if (highlighted)
                Text(AppLocalizations.of(context).studentChallengesPoints(1),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                leader.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                leader.level,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            child: Text(
              leader.name.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              '${leader.rank}',
              style: TextStyle(
                fontSize: highlighted ? 22 : 18,
                fontWeight: FontWeight.w800,
                color: highlighted ? const Color(0xFFFFDBCE) : Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyChallengeTile extends StatelessWidget {
  const _MyChallengeTile({required this.challenge, required this.onTap});

  final _Challenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completed = challenge.status == ChallengeStatus.completed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AppSectionCard(
        borderRadius: 8,
        child: Row(
          children: [
            Icon(
              completed ? Icons.verified : Icons.chevron_left,
              color: completed ? AppColors.success : colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    completed
                        ? AppLocalizations.of(context)
                            .studentChallengesCompleteProgress(
                                challenge.progress * 100 ~/ 1)
                        : challenge.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: completed
                          ? AppColors.success
                          : colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: challenge.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                challenge.subjectIcon,
                color: challenge.accentColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    this.isLocked = false,
  });

  final IconData icon;
  final String label;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isLocked
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF60A5FA), Color(0xFF4F46E5)],
                    ),
              border: isLocked
                  ? Border.all(color: colorScheme.outlineVariant, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isLocked ? colorScheme.outline : Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isLocked ? FontWeight.w400 : FontWeight.w700,
              color: isLocked ? colorScheme.outline : colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          AppLocalizations.of(context).studentChallengesLiveNow,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(height: 4),
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
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
