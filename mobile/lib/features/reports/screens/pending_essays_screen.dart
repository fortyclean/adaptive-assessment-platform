import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Pending Essays Screen — lists all student attempts awaiting essay grading.
/// Requirements: 18.5, 18.6
///
/// Teachers navigate here to see which sessions have essay answers that
/// require manual grading before the session result can be finalised.
class PendingEssaysScreen extends ConsumerStatefulWidget {
  const PendingEssaysScreen({super.key});

  @override
  ConsumerState<PendingEssaysScreen> createState() =>
      _PendingEssaysScreenState();
}

class _PendingEssaysScreenState extends ConsumerState<PendingEssaysScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _attempts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ref
          .read(teacherRepositoryProvider)
          .getPendingEssayAttempts();
      setState(() {
        _attempts = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل الجلسات المعلقة';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('الأسئلة المقالية — بانتظار التصحيح'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
          tooltip: 'رجوع',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadAttempts,
                  child: _attempts.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
                ),
    );

  Widget _buildError() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_error!,
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAttempts,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );

  Widget _buildEmpty() => ListView(
      // Wrap in ListView so RefreshIndicator works even when empty
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 72,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد أسئلة مقالية بانتظار التصحيح',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'جميع الجلسات المقالية تم تصحيحها',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildList() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attempts.length,
      itemBuilder: (ctx, i) {
        final attempt = _attempts[i];
        return _PendingAttemptCard(
          attempt: attempt,
          onGrade: () {
            final attemptId = attempt['_id'] as String? ?? '';
            final studentName =
                attempt['studentName'] as String? ?? 'طالب';
            context.push(
              '/teacher/pending-essays/$attemptId',
              extra: {'studentName': studentName},
            );
          },
        );
      },
    );
}

/// Card representing a single pending-review attempt.
class _PendingAttemptCard extends StatelessWidget {
  const _PendingAttemptCard({
    required this.attempt,
    required this.onGrade,
  });

  final Map<String, dynamic> attempt;
  final VoidCallback onGrade;

  @override
  Widget build(BuildContext context) {
    final studentName = attempt['studentName'] as String? ?? 'طالب';
    final assessmentTitle =
        attempt['assessmentTitle'] as String? ?? 'اختبار';
    final subject = attempt['subject'] as String? ?? '';
    final submittedAt = attempt['submittedAt'] as String?;
    final essayCount = attempt['pendingEssayCount'] as int? ?? 0;

    // Format submission date
    var dateLabel = '';
    if (submittedAt != null) {
      try {
        final dt = DateTime.parse(submittedAt).toLocal();
        dateLabel =
            '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppConstants.cardBorderRadius),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student name + pending badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    studentName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _PendingBadge(count: essayCount),
              ],
            ),
            const SizedBox(height: 6),

            // Assessment title
            Text(
              assessmentTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: 4),

            // Subject + date
            Row(
              children: [
                if (subject.isNotEmpty) ...[
                  const Icon(Icons.book_outlined,
                      size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    subject,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (dateLabel.isNotEmpty) ...[
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Grade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onGrade,
                icon: const Icon(Icons.rate_review_rounded, size: 18),
                label: const Text('بدء التصحيح'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.buttonBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge showing the number of ungraded essay questions.
class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pending_actions_rounded,
              size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            '$count سؤال',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
}
