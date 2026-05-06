import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../repositories/auth_repository.dart';

/// Teacher/Student Settings Screen — Screen 11
/// Requirements: 1.7
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.onPrimaryContainer,
                    child: Text(
                      user?.fullName.isNotEmpty ?? false
                          ? user!.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? '',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(user?.username ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                        Text(
                          user?.role.name == 'teacher'
                              ? 'معلم'
                              : user?.role.name == 'admin'
                                  ? 'مشرف'
                                  : 'طالب',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Settings options
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'تغيير كلمة المرور',
            onTap: () => context.push(AppRoutes.changePassword),
          ),

          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'الإشعارات',
            onTap: () {},
          ),

          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'عن التطبيق',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'منصة التقييم التكيفي',
              applicationVersion: '1.0.0',
            ),
          ),

          const SizedBox(height: 20),

          // Logout
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل تريد تسجيل الخروج؟'),
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

              if (confirmed ?? false) {
                await ref.read(authRepositoryProvider).logout();
                ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile(
      {required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
}
