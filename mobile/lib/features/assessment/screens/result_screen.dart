import 'dart:math' as math;
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

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _result;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _loadResult();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// بناء نتيجة demo واقعية عند عدم توفر API
  static Map<String, dynamic> _buildDemoResult(String attemptId) => {
        'status': 'completed',
        'scorePercentage': 78.5,
        'correctAnswers': 16,
        'totalQuestions': 20,
        'timeTakenSeconds': 1245,
        'passed': true,
        'masteryLevel': 'متقدم',
        'pointsEarned': 157,
        'bonusAwarded': false,
        'skillBreakdown': [
          {'mainSkill': 'الفهم والاستيعاب', 'percentage': 85.0},
          {'mainSkill': 'التطبيق', 'percentage': 75.0},
          {'mainSkill': 'التحليل', 'percentage': 70.0},
        ],
        'wrongAnswers': [],
        'pendingEssayGrading': 0,
      };

  /// التحقق مما إذا كان attemptId يشير إلى وضع demo/mock
  bool get _isDemoAttempt {
    final id = widget.attemptId;
    return AppConstants.useMockData &&
        (id.startsWith('demo-') ||
            id.startsWith('mock') ||
            id.startsWith('local-'));
  }

  Future<void> _loadResult() async {
    // Demo mode: if attemptId starts with 'demo-', 'mock', or 'local-'
    if (_isDemoAttempt) {
      await Future.delayed(
          const Duration(milliseconds: 800)); // simulate loading
      if (!mounted) return;
      setState(() {
        _result = _buildDemoResult(widget.attemptId);
        _isLoading = false;
      });
      _animController.forward();
      return;
    }

    try {
      final data = await ref
          .read(assessmentRepositoryProvider)
          .getResult(widget.attemptId);
      if (!mounted) return;
      setState(() {
        _result = data;
        _isLoading = false;
      });
      _animController.forward();
    } on Exception {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل النتيجة. يرجى المحاولة مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'نتيجة الاختبار',
            style: TextStyle(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () => context.go('/student'),
              child: const Text(
                'الرئيسية',
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE2E8F0)),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                ),
              )
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  )
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

    if (status == 'pending_review') {
      return _buildPendingReviewContent(pendingEssayGrading);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score ring
          AnimatedBuilder(
            animation: _scoreAnim,
            builder: (_, __) => _ScoreRing(
              score: score,
              animValue: _scoreAnim.value,
            ),
          ),
          const SizedBox(height: 20),

          // Achievement badge for >= 90%
          if (score >= 90) ...[
            _AchievementBadge(),
            const SizedBox(height: 16),
          ],

          // Points earned
          _PointsCard(points: points, bonusAwarded: bonusAwarded),
          const SizedBox(height: 24),

          // Skill breakdown
          if (skillBreakdown.isNotEmpty) ...[
            const _SectionHeader(title: 'تحليل المهارات'),
            const SizedBox(height: 12),
            _SkillBreakdownCard(skills: skillBreakdown),
            const SizedBox(height: 24),
          ],

          // Wrong answers
          if (wrongAnswers.isNotEmpty) ...[
            const _SectionHeader(title: 'الأسئلة الخاطئة'),
            const SizedBox(height: 12),
            ...wrongAnswers.map((a) => _WrongAnswerCard(answer: a)),
          ],
        ],
      ),
    );
  }

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
              const Text(
                'في انتظار المراجعة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'تم تسليم اختبارك بنجاح. يحتوي على '
                '${pendingCount > 0 ? pendingCount : 'بعض'} '
                'أسئلة مقالية تحتاج إلى مراجعة يدوية من المعلم.\n\n'
                'ستصلك إشعاراً عند اكتمال التصحيح.',
                style: const TextStyle(
                  fontSize: 14,
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
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryContainer,
                  side: const BorderSide(color: AppColors.primaryContainer),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Score Ring ───────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.animValue});
  final double score;
  final double animValue;

  @override
  Widget build(BuildContext context) {
    final isGood = score >= 70;
    final ringColor = isGood ? AppColors.success : AppColors.error;
    final bgColor =
        isGood ? AppColors.successContainer : AppColors.errorContainer;
    final label = score >= 90
        ? 'ممتاز'
        : score >= 70
            ? 'جيد'
            : 'يحتاج تحسين';

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: score / 100 * animValue,
                      ringColor: ringColor,
                      bgColor: bgColor,
                      strokeWidth: 12,
                    ),
                  ),
                ),
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(score * animValue).round()}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: ringColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ringColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.bgColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color ringColor;
  final Color bgColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.ringColor != ringColor;
}

// ─── Achievement Badge ────────────────────────────────────────────────────────

class _AchievementBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_rounded,
                color: Color(0xFFD97706), size: 28),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إنجاز رائع!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  'حصلت على شارة التميز',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

// ─── Points Card ──────────────────────────────────────────────────────────────

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points, required this.bonusAwarded});
  final int points;
  final bool bonusAwarded;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded,
                color: AppColors.pointsGold, size: 28),
            const SizedBox(width: 8),
            Text(
              '+$points نقطة',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.pointsGold,
              ),
            ),
            if (bonusAwarded) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.pointsGold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '+${AppConstants.bonusPoints} مكافأة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      );
}

// ─── Skill Breakdown Card ─────────────────────────────────────────────────────

class _SkillBreakdownCard extends StatelessWidget {
  const _SkillBreakdownCard({required this.skills});
  final List<Map<String, dynamic>> skills;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
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
          children: skills
              .map((s) => _SkillRow(skill: s, isLast: s == skills.last))
              .toList(),
        ),
      );
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill, required this.isLast});
  final Map<String, dynamic> skill;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final pct = (skill['percentage'] as num?)?.toDouble() ?? 0;
    final isStrength = pct >= AppConstants.strengthThreshold;
    final color = isStrength ? AppColors.success : AppColors.error;
    final bgColor =
        isStrength ? AppColors.successContainer : AppColors.errorContainer;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Skill icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  isStrength
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          skill['mainSkill'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            // Strength/weakness badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isStrength ? 'نقطة قوة' : 'يحتاج تحسين',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${pct.round()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: AppColors.surfaceContainer,
                        color: color,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Wrong Answer Card ────────────────────────────────────────────────────────

class _WrongAnswerCard extends StatelessWidget {
  const _WrongAnswerCard({required this.answer});
  final Map<String, dynamic> answer;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question text
              Text(
                answer['questionText'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              // Divider
              const Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: 10),
              // Your answer
              _AnswerRow(
                icon: Icons.close_rounded,
                label: 'إجابتك',
                value: answer['selectedAnswer'] as String? ?? '',
                color: AppColors.error,
                bgColor: AppColors.errorContainer,
              ),
              const SizedBox(height: 8),
              // Correct answer
              _AnswerRow(
                icon: Icons.check_rounded,
                label: 'الإجابة الصحيحة',
                value: answer['correctAnswer'] as String? ?? '',
                color: AppColors.success,
                bgColor: AppColors.successContainer,
              ),
            ],
          ),
        ),
      );
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
