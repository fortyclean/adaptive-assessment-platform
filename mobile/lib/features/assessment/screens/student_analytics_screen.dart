import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/student_state_view.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../models/student_learning_insights.dart';
import '../repositories/assessment_repository.dart';

/// StudentAnalyticsScreen — Screen 50
/// Comprehensive student performance analytics with bento grid metrics,
/// subject progress bars, attachment stats, and achievement badges.
/// RTL Arabic layout matching _50/code.html design.
class StudentAnalyticsScreen extends ConsumerStatefulWidget {
  const StudentAnalyticsScreen({super.key});

  @override
  ConsumerState<StudentAnalyticsScreen> createState() =>
      _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState
    extends ConsumerState<StudentAnalyticsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  double _overallPerformance = 0;
  double _trendPercent = 0;
  int _completedAttempts = 0;
  int _totalPoints = 0;

  List<_SubjectProgress> _subjects = const [];

  List<double> _weeklyData = const [0, 0, 0, 0, 0, 0, 0];
  final List<String> _weekDays = const [
    'أحد',
    'اثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
    'سبت',
  ];

  List<_AttachmentStat> _attachments = const [];

  List<_Badge> _badges = const [];
  LearningRecommendation _recommendation =
      const StudentLearningInsightsSource().recommendationFor([]);

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();
      final completed = history
          .where((h) =>
              h['status'] == 'completed' && (h['scorePercentage'] is num))
          .toList();

