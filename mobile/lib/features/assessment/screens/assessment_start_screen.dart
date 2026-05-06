import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../repositories/assessment_repository.dart';

/// Assessment Start Screen — Screen 14
/// Requirements: 14.1–14.5
class AssessmentStartScreen extends ConsumerStatefulWidget {
  const AssessmentStartScreen({required this.assessmentId, super.key});
  final String assessmentId;

  @override
  ConsumerState<AssessmentStartScreen> createState() =>
      _AssessmentStartScreenState();
}

class _AssessmentStartScreenState
    extends ConsumerState<AssessmentStartScreen> {
  bool _isLoading = true;
  bool _isStarting = false;
  Map<String, dynamic>? _assessment;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    try {
      final data = await ref
          .read(assessmentRepositoryProvider)
          .getAssessment(widget.assessmentId);
      setState(() {
        _assessment = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل بيانات الاختبار';
        _isLoading = false;
      });
    }
  }

  bool get _isAvailable {
    if (_assessment == null) return false;
    final now = DateTime.now();
    final from = _assessment!['availableFrom'] != null
        ? DateTime.parse(_assessment!['availableFrom'] as String)
        : null;
    final until = _assessment!['availableUntil'] != null
        ? DateTime.parse(_assessment!['availableUntil'] as String)
        : null;
    if (from != null && now.isBefore(from)) return false;
    if (until != null && now.isAfter(until)) return false;
    return _assessment!['status'] == 'active';
  }

  Future<void> _startAssessment() async {
    if (_assessment == null) return;
    setState(() => _isStarting = true);
    try {
      // Use first classroom ID from assessment
      final classroomIds = _assessment!['classroomIds'] as List?;
      final classroomId = classroomIds?.isNotEmpty ?? false
          ? classroomIds!.first as String
          : '';

      final result = await ref.read(assessmentRepositoryProvider).startAttempt(
            assessmentId: widget.assessmentId,
            classroomId: classroomId,
          );

      if (!mounted) return;
      context.push(
          '/student/assessments/${widget.assessmentId}/exam',
          extra: {
            'attemptId': result['attemptId'] as String? ?? '',
            'questionCount': (_assessment!['questionCount'] as num?)?.toInt() ?? 10,
            'timeLimitMinutes': (_assessment!['timeLimitMinutes'] as num?)?.toInt() ?? 30,
          });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر بدء الاختبار. حاول مرة أخرى')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('بدء الاختبار'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
    );

  Widget _buildContent() {
    final a = _assessment!;
    final type = a['assessmentType'] == 'adaptive' ? 'تكيفي' : 'عشوائي';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Assessment info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a['title'] as String? ?? '',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.subject_rounded,
                      label: 'المادة', value: a['subject'] as String? ?? ''),
                  _InfoRow(icon: Icons.category_rounded,
                      label: 'النوع', value: type),
                  _InfoRow(icon: Icons.quiz_rounded,
                      label: 'عدد الأسئلة',
                      value: '${a['questionCount'] ?? ''} سؤال'),
                  _InfoRow(icon: Icons.timer_rounded,
                      label: 'الوقت المحدد',
                      value: '${a['timeLimitMinutes'] ?? ''} دقيقة'),
                  if (a['createdBy'] != null)
                    _InfoRow(icon: Icons.person_rounded,
                        label: 'المعلم',
                        value: (a['createdBy'] as Map?)?['fullName'] as String? ?? ''),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيتم تسجيل أي محاولة للخروج من شاشة الاختبار',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Start button
          ElevatedButton.icon(
            onPressed: (_isAvailable && !_isStarting) ? _startAssessment : null,
            icon: _isStarting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_isAvailable ? 'ابدأ الاختبار الآن' : 'الاختبار غير متاح'),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('رجوع'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label: ',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
}
