import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

const _notificationSettingsPrefix = 'notification_settings.';

/// Notification Settings Screen - Screen 35
/// Requirements: 21.x
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _studentPerfPush = true;
  bool _studentPerfEmail = false;
  bool _questionBankPush = true;
  bool _questionBankSms = false;
  bool _periodicReportsEmail = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _restoreSettings();
  }

  Future<void> _restoreSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _studentPerfPush = prefs.getBool(
              '${_notificationSettingsPrefix}studentPerfPush',
            ) ??
            _studentPerfPush;
        _studentPerfEmail = prefs.getBool(
              '${_notificationSettingsPrefix}studentPerfEmail',
            ) ??
            _studentPerfEmail;
        _questionBankPush = prefs.getBool(
              '${_notificationSettingsPrefix}questionBankPush',
            ) ??
            _questionBankPush;
        _questionBankSms = prefs.getBool(
              '${_notificationSettingsPrefix}questionBankSms',
            ) ??
            _questionBankSms;
        _periodicReportsEmail = prefs.getBool(
              '${_notificationSettingsPrefix}periodicReportsEmail',
            ) ??
            _periodicReportsEmail;
      });
    } on Object {
      // Keep the default in-memory settings when local storage is unavailable.
    }
  }

  bool get _settingsAreValid =>
      (_studentPerfPush || _studentPerfEmail) &&
      (_questionBankPush || _questionBankSms) &&
      _periodicReportsEmail;

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context);

    if (!_settingsAreValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.enableOneChannelPerNotificationGroup,
            style: const TextStyle(fontFamily: 'Almarai'),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        '${_notificationSettingsPrefix}studentPerfPush',
        _studentPerfPush,
      );
      await prefs.setBool(
        '${_notificationSettingsPrefix}studentPerfEmail',
        _studentPerfEmail,
      );
      await prefs.setBool(
        '${_notificationSettingsPrefix}questionBankPush',
        _questionBankPush,
      );
      await prefs.setBool(
        '${_notificationSettingsPrefix}questionBankSms',
        _questionBankSms,
      );
      await prefs.setBool(
        '${_notificationSettingsPrefix}periodicReportsEmail',
        _periodicReportsEmail,
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.notificationSettingsSaved,
              style: const TextStyle(fontFamily: 'Almarai'),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.notificationSettingsSavedLocally,
              style: const TextStyle(fontFamily: 'Almarai'),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context, l10n),
        body: _buildBody(l10n),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: colorScheme.outlineVariant),
      ),
      title: Text(
        l10n.smartAssessmentTitle,
        style: const TextStyle(
          color: Color(0xFF1E40AF),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Almarai',
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF1E40AF).withValues(alpha: 0.15),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF1E40AF),
            size: 20,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF64748B),
          ),
          onPressed: () => context.pop(),
        ),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          _buildPageHeader(l10n),
          const SizedBox(height: 24),
          _NotificationGroup(
            icon: Icons.analytics_rounded,
            title: l10n.studentPerformanceNotificationsGroup,
            rows: [
              _NotificationToggleRow(
                title: l10n.pushNotificationsTitle,
                subtitle: l10n.studentPerformancePushSubtitle,
                value: _studentPerfPush,
                onChanged: (v) => setState(() => _studentPerfPush = v),
              ),
              _NotificationToggleRow(
                title: l10n.emailNotificationTitle,
                subtitle: l10n.studentPerformanceEmailSubtitle,
                value: _studentPerfEmail,
                onChanged: (v) => setState(() => _studentPerfEmail = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _NotificationGroup(
            icon: Icons.quiz_rounded,
            title: l10n.questionBankNotificationsGroup,
            rows: [
              _NotificationToggleRow(
                title: l10n.contentUpdatesNotificationTitle,
                subtitle: l10n.questionBankContentUpdatesSubtitle,
                value: _questionBankPush,
                onChanged: (v) => setState(() => _questionBankPush = v),
              ),
              _NotificationToggleRow(
                title: l10n.smsNotificationTitle,
                subtitle: l10n.questionBankSmsSubtitle,
                value: _questionBankSms,
                onChanged: (v) => setState(() => _questionBankSms = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _NotificationGroup(
            icon: Icons.description_rounded,
            title: l10n.periodicReportsNotificationsGroup,
            rows: [
              _NotificationToggleRow(
                title: l10n.emailNotificationTitle,
                subtitle: l10n.periodicReportsEmailSubtitle,
                value: _periodicReportsEmail,
                onChanged: (v) => setState(() => _periodicReportsEmail = v),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSaveButton(l10n),
        ],
      );

  Widget _buildPageHeader(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notificationSettings,
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.notificationSettingsPageSubtitle,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  l10n.saveChanges,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      );
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<_NotificationToggleRow> rows;

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
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant,
                indent: 0,
                endIndent: 0,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _NotificationToggleRow extends StatelessWidget {
  const _NotificationToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _AppToggle(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _AppToggle extends StatelessWidget {
  const _AppToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: value ? AppColors.primary : const Color(0xFFDAD9E3),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                right: value ? 2 : null,
                left: value ? null : 2,
                top: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
