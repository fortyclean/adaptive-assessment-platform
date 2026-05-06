import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../repositories/assessment_repository.dart';

/// Results Screen — Screen 4 & 16
/// Requirements: 8.1–8.4, 15.2, 15.4
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({required this.attemptId, super.key});
  final String attemptId;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    try {
      final data = await ref
          .read(assessmentRepositoryProvider)
          .getResult(widget.attemptId);
      setState(() {
        _result = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل النتيجة';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الاختبار'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/student'),
            child: const Text('الرئيسية'),
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
    final r = _result!;
    final status = r['status'] as String? ?? 'completed';
    final score = (r['scorePercentage'] as num?)?.toDouble() ?? 0;
    final points = r['pointsEarned'] as int? ?? 0;
    final bonusAwarded = r['bonusAwarded'] as bool? ?? false;
    final skillBreakdown =
        (r['skillBreakdown'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final wrongAnswers =
        (r['wrongAnswers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final pendingEssayGrading = r['pendingEssayGrading'] as int? ?? 0;

    // Show pending review state when session has ungraded essay questions (Req 18.5)
    if (status == 'pending_review') {
      return _buildPendingReviewContent(pendingEssayGrading);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score circle
          _ScoreCircle(score: score),
          const SizedBox(height: 16),

          // Points earned
          _PointsBadge(points: points, bonusAwarded: bonusAwarded),
          const SizedBox(height: 24),

          // Skill breakdown
          if (skillBreakdown.isNotEmpty) ...[
            Text('تحليل المهارات',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...skillBreakdown.map((s) => _SkillRow(skill: s)),
            const SizedBox(height: 24),
          ],

          // Wrong answers with correct answers (Req 8.4)
          if (wrongAnswers.isNotEmpty) ...[
            Text('الأسئلة الخاطئة',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...wrongAnswers.map((a) => _WrongAnswerCard(answer: a)),
          ],
        ],
      ),
    );
  }

  /// Shown when the session contains essay questions awaiting teacher grading (Req 18.5)
  Widget _buildPendingReviewContent(int pendingCount) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainer,
                border: Border.all(color: AppColors.outlineVariant, width: 3),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'في انتظار المراجعة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'تم تسليم اختبارك بنجاح. يحتوي على ${pendingCount > 0 ? pendingCount : 'بعض'} '
              'أسئلة مقالية تحتاج إلى مراجعة يدوية من المعلم.\n\n'
              'ستصلك إشعاراً عند اكتمال التصحيح وظهور نتيجتك النهائية.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.go('/student'),
              icon: const Icon(Icons.home_rounded),
              label: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    );
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 70 ? AppColors.success : AppColors.error;
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: score >= 70 ? AppColors.successContainer : AppColors.errorContainer,
          border: Border.all(color: color, width: 4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${score.round()}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              score >= 70 ? 'ممتاز' : 'يحتاج تحسين',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points, required this.bonusAwarded});
  final int points;
  final bool bonusAwarded;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded,
                color: AppColors.pointsGold, size: 28),
            const SizedBox(width: 8),
            Text(
              '+$points نقطة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.pointsGold,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (bonusAwarded) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pointsGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+${AppConstants.bonusPoints} مكافأة',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill});
  final Map<String, dynamic> skill;

  @override
  Widget build(BuildContext context) {
    final pct = (skill['percentage'] as num?)?.toDouble() ?? 0;
    final isStrength = pct >= AppConstants.strengthThreshold;
    final color = isStrength ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill['mainSkill'] as String? ?? '',
                  style: Theme.of(context).textTheme.bodyMedium),
              Row(
                children: [
                  Icon(
                    isStrength
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${pct.round()}%',
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: AppColors.surfaceContainer,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _WrongAnswerCard extends StatelessWidget {
  const _WrongAnswerCard({required this.answer});
  final Map<String, dynamic> answer;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer['questionText'] as String? ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _AnswerRow(
              label: 'إجابتك',
              value: answer['selectedAnswer'] as String? ?? '',
              color: AppColors.error,
            ),
            _AnswerRow(
              label: 'الإجابة الصحيحة',
              value: answer['correctAnswer'] as String? ?? '',
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
}
