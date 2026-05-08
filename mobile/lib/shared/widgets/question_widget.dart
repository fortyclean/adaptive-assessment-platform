import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'mcq_option.dart';
import 'question_image.dart';

/// Unified question widget that renders the correct UI based on question type.
/// Requirements: 18.1, 18.2, 18.3, 18.4, 18.7
///
/// Supported types:
///   - mcq         → 4 MCQ options (existing)
///   - true_false  → True/False buttons (Req 18.1)
///   - fill_blank  → Text input field (Req 18.2, 18.3)
///   - essay       → Multi-line text area (Req 18.4)
class QuestionWidget extends StatelessWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.isDisabled = false,
    this.showCorrectAnswer = false,
  });

  final Map<String, dynamic> question;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;
  final bool isDisabled;
  final bool showCorrectAnswer;

  String get _questionType => question['questionType'] as String? ?? 'mcq';
  String get _questionText => question['questionText'] as String? ?? '';
  String? get _imageUrl => question['imageUrl'] as String?;
  String get _correctAnswer => question['correctAnswer'] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image (if present)
        if (_imageUrl != null && _imageUrl!.isNotEmpty)
          QuestionImage(imageUrl: _imageUrl!),

        // Question text
        Text(
          _questionText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
        ),

        const SizedBox(height: 20),

        // Answer input based on type
        switch (_questionType) {
          'true_false' => _TrueFalseWidget(
              selectedAnswer: selectedAnswer,
              correctAnswer: showCorrectAnswer ? _correctAnswer : null,
              onSelected: onAnswerSelected,
              isDisabled: isDisabled,
            ),
          'fill_blank' => _FillBlankWidget(
              selectedAnswer: selectedAnswer,
              onChanged: onAnswerSelected,
              isDisabled: isDisabled,
            ),
          'essay' => _EssayWidget(
              selectedAnswer: selectedAnswer,
              onChanged: onAnswerSelected,
              isDisabled: isDisabled,
            ),
          _ => _McqWidget(
              options: (question['options'] as List?)
                      ?.cast<Map<String, dynamic>>() ??
                  [],
              selectedAnswer: selectedAnswer,
              correctAnswer: showCorrectAnswer ? _correctAnswer : null,
              onSelected: onAnswerSelected,
              isDisabled: isDisabled,
            ),
        },
      ],
    );
  }
}

// ─── MCQ Widget ───────────────────────────────────────────────────────────────

class _McqWidget extends StatelessWidget {
  const _McqWidget({
    required this.options,
    required this.selectedAnswer,
    required this.onSelected,
    this.correctAnswer,
    this.isDisabled = false,
  });

  final List<Map<String, dynamic>> options;
  final String? selectedAnswer;
  final String? correctAnswer;
  final ValueChanged<String> onSelected;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final key = opt['key'] as String;
        final isSelected = selectedAnswer == key;
        final isCorrect = correctAnswer != null && key == correctAnswer;
        final isIncorrect = correctAnswer != null && isSelected && key != correctAnswer;

        return McqOption(
          optionKey: key,
          value: opt['value'] as String? ?? '',
          isSelected: isSelected,
          onTap: () => onSelected(key),
          isCorrect: isCorrect ? true : null,
          isIncorrect: isIncorrect ? true : null,
          isDisabled: isDisabled,
        );
      }).toList(),
    );
  }
}

// ─── True/False Widget (Req 18.1) ─────────────────────────────────────────────

class _TrueFalseWidget extends StatelessWidget {
  const _TrueFalseWidget({
    required this.selectedAnswer,
    required this.onSelected,
    this.correctAnswer,
    this.isDisabled = false,
  });

  final String? selectedAnswer;
  final String? correctAnswer;
  final ValueChanged<String> onSelected;
  final bool isDisabled;

  Color _getColor(String value) {
    if (correctAnswer != null) {
      if (value == correctAnswer) return AppColors.success;
      if (value == selectedAnswer && value != correctAnswer) return AppColors.error;
    }
    if (selectedAnswer == value) return AppColors.primary;
    return AppColors.outlineVariant;
  }

  Color _getBgColor(String value) {
    if (correctAnswer != null) {
      if (value == correctAnswer) return AppColors.successContainer;
      if (value == selectedAnswer && value != correctAnswer) return AppColors.errorContainer;
    }
    if (selectedAnswer == value) return AppColors.onPrimaryContainer;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _TFButton(
          label: 'صحيح',
          icon: Icons.check_circle_outline_rounded,
          value: 'true',
          borderColor: _getColor('true'),
          bgColor: _getBgColor('true'),
          onTap: isDisabled ? null : () => onSelected('true'),
        )),
        const SizedBox(width: 16),
        Expanded(child: _TFButton(
          label: 'خطأ',
          icon: Icons.cancel_outlined,
          value: 'false',
          borderColor: _getColor('false'),
          bgColor: _getBgColor('false'),
          onTap: isDisabled ? null : () => onSelected('false'),
        )),
      ],
    );
  }
}

class _TFButton extends StatelessWidget {
  const _TFButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.borderColor,
    required this.bgColor,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final Color borderColor;
  final Color bgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: borderColor, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: borderColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Fill-in-the-Blank Widget (Req 18.2, 18.3) ───────────────────────────────

class _FillBlankWidget extends StatefulWidget {
  const _FillBlankWidget({
    required this.selectedAnswer,
    required this.onChanged,
    this.isDisabled = false,
  });

  final String? selectedAnswer;
  final ValueChanged<String> onChanged;
  final bool isDisabled;

  @override
  State<_FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<_FillBlankWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedAnswer ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'أدخل إجابتك',
      textField: true,
      child: TextField(
        controller: _controller,
        enabled: !widget.isDisabled,
        decoration: InputDecoration(
          hintText: 'اكتب إجابتك هنا...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: widget.onChanged,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

// ─── Essay Widget (Req 18.4) ──────────────────────────────────────────────────

class _EssayWidget extends StatefulWidget {
  const _EssayWidget({
    required this.selectedAnswer,
    required this.onChanged,
    this.isDisabled = false,
  });

  final String? selectedAnswer;
  final ValueChanged<String> onChanged;
  final bool isDisabled;

  @override
  State<_EssayWidget> createState() => _EssayWidgetState();
}

class _EssayWidgetState extends State<_EssayWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedAnswer ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'هذا السؤال يتطلب مراجعة يدوية من المعلم',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: 'اكتب إجابتك المقالية',
          textField: true,
          child: TextField(
            controller: _controller,
            enabled: !widget.isDisabled,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'اكتب إجابتك هنا...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: widget.onChanged,
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }
}
