import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الاختبار'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري تصدير CSV...')),
              );
            },
            tooltip: 'تصدير CSV',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
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
        // Summary stats
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'المتوسط',
                    value: avg != null ? '${avg.round()}%' : '-',
                    color: AppColors.primary)),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: 'الأعلى',
                    value: highest != null ? '${highest.round()}%' : '-',
                    color: AppColors.success)),
            const SizedBox(width: 8),
            Expanded(
                child: _StatCard(
                    label: 'الأدنى',
                    value: lowest != null ? '${lowest.round()}%' : '-',
                    color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 20),

        // Score distribution
        Text('توزيع الدرجات',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _DistributionChart(distribution: dist),
        const SizedBox(height: 20),

        // Skill heatmap
        if (heatmap.isNotEmpty) ...[
          Text('خريطة المهارات',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...heatmap.map((s) => _SkillHeatmapRow(skill: s)),
          const SizedBox(height: 20),
        ],

        // Student results table
        Text('نتائج الطلاب',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (students.isEmpty)
          const Text('لا توجد نتائج بعد')
        else
          ...students.map((s) => _StudentResultTile(student: s)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    )),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
}

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({required this.distribution});
  final Map<String, dynamic> distribution;

  @override
  Widget build(BuildContext context) {
    final buckets = [
      ('0-49%', distribution['0-49'] as int? ?? 0, AppColors.error),
      ('50-69%', distribution['50-69'] as int? ?? 0, AppColors.warning),
      ('70-89%', distribution['70-89'] as int? ?? 0, AppColors.primary),
      ('90-100%', distribution['90-100'] as int? ?? 0, AppColors.success),
    ];

    final maxCount = buckets.map((b) => b.$2).fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: buckets.map((b) {
            final progress = maxCount > 0 ? b.$2 / maxCount : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(b.$1,
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceContainer,
                      color: b.$3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${b.$2}',
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SkillHeatmapRow extends StatelessWidget {
  const _SkillHeatmapRow({required this.skill});
  final Map<String, dynamic> skill;

  @override
  Widget build(BuildContext context) {
    final pct = (skill['averagePercentage'] as num?)?.toDouble() ?? 0;
    final color = pct >= 70 ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(skill['mainSkill'] as String? ?? '',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: AppColors.surfaceContainer,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text('${pct.round()}%',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StudentResultTile extends StatelessWidget {
  const _StudentResultTile({required this.student});
  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final score = student['scorePercentage'] as num?;
    final scoreColor =
        score != null && score >= 70 ? AppColors.success : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: score != null && score >= 70
              ? AppColors.successContainer
              : AppColors.errorContainer,
          child: Text(
            score != null ? '${score.round()}%' : '-',
            style: TextStyle(
                color: scoreColor,
                fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(student['fullName'] as String? ?? 'طالب'),
        subtitle: Text(
          '${student['timeTakenSeconds'] != null ? '${(student['timeTakenSeconds'] as int) ~/ 60} دقيقة' : ''} • ${student['status'] == 'completed' ? 'مكتمل' : 'منتهي الوقت'}',
        ),
      ),
    );
  }
}