      if (!mounted) return;
      setState(() {
        _applyHistory(completed);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'تعذر تحميل تحليلاتك الآن. تحقق من الاتصال ثم حاول مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  void _applyHistory(List<Map<String, dynamic>> history) {
    _completedAttempts = history.length;
    _totalPoints = history.fold<int>(
      0,
      (sum, h) => sum + ((h['pointsEarned'] as num?)?.toInt() ?? 0),
    );

    final chronologicalHistory = _sortAttemptsByDate(history);
    final scores = chronologicalHistory
        .map((h) => (h['scorePercentage'] as num).toDouble())
        .toList();
    _overallPerformance =
        scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
    _trendPercent = _calculateRecentTrend(scores);

    _subjects = _buildSubjectProgressFromHistory(history);
    _weeklyData = _buildWeeklyData(history);
    _attachments = _buildSkillInsights(history);
    _recommendation =
        const StudentLearningInsightsSource().recommendationFor(history);
    _badges = _buildEarnedBadges();
  }

  List<Map<String, dynamic>> _sortAttemptsByDate(
    List<Map<String, dynamic>> history,
  ) {
    final sorted = [...history];
    sorted.sort((a, b) => _attemptDate(a).compareTo(_attemptDate(b)));
    return sorted;
  }

  DateTime _attemptDate(Map<String, dynamic> attempt) {
    return DateTime.tryParse(
          (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  double _calculateRecentTrend(List<double> scores) {
    if (scores.length < 2) return 0;
    final latest = scores.last;
    final previous = scores[scores.length - 2];
    return latest - previous;
  }

  String get _performanceLabel {
    if (_overallPerformance >= 90) return 'ممتاز';
    if (_overallPerformance >= 75) return 'جيد جداً';
    if (_overallPerformance >= 60) return 'جيد';
    return 'يحتاج دعم';
  }

  String get _trendText {
    if (_completedAttempts < 2 || _trendPercent.abs() < 0.1) {
      return 'لا يوجد تغير واضح بعد';
    }
    final sign = _trendPercent > 0 ? '+' : '';
    return '$sign${_trendPercent.toStringAsFixed(1)}% عن آخر اختبار';
  }

  List<_SubjectProgress> _buildSubjectProgressFromHistory(
    List<Map<String, dynamic>> history,
  ) {
    final grouped = <String, List<double>>{};
    for (final attempt in history) {
      final subject = _extractSubject(attempt);
      final score = (attempt['scorePercentage'] as num?)?.toDouble();
      if (subject == null || score == null) continue;
      grouped.putIfAbsent(subject, () => []).add(score);
    }

    final subjects = grouped.entries.map((entry) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return _SubjectProgress(name: entry.key, percentage: avg / 100);
    }).toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    return subjects.take(4).toList();
  }

  List<double> _buildWeeklyData(List<Map<String, dynamic>> history) {
    final buckets = List.generate(7, (_) => <double>[]);
    final now = DateTime.now();

    for (final attempt in history) {
      final score = (attempt['scorePercentage'] as num?)?.toDouble();
      final createdAt = DateTime.tryParse(
        (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
      );
      if (score == null || createdAt == null) continue;

      final diff = now.difference(createdAt).inDays;
      if (diff < 0 || diff > 6) continue;
      buckets[6 - diff].add(score / 100);
    }

    return buckets
        .map((items) =>
            items.isEmpty ? 0.0 : items.reduce((a, b) => a + b) / items.length)
        .toList();
  }

  List<_AttachmentStat> _buildSkillInsights(
    List<Map<String, dynamic>> history,
  ) {
    final skillScores = <String, List<double>>{};
    for (final attempt in history) {
      final breakdown = attempt['skillBreakdown'];
      if (breakdown is! List) continue;
      for (final item in breakdown) {
        if (item is! Map) continue;
        final total = (item['totalQuestions'] as num?)?.toDouble() ?? 0;
        final correct = (item['correctAnswers'] as num?)?.toDouble() ?? 0;
        final skill = (item['mainSkill'] ?? item['skill'] ?? '').toString();
        if (skill.isEmpty || total <= 0) continue;
        skillScores.putIfAbsent(skill, () => []).add(correct / total);
      }
    }

    final ranked = skillScores.entries.map((entry) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, avg);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (ranked.isEmpty) return const [];

    final strongest = ranked.first;
    final weakest = ranked.last;
    return [
      _AttachmentStat(
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.success,
        bgColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFFA7F3D0),
        title: 'أقوى مهارة',
        subtitle: strongest.key,
        percentage: (strongest.value * 100).round(),
        percentageColor: AppColors.success,
      ),
      _AttachmentStat(
        icon: Icons.tips_and_updates_outlined,
        iconColor: AppColors.warning,
        bgColor: const Color(0xFFFFF7ED),
        borderColor: const Color(0xFFFFDBC8),
        title: 'تحتاج مراجعة',
        subtitle: weakest.key,
        percentage: (weakest.value * 100).round(),
        percentageColor: AppColors.warning,
      ),
    ];
  }

  List<_Badge> _buildEarnedBadges() => [
        _Badge(
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFFDE68A),
          label: 'اختبارات مكتملة',
          isEarned: _completedAttempts > 0,
          count: _completedAttempts == 0 ? null : _completedAttempts,
        ),
        _Badge(
          icon: Icons.speed_rounded,
          iconColor: AppColors.primary,
          bgColor: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          label: 'أداء مرتفع',
          isEarned: _overallPerformance >= 85,
        ),
        _Badge(
          icon: Icons.verified_rounded,
          iconColor: AppColors.success,
          bgColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
          label: 'ملتزم',
          isEarned: _completedAttempts >= 3,
        ),
      ];

  String? _extractSubject(Map<String, dynamic> attempt) {
    final direct = attempt['subject'] as String?;
    if (direct != null && direct.trim().isNotEmpty) return direct;

    final assessment = attempt['assessmentId'];
    if (assessment is Map && assessment['subject'] is String) {
      return assessment['subject'] as String;
    }
    if (attempt['assessment'] is Map &&
        (attempt['assessment'] as Map)['subject'] is String) {
      return (attempt['assessment'] as Map)['subject'] as String;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName.split(' ').first ?? 'طالب';
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 2, role: 'student'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: StudentStateView(
          icon: Icons.wifi_off_rounded,
          title: 'تعذر تحميل التحليلات',
          message: _errorMessage!,
          actionLabel: 'إعادة المحاولة',
          onAction: _loadAnalytics,
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 2, role: 'student'),
      );
    }

    if (_completedAttempts == 0) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: StudentStateView(
          icon: Icons.insights_outlined,
          title: 'لا توجد تحليلات بعد',
          message: 'ستظهر مؤشرات الأداء والمهارات بعد إكمال أول اختبار.',
          actionLabel: 'عرض الاختبارات',
          onAction: () => context.go('/student/assessments-list'),
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 2, role: 'student'),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ─── Top App Bar ─────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: Colors.black12,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Notifications (RTL: left)
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.onSurfaceVariant,
                  onPressed: () => context.push('/student/notifications'),
                ),
                // Logo + Avatar (RTL: right)
                Row(
                  children: [
                    const Text(
                      'إحصائيات EduAssess',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    UserAvatar(
                      user: user,
                      size: 40,
                      borderColor: colorScheme.outlineVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Main Content ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome section
                _buildWelcomeSection(firstName),
                const SizedBox(height: 24),

                // Bento Grid: Main Performance Metrics
                _buildBentoGrid(),
                const SizedBox(height: 24),

                // Subject Progress
                _buildSubjectProgress(),
                const SizedBox(height: 24),

                // Attachment Stats
                _buildAttachmentStats(),
                const SizedBox(height: 24),

                // Recommended next action
                _buildNextStepCard(),
                const SizedBox(height: 24),

                // Achievements & Badges
                _buildAchievements(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2, role: 'student'),
    );
  }

  // ─── Welcome Section ─────────────────────────────────────────────────────

  Widget _buildWelcomeSection(String name) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'مرحباً، $name!',
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          const Text(
            'إليك نظرة شاملة على أدائك التعليمي لهذا الفصل.',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      );

  // ─── Bento Grid ──────────────────────────────────────────────────────────

  Widget _buildBentoGrid() => Column(
        children: [
          // Full-width performance card
          _buildPerformanceCard(),
          const SizedBox(height: 12),
          // Two small cards
          Row(
            children: [
              Expanded(
                  child: _buildSmallMetricCard(
                icon: Icons.schedule_outlined,
                iconColor: const Color(0xFF611E00),
                value: '$_completedAttempts',
                label: 'اختبار مكتمل',
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildSmallMetricCard(
                icon: Icons.description_outlined,
                iconColor: AppColors.primary,
                value: '$_totalPoints',
                label: 'نقطة مكتسبة',
              )),
            ],
          ),
        ],
      );

  Widget _buildPerformanceCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Circular progress (RTL: left)
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: _overallPerformance / 100,
                      strokeWidth: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryContainer,
                      ),
                    ),
                  ),
                  Text(
                    _performanceLabel,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Text info (RTL: right)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'معدل الأداء العام',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_overallPerformance.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _trendText,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _trendPercent < 0
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _trendPercent < 0
                              ? Icons.trending_down
                              : Icons.trending_up,
                          size: 16,
                          color: _trendPercent < 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildSmallMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );

  // ─── Subject Progress ─────────────────────────────────────────────────────

  Widget _buildSubjectProgress() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.push('/student/subjects'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'تفاصيل أكثر',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Text(
                'تقدم المواد الدراسية',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subject bars
                ..._subjects.map(_buildSubjectBar),
                const SizedBox(height: 16),
                // Weekly chart
                _buildWeeklyChart(),
              ],
            ),
          ),
        ],
      );

  Widget _buildSubjectBar(_SubjectProgress subject) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(subject.percentage * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: subject.percentage,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      );

  Widget _buildWeeklyChart() => Column(
        children: [
          Divider(
              color: Theme.of(context).colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 16),
          SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_weeklyData.length, (i) {
                final isMax = _weeklyData[i] ==
                    _weeklyData.reduce((a, b) => a > b ? a : b);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FractionallySizedBox(
                      heightFactor: _weeklyData[i],
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMax
                              ? AppColors.primary
                              : AppColors.primaryContainer
                                  .withValues(alpha: 0.4),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _weekDays
                .map((d) => Expanded(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ),
        ],
      );

  // ─── Attachment Stats ─────────────────────────────────────────────────────

  Widget _buildAttachmentStats() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'رؤى المهارات من الاختبارات',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ..._attachments.map(_buildAttachmentCard),
        ],
      );

  Widget _buildAttachmentCard(_AttachmentStat stat) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: stat.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stat.borderColor),
        ),
        child: Row(
          children: [
            // Percentage (RTL: left)
            Text(
              '${stat.percentage}%',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: stat.percentageColor,
              ),
            ),
            const SizedBox(width: 12),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stat.title,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Icon (RTL: right)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(stat.icon, color: stat.iconColor, size: 28),
            ),
          ],
        ),
      );

  // ─── Achievements & Badges ────────────────────────────────────────────────

  Widget _buildNextStepCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final needsSupport = _overallPerformance < 75 || _trendPercent < 0;
    final title = _recommendation.title;
    final message = _recommendation.message;
    final actionLabel = _recommendation.actionLabel;
    final route = _recommendation.route;

    return Semantics(
      label: '$title. $message',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(
                  needsSupport
                      ? Icons.auto_awesome_motion_rounded
                      : Icons.trending_up_rounded,
                  color: colorScheme.primary,
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 14,
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(route),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'الأوسمة والإنجازات',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true, // RTL scroll
              itemCount: _badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _buildBadgeCard(_badges[index]),
            ),
          ),
        ],
      );

  Widget _buildBadgeCard(_Badge badge) => Opacity(
        opacity: badge.isEarned ? 1.0 : 0.5,
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: badge.bgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: badge.borderColor, width: 4),
                    ),
                    child: Icon(
                      badge.icon,
                      color: badge.iconColor,
                      size: 28,
                    ),
                  ),
                  if (badge.count != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'x${badge.count}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                badge.label,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class _SubjectProgress {
  const _SubjectProgress({required this.name, required this.percentage});
  final String name;
  final double percentage;
}

class _AttachmentStat {
  const _AttachmentStat({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.percentageColor,
  });
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final int percentage;
  final Color percentageColor;
}

class _Badge {
  const _Badge({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.label,
    required this.isEarned,
    this.count,
  });
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String label;
  final bool isEarned;
  final int? count;
}
