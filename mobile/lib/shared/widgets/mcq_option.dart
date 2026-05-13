import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// MCQ Option Widget with all visual states.
/// Requirements: 7.4
///
/// States:
///   - Unselected: 1px border, white background
///   - Selected: 2px #00288E border, #DDE1FF background, 1.01x scale
///   - Correct (post-session): #D1FAE5 background, #047857 border
///   - Incorrect (post-session): #FEE2E2 background, #BA1A1A border
class McqOption extends StatelessWidget {
  const McqOption({
    required this.optionKey,
    required this.value,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.isCorrect,
    this.isIncorrect,
    this.isDisabled = false,
  });

  final String optionKey;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  /// Set to true after session ends to show correct answer highlight
  final bool? isCorrect;

  /// Set to true after session ends to show incorrect answer highlight
  final bool? isIncorrect;

  /// Disable interaction (e.g., after session ends)
  final bool isDisabled;

  Color get _borderColor {
    if (isCorrect ?? false) return AppColors.optionCorrectBorder;
    if (isIncorrect ?? false) return AppColors.optionIncorrectBorder;
    if (isSelected) return AppColors.optionSelectedBorder;
    return AppColors.optionUnselectedBorder;
  }

  Color get _backgroundColor {
    if (isCorrect ?? false) return AppColors.optionCorrectBackground;
    if (isIncorrect ?? false) return AppColors.optionIncorrectBackground;
    if (isSelected) return AppColors.optionSelectedBackground;
    return AppColors.optionUnselectedBackground;
  }

  double get _borderWidth {
    if ((isCorrect ?? false) || (isIncorrect ?? false)) return 2;
    if (isSelected) return AppConstants.selectedOptionBorderWidth;
    return AppConstants.cardBorderWidth;
  }

  double get _scale {
    if (isSelected && isCorrect == null && isIncorrect == null) return 1.01;
    return 1;
  }

  Color get _keyCircleColor {
    if (isCorrect ?? false) return AppColors.success;
    if (isIncorrect ?? false) return AppColors.error;
    if (isSelected) return AppColors.primary;
    return AppColors.surfaceContainer;
  }

  Color get _keyTextColor {
    if ((isCorrect ?? false) || (isIncorrect ?? false) || isSelected) {
      return Colors.white;
    }
    return AppColors.onSurface;
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'الخيار $optionKey: $value',
        button: true,
        selected: isSelected,
        child: AnimatedScale(
          scale: _scale,
          duration: AppConstants.shortAnimation,
          child: GestureDetector(
            onTap: isDisabled ? null : onTap,
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius:
                    BorderRadius.circular(AppConstants.cardBorderRadius),
                border: Border.all(color: _borderColor, width: _borderWidth),
              ),
              child: Row(
                children: [
                  // Option key circle
                  AnimatedContainer(
                    duration: AppConstants.shortAnimation,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _keyCircleColor,
                    ),
                    child: Center(
                      child: Text(
                        optionKey,
                        style: TextStyle(
                          color: _keyTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Option text
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ),

                  // Post-session indicator
                  if (isCorrect ?? false)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20)
                  else if (isIncorrect ?? false)
                    const Icon(Icons.cancel_rounded,
                        color: AppColors.error, size: 20),
                ],
              ),
            ),
          ),
        ),
      );
}
