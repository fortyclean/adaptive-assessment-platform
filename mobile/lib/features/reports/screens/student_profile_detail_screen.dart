import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../assessment/repositories/teacher_repository.dart';

class _SkillData {
  const _SkillData({required this.name, required this.value});
  final String name;
  final double value;
}

class _ActivityLog {
  const _ActivityLog({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;
}

/// StudentProfileDetailScreen — Screens 56, 57, 58
/// Teacher-facing screen showing a student's detailed profile with:
/// - Skill radar chart (hexagonal/spider chart via CustomPainter)
/// - Behavior/activity log
/// - Weekly performance trend
/// Requirements: 9.5, 9.6
class StudentProfileDetailScreen extends ConsumerStatefulWidget {
  const StudentProfileDetailScreen({
    required this.studentId,
    super.key,
    this.studentName,
    this.assessmentId,
  });

  final String studentId;
  final String? studentName;
  final String? assessmentId;

  @override
  ConsumerState<StudentProfileDetailScreen> createState() =>
      _StudentProfileDetailScreenState();
}

class _StudentProfileDetailScreenState
    extends ConsumerState<StudentProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _studentData;
  late TabController _tabController;

  // ── Mock / fallback data ──────────────────────────────────────────────────
  List<_SkillData> get _fallbackSkills {
    final l10n = AppLocalizations.of(context);
    return [
      _SkillData(name: l10n.skillUnderstanding, value: 0.85),
      _SkillData(name: l10n.skillAnalysisName, value: 0.72),
      _SkillData(name: l10n.skillApplication, value: 0.90),
      _SkillData(name: l10n.skillEvaluation, value: 0.65),
      _SkillData(name: l10n.skillSynthesis, value: 0.78),
      _SkillData(name: l10n.skillRecall, value: 0.88),
    ];
  }

  final List<double> _weeklyScores = const [
    0.62,
    0.75,
    0.68,
    0.82,
    0.79,
    0.88,
    0.84,
  ];

  List<String> get _fallbackWeekDays {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.weekdaySunday,
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
    ];
  }

