import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_version.dart';
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
                        onPressed: () {
                          final nameController = TextEditingController(text: user?.fullName ?? '');
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            builder: (ctx) => Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 16, right: 16, top: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
                                  const SizedBox(height: 16),
                                  const Text('تعديل الملف الشخصي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: nameController,
                                    textDirection: TextDirection.rtl,
                                    decoration: InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final newName = nameController.text.trim();
                                      if (newName.length < 2) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('الاسم يجب أن يحتوي على حرفين على الأقل'), behavior: SnackBarBehavior.floating),
                                        );
                                        return;
                                      }
                                      try {
                                        final userId = ref.read(currentUserProvider)?.id ?? '';
                                        await ref.read(authRepositoryProvider).updateProfile(userId: userId, name: newName);
                                        ref.read(authProvider.notifier).updateName(newName);
                                        if (context.mounted) {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم تحديث الاسم بنجاح'), behavior: SnackBarBehavior.floating),
                                          );
                                        }
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تعذر حفظ التغييرات، يرجى المحاولة مرة أخرى'), behavior: SnackBarBehavior.floating),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    child: const Text('حفظ التغييرات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) {
                      final nameController = TextEditingController(text: user?.fullName ?? '');
                      return Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 16, right: 16, top: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
                            const SizedBox(height: 16),
                            const Text('تعديل الملف الشخصي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: nameController,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final newName = nameController.text.trim();
                                if (newName.length < 2) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('الاسم يجب أن يحتوي على حرفين على الأقل'), behavior: SnackBarBehavior.floating),
                                  );
                                  return;
                                }
                                try {
                                  final userId = ref.read(currentUserProvider)?.id ?? '';
                                  await ref.read(authRepositoryProvider).updateProfile(userId: userId, name: newName);
                                  ref.read(authProvider.notifier).updateName(newName);
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم تحديث الاسم بنجاح'), behavior: SnackBarBehavior.floating),
                                    );
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تعذر حفظ التغييرات، يرجى المحاولة مرة أخرى'), behavior: SnackBarBehavior.floating),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: const Text('حفظ التغييرات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                title: 'اللغة',
                subtitle: 'العربية',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('اختيار اللغة'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Text('🇸🇦',
                                style: TextStyle(fontSize: 24)),
                            title: const Text('العربية'),
                            trailing: const Icon(Icons.check,
                                color: AppColors.primary),
                            onTap: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('اللغة: العربية'),
                                    behavior: SnackBarBehavior.floating),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Text('🇺🇸',
                                style: TextStyle(fontSize: 24)),
                            title: const Text('الإنجليزية'),
                            onTap: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('اللغة الإنجليزية (قريبًا)'),
                                    behavior: SnackBarBehavior.floating),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('إعدادات إشعارات النتائج'),
                        behavior: SnackBarBehavior.floating),
                  );
                },
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
                iconColor: AppColors.primary,
                title: 'عن التطبيق وسجل الإصدارات',
                subtitle: 'الإصدار ${AppVersion.current} — EduAssess',
                onTap: () => context.push('/about'),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.onSurfaceVariant,
                title: 'الدعم الفني',
                subtitle: 'تواصل مع فريق الدعم',
                onTap: () => context.push(AppRoutes.support),
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

                if (confirmed == true && context.mounted) {
                  // Show loading immediately
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  // Logout in parallel - don't wait for API
                  ref.read(authProvider.notifier).logout(); // immediate local logout

                  // Navigate immediately
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }

                  // API logout in background (fire and forget)
                  ref.read(authRepositoryProvider).logout().catchError((_) {});
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

class _AboutFeature extends StatelessWidget {
  const _AboutFeature({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurface, height: 1.5),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
