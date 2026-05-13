import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Widget to display a question image above the question text.
/// Requirements: 17.3, 17.5, 17.6
///
/// - Renders image scaled to screen width without distortion
/// - Shows alt-text placeholder on image load failure
/// - Logs image load failures without interrupting the session
class QuestionImage extends StatelessWidget {
  const QuestionImage({
    required this.imageUrl,
    super.key,
    this.altText = 'صورة السؤال',
  });

  final String imageUrl;
  final String altText;

  @override
  Widget build(BuildContext context) => Semantics(
        label: altText,
        image: true,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 240),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 120,
                  color: AppColors.surfaceContainer,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Req 17.6: log failure without interrupting session
                debugPrint('QuestionImage load failed: $error');
                return _buildPlaceholder(context);
              },
            ),
          ),
        ),
      );

  Widget _buildPlaceholder(BuildContext context) => Container(
        height: 80,
        color: AppColors.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined,
                color: AppColors.onSurfaceVariant, size: 24),
            const SizedBox(width: 8),
            Text(
              altText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
}
