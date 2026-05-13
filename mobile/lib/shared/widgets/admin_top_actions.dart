import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../providers/auth_provider.dart';

/// Common admin actions shown on every admin-facing screen.
class AdminTopActions extends ConsumerWidget {
  const AdminTopActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      PopupMenuButton<_AdminAction>(
        tooltip: 'حساب المشرف',
        icon:
            const Icon(Icons.account_circle_outlined, color: AppColors.primary),
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _AdminAction.home,
            child: _AdminMenuItem(icon: Icons.home_outlined, label: 'الرئيسية'),
          ),
          PopupMenuItem(
            value: _AdminAction.settings,
            child: _AdminMenuItem(
              icon: Icons.settings_outlined,
              label: 'الإعدادات',
            ),
          ),
          PopupMenuItem(
            value: _AdminAction.about,
            child:
                _AdminMenuItem(icon: Icons.info_outline, label: 'عن التطبيق'),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: _AdminAction.logout,
            child: _AdminMenuItem(
              icon: Icons.logout_rounded,
              label: 'تسجيل الخروج',
              color: AppColors.error,
            ),
          ),
        ],
      );

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _AdminAction action,
  ) async {
    switch (action) {
      case _AdminAction.home:
        context.go(AppRoutes.adminDashboard);
      case _AdminAction.settings:
        context.go(AppRoutes.institutionSettings);
      case _AdminAction.about:
        await context.push(AppRoutes.about);
      case _AdminAction.logout:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('تسجيل الخروج'),
            content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'خروج',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
        if ((confirmed ?? false) && context.mounted) {
          ref.read(authProvider.notifier).logout();
          context.go(AppRoutes.login);
          unawaited(
              ref.read(authRepositoryProvider).logout().catchError((_) {}));
        }
    }
  }
}

enum _AdminAction { home, settings, about, logout }

class _AdminMenuItem extends StatelessWidget {
  const _AdminMenuItem({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.onSurface;
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(icon, size: 20, color: itemColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Almarai',
            color: itemColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
