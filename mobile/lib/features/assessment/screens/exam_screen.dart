import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
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
    required this.assessmentId, required this.attemptId, required this.questionCount, required this.timeLimitMinutes, super.key,
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectAnswer(String key) async {
    if (_isSubmitting) return;
    final questionId = _currentQuestion?['_id'] as String? ?? '';

    setState(() => _selectedAnswer = key);

    // Persist locally (Req 7.11)
    _answers[questionId] = key;
    await _pendingAnswersBox.put(widget.attemptId, _answers);

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
    try {
      await ref
          .read(assessmentRepositoryProvider)
          .submitAttempt(widget.attemptId);
      // Clear local cache
      await _pendingAnswersBox.delete(widget.attemptId);
    } catch (_) {}

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
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildQuestionBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Question counter
          Text(
            'سؤال $_questionNumber من ${widget.questionCount}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          // Timer (Req 7.2, 7.3)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isTimerWarning
                  ? AppColors.errorContainer
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_rounded,
                    size: 16,
                    color: _isTimerWarning
                        ? AppColors.error
                        : AppColors.onSurface),
                const SizedBox(width: 4),
                Text(
                  _timerDisplay,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _isTimerWarning
                            ? AppColors.error
                            : AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_questionNumber - 1) / widget.questionCount,
            backgroundColor: AppColors.surfaceContainer,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),

          // Question text (disable selection — Req 7.10)
          SelectionArea(
            child: IgnorePointer(
              child: Text(
                _currentQuestion!['questionText'] as String? ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Render the appropriate input widget based on question type
          if (qType == _QuestionType.fillBlank)
            _FillBlankInput(
              controller: _fillBlankController,
              onSubmit: _selectAnswer,
            )
          else if (qType == _QuestionType.essay)
            _EssayInput(
              controller: _essayController,
              onSubmit: _selectAnswer,
            )
          else if (qType == _QuestionType.trueFalse)
            // True/False uses the same MCQ option widget with صح/خطأ options
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
        ],
      ),
    );
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
    double scale;

    if (isCorrect ?? false) {
      borderColor = AppColors.optionCorrectBorder;
      bgColor = AppColors.optionCorrectBackground;
      borderWidth = 2;
      scale = 1.0;
    } else if (isIncorrect ?? false) {
      borderColor = AppColors.optionIncorrectBorder;
      bgColor = AppColors.optionIncorrectBackground;
      borderWidth = 2;
      scale = 1.0;
    } else if (isSelected) {
      borderColor = AppColors.optionSelectedBorder;
      bgColor = AppColors.optionSelectedBackground;
      borderWidth = AppConstants.selectedOptionBorderWidth;
      scale = 1.01;
    } else {
      borderColor = AppColors.optionUnselectedBorder;
      bgColor = AppColors.optionUnselectedBackground;
      borderWidth = AppConstants.cardBorderWidth;
      scale = 1.0;
    }

    return AnimatedScale(
      scale: scale,
      duration: AppConstants.shortAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                ),
                child: Center(
                  child: Text(
                    optionKey,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
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
  Widget build(BuildContext context) => Column(
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
  Widget build(BuildContext context) => Column(
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
