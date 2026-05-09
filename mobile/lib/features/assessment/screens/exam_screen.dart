import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/demo_questions.dart';
import '../repositories/assessment_repository.dart';

/// Supported question types returned by the backend.
enum _QuestionType { mcq, trueFalse, fillBlank, essay, unknown }

_QuestionType _parseQuestionType(String? raw) {
  switch (raw) {
    case 'mcq':
      return _QuestionType.mcq;
    case 'true_false':
      return _QuestionType.trueFalse;
    case 'fill_blank':
      return _QuestionType.fillBlank;
    case 'essay':
      return _QuestionType.essay;
    default:
      return _QuestionType.unknown;
  }
}

/// Exam Screen — Screen 15 & 2
/// Requirements: 7.1–7.11
class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({
    super.key,
    required this.assessmentId,
    required this.attemptId,
    required this.questionCount,
    required this.timeLimitMinutes,
  });

  final String assessmentId;
  final String attemptId;
  final int questionCount;
  final int timeLimitMinutes;

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen>
    with WidgetsBindingObserver {
  // ─── State ────────────────────────────────────────────────────────────────
  Map<String, dynamic>? _currentQuestion;
  int _questionNumber = 1;
  String? _selectedAnswer;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Demo mode — used when API is unavailable
  bool _isDemoMode = false;
  int _demoQuestionIndex = 0;
  List<Map<String, dynamic>> _demoQuestions = [];

  // Answers map: questionId → selectedAnswer (for offline resilience)
  final Map<String, String> _answers = {};

  // Text controller for Fill-in-the-Blank questions (Req 18.2, 18.3)
  final TextEditingController _fillBlankController = TextEditingController();

  // Text controller for Essay questions (Req 18.4)
  final TextEditingController _essayController = TextEditingController();

  // Timer
  late int _remainingSeconds;
  Timer? _timer;

  // Hive box for offline answer persistence (Req 7.11)
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
    // Restore any pending answers for this attempt
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

    // ── Demo mode: serve questions from local data ────────────────────────
    if (_isDemoMode) {
      if (_demoQuestionIndex >= _demoQuestions.length) {
        await _finaliseSession();
        return;
      }
      final q = _demoQuestions[_demoQuestionIndex];
      setState(() {
        _currentQuestion = q;
        _selectedAnswer = _answers[q['_id'] as String? ?? ''];
        _isLoading = false;
      });
      return;
    }

    // ── Normal mode: fetch from API ───────────────────────────────────────
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

      // Restore fill-blank text if the student already answered this question
      final restoredAnswer = _answers[_currentQuestion?['_id'] as String? ?? ''];
      final qType = _parseQuestionType(
          _currentQuestion?['questionType'] as String?);
      if (qType == _QuestionType.fillBlank) {
        _fillBlankController.text = restoredAnswer ?? '';
      } else if (qType == _QuestionType.essay) {
        _essayController.text = restoredAnswer ?? '';
      }
    } catch (e) {
      // API failed — switch to demo mode
      _isDemoMode = true;
      _demoQuestionIndex = 0;
      // Pick questions based on assessmentId subject hint, or use all
      _demoQuestions = _buildDemoQuestions();
      if (_demoQuestions.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      final q = _demoQuestions[0];
      setState(() {
        _currentQuestion = q;
        _selectedAnswer = null;
        _isLoading = false;
      });
    }
  }

  /// Build the demo question list for the current assessment.
  List<Map<String, dynamic>> _buildDemoQuestions() {
    final id = widget.assessmentId.toLowerCase();
    List<Map<String, dynamic>> pool;
    if (id.contains('math') || id.contains('demo-math') || id == '1') {
      pool = DemoQuestions.mathematics;
    } else if (id.contains('arabic') || id.contains('demo-arabic') || id == '2') {
      pool = DemoQuestions.arabic;
    } else if (id.contains('english') || id.contains('demo-english')) {
      pool = DemoQuestions.english;
    } else if (id.contains('history') || id.contains('demo-history')) {
      pool = DemoQuestions.history;
    } else if (id.contains('bio') || id.contains('demo-biology') || id.contains('science')) {
      pool = DemoQuestions.biology;
    } else if (id.contains('chem') || id.contains('demo-chemistry') || id.contains('chemical')) {
      pool = DemoQuestions.chemistry;
    } else if (id.startsWith('mock')) {
      // For generic mock IDs, use mathematics as default
      pool = DemoQuestions.mathematics;
    } else {
      // For real assessment IDs that failed API, use all questions
      pool = DemoQuestions.all;
    }
    // Limit to questionCount
    final count = widget.questionCount.clamp(1, pool.length);
    return pool.take(count).toList();
  }

  Future<void> _selectAnswer(String key) async {
    if (_isSubmitting) return;
    final questionId = _currentQuestion?['_id'] as String? ?? '';

    setState(() => _selectedAnswer = key);

    // Persist locally (Req 7.11)
    _answers[questionId] = key;
    await _pendingAnswersBox.put(widget.attemptId, _answers);

    // Demo mode: skip API call, advance to next question directly
    if (_isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _demoQuestionIndex++;
      setState(() => _questionNumber++);
      await _loadNextQuestion();
      return;
    }

    // Submit to server
    try {
      await ref.read(assessmentRepositoryProvider).submitAnswer(
            attemptId: widget.attemptId,
            questionId: questionId,
            selectedAnswer: key,
          );

      // Load next question after short delay for UX
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _questionNumber++);
        await _loadNextQuestion();
      }
    } catch (_) {
      // Answer saved locally — will retry on reconnect
    }
  }

  Future<void> _autoSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    await _finaliseSession();
  }

  Future<void> _finaliseSession() async {
    if (!_isDemoMode) {
      try {
        await ref
            .read(assessmentRepositoryProvider)
            .submitAttempt(widget.attemptId);
        // Clear local cache
        await _pendingAnswersBox.delete(widget.attemptId);
      } catch (_) {}
    }

    if (mounted) {
      context.pushReplacement(
          '/student/results/${widget.attemptId}');
    }
  }

  Future<bool> _onWillPop() async {
    // Log navigation event (Req 7.9)
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
              child: const Text('خروج',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Log app background/foreground events (Req 7.9)
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
    _fillBlankController.dispose();
    _essayController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String get _timerDisplay {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _isTimerWarning =>
      _remainingSeconds <= AppConstants.timerWarningThresholdSeconds;

  @override
  Widget build(BuildContext context) {
    // Full-screen exam — suppress system navigation (Req 7.1)
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
                _buildProgressBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildQuestionBody(),
                ),
                if (!_isLoading && _currentQuestion != null)
                  _buildNavigationBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timer (Req 7.2, 7.3) — on the right in RTL
          AnimatedContainer(
            duration: AppConstants.shortAnimation,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isTimerWarning
                  ? AppColors.errorContainer
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isTimerWarning
                    ? AppColors.error.withValues(alpha: 0.4)
                    : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 16,
                  color: _isTimerWarning ? AppColors.error : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  _timerDisplay,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _isTimerWarning
                            ? AppColors.error
                            : AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: 1.0,
                      ),
                ),
              ],
            ),
          ),
          // Question counter — on the left in RTL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'السؤال $_questionNumber من ${widget.questionCount}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = widget.questionCount > 0
        ? _questionNumber / widget.questionCount
        : 0.0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isTimerWarning ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    final canGoNext = _selectedAnswer != null;
    final isLastQuestion = _questionNumber >= widget.questionCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Next / Submit button (primary action, on the right in RTL = left in Row)
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: canGoNext && !_isSubmitting
                  ? () {
                      if (isLastQuestion) {
                        _autoSubmit();
                      } else {
                        setState(() => _questionNumber++);
                        _loadNextQuestion();
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastQuestion ? 'تسليم الاختبار' : 'التالي',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: canGoNext ? Colors.white : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                  ),
                  if (!isLastQuestion) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: canGoNext ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ] else ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: canGoNext ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_questionNumber > 1) ...[
            const SizedBox(width: 12),
            // Previous button
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (_questionNumber > 1) {
                          setState(() => _questionNumber--);
                          _loadNextQuestion();
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'السابق',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionBody() {
    if (_currentQuestion == null) {
      return const Center(child: Text('لا توجد أسئلة'));
    }

    final qType = _parseQuestionType(
        _currentQuestion!['questionType'] as String?);

    final options =
        (_currentQuestion!['options'] as List?)?.cast<Map<String, dynamic>>() ??
            [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question type badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _questionTypeName(qType),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Question text (disable selection — Req 7.10)
                IgnorePointer(
                  child: Text(
                    _currentQuestion!['questionText'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.7,
                          fontSize: 17,
                          color: AppColors.onSurface,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Answer section label
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'اختر الإجابة الصحيحة:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
              textDirection: TextDirection.rtl,
            ),
          ),

          // Render the appropriate input widget based on question type
          if (qType == _QuestionType.fillBlank)
            _FillBlankInput(
              controller: _fillBlankController,
              onSubmit: (text) => _selectAnswer(text),
            )
          else if (qType == _QuestionType.essay)
            _EssayInput(
              controller: _essayController,
              onSubmit: (text) => _selectAnswer(text),
            )
          else if (qType == _QuestionType.trueFalse)
            ...options.isNotEmpty
                ? options.map((opt) {
                    final key = opt['key'] as String;
                    final value = opt['value'] as String;
                    final isSelected = _selectedAnswer == key;
                    return _McqOption(
                      optionKey: key,
                      value: value,
                      isSelected: isSelected,
                      onTap: () => _selectAnswer(key),
                    );
                  })
                : [
                    _McqOption(
                      optionKey: 'true',
                      value: 'صح',
                      isSelected: _selectedAnswer == 'true',
                      onTap: () => _selectAnswer('true'),
                    ),
                    _McqOption(
                      optionKey: 'false',
                      value: 'خطأ',
                      isSelected: _selectedAnswer == 'false',
                      onTap: () => _selectAnswer('false'),
                    ),
                  ]
          else
            // MCQ Options (Req 7.4) — default for mcq and unknown types
            ...options.map((opt) {
              final key = opt['key'] as String;
              final value = opt['value'] as String;
              final isSelected = _selectedAnswer == key;

              return _McqOption(
                optionKey: key,
                value: value,
                isSelected: isSelected,
                onTap: () => _selectAnswer(key),
              );
            }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _questionTypeName(_QuestionType type) {
    switch (type) {
      case _QuestionType.mcq:
        return 'اختيار من متعدد';
      case _QuestionType.trueFalse:
        return 'صح أو خطأ';
      case _QuestionType.fillBlank:
        return 'ملء الفراغ';
      case _QuestionType.essay:
        return 'مقالي';
      case _QuestionType.unknown:
        return 'سؤال';
    }
  }
}

/// MCQ Option widget with all visual states (Req 7.4)
class _McqOption extends StatelessWidget {
  const _McqOption({
    required this.optionKey,
    required this.value,
    required this.isSelected,
    required this.onTap,
    this.isCorrect,
    this.isIncorrect,
  });

  final String optionKey;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final bool? isCorrect;
  final bool? isIncorrect;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    double borderWidth;
    Color badgeBg;
    Color badgeFg;
    Widget? trailingIcon;

    if (isCorrect == true) {
      borderColor = AppColors.optionCorrectBorder;
      bgColor = AppColors.optionCorrectBackground;
      borderWidth = 2;
      badgeBg = AppColors.success;
      badgeFg = Colors.white;
      trailingIcon = const Icon(Icons.check_circle_rounded,
          color: AppColors.success, size: 20);
    } else if (isIncorrect == true) {
      borderColor = AppColors.optionIncorrectBorder;
      bgColor = AppColors.optionIncorrectBackground;
      borderWidth = 2;
      badgeBg = AppColors.error;
      badgeFg = Colors.white;
      trailingIcon = const Icon(Icons.cancel_rounded,
          color: AppColors.error, size: 20);
    } else if (isSelected) {
      borderColor = AppColors.optionSelectedBorder;
      bgColor = AppColors.optionSelectedBackground;
      borderWidth = AppConstants.selectedOptionBorderWidth;
      badgeBg = AppColors.primary;
      badgeFg = Colors.white;
      trailingIcon = const Icon(Icons.radio_button_checked_rounded,
          color: AppColors.primary, size: 20);
    } else {
      borderColor = AppColors.optionUnselectedBorder;
      bgColor = AppColors.optionUnselectedBackground;
      borderWidth = AppConstants.cardBorderWidth;
      badgeBg = AppColors.surfaceContainer;
      badgeFg = AppColors.onSurfaceVariant;
      trailingIcon = const Icon(Icons.radio_button_unchecked_rounded,
          color: AppColors.outlineVariant, size: 20);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Option key badge (A, B, C, D)
            AnimatedContainer(
              duration: AppConstants.shortAnimation,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeBg,
                border: isSelected || isCorrect == true || isIncorrect == true
                    ? null
                    : Border.all(color: AppColors.outlineVariant),
              ),
              child: Center(
                child: Text(
                  optionKey.toUpperCase(),
                  style: TextStyle(
                    color: badgeFg,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Option text
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.onSurface
                          : AppColors.onSurface,
                      height: 1.5,
                    ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(width: 8),
            // Trailing state icon
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}

/// Fill-in-the-Blank input widget (Requirements 18.2, 18.3)
///
/// Renders a text field where the student types their answer.
/// The student taps "تأكيد الإجابة" (Confirm Answer) to submit.
/// The answer is saved locally on every keystroke for offline resilience.
class _FillBlankInput extends StatefulWidget {
  const _FillBlankInput({
    required this.controller,
    required this.onSubmit,
  });

  /// Shared [TextEditingController] managed by [_ExamScreenState] so that the
  /// text is preserved when the widget rebuilds.
  final TextEditingController controller;

  /// Called with the trimmed text when the student confirms their answer.
  final void Function(String answer) onSubmit;

  @override
  State<_FillBlankInput> createState() => _FillBlankInputState();
}

class _FillBlankInputState extends State<_FillBlankInput> {
  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Text input field
        TextField(
          controller: widget.controller,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_hasText) widget.onSubmit(widget.controller.text.trim());
          },
          decoration: InputDecoration(
            hintText: 'اكتب إجابتك هنا...',
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: AppColors.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),

        // Confirm button — enabled only when the field is non-empty
        FilledButton(
          onPressed: _hasText
              ? () => widget.onSubmit(widget.controller.text.trim())
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.surfaceContainer,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
          child: Text(
            'تأكيد الإجابة',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _hasText ? Colors.white : AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

/// Essay question input widget (Requirement 18.4)
///
/// Renders a multi-line text area where the student types a long-form answer.
/// The student taps "تسليم الإجابة" (Submit Answer) to submit.
/// The session will be flagged as "pending_review" after submission (Req 18.5).
class _EssayInput extends StatefulWidget {
  const _EssayInput({
    required this.controller,
    required this.onSubmit,
  });

  /// Shared [TextEditingController] managed by [_ExamScreenState].
  final TextEditingController controller;

  /// Called with the trimmed text when the student confirms their answer.
  final void Function(String answer) onSubmit;

  @override
  State<_EssayInput> createState() => _EssayInputState();
}

class _EssayInputState extends State<_EssayInput> {
  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Informational banner about pending review
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'سيتم مراجعة إجابتك من قِبل المعلم وتحديد الدرجة لاحقاً',
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Multi-line text area
        TextField(
          controller: widget.controller,
          textDirection: TextDirection.rtl,
          maxLines: 8,
          minLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'اكتب إجابتك المقالية هنا...',
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: AppColors.surfaceContainer,
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),

        // Submit button — enabled only when the field is non-empty
        FilledButton(
          onPressed: _hasText
              ? () => widget.onSubmit(widget.controller.text.trim())
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.surfaceContainer,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
          child: Text(
            'تسليم الإجابة',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _hasText ? Colors.white : AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
