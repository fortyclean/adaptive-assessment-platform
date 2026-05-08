import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../repositories/assessment_repository.dart';

/// Assessment Start Screen — Screen 14
/// Requirements: 14.1–14.5
class AssessmentStartScreen extends ConsumerStatefulWidget {
  const AssessmentStartScreen({super.key, required this.assessmentId});
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

  static final Map<String, dynamic> _mockAssessment = {
    '_id': 'mock1',
    'title': 'اختبار منتصف الفصل - رياضيات',
    'subject': 'الرياضيات',
    'unit': 'الوحدة الثالثة: الجبر',
    'assessmentType': 'adaptive',
    'questionCount': 25,
    'timeLimitMinutes': 45,
    'status': 'active',
    'availableFrom': null,
    'availableUntil': null,
    'createdBy': {'fullName': 'أ. محمد أحمد'},
    'previousScore': null,
  };

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
        _assessment = _mockAssessment;
        _isLoading = false;
      });
    }
  }

  bool get _isAvailable {
    if (_assessment == null) return false;
    final now = DateTime.now();
    final from = _assessment!['availableFrom'] != null
        ? DateTime.tryParse(_assessment!['availableFrom'] as String)
        : null;
    final until = _assessment!['availableUntil'] != null
        ? DateTime.tryParse(_assessment!['availableUntil'] as String)
        : null;
    if (from != null && now.isBefore(from)) return false;
    if (until != null && now.isAfter(until)) return false;
    return _assessment!['status'] == 'active';
  }

  Future<void> _startAssessment() async {
    if (_assessment == null) return;
    setState(() => _isStarting = true);
    try {
      final classroomIds = _assessment!['classroomIds'] as List?;
      final classroomId = classroomIds?.isNotEmpty == true
          ? classroomIds!.first as String
          : '';

      // Demo mode: if assessmentId starts with 'mock' or API fails, go directly to exam
      if (widget.assessmentId.startsWith('mock') ||
          widget.assessmentId == '1' ||
          widget.assessmentId == '2') {
        if (!mounted) return;
        context.push(
          '/student/assessments/${widget.assessmentId}/exam',
          extra: {
            'attemptId': 'demo-attempt-${widget.assessmentId}',
            'questionCount': _assessment!['questionCount'] as int? ?? 10,
            'timeLimitMinutes': _assessment!['timeLimitMinutes'] as int? ?? 30,
          },
        );
        return;
      }

      final result = await ref.read(assessmentRepositoryProvider).startAttempt(
            assessmentId: widget.assessmentId,
            classroomId: classroomId,
          );

      if (!mounted) return;
      context.push(
        '/student/assessments/${widget.assessmentId}/exam',
        extra: {
          'attemptId': result['attemptId'] as String? ?? '',
          'questionCount': _assessment!['questionCount'] as int? ?? 10,
          'timeLimitMinutes': _assessment!['timeLimitMinutes'] as int? ?? 30,
        },
      );
    } catch (e) {
      // Show error message to user instead of silent navigation
      if (mounted) {
        setState(() => _isStarting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تعذر بدء الاختبار، يرجى المحاولة مرة أخرى'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: _startAssessment,
            ),
          ),
        );
      }
    } finally {
      if (mounted && _isStarting) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'بدء الاختبار',
          style: TextStyle(
            color: Color(0xFF1A1B22),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                  color: AppColors.onSurface, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _loadAssessment,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final a = _assessment!;
    final type = a['assessmentType'] == 'adaptive' ? 'تكيفي' : 'عشوائي';
    final isAdaptive = a['assessmentType'] == 'adaptive';
    final teacherName =
        (a['createdBy'] as Map?)?['fullName'] as String? ?? '';
    final previousScore = a['previousScore'] as num?;
    final unit = a['unit'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header card ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top accent bar
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge
                      _TypeBadge(label: type, isAdaptive: isAdaptive),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        a['title'] as String? ?? '',
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      if ((a['subject'] as String?)?.isNotEmpty == true) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.book_outlined,
                                size: 14,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              a['subject'] as String,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (unit?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.layers_outlined,
                                size: 14,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              unit!,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Details grid ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DetailItem(
                        icon: Icons.quiz_outlined,
                        label: 'عدد الأسئلة',
                        value: '${a['questionCount'] ?? '--'} سؤال',
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 48,
                        color: AppColors.outlineVariant),
                    Expanded(
                      child: _DetailItem(
                        icon: Icons.timer_outlined,
                        label: 'الوقت المحدد',
                        value: '${a['timeLimitMinutes'] ?? '--'} دقيقة',
                      ),
                    ),
                  ],
                ),
                if (teacherName.isNotEmpty) ...[
                  const Divider(
                      height: 24, color: AppColors.outlineVariant),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'المعلم',
                    value: teacherName,
                  ),
                ],
              ],
            ),
          ),

          // ── Previous score ────────────────────────────────────────────────
          if (previousScore != null) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نتيجتك السابقة',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${previousScore.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Navigation warning ────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.warning.withOpacity(0.4)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'سيتم تسجيل أي محاولة للخروج من شاشة الاختبار',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Start button ──────────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (_isAvailable && !_isStarting)
                  ? _startAssessment
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.outlineVariant,
                disabledForegroundColor: AppColors.onSurfaceVariant,
                elevation: 2,
                shadowColor: AppColors.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isStarting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          _isAvailable
                              ? 'ابدأ الاختبار الآن'
                              : 'الاختبار غير متاح',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Back button ───────────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'رجوع',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.isAdaptive});
  final String label;
  final bool isAdaptive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdaptive
            ? const Color(0xFFD0E1FB)
            : const Color(0xFFFFDBCE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAdaptive
              ? const Color(0xFFB7C8E1)
              : const Color(0xFFFFB59A),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isAdaptive
              ? const Color(0xFF54647A)
              : const Color(0xFF611E00),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
