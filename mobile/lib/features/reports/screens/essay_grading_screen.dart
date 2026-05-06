import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Essay Grading Screen — Teacher grades pending essay answers
/// Requirements: 18.4, 18.5, 18.6
///
/// Allows the teacher to:
///   - View essay questions that need grading
///   - Read student answers
///   - Assign scores (0 to max marks) per question
///   - Finalize the session result after all essays are graded
class EssayGradingScreen extends ConsumerStatefulWidget {
  const EssayGradingScreen({
    required this.attemptId, required this.studentName, super.key,
  });

  /// The student attempt ID to grade.
  final String attemptId;

  /// Display name of the student (for the AppBar title).
  final String studentName;

  @override
  ConsumerState<EssayGradingScreen> createState() =>
      _EssayGradingScreenState();
}

class _EssayGradingScreenState extends ConsumerState<EssayGradingScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  /// The full attempt data returned by the API.
  Map<String, dynamic>? _attempt;

  /// Essay answers that require grading.
  List<Map<String, dynamic>> _essayAnswers = [];

  /// Map of questionId → score entered by the teacher.
  final Map<String, int> _scores = {};

  /// Map of questionId → TextEditingController for the score input.
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadAttempt();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAttempt() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ref
          .read(teacherRepositoryProvider)
          .getAttemptForGrading(widget.attemptId);

      final answers =
          (data['answers'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      // Filter only essay answers that need grading
      final essays = answers
          .where((a) => a['questionType'] == 'essay')
          .toList();

      // Initialise controllers and pre-fill any existing scores
      for (final essay in essays) {
        final qId = essay['questionId'] as String? ?? '';
        final existingScore = essay['score'] as int?;
        final ctrl = TextEditingController(
          text: existingScore != null ? '$existingScore' : '',
        );
        _controllers[qId] = ctrl;
        if (existingScore != null) {
          _scores[qId] = existingScore;
        }
      }

      setState(() {
        _attempt = data;
        _essayAnswers = essays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل بيانات الجلسة';
        _isLoading = false;
      });
    }
  }

  /// Returns true when every essay question has a valid score entered.
  bool get _allGraded {
    if (_essayAnswers.isEmpty) return false;
    return _essayAnswers.every((a) {
      final qId = a['questionId'] as String? ?? '';
      return _scores.containsKey(qId);
    });
  }

  /// Validates and stores the score for [questionId].
  void _onScoreChanged(String questionId, String value, int maxMarks) {
    final parsed = int.tryParse(value.trim());
    setState(() {
      if (parsed != null && parsed >= 0 && parsed <= maxMarks) {
        _scores[questionId] = parsed;
      } else {
        _scores.remove(questionId);
      }
    });
  }

  /// Submits all scores to the backend and finalises the session.
  Future<void> _finaliseGrading() async {
    if (!_allGraded || _isSubmitting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد إنهاء التصحيح'),
        content: const Text(
          'هل أنت متأكد من إنهاء التصحيح؟ سيتم احتساب النتيجة النهائية للطالب.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(teacherRepositoryProvider).submitEssayGrades(
            attemptId: widget.attemptId,
            grades: _scores,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنهاء التصحيح وتحديث نتيجة الطالب'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حفظ الدرجات، يرجى المحاولة مجدداً'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('تصحيح مقالات — ${widget.studentName}'),
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
              : _buildContent(),
      bottomNavigationBar: _isLoading || _error != null
          ? null
          : _buildBottomBar(),
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
            onPressed: _loadAttempt,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );

  Widget _buildContent() {
    if (_essayAnswers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            Text(
              'لا توجد أسئلة مقالية تحتاج تصحيحاً',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Status banner
        _StatusBanner(
          gradedCount: _scores.length,
          totalCount: _essayAnswers.length,
        ),
        const SizedBox(height: 16),

        // Essay grading cards
        ..._essayAnswers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          return _EssayGradingCard(
            index: index + 1,
            answer: answer,
            controller: _controllers[answer['questionId'] as String? ?? ''] ??
                TextEditingController(),
            currentScore: _scores[answer['questionId'] as String? ?? ''],
            onScoreChanged: (value) => _onScoreChanged(
              answer['questionId'] as String? ?? '',
              value,
              answer['maxMarks'] as int? ?? 10,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar() {
    final gradedCount = _scores.length;
    final totalCount = _essayAnswers.length;
    final isReady = _allGraded;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? gradedCount / totalCount : 0,
                    backgroundColor: AppColors.surfaceContainer,
                    color: isReady ? AppColors.success : AppColors.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$gradedCount / $totalCount',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isReady
                            ? AppColors.success
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Finalise button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isReady && !_isSubmitting ? _finaliseGrading : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(
                  _isSubmitting ? 'جاري الحفظ...' : 'إنهاء التصحيح وتحديث النتيجة',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.surfaceContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

/// Banner showing how many essays have been graded so far.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.gradedCount,
    required this.totalCount,
  });

  final int gradedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final isComplete = gradedCount == totalCount;
    final color = isComplete ? AppColors.success : AppColors.warning;
    final bgColor =
        isComplete ? AppColors.successContainer : AppColors.warningContainer;
    final icon = isComplete
        ? Icons.check_circle_rounded
        : Icons.pending_actions_rounded;
    final message = isComplete
        ? 'تم تصحيح جميع الأسئلة المقالية — يمكنك إنهاء التصحيح'
        : 'تبقّى ${totalCount - gradedCount} سؤال مقالي بدون درجة';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card for a single essay question — shows question text, student answer,
/// and a score input field.
class _EssayGradingCard extends StatelessWidget {
  const _EssayGradingCard({
    required this.index,
    required this.answer,
    required this.controller,
    required this.onScoreChanged,
    this.currentScore,
  });

  final int index;
  final Map<String, dynamic> answer;
  final TextEditingController controller;
  final void Function(String) onScoreChanged;
  final int? currentScore;

  @override
  Widget build(BuildContext context) {
    final questionText =
        answer['questionText'] as String? ?? 'نص السؤال غير متاح';
    final studentAnswer =
        answer['selectedAnswer'] as String? ?? '(لم يُجب الطالب)';
    final maxMarks = answer['maxMarks'] as int? ?? 10;
    final isGraded = currentScore != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color: isGraded
              ? AppColors.success.withOpacity(0.5)
              : AppColors.outlineVariant,
          width: isGraded ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card header: question number + graded badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السؤال $index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (isGraded)
                  _GradedBadge(score: currentScore!, maxMarks: maxMarks),
              ],
            ),
            const SizedBox(height: 12),

            // Question text
            const _SectionLabel(label: 'نص السؤال'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius:
                    BorderRadius.circular(AppConstants.inputBorderRadius),
              ),
              child: Text(
                questionText,
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // Student answer
            const _SectionLabel(label: 'إجابة الطالب'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppConstants.inputBorderRadius),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Text(
                studentAnswer,
                textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.7,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // Score input
            _SectionLabel(label: 'الدرجة (0 – $maxMarks)'),
            const SizedBox(height: 6),
            _ScoreInput(
              controller: controller,
              maxMarks: maxMarks,
              onChanged: onScoreChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small label used as a section heading inside the grading card.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
      label,
      textDirection: TextDirection.rtl,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
    );
}

/// Badge shown on a graded card displaying the awarded score.
class _GradedBadge extends StatelessWidget {
  const _GradedBadge({required this.score, required this.maxMarks});
  final int score;
  final int maxMarks;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded,
              size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            '$score / $maxMarks',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
}

/// Score input field with validation (0 ≤ score ≤ maxMarks).
class _ScoreInput extends StatefulWidget {
  const _ScoreInput({
    required this.controller,
    required this.maxMarks,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int maxMarks;
  final void Function(String) onChanged;

  @override
  State<_ScoreInput> createState() => _ScoreInputState();
}

class _ScoreInputState extends State<_ScoreInput> {
  String? _validationError;

  void _validate(String value) {
    final parsed = int.tryParse(value.trim());
    setState(() {
      if (value.trim().isEmpty) {
        _validationError = null;
      } else if (parsed == null) {
        _validationError = 'يرجى إدخال رقم صحيح';
      } else if (parsed < 0) {
        _validationError = 'الدرجة لا يمكن أن تكون سالبة';
      } else if (parsed > widget.maxMarks) {
        _validationError = 'الحد الأقصى هو ${widget.maxMarks}';
      } else {
        _validationError = null;
      }
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) => TextField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      onChanged: _validate,
      decoration: InputDecoration(
        hintText: '0 – ${widget.maxMarks}',
        errorText: _validationError,
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide:
              const BorderSide(color: AppColors.error, width: 2),
        ),
        suffixText: '/ ${widget.maxMarks}',
        suffixStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
}
