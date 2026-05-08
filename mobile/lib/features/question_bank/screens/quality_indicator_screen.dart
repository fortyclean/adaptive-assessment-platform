import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Question Bank Quality Indicator Screen — Screen 29
/// Requirements: 22.3, 22.4
class QualityIndicatorScreen extends ConsumerStatefulWidget {
  const QualityIndicatorScreen({
    super.key,
    required this.subject,
    required this.gradeLevel,
    required this.unit,
  });
  final String subject;
  final String gradeLevel;
  final String unit;

  @override
  ConsumerState<QualityIndicatorScreen> createState() =>
      _QualityIndicatorScreenState();
}

class _QualityIndicatorScreenState
    extends ConsumerState<QualityIndicatorScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _qualityData;

  @override
  void initState() {
    super.initState();
    _loadQuality();
  }

  Future<void> _loadQuality() async {
    try {
      final data = await ref.read(teacherRepositoryProvider).getQualityCheck(
            subject: widget.subject,
            gradeLevel: widget.gradeLevel,
            unit: widget.unit,
          );
      setState(() {
        _qualityData = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جودة بنك الأسئلة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _qualityData == null
              ? const Center(child: Text('تعذر تحميل البيانات'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final data = _qualityData!;
    final counts = data['counts'] as Map<String, dynamic>? ??
        {'easy': 0, 'medium': 0, 'hard': 0};
    final isBalanced = data['isAdaptiveReady'] as bool? ?? false;
    final total = (counts['easy'] as int? ?? 0) +
        (counts['medium'] as int? ?? 0) +
        (counts['hard'] as int? ?? 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Bento Grid
        Row(
          children: [
            Expanded(
              child: _BentoCard(
                label: 'إجمالي الأسئلة',
                value: '$total',
                icon: Icons.quiz_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BentoCard(
                label: 'الحالة',
                value: isBalanced ? 'متوازن' : 'غير كافٍ',
                icon: isBalanced
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: isBalanced ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Per-difficulty cards
        Text('توزيع الأسئلة حسب الصعوبة',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        _DifficultyCard(
          label: 'سهل',
          count: counts['easy'] as int? ?? 0,
          color: AppColors.success,
          minRequired: 3,
        ),
        const SizedBox(height: 8),
        _DifficultyCard(
          label: 'متوسط',
          count: counts['medium'] as int? ?? 0,
          color: AppColors.warning,
          minRequired: 3,
        ),
        const SizedBox(height: 8),
        _DifficultyCard(
          label: 'صعب',
          count: counts['hard'] as int? ?? 0,
          color: AppColors.error,
          minRequired: 3,
        ),

        const SizedBox(height: 24),

        // Add questions shortcut
        ElevatedButton.icon(
          onPressed: () => context.push(AppRoutes.teacherAddQuestion),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة أسئلة'),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
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
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.label,
    required this.count,
    required this.color,
    required this.minRequired,
  });
  final String label;
  final int count;
  final Color color;
  final int minRequired;

  bool get _isSufficient => count >= minRequired;

  @override
  Widget build(BuildContext context) {
    final progress = (count / (minRequired * 2)).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: color)),
                Row(
                  children: [
                    Text('$count سؤال',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isSufficient
                            ? AppColors.successContainer
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isSufficient ? 'كافٍ' : 'غير كافٍ',
                        style: TextStyle(
                          color: _isSufficient
                              ? AppColors.success
                              : AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainer,
              color: _isSufficient ? color : AppColors.error,
            ),
            const SizedBox(height: 4),
            Text(
              'الحد الأدنى: $minRequired أسئلة',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
