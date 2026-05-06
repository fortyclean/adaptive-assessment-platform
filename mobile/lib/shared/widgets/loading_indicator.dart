import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A centered circular loading indicator.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 40.0,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 3,
          ),
        ),
      );
}

/// A full-screen loading overlay.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading, required this.child, super.key,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          child,
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const LoadingIndicator(),
            ),
        ],
      );
}
