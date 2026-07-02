import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_version.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../repositories/auth_repository.dart';

/// Teacher/Student Settings Screen — Screen 11
/// Requirements: 1.7
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _persistUpdatedUser(AuthUser user) async {
    const storage = FlutterSecureStorage();
    await storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('AR', style: TextStyle(fontSize: 14)),
              title: Text(l10n.arabic),
              trailing: currentLocale.languageCode == 'ar'
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () {
                ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('ar', 'SA'));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.languageArabicSelected),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Text('EN', style: TextStyle(fontSize: 14)),
              title: Text(l10n.english),
              trailing: currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () {
                ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('en', 'US'));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.languageEnglishSelected),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet(
      BuildContext context, WidgetRef ref, AuthUser? user) {
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(l10n.editProfile,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              textDirection: locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              decoration: InputDecoration(
                  labelText: l10n.fullName,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.nameTooShort),
                        behavior: SnackBarBehavior.floating),
                  );
                  return;
                }
                try {
                  final authState = ref.read(authProvider);
                  final currentUser = authState.user;
                  final token = authState.accessToken ?? '';
                  if (currentUser == null) return;

                  final isDemoSession = token.startsWith('demo-token-');
                  if (!isDemoSession) {
                    await ref.read(authRepositoryProvider).updateProfile(
                          userId: currentUser.id,
                          name: newName,
                        );
                  }
                  ref.read(authProvider.notifier).updateName(newName);
                  final updatedUser = AuthUser(
                    id: currentUser.id,
                    username: currentUser.username,
                    fullName: newName,
                    email: currentUser.email,
                    role: currentUser.role,
                    classroomIds: currentUser.classroomIds,
                    avatarUrl: currentUser.avatarUrl,
                  );
                  await _persistUpdatedUser(updatedUser);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.nameUpdated),
                          behavior: SnackBarBehavior.floating),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.saveFailed),
                          behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: Text(l10n.saveChanges,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    final fullName = user?.fullName ?? l10n.userRole;
    final email = user?.username ?? '';
    final roleLabel = switch (user?.role) {
      UserRole.teacher => l10n.teacherRole,
      UserRole.admin => l10n.adminRole,
      UserRole.parent => 'ولي الأمر',
      UserRole.student || null => l10n.studentRole,
    };

    // Initials
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: colorScheme.onSurface,
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
              : user?.role == UserRole.parent
                  ? const AppBottomNav(currentIndex: 3, role: 'parent')
                  : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile card ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
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
                          _showEditProfileBottomSheet(context, ref, user);
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
          _SectionLabel(label: l10n.accountSettings),
          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.primary,
                title: l10n.changePassword,
                subtitle: l10n.changePasswordSubtitle,
                onTap: () => context.push(AppRoutes.changePassword),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
                title: l10n.editProfile,
                subtitle: l10n.profileSubtitle,
                onTap: () {
                  _showEditProfileBottomSheet(context, ref, user);
                },
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                title: l10n.appLanguage,
                subtitle:
                    locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
                onTap: () => _showLanguageDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Appearance section ──────────────────────────────────────────
          _SectionLabel(label: l10n.appearance),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
                  return _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: l10n.darkMode,
                    subtitle: isDark
                        ? l10n.darkModeCurrentlyEnabled
                        : l10n.darkModeCurrentlyDisabled,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).setDarkMode(
                            enabled: !isDark,
                          );
                    },
                    trailing: _ToggleSwitch(
                      value: isDark,
                      onChanged: (v) {
                        ref.read(themeModeProvider.notifier).setDarkMode(
                              enabled: v,
                            );
                      },
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Notifications section ─────────────────────────────────────────
          _SectionLabel(label: l10n.notifications),
          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFD97706),
                title: l10n.assessmentNotifications,
                subtitle: l10n.assessmentNotificationsSubtitle,
                onTap: () => context.push(AppRoutes.notificationSettings),
                trailing: _ToggleSwitch(value: true, onChanged: (_) {}),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFFD97706),
                title: l10n.resultNotifications,
                subtitle: l10n.resultNotificationsSubtitle,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l10n.resultNotificationSettings),
                        behavior: SnackBarBehavior.floating),
                  );
                },
                trailing: _ToggleSwitch(value: true, onChanged: (_) {}),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── About section ─────────────────────────────────────────────────
          _SectionLabel(label: l10n.aboutApp),
          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: l10n.aboutAndChangelog,
                subtitle: l10n.versionLabel(AppVersion.current),
                onTap: () => context.push('/about'),
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.onSurfaceVariant,
                title: l10n.support,
                subtitle: l10n.supportSubtitle,
                onTap: () => context.push(AppRoutes.support),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Logout button ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
              title: Text(
                l10n.logout,
                style: const TextStyle(
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
                    title: Text(l10n.logout),
                    content: Text(l10n.logoutQuestion),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancel)),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.logoutConfirm,
                              style: const TextStyle(color: AppColors.error))),
                    ],
                  ),
                );

                if ((confirmed ?? false) && context.mounted) {
                  // Show loading immediately
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  // Logout in parallel - don't wait for API
                  ref
                      .read(authProvider.notifier)
                      .logout(); // immediate local logout

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
  Widget build(BuildContext context) => Padding(
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

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
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
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.onSurfaceVariant),
        onTap: onTap,
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        indent: 68,
        endIndent: 0,
        color: AppColors.outlineVariant,
      );
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
  void didUpdateWidget(covariant _ToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) => Switch(
        value: _value,
        onChanged: (v) {
          setState(() => _value = v);
          widget.onChanged(v);
        },
        activeThumbColor: AppColors.primary,
      );
}

// ignore: unused_element
class _AboutFeature extends StatelessWidget {
  const _AboutFeature(
      {required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.onSurface, height: 1.5),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      );
}
