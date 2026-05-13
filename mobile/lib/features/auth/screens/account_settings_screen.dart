import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_version.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../repositories/auth_repository.dart';

/// Account Settings Screen — Screen 49: إعدادات الحساب | EduAssess
/// Displays profile card, security settings, appearance preferences, and logout.
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _examNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(user),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeader(),
                const SizedBox(height: 32),

                // ── Profile Card ─────────────────────────────────────────
                _buildProfileCard(user),
                const SizedBox(height: 16),

                // ── Security & Privacy Group ─────────────────────────────
                _buildSectionLabel('الأمان والخصوصية'),
                const SizedBox(height: 8),
                _buildSecurityGroup(context),
                const SizedBox(height: 16),

                // ── Appearance & Language Group ──────────────────────────
                _buildSectionLabel('المظهر واللغة'),
                const SizedBox(height: 8),
                _buildAppearanceGroup(),
                const SizedBox(height: 16),

                // ── Other Group ──────────────────────────────────────────
                _buildSectionLabel('أخرى'),
                const SizedBox(height: 8),
                _buildOtherGroup(context),
                const SizedBox(height: 24),

                // ── App Version ──────────────────────────────────────────
                Center(
                  child: Text(
                    'EduAssess v${AppVersion.current}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AuthUser? user) => AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Profile avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer,
                ),
                child: ClipOval(
                  child: _buildAvatarContent(user),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'EduAssess',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF64748B)),
                onPressed: () => context.push(AppRoutes.notificationCenter),
              ),
            ],
          ),
        ),
      );

  // ── Header Section ─────────────────────────────────────────────────────────

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات الحساب',
            style: AppTextStyles.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'تحكم في ملفك الشخصي وتفضيلات التطبيق',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      );

  // ── Profile Card ───────────────────────────────────────────────────────────

  Widget _buildProfileCard(AuthUser? user) {
    final initials = _getInitials(user?.fullName);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Avatar with edit button
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child:
                      _buildAvatarContent(user, size: 64, initials: initials),
                ),
              ),
              Positioned(
                bottom: -4,
                left: -4,
                child: GestureDetector(
                  onTap: _onEditPhoto,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name & email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'أحمد محمد علي',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'ahmed.ali@eduassess.com',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
      );

  // ── Security Group ─────────────────────────────────────────────────────────

  Widget _buildSecurityGroup(BuildContext context) => _SettingsCard(
        children: [
          _SettingsRowTile(
            icon: Icons.lock_outline_rounded,
            title: 'تغيير كلمة المرور',
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          const _Divider(),
          _SettingsToggleTile(
            icon: Icons.notifications_active_outlined,
            title: 'تنبيهات الاختبارات',
            subtitle: 'تفعيل التذكير بالاختبارات القادمة',
            value: _examNotificationsEnabled,
            onChanged: (v) => setState(() => _examNotificationsEnabled = v),
          ),
        ],
      );

  // ── Appearance Group ───────────────────────────────────────────────────────

  Widget _buildAppearanceGroup() => _SettingsCard(
        children: [
          // Language row — static badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.language_rounded,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'لغة التطبيق',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE1FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'العربية',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _Divider(),
          // Dark mode toggle
          const _SettingsRowTile(
            icon: Icons.dark_mode_outlined,
            title: 'الوضع الليلي (غير متاح مؤقتًا)',
            subtitle: 'سيتم تفعيله بعد ضبطه على جميع الشاشات.',
            showChevron: false,
            onTap: null,
          ),
        ],
      );

  // ── Other Group ────────────────────────────────────────────────────────────

  Widget _buildOtherGroup(BuildContext context) => _SettingsCard(
        children: [
          _SettingsRowTile(
            icon: Icons.help_outline_rounded,
            title: 'مركز المساعدة',
            onTap: () => _showHelpCenter(context),
          ),
          const _Divider(),
          // Logout row
          InkWell(
            onTap: () => _handleLogout(context),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.error, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    'تسجيل الخروج',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  // ── Bottom Navigation ──────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    final role = ref.watch(currentUserProvider)?.role;
    if (role == null) {
      // Avoid rendering a potentially wrong role nav while auth state is still restoring.
      return const SizedBox.shrink();
    }

    if (role == UserRole.admin) {
      return const AppBottomNav(currentIndex: 4, role: 'admin');
    }
    if (role == UserRole.student) {
      return const AppBottomNav(currentIndex: 3, role: 'student');
    }
    return const AppBottomNav(currentIndex: 4, role: 'teacher');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildAvatarContent(AuthUser? user,
      {double size = 40, String? initials}) {
    final text = initials ?? _getInitials(user?.fullName);
    return Container(
      width: size,
      height: size,
      color: AppColors.surfaceContainer,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '؟';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  Future<void> _onEditPhoto() async {
    // Show dialog to edit name
    final user = ref.read(currentUserProvider);
    final nameController = TextEditingController(text: user?.fullName ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تعديل الاسم'),
          content: TextField(
            controller: nameController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      // Call API to update user profile
      try {
        final userId = user?.id ?? '';
        await ref.read(authRepositoryProvider).updateProfile(
              userId: userId,
              name: result,
            );
        // Update local state
        ref.read(authProvider.notifier).updateName(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التعديلات بنجاح'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حفظ التعديلات: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showHelpCenter(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'EduAssess',
      applicationVersion: '2.4.0',
      applicationLegalese: '© 2024 EduAssess. جميع الحقوق محفوظة.',
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
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
      ),
    );

    if ((confirmed ?? false) && mounted) {
      await ref.read(authRepositoryProvider).logout();
      ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

/// A card container for a group of settings rows.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      );
}

/// A tappable settings row with icon, title, and chevron.
class _SettingsRowTile extends StatelessWidget {
  const _SettingsRowTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
            ],
          ),
        ),
      );
}

/// A settings row with icon, title, optional subtitle, and a toggle switch.
class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primaryContainer,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.surfaceContainerHigh,
              trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.transparent;
                }
                return AppColors.outlineVariant;
              }),
            ),
          ],
        ),
      );
}

/// A thin horizontal divider matching the design system.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outlineVariant,
        indent: 0,
        endIndent: 0,
      );
}
