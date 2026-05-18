import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.borderColor,
  });

  final AuthUser? user;
  final double size;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = user?.avatarUrl?.trim();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: borderColor ?? colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => _Initials(user: user, size: size),
              errorWidget: (_, __, ___) => _Initials(user: user, size: size),
            )
          : _Initials(user: user, size: size),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.user, required this.size});

  final AuthUser? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        _initials(user?.fullName),
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          fontFamily: 'Almarai',
        ),
      ),
    );
  }

  String _initials(String? name) {
    final normalized = name?.trim();
    if (normalized == null || normalized.isEmpty) return '؟';
    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts.first[0];
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _GoogleMarkPainter()),
      );
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    void arc(Color color, double start, double sweep) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(arcRect, start, sweep, false, paint);
    }

    arc(const Color(0xFF4285F4), -0.12, 1.35);
    arc(const Color(0xFF34A853), 1.25, 1.12);
    arc(const Color(0xFFFBBC05), 2.35, 1.05);
    arc(const Color(0xFFEA4335), 3.38, 1.75);

    final blue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square
      ..color = const Color(0xFF4285F4);
    final y = size.height * 0.52;
    canvas.drawLine(Offset(size.width * 0.52, y), Offset(size.width, y), blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
