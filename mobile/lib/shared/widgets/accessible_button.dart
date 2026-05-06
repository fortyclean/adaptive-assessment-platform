import 'package:flutter/material.dart';

/// Accessible button wrapper that ensures WCAG 2.1 Level AA compliance.
/// Requirements: 12.6
///
/// - Minimum touch target: 44x44 dp
/// - Semantic label for screen readers
/// - Sufficient color contrast (primary #00288E on white = 8.59:1 ratio)
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    required this.label, required this.onPressed, super.key,
    this.semanticLabel,
    this.icon,
    this.isLoading = false,
    this.variant = AccessibleButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final IconData? icon;
  final bool isLoading;
  final AccessibleButtonVariant variant;

  @override
  Widget build(BuildContext context) => Semantics(
      label: semanticLabel ?? label,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: _buildButton(context),
    );

  Widget _buildButton(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    switch (variant) {
      case AccessibleButtonVariant.primary:
        return ElevatedButton(
          onPressed: (onPressed != null && !isLoading) ? onPressed : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          child: child,
        );
      case AccessibleButtonVariant.outlined:
        return OutlinedButton(
          onPressed: (onPressed != null && !isLoading) ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          child: child,
        );
      case AccessibleButtonVariant.text:
        return TextButton(
          onPressed: (onPressed != null && !isLoading) ? onPressed : null,
          child: child,
        );
    }
  }
}

enum AccessibleButtonVariant { primary, outlined, text }

/// Accessible icon button with minimum 44x44 touch target.
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    required this.icon, required this.onPressed, required this.tooltip, super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Semantics(
      label: tooltip,
      button: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          tooltip: tooltip,
          padding: EdgeInsets.zero,
        ),
      ),
    );
}

/// Accessible form field with proper labeling.
class AccessibleTextField extends StatelessWidget {
  const AccessibleTextField({
    required this.label, super.key,
    this.hint,
    this.controller,
    this.validator,
    this.onSaved,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.textDirection,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) => Semantics(
      label: label,
      textField: true,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textDirection: textDirection,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
}