  List<_ActivityLog> get _fallbackActivityLog {
    final l10n = AppLocalizations.of(context);
    return [
      _ActivityLog(
        icon: Icons.assignment_turned_in_outlined,
        iconColor: AppColors.success,
        bgColor: const Color(0xFFECFDF5),
        title: l10n.activityCompletedMathAssessment,
        subtitle: l10n.activityMathScoreUnit,
        time: l10n.activityTwoHoursAgo,
      ),
      _ActivityLog(
        icon: Icons.login_rounded,
        iconColor: AppColors.primary,
        bgColor: const Color(0xFFEFF6FF),
        title: l10n.activityPlatformLogin,
        subtitle: l10n.activityActiveSession45,
        time: l10n.activityThreeHoursAgo,
      ),
      _ActivityLog(
        icon: Icons.quiz_outlined,
        iconColor: AppColors.warning,
        bgColor: const Color(0xFFFEF3C7),
        title: l10n.activityStartedScienceAssessment,
        subtitle: l10n.activityNotCompletedTimedOut,
        time: l10n.activityYesterday,
      ),
      _ActivityLog(
        icon: Icons.emoji_events_outlined,
        iconColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        title: l10n.activityEarnedExcellentBadge,
        subtitle: l10n.activityFirstStudent90,
        time: l10n.activityTwoDaysAgo,
      ),
      _ActivityLog(
        icon: Icons.assignment_outlined,
        iconColor: AppColors.primary,
        bgColor: const Color(0xFFEFF6FF),
        title: l10n.activityCompletedArabicAssessment,
        subtitle: l10n.activityArabicScoreUnit,
        time: l10n.activityThreeDaysAgo,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    try {
      if (widget.assessmentId != null && widget.assessmentId!.isNotEmpty) {
        final data = await ref.read(teacherRepositoryProvider).getStudentReport(
            widget.studentId,
            assessmentId: widget.assessmentId!);
        setState(() {
          _studentData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = _studentData?['fullName'] as String? ??
        widget.studentName ??
        l10n.studentProfileFallbackName;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(name),
                SliverToBoxAdapter(child: _buildProfileHeader(name)),
                SliverToBoxAdapter(child: _buildTabBar()),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSkillsTab(),
                      _buildPerformanceTab(),
                      _buildActivityTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Sliver App Bar ───────────────────────────────────────────────────────

  SliverAppBar _buildSliverAppBar(String name) {
    final cs = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.onSurface,
        onPressed: () => context.pop(),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Almarai',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded),
          color: AppColors.onSurfaceVariant,
          onPressed: _exportReport,
          tooltip: AppLocalizations.of(context).exportStudentReport,
        ),
      ],
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).exportingStudentReport),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader(String name) {
    final score = _studentData?['scorePercentage'] as num?;
    final timeTaken = _studentData?['timeTakenSeconds'] as num?;
    final scoreColor =
        score != null && score >= 70 ? AppColors.success : AppColors.error;
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              // Score badge (RTL: left)
              if (score != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: score >= 70
                        ? AppColors.successContainer
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: scoreColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '%',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).scoreLabel,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 11,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              // Student info (RTL: right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (timeTaken != null) ...[
                          Text(
                            AppLocalizations.of(context).minutesUnit,
                            style: const TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.schedule_outlined,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _studentData?['status'] == 'completed'
                              ? AppLocalizations.of(context).completedStatus
                              : AppLocalizations.of(context).timedOutStatus,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 13,
                            color: _studentData?['status'] == 'completed'
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Avatar (RTL: rightmost)
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceContainer,
                child: Text(
                  name.isNotEmpty
                      ? name[0]
                      : AppLocalizations.of(context).studentInitialFallback,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar() => Container(
        color: Theme.of(context).colorScheme.surface,
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(text: AppLocalizations.of(context).skillsTab),
            Tab(text: AppLocalizations.of(context).performanceTab),
            Tab(text: AppLocalizations.of(context).activityTab),
          ],
        ),
      );

  // ─── Skills Tab (Radar Chart) ─────────────────────────────────────────────

  Widget _buildSkillsTab() {
    // Merge API skill breakdown with fallback data
    final List<_SkillData> skills;
    final breakdown = _studentData?['skillBreakdown'] as List?;
    if (breakdown != null && breakdown.isNotEmpty) {
      skills = breakdown.take(6).map((s) {
        final map = s as Map<String, dynamic>;
        return _SkillData(
          name: (map['mainSkill'] as String?) ?? '',
          value: ((map['percentage'] as num?) ?? 0) / 100.0,
        );
      }).toList();
    } else {
      skills = _fallbackSkills;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radar chart card
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).skillMapTitle,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).skillMapSubtitle,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 260,
                  child: CustomPaint(
                    painter: _SkillRadarPainter(skills: skills),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: skills.map((s) {
                    final isStrength = s.value >= 0.70;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isStrength
                                ? AppColors.success
                                : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${s.name} (${(s.value * 100).round()}%)',
                          style: const TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Skill breakdown bars
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).skillBreakdownTitle,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ...skills.map((s) => _SkillProgressRow(skill: s)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Performance Tab (Weekly Bar Chart) ──────────────────────────────────

  Widget _buildPerformanceTab() {
    // Merge API data with fallback
    final List<double> scores;
    final List<String> days;
    final weeklyData = _studentData?['weeklyScores'] as List?;
    if (weeklyData != null && weeklyData.isNotEmpty) {
      scores = weeklyData
          .map((v) => (v as num).toDouble().clamp(0.0, 100.0) / 100.0)
          .toList();
      days = List.generate(
        scores.length,
        (i) => AppLocalizations.of(context).dayNumber(i + 1),
      );
    } else {
      scores = _weeklyScores;
      days = _fallbackWeekDays;
    }

    final avg =
        scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
    final best = scores.isEmpty ? 0.0 : scores.reduce(math.max);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary KPIs
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: AppLocalizations.of(context).weeklyAverage,
                  value: '${(avg * 100).round()}%',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  label: AppLocalizations.of(context).bestPerformance,
                  value: '${(best * 100).round()}%',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekly bar chart
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).weeklyPerformanceTitle,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).lastSevenDaysScores,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(scores.length, (i) {
                      final score = scores[i];
                      final isHighest = score == best;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${(score * 100).round()}%',
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isHighest
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400 + i * 60),
                                height: (score * 140).clamp(8.0, 140.0),
                                decoration: BoxDecoration(
                                  color: isHighest
                                      ? AppColors.success
                                      : AppColors.primary
                                          .withValues(alpha: 0.75),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                i < days.length ? days[i] : '',
                                style: const TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Answer history from API
          if (_studentData?['answers'] != null)
            _AnswerHistoryCard(
              answers: List<Map<String, dynamic>>.from(
                  _studentData!['answers'] as List),
            ),
        ],
      ),
    );
  }

  // ─── Activity Tab ─────────────────────────────────────────────────────────

  Widget _buildActivityTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).recentActivityLog,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).recentActivitySubtitle,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(_fallbackActivityLog.length, (i) {
                  final log = _fallbackActivityLog[i];
                  final isLast = i == _fallbackActivityLog.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: log.bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                log.icon,
                                color: log.iconColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.title,
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    log.subtitle,
                                    style: const TextStyle(
                                      fontFamily: 'Almarai',
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Time
                            Text(
                              log.time,
                              style: const TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: 11,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 72,
                          color: AppColors.outlineVariant,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      );
}

// ─── Skill Radar Painter ──────────────────────────────────────────────────────

class _SkillRadarPainter extends CustomPainter {
  const _SkillRadarPainter({required this.skills});
  final List<_SkillData> skills;

  @override
  void paint(Canvas canvas, Size size) {
    if (skills.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 24;
    final count = skills.length;
    final angleStep = (2 * math.pi) / count;
    // Start from top (−π/2)
    const startAngle = -math.pi / 2;

    // ── Grid lines (concentric hexagons) ──────────────────────────────────
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var level = 1; level <= 4; level++) {
      final r = radius * level / 4;
      final path = Path();
      for (var i = 0; i < count; i++) {
        final angle = startAngle + i * angleStep;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // ── Axis lines ────────────────────────────────────────────────────────
    final axisPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    for (var i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // ── Data polygon ──────────────────────────────────────────────────────
    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final dataPath = Path();
    for (var i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final r = radius * skills[i].value.clamp(0.0, 1.0);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // ── Data points ───────────────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final r = radius * skills[i].value.clamp(0.0, 1.0);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // ── Labels ────────────────────────────────────────────────────────────
    final labelRadius = radius + 20;
    for (var i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: skills[i].name,
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: 60);
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_SkillRadarPainter oldDelegate) =>
      oldDelegate.skills != skills;
}

// ─── Skill Progress Row ───────────────────────────────────────────────────────

class _SkillProgressRow extends StatelessWidget {
  const _SkillProgressRow({required this.skill});
  final _SkillData skill;

  @override
  Widget build(BuildContext context) {
    final isStrength = skill.value >= 0.70;
    final barColor = isStrength ? AppColors.success : AppColors.error;
    final pct = (skill.value * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isStrength
                          ? AppColors.successContainer
                          : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isStrength
                          ? AppLocalizations.of(context).strengthLabel
                          : AppLocalizations.of(context).weaknessLabel,
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: barColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                skill.name,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '$pct%',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: skill.value.clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── KPI Card ─────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

// ─── Answer History Card ──────────────────────────────────────────────────────

class _AnswerHistoryCard extends StatelessWidget {
  const _AnswerHistoryCard({required this.answers});
  final List<Map<String, dynamic>> answers;

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).answerReviewTitle,
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...answers.take(10).map((answer) {
            final isCorrect = (answer['isCorrect'] as bool?) ?? false;
            final questionText = (answer['questionText'] as String?) ??
                AppLocalizations.of(context).questionFallback;
            final selectedAnswer = (answer['selectedAnswer'] as String?) ?? '';
            final correctAnswer = (answer['correctAnswer'] as String?) ?? '';
            final difficulty =
                (answer['difficultyLevel'] as String?) ?? 'medium';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.successContainer.withValues(alpha: 0.4)
                      : AppColors.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? AppColors.successContainer
                                : AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isCorrect
                                ? AppLocalizations.of(context).correctStatus
                                : AppLocalizations.of(context).incorrectStatus,
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            difficulty == 'easy'
                                ? AppLocalizations.of(context).easyDifficulty
                                : difficulty == 'hard'
                                    ? AppLocalizations.of(context)
                                        .hardDifficulty
                                    : AppLocalizations.of(context)
                                        .mediumDifficulty,
                            style: const TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      questionText,
                      style: const TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)
                          .yourAnswerValue(selectedAnswer),
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 12,
                        color: isCorrect ? AppColors.success : AppColors.error,
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)
                            .correctAnswerValue(correctAnswer),
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
