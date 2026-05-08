import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../repositories/assessment_repository.dart';

/// Exam With Timer Toggle Screen — Design _43
///
/// Variant of the exam screen that adds:
/// - A visibility toggle button next to the timer (show/hide countdown)
/// - A "تحديد للمراجعة" (bookmark/flag) button in the question card
/// - Previous / Next navigation buttons in the footer
/// - Image placeholder in the question card
///
/// Requirements: 7.1–7.11
class ExamWithTimerToggleScreen extends ConsumerStatefulWidget {
  const ExamWithTimerToggleScreen({
    super.key,
    required this.assessmentId,
    required this.attemptId,
    required this.questionCount,
    required this.timeLimitMinutes,
    this.subjectTitle = 'الرياضيات المتقدمة',
  });

  final String assessmentId;
  final String attemptId;
  final int questionCount;
  final int timeLimitMinutes;
  final String subjectTitle;

  @override
  ConsumerState<ExamWithTimerToggleScreen> createState() =>
      _ExamWithTimerToggleScreenState();
}

class _ExamWithTimerToggleScreenState
    extends ConsumerState<ExamWithTimerToggleScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? _currentQuestion;
  int _questionNumber = 1;
  String? _selectedAnswer;
  bool _isLoading = true;
  bool _isSubmitting = false;
  final Map<String, String> _answers = {};
  final Set<String> _flaggedQuestions = {};

  // Timer state
  late int _remainingSeconds;
  Timer? _timer;
  bool _isTimerVisible = true; // Toggle state

  late Box<dynamic> _pendingAnswersBox;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingSeconds = widget.timeLimitMinutes * 60;
    _initHive();
    _startTimer();
    _loadNextQuestion();
  }

  Future<void> _initHive() async {
    _pendingAnswersBox =
        Hive.box<dynamic>(AppConstants.pendingAnswersBoxName);
    final saved = _pendingAnswersBox.get(widget.attemptId);
    if (saved is Map) {
      _answers.addAll(Map<String, String>.from(saved));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _autoSubmit();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _loadNextQuestion() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref
          .read(assessmentRepositoryProvider)
          .getNextQuestion(widget.attemptId);

      if (data['complete'] == true) {
        await _finaliseSession();
        return;
      }

      setState(() {
        _currentQuestion = data['question'] as Map<String, dynamic>?;
        _questionNumber = data['questionNumber'] as int? ?? _questionNumber;
        _selectedAnswer =
            _answers[_currentQuestion?['_id'] as String? ?? ''];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectAnswer(String key) async {
    if (_isSubmitting) return;
    final questionId = _currentQuestion?['_id'] as String? ?? '';
    setState(() => _selectedAnswer = key);
    _answers[questionId] = key;
    await _pendingAnswersBox.put(widget.attemptId, _answers);

    try {
      await ref.read(assessmentRepositoryProvider).submitAnswer(
            attemptId: widget.attemptId,
            questionId: questionId,
            selectedAnswer: key,
          );
    } catch (_) {}
  }

  void _toggleBookmark() {
    final questionId = _currentQuestion?['_id'] as String? ?? '';
    setState(() {
      if (_flaggedQuestions.contains(questionId)) {
        _flaggedQuestions.remove(questionId);
      } else {
        _flaggedQuestions.add(questionId);
      }
    });
  }

  void _toggleTimerVisibility() {
    setState(() => _isTimerVisible = !_isTimerVisible);
  }

  bool get _isCurrentFlagged {
    final questionId = _currentQuestion?['_id'] as String? ?? '';
    return _flaggedQuestions.contains(questionId);
  }

  Future<void> _goToNext() async {
    if (_isSubmitting) return;
    setState(() => _questionNumber++);
    await _loadNextQuestion();
  }

  Future<void> _goToPrevious() async {
    if (_questionNumber <= 1) return;
    setState(() {
      _questionNumber--;
      _isLoading = false;
    });
  }

  Future<void> _autoSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    await _finaliseSession();
  }

  Future<void> _finaliseSession() async {
    try {
      await ref
          .read(assessmentRepositoryProvider)
          .submitAttempt(widget.attemptId);
      await _pendingAnswersBox.delete(widget.attemptId);
    } catch (_) {}
    if (mounted) {
      context.pushReplacement('/student/results/${widget.attemptId}');
    }
  }

  Future<bool> _onWillPop() async {
    ref.read(assessmentRepositoryProvider).logAntiCheatEvent(
        widget.attemptId, 'back_button_pressed');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الخروج'),
        content: const Text(
            'هل تريد الخروج من الاختبار؟ سيتم حفظ إجاباتك.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('خروج',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(assessmentRepositoryProvider).logAntiCheatEvent(
          widget.attemptId, 'app_backgrounded');
    } else if (state == AppLifecycleState.resumed) {
      ref.read(assessmentRepositoryProvider).logAntiCheatEvent(
          widget.attemptId, 'app_foregrounded');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String get _timerDisplay {
    if (!_isTimerVisible) return '--:--';
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _isTimerWarning =>
      _remainingSeconds <= AppConstants.timerWarningThresholdSeconds;

  double get _progressValue =>
      widget.questionCount > 0
          ? (_questionNumber - 1) / widget.questionCount
          : 0.0;

  int get _progressPercent => (_progressValue * 100).round();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) context.pop();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBody(),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button (RTL: left)
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: const Color(0xFF64748B),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) context.pop();
            },
          ),
          // Timer with toggle (RTL: center)
          _buildTimerWidget(),
          // Subject title (RTL: right)
          Text(
            widget.subjectTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E40AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visibility toggle button
          GestureDetector(
            onTap: _toggleTimerVisibility,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTimerVisible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 16,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Timer icon
          Icon(Icons.timer_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: 4),
          // Timer display
          AnimatedOpacity(
            opacity: _isTimerVisible ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Text(
              _timerDisplay,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    final options =
        (_currentQuestion?['options'] as List?)
            ?.cast<Map<String, dynamic>>() ??
            _mockOptions();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressRow(),
          const SizedBox(height: 16),
          _buildQuestionCard(),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final key = opt['key'] as String;
            final value = opt['value'] as String;
            return _McqOptionTile(
              optionKey: key,
              value: value,
              isSelected: _selectedAnswer == key,
              onTap: () => _selectAnswer(key),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_progressPercent% مكتمل',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              'السؤال $_questionNumber من ${widget.questionCount}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progressValue.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryContainer),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final questionText =
        _currentQuestion?['questionText'] as String? ??
            'إذا كان x + 5 = 12، فما هي قيمة 2x - 4؟';
    final imageUrl = _currentQuestion?['imageUrl'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header: number badge + bookmark + question text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bookmark button (RTL: left)
              _buildBookmarkButton(),
              const SizedBox(width: 8),
              // Question text
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1A1B22),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              // Number badge (RTL: far right)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$_questionNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: _toggleBookmark,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _isCurrentFlagged
              ? const Color(0xFFFFF7ED)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isCurrentFlagged
                ? const Color(0xFFD97706)
                : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCurrentFlagged
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: 18,
              color: _isCurrentFlagged
                  ? const Color(0xFFD97706)
                  : AppColors.outline,
            ),
            const SizedBox(width: 4),
            Text(
              'تحديد للمراجعة',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _isCurrentFlagged
                    ? const Color(0xFFD97706)
                    : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 36, color: AppColors.outline),
          const SizedBox(height: 8),
          Text(
            'صورة توضيحية',
            style: TextStyle(fontSize: 12, color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  // ─── Footer ──────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFC4C5D5), width: 1)),
      ),
      child: Row(
        children: [
          // Previous (RTL: left)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _questionNumber > 1 ? _goToPrevious : null,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('السابق'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                side: const BorderSide(color: Color(0xFFC4C5D5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next (RTL: right)
          Expanded(
            child: FilledButton.icon(
              onPressed: _goToNext,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('التالي'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _mockOptions() => [
        {'key': 'A', 'value': '10'},
        {'key': 'B', 'value': '14'},
        {'key': 'C', 'value': '18'},
        {'key': 'D', 'value': '20'},
      ];
}

// ─── MCQ Option Tile ──────────────────────────────────────────────────────

class _McqOptionTile extends StatelessWidget {
  const _McqOptionTile({
    required this.optionKey,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String optionKey;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E40AF)
                : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Radio indicator (RTL: left)
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF1E40AF), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: 24,
                height: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.outlineVariant, width: 1.5),
                  ),
                ),
              ),
            // Option text + key (RTL: right)
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: const Color(0xFF1A1B22),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$optionKey)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF1E40AF)
                        : AppColors.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
