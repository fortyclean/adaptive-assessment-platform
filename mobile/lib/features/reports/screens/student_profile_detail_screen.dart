import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// StudentProfileDetailScreen — Screens 56, 57, 58
/// Teacher-facing screen showing a student's detailed profile with:
/// - Skill radar chart (hexagonal/spider chart via CustomPainter)
/// - Behavior/activity log
/// - Weekly performance trend
/// Requirements: 9.5, 9.6
class StudentProfileDetailScreen extends ConsumerStatefulWidget {
  const StudentProfileDetailScreen({
    super.key,
    required this.studentId,
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
  String? _error;
  late TabController _tabController;

  // ── Mock / fallback data ──────────────────────────────────────────────────
  final List<_SkillData> _skills = const [
    _SkillData(name: 'الفهم', value: 0.85),
    _SkillData(name: 'التحليل', value: 0.72),
    _SkillData(name: 'التطبيق', value: 0.90),
    _SkillData(name: 'التقييم', value: 0.65),
    _SkillData(name: 'التركيب', value: 0.78),
    _SkillData(name: 'التذكر', value: 0.88),
  ];

  final List<double> _weeklyScores = const [
    0.62, 0.75, 0.68, 0.82, 0.79, 0.88, 0.84,
  ];

  final List<String> _weekDays = const [
    'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت',
  ];

  final List<_ActivityLog> _activityLog = const [
    _ActivityLog(
      icon: Icons.assignment_turned_in_outlined,
      iconColor: AppColors.success,
      bgColor: Color(0xFFECFDF5),
      title: 'أكمل اختبار الرياضيات',
      subtitle: 'درجة: 88% — وحدة 3',
      time: 'منذ ساعتين',
    ),
    _ActivityLog(
      icon: Icons.login_rounded,
      iconColor: AppColors.primary,
      bgColor: Color(0xFFEFF6FF),
      title: 'تسجيل دخول للمنصة',
      subtitle: 'جلسة نشطة لمدة 45 دقيقة',
      time: 'منذ 3 ساعات',
    ),
    _ActivityLog(
      icon: Icons.quiz_outlined,
      iconColor: AppColors.warning,
      bgColor: Color(0xFFFEF3C7),
      title: 'بدأ اختبار العلوم',
      subtitle: 'لم يكتمل — انتهى الوقت',
      time: 'أمس',
    ),
    _ActivityLog(
      icon: Icons.emoji_events_outlined,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      title: 'حصل على وسام "متميز"',
      subtitle: 'أول طالب يحقق 90%+ في الوحدة',
      time: 'منذ يومين',
    ),
    _ActivityLog(
      icon: Icons.assignment_outlined,
      iconColor: AppColors.primary,
      bgColor: Color(0xFFEFF6FF),
      title: 'أكمل اختبار اللغة العربية',
      subtitle: 'درجة: 76% — وحدة 2',
      time: 'منذ 3 أيام',
    ),
  ];

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
        final data = await ref
            .read(teacherRepositoryProvider)
            .getStudentReport(widget.studentId, assessmentId: widget.assessmentId!);
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
    final name = _studentData?['fullName'] as String? ??
        widget.studentName ??
        'الطالب';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(name),
                SliverToBoxAdapter(child: _buildProfileHeader(name)),
                SliverToBoxAdapter(child: _buildTabBar()),
                SliverFillRemaining(
                  hasScrollBody: true,
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
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
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
          tooltip: 'تصدير التقرير',
        ),
      ],
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير تقرير الطالب...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader(String name) {
    final score = _studentData?['scorePercentage'] as num?;
    final timeTaken = _studentData?['timeTakenSeconds'] as num?;
    final scoreColor = score != null && score >= 70
        ? AppColors.success
        : AppColors.error;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              // Score badge (RTL: left)
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: score >= 70
                        ? AppColors.successContainer
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
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
                        'الدرجة',
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
                            ' دقيقة',
                            style: const TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.schedule_outlined,
                              size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _studentData?['status'] == 'completed'
                              ? 'مكتمل'
                              : 'منتهي الوقت',
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
                  name.isNotEmpty ? name[0] : 'ط',
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
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
        tabs: const [
          Tab(text: 'المهارات'),
          Tab(text: 'الأداء'),
          Tab(text: 'النشاط'),
        ],
      ),
    );
  }


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
      skills = _skills;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radar chart card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
                const Text(
                  'خريطة المهارات',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'نسبة الإتقان لكل مهارة رئيسية',
                  style: TextStyle(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تفصيل المهارات',
                  style: TextStyle(
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
          .map((v) => ((v as num).toDouble()).clamp(0.0, 100.0) / 100.0)
          .toList();
      days = List.generate(scores.length, (i) => 'يوم ${i + 1}');
    } else {
      scores = _weeklyScores;
      days = _weekDays;
    }

    final avg = scores.isEmpty
        ? 0.0
        : scores.reduce((a, b) => a + b) / scores.length;
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
                  label: 'المتوسط الأسبوعي',
                  value: '${(avg * 100).round()}%',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  label: 'أفضل أداء',
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
              color: Colors.white,
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
                const Text(
                  'الأداء الأسبوعي',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'درجات آخر 7 أيام',
                  style: TextStyle(
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
                                duration: Duration(
                                    milliseconds: 400 + i * 60),
                                height: (score * 140).clamp(8.0, 140.0),
                                decoration: BoxDecoration(
                                  color: isHighest
                                      ? AppColors.success
                                      : AppColors.primary.withOpacity(0.75),
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

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'سجل النشاط الأخير',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'آخر الأنشطة والمحاولات',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
              children: List.generate(_activityLog.length, (i) {
                final log = _activityLog[i];
                final isLast = i == _activityLog.length - 1;
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
}

// ─── Data Classes ─────────────────────────────────────────────────────────────

class _SkillData {
  const _SkillData({required this.name, required this.value});
  final String name;
  final double value; // 0.0 – 1.0
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
      ..color = AppColors.outlineVariant.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final r = radius * level / 4;
      final path = Path();
      for (int i = 0; i < count; i++) {
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
      ..color = AppColors.outlineVariant.withOpacity(0.4)
      ..strokeWidth = 1;

    for (int i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // ── Data polygon ──────────────────────────────────────────────────────
    final fillPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final dataPath = Path();
    for (int i = 0; i < count; i++) {
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

    for (int i = 0; i < count; i++) {
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
    for (int i = 0; i < count; i++) {
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isStrength
                          ? AppColors.successContainer
                          : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isStrength ? 'قوة' : 'ضعف',
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مراجعة الإجابات',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...answers.take(10).map((answer) {
            final isCorrect = (answer['isCorrect'] as bool?) ?? false;
            final questionText =
                (answer['questionText'] as String?) ?? 'سؤال';
            final selectedAnswer =
                (answer['selectedAnswer'] as String?) ?? '';
            final correctAnswer =
                (answer['correctAnswer'] as String?) ?? '';
            final difficulty =
                (answer['difficultyLevel'] as String?) ?? 'medium';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.successContainer.withOpacity(0.4)
                      : AppColors.errorContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.error.withOpacity(0.3),
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
                            isCorrect ? 'صحيح' : 'خاطئ',
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
                                ? 'سهل'
                                : difficulty == 'hard'
                                    ? 'صعب'
                                    : 'متوسط',
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
                      'إجابتك: $selectedAnswer',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 12,
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 2),
                      Text(
                        'الإجابة الصحيحة: $correctAnswer',
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
