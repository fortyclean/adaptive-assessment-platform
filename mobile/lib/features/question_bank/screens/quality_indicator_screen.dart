import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Question Bank Quality Indicator Screen.
class QualityIndicatorScreen extends ConsumerStatefulWidget {
  const QualityIndicatorScreen({
    required this.subject,
    required this.gradeLevel,
    required this.unit,
    super.key,
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionBankQualityTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _qualityData == null
              ? Center(child: Text(l10n.qualityDataLoadFailed))
              : _buildContent(context, l10n),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
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
        Row(
          children: [
            Expanded(
              child: _BentoCard(
                label: l10n.totalQuestionsLabel,
                value: '$total',
                icon: Icons.quiz_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BentoCard(
                label: l10n.qualityStatusLabel,
                value:
                    isBalanced ? l10n.balancedStatus : l10n.insufficientStatus,
                icon: isBalanced
                    ? Icons.check_circle_rounded
                    : Icons.warning_rounded,
                color: isBalanced ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.questionDifficultyDistribution,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          label: l10n.easyDifficulty,
          count: counts['easy'] as int? ?? 0,
          color: AppColors.success,
          minRequired: 3,
        ),
        const SizedBox(height: 8),
        _DifficultyCard(
          label: l10n.mediumDifficulty,
          count: counts['medium'] as int? ?? 0,
          color: AppColors.warning,
          minRequired: 3,
        ),
        const SizedBox(height: 8),
        _DifficultyCard(
          label: l10n.hardDifficulty,
          count: counts['hard'] as int? ?? 0,
          color: AppColors.error,
          minRequired: 3,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push(AppRoutes.teacherAddQuestion),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addQuestions),
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
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                label,
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
    final l10n = AppLocalizations.of(context);
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
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: color),
                ),
                Row(
                  children: [
                    Text(
                      l10n.questionCountCompact(count),
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _isSufficient
                            ? AppColors.successContainer
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isSufficient
                            ? l10n.balancedStatus
                            : l10n.insufficientStatus,
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
              l10n.minimumQuestionsRequired(minRequired),
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
