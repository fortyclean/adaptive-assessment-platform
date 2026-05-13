import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/download_helper.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Teacher Analytics Report Screen — Screen 9, 28, 22
/// Requirements: 9.1–9.6
class TeacherReportScreen extends ConsumerStatefulWidget {
  const TeacherReportScreen({required this.assessmentId, super.key});
  final String assessmentId;

  @override
  ConsumerState<TeacherReportScreen> createState() =>
      _TeacherReportScreenState();
}

class _TeacherReportScreenState extends ConsumerState<TeacherReportScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _report;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    // Demo mode: if assessmentId starts with 'mock' or 'demo-', show mock report
    if (widget.assessmentId.startsWith('mock') ||
        widget.assessmentId.startsWith('demo-') ||
        widget.assessmentId == '1' ||
        widget.assessmentId == '2') {
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _report = {
          'classAverage': 74.5,
          'highestScore': 95.0,
          'lowestScore': 45.0,
          'scoreDistribution': {'90-100': 3, '70-89': 8, '50-69': 5, '0-49': 2},
          'skillHeatmap': [
            {'mainSkill': 'الفهم والاستيعاب', 'averagePercentage': 82.0},
            {'mainSkill': 'التطبيق', 'averagePercentage': 68.0},
            {'mainSkill': 'التحليل والتقييم', 'averagePercentage': 55.0},
          ],
          'studentResults': [
            {
              'fullName': 'أحمد محمد',
              'scorePercentage': 95.0,
              'status': 'completed',
              'timeTakenSeconds': 1800
            },
            {
              'fullName': 'سارة علي',
              'scorePercentage': 88.0,
              'status': 'completed',
              'timeTakenSeconds': 2100
            },
            {
              'fullName': 'محمد خالد',
              'scorePercentage': 76.0,
              'status': 'completed',
              'timeTakenSeconds': 2400
            },
            {
              'fullName': 'فاطمة أحمد',
              'scorePercentage': 65.0,
              'status': 'completed',
              'timeTakenSeconds': 2700
            },
            {
              'fullName': 'عمر حسن',
              'scorePercentage': 45.0,
              'status': 'timeout',
              'timeTakenSeconds': 2700
            },
          ],
        };
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await ref
          .read(teacherRepositoryProvider)
          .getAssessmentReport(widget.assessmentId);
      setState(() {
        _report = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل التقرير';
        _isLoading = false;
      });
    }
  }

  Future<void> _exportReport(BuildContext context) async {
    if (_report == null) return;

    final students =
        (_report!['studentResults'] as List?)?.cast<Map<String, dynamic>>() ??
            [];
    final headers = ['الاسم', 'النتيجة', 'الحالة', 'الوقت (دقيقة)'];
    final rows = students
        .map((s) => [
              s['fullName'] as String? ?? '',
              '${s['scorePercentage']}%',
              if (s['status'] == 'completed') 'مكتمل' else 'انتهى الوقت',
              '${(s['timeTakenSeconds'] as int? ?? 0) ~/ 60}',
            ])
        .toList();

    await DownloadHelper.exportReportCsv(
      context: context,
      rows: rows,
      headers: headers,
      fileName: 'report_${widget.assessmentId}.csv',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: const Text(
            'تقرير الاختبار',
            style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.onSurface, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.download_rounded, color: AppColors.primary),
              onPressed: () => _exportReport(context),
              tooltip: 'تصدير CSV',
            ),
            const SizedBox(width: 4),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.outlineVariant),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? _buildErrorState()
                : _buildContent(),
      );

  Widget _buildErrorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadReport();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );

  Widget _buildContent() {
    final r = _report!;
    final avg = r['classAverage'] as num?;
    final highest = r['highestScore'] as num?;
    final lowest = r['lowestScore'] as num?;
    final dist = r['scoreDistribution'] as Map<String, dynamic>? ?? {};
    final students =
        (r['studentResults'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final heatmap =
        (r['skillHeatmap'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Summary Stats ──────────────────────────────────────────────────
        _buildSectionLabel('ملخص النتائج'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'متوسط الصف',
                value: avg != null ? '${avg.round()}%' : '-',
                icon: Icons.bar_chart_rounded,
                color: AppColors.primary,
                bgColor: const Color(0xFFDDE1FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'أعلى درجة',
                value: highest != null ? '${highest.round()}%' : '-',
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
                bgColor: AppColors.successContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'أدنى درجة',
                value: lowest != null ? '${lowest.round()}%' : '-',
                icon: Icons.trending_down_rounded,
                color: AppColors.error,
                bgColor: AppColors.errorContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Score Distribution ─────────────────────────────────────────────
        _buildSectionLabel('توزيع الدرجات'),
        const SizedBox(height: 10),
        _DistributionChart(distribution: dist),
        const SizedBox(height: 24),

        // ── Skill Heatmap ──────────────────────────────────────────────────
        if (heatmap.isNotEmpty) ...[
          _buildSectionLabel('مستويات إتقان المهارات'),
          const SizedBox(height: 10),
          _SkillHeatmapCard(heatmap: heatmap),
          const SizedBox(height: 24),
        ],

        // ── Student Results ────────────────────────────────────────────────
        _buildSectionLabel('نتائج الطلاب'),
        const SizedBox(height: 10),
        if (students.isEmpty)
          _buildEmptyStudents()
        else
          ...students.asMap().entries.map(
                (e) => _StudentResultTile(
                  student: e.value,
                  rank: e.key + 1,
                ),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        textDirection: TextDirection.rtl,
      );

  Widget _buildEmptyStudents() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Column(
          children: [
            Icon(Icons.people_outline_rounded,
                color: AppColors.outlineVariant, size: 40),
            SizedBox(height: 12),
            Text(
              'لا توجد نتائج بعد',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
}

// ─── Stat Card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

// ─── Distribution Chart ────────────────────────────────────────────────────

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({required this.distribution});
  final Map<String, dynamic> distribution;

  @override
  Widget build(BuildContext context) {
    final buckets = [
      _Bucket('90-100%', distribution['90-100'] as int? ?? 0, AppColors.success,
          const Color(0xFFD1FAE5)),
      _Bucket('70-89%', distribution['70-89'] as int? ?? 0, AppColors.primary,
          const Color(0xFFDDE1FF)),
      _Bucket('50-69%', distribution['50-69'] as int? ?? 0, AppColors.warning,
          AppColors.warningContainer),
      _Bucket('0-49%', distribution['0-49'] as int? ?? 0, AppColors.error,
          AppColors.errorContainer),
    ];

    final maxCount =
        buckets.map((b) => b.count).fold(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Chart bars
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.map((b) {
                final barHeight =
                    maxCount > 0 ? (b.count / maxCount) * 100.0 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Count label above bar
                        Text(
                          '${b.count}',
                          style: TextStyle(
                            color: b.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: b.bgColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            border: Border.all(color: b.color, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 8),
          // Labels row
          Row(
            children: buckets
                .map((b) => Expanded(
                      child: Center(
                        child: Text(
                          b.label,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Bucket {
  const _Bucket(this.label, this.count, this.color, this.bgColor);
  final String label;
  final int count;
  final Color color;
  final Color bgColor;
}

// ─── Skill Heatmap Card ────────────────────────────────────────────────────

class _SkillHeatmapCard extends StatelessWidget {
  const _SkillHeatmapCard({required this.heatmap});
  final List<Map<String, dynamic>> heatmap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F2FC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  bottom: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology_rounded,
                      color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'تحليل مفصل للمفاهيم الأساسية',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Skills list
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: heatmap.asMap().entries.map((e) {
                  final isLast = e.key == heatmap.length - 1;
                  return Column(
                    children: [
                      _SkillHeatmapRow(skill: e.value),
                      if (!isLast) ...[
                        const SizedBox(height: 4),
                        const Divider(
                            height: 16, color: AppColors.outlineVariant),
                      ],
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
}

class _SkillHeatmapRow extends StatelessWidget {
  const _SkillHeatmapRow({required this.skill});
  final Map<String, dynamic> skill;

  @override
  Widget build(BuildContext context) {
    final pct = (skill['averagePercentage'] as num?)?.toDouble() ?? 0;
    final isStrong = pct >= 70;
    final color = isStrong ? AppColors.success : AppColors.error;
    final bgColor =
        isStrong ? AppColors.successContainer : AppColors.errorContainer;
    final label = isStrong ? 'إتقان جيد' : 'يحتاج تطوير';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                skill['mainSkill'] as String? ?? '',
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${pct.round()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الهدف: 80%',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

// ─── Student Result Tile ───────────────────────────────────────────────────

class _StudentResultTile extends StatelessWidget {
  const _StudentResultTile({required this.student, required this.rank});
  final Map<String, dynamic> student;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final score = student['scorePercentage'] as num?;
    final isPass = score != null && score >= 70;
    final scoreColor = isPass ? AppColors.success : AppColors.error;
    final scoreBg =
        isPass ? AppColors.successContainer : AppColors.errorContainer;
    final timeSecs = student['timeTakenSeconds'] as int?;
    final timeStr = timeSecs != null
        ? '${timeSecs ~/ 60} دقيقة ${timeSecs % 60} ثانية'
        : null;
    final isCompleted = student['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? const Color(0xFFFEF3C7)
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank <= 3
                      ? const Color(0xFFD97706)
                      : AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['fullName'] as String? ?? 'طالب',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFD1FAE5)
                            : AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCompleted ? 'مكتمل' : 'انتهى الوقت',
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (timeStr != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.schedule_rounded,
                          size: 11, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Score badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scoreBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scoreColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  score != null ? '${score.round()}' : '-',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
