import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../repositories/auth_repository.dart';

/// Teacher/Student Settings Screen — Screen 11
/// Requirements: 1.7
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final fullName = user?.fullName ?? 'المستخدم';
    final email = user?.username ?? '';
    final roleLabel = user?.role.name == 'teacher'
        ? 'معلم'
        : user?.role.name == 'admin'
            ? 'مشرف'
            : 'طالب';

    // Initials
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            color: Color(0xFF1A1B22),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.onSurfaceVariant),
                onPressed: () => context.pop(),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      // Bottom nav — show for student (index 3) and teacher (index 4)
      bottomNavigationBar: user?.role == UserRole.student
          ? const AppBottomNav(currentIndex: 3, role: 'student')
          : user?.role == UserRole.teacher
              ? const AppBottomNav(currentIndex: 4, role: 'teacher')
              : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile card ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top accent bar
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Color(0xFFDDE1FF),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0E1FB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                roleLabel,
                                style: const TextStyle(
                                  color: Color(0xFF54647A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Account settings section ──────────────────────────────────────
          _SectionLabel(label: 'إعدادات الحساب'),
          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.primary,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث كلمة المرور الخاصة بك',
                onTap: () => context.push(AppRoutes.changePassword),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
                title: 'تعديل الملف الشخصي',
                subtitle: 'تحديث بياناتك الشخصية',
                onTap: () {},
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                title: 'اللغة',
                subtitle: 'العربية',
                onTap: () {},
                showArrow: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Notifications section ─────────────────────────────────────────
          _SectionLabel(label: 'الإشعارات'),
          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFD97706),
                title: 'إشعارات الاختبارات',
                subtitle: 'تنبيهات الاختبارات الجديدة',
                onTap: () => context.push(AppRoutes.notificationSettings),
                trailing: _ToggleSwitch(value: true, onChanged: (_) {}),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFFD97706),
                title: 'إشعارات النتائج',
                subtitle: 'تنبيهات عند صدور النتائج',
                onTap: () {},
                trailing: _ToggleSwitch(value: true, onChanged: (_) {}),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── About section ─────────────────────────────────────────────────
          _SectionLabel(label: 'عن التطبيق'),
          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.onSurfaceVariant,
                title: 'عن التطبيق',
                subtitle: 'الإصدار 1.0.0',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'منصة التقييم التكيفي',
                  applicationVersion: '1.0.0',
                ),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.onSurfaceVariant,
                title: 'الدعم الفني',
                subtitle: 'تواصل مع فريق الدعم',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Logout button ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 18),
              ),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.error),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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

                if (confirmed == true) {
                  await ref.read(authRepositoryProvider).logout();
                  ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.login);
                }
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.showArrow = true,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ??
          (showArrow
              ? const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.onSurfaceVariant)
              : null),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 68,
      endIndent: 0,
      color: AppColors.outlineVariant,
    );
  }
}

class _ToggleSwitch extends StatefulWidget {
  const _ToggleSwitch({required this.value, required this.onChanged});
  final bool value;
  final void Function(bool) onChanged;

  @override
  State<_ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<_ToggleSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
      activeColor: AppColors.primary,
    );
  }
}
