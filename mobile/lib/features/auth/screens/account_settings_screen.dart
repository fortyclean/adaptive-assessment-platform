import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_version.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../repositories/auth_repository.dart';

/// Account Settings Screen — Screen 49: إعدادات الحساب | EduAssess
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  Future<void> _persistUpdatedUser(AuthUser user) async {
    const storage = FlutterSecureStorage();
    await storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.chooseLanguage,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
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
                  Navigator.pop(sheetContext);
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
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Directionality(
      textDirection:
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(user),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colorScheme),
                const SizedBox(height: 24),
                _buildProfileCard(user, colorScheme),
                const SizedBox(height: 16),
                _buildSectionLabel(l10n.securityAndPrivacy, colorScheme),
                const SizedBox(height: 8),
                _buildSecurityGroup(context),
                const SizedBox(height: 16),
                _buildSectionLabel(l10n.languageAndAppearance, colorScheme),
                const SizedBox(height: 8),
                _buildAppearanceGroup(),
                const SizedBox(height: 16),
                _buildSectionLabel(l10n.other, colorScheme),
                const SizedBox(height: 8),
                _buildOtherGroup(context),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'EduAssess v${AppVersion.current}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthUser? user) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            UserAvatar(user: user, size: 40),
            const SizedBox(width: 12),
            Text(
              'EduAssess',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: AppLocalizations.of(context).notificationCenter,
              icon: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => context.push(AppRoutes.notificationCenter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).accountSettings,
            style: AppTextStyles.displayMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).profileSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );

  Widget _buildProfileCard(AuthUser? user, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    final roleLabel = switch (user?.role) {
      UserRole.admin => l10n.adminRole,
      UserRole.teacher => l10n.teacherRole,
      UserRole.student => l10n.studentRole,
      null => l10n.userRole,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                user: user,
                size: 64,
                borderColor: AppColors.primaryContainer,
              ),
              Positioned(
                bottom: -4,
                left: -4,
                child: Tooltip(
                  message: l10n.editNameTooltip,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _showEditProfileDialog,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: colorScheme.surface, width: 2),
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
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? l10n.userRole,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? user?.username ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    roleLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ColorScheme colorScheme) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _buildSecurityGroup(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsCard(
      children: [
        _SettingsRowTile(
          icon: Icons.lock_outline_rounded,
          title: l10n.changePassword,
          subtitle: l10n.changePasswordSubtitle,
          onTap: () => context.push(AppRoutes.changePassword),
        ),
        const _Divider(),
        _SettingsRowTile(
          icon: Icons.notifications_active_outlined,
          title: l10n.notificationSettings,
          subtitle: l10n.notificationSettingsSubtitle,
          onTap: () => context.push(AppRoutes.notificationSettings),
        ),
      ],
    );
  }

  Widget _buildAppearanceGroup() {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final languageLabel =
        locale.languageCode == 'ar' ? l10n.arabic : l10n.english;

    return _SettingsCard(
      children: [
        InkWell(
          onTap: () => _showLanguageDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.language_rounded,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(l10n.appLanguage, style: AppTextStyles.bodyLarge),
                ),
                _LanguageBadge(label: languageLabel),
              ],
            ),
          ),
        ),
        const _Divider(),
        _SettingsToggleTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.darkMode,
          subtitle: isDarkMode ? l10n.darkModeEnabled : l10n.darkModeDisabled,
          value: isDarkMode,
          onChanged: (enabled) =>
              ref.read(themeModeProvider.notifier).setDarkMode(
                    enabled: enabled,
                  ),
        ),
      ],
    );
  }

  Widget _buildOtherGroup(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsCard(
      children: [
        _SettingsRowTile(
          icon: Icons.info_outline_rounded,
          title: l10n.aboutAndChangelog,
          subtitle: l10n.versionLabel(AppVersion.current),
          onTap: () => context.push('/about'),
        ),
        const _Divider(),
        _SettingsRowTile(
          icon: Icons.help_outline_rounded,
          title: l10n.helpCenter,
          subtitle: l10n.helpCenterSubtitle,
          onTap: () => _showHelpCenter(context),
        ),
        const _Divider(),
        InkWell(
          onTap: () => _handleLogout(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.logout,
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
  }

  Widget _buildBottomNav() {
    final role = ref.watch(currentUserProvider)?.role;
    if (role == null) return const SizedBox.shrink();

    return switch (role) {
      UserRole.admin => const AppBottomNav(currentIndex: 4, role: 'admin'),
      UserRole.student => const AppBottomNav(currentIndex: 3, role: 'student'),
      UserRole.teacher => const AppBottomNav(currentIndex: 4, role: 'teacher'),
    };
  }

  Future<void> _showEditProfileDialog() async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final locale = ref.read(localeProvider);

    final nameController = TextEditingController(text: user.fullName);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection:
            locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.editName),
          content: TextField(
            controller: nameController,
            textDirection: locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.fullName,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();

    if (!mounted || result == null) return;
    if (result.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nameTooShort),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final latestState = ref.read(authProvider);
      final currentUser = latestState.user;
      if (currentUser == null) return;

      final token = latestState.accessToken ?? '';
      final isDemoSession = token.startsWith('demo-token-');
      if (!isDemoSession) {
        await ref.read(authRepositoryProvider).updateProfile(
              userId: currentUser.id,
              name: result,
            );
      }

      ref.read(authProvider.notifier).updateName(result);
      final updatedUser = AuthUser(
        id: currentUser.id,
        username: currentUser.username,
        fullName: result,
        email: currentUser.email,
        role: currentUser.role,
        classroomIds: currentUser.classroomIds,
        avatarUrl: currentUser.avatarUrl,
      );
      await _persistUpdatedUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.nameUpdated),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showHelpCenter(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showAboutDialog(
      context: context,
      applicationName: 'EduAssess',
      applicationVersion: AppVersion.current,
      applicationLegalese: l10n.legalese,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final locale = ref.read(localeProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection:
            locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutAccountQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.logoutConfirm,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );

    if ((confirmed ?? false) && mounted) {
      ref.read(authProvider.notifier).logout();
      ref.read(authRepositoryProvider).logout().catchError((_) {});
      if (context.mounted) context.go(AppRoutes.login);
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
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
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _SettingsRowTile extends StatelessWidget {
  const _SettingsRowTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
            activeTrackColor: colorScheme.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.transparent;
              }
              return colorScheme.outlineVariant;
            }),
          ),
        ],
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
        indent: 0,
        endIndent: 0,
      );
}
