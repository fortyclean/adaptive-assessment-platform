import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_version.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../l10n/app_localizations.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';

/// Screen 69 — إعدادات المؤسسة (Institution Settings)
class InstitutionSettingsScreen extends ConsumerStatefulWidget {
  const InstitutionSettingsScreen({super.key});

  @override
  ConsumerState<InstitutionSettingsScreen> createState() =>
      _InstitutionSettingsScreenState();
}

class _InstitutionSettingsScreenState
    extends ConsumerState<InstitutionSettingsScreen> {
  static const String _settingsPrefix = 'admin_institution_settings.';

  String _schoolName = 'أكاديمية المستقبل الدولية';
  String _schoolPhone = '+966 500 000 000';
  String _schoolEmail = 'contact@future-academy.edu';
  String _academicYear = '2025 / 2026';
  String _term = 'الفصل الدراسي الثاني';
  String _gradeScale = 'A-F';
  String _language = 'العربية';
  String _timezone = 'Asia/Kuwait';
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _weeklyDigest = true;
  bool _sisIntegration = false;
  bool _lmsIntegration = false;
  bool _isSavingSettings = false;
  DateTime? _lastSyncedAt;
  String _syncStatusMessage = 'لم تتم مزامنة الإعدادات بعد';

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadInstitutionSettings();
  }

  bool get _allowLocalOnlySettings {
    if (AppConstants.useMockData) return true;
    final authState = ref.read(authProvider);
    return (authState.accessToken ?? '').startsWith('demo-token-');
  }

  List<Map<String, dynamic>> get _demoAuditLogs => [
        {
          'action': 'تعطيل حساب مستخدم',
          'actorName': 'مدير النظام',
          'targetName': 'حساب طالب غير نشط',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 18)),
          'severity': 'high',
        },
        {
          'action': 'ربط معلم بفصل',
          'actorName': 'مدير النظام',
          'targetName': 'الأول المتوسط (أ)',
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
          'severity': 'medium',
        },
        {
          'action': 'تحديث إعدادات المؤسسة',
          'actorName': 'مدير النظام',
          'targetName': _schoolName,
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
          'severity': 'low',
        },
        {
          'action': 'طلب أرشفة بيانات',
          'actorName': 'مدير النظام',
          'targetName': 'بيانات المؤسسة',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          'severity': 'critical',
        },
      ];

  Future<void> _loadInstitutionSettings() async {
    await _loadSavedInstitutionSettings();

    if (_allowLocalOnlySettings) {
      if (!mounted) return;
      setState(() {
        _syncStatusMessage = _l10n.institutionDemoLocalSaveStatus;
      });
      return;
    }

    try {
      final settings =
          await ref.read(adminRepositoryProvider).getInstitutionSettings();
      if (!mounted) return;
      setState(() {
        _applyInstitutionSettings(settings);
        _lastSyncedAt = DateTime.now();
        _syncStatusMessage = _l10n.syncedWithServer;
      });
      await _saveSettingsLocally();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _syncStatusMessage = _l10n.serverConnectionFailed;
      });
      _showMessage(
        _l10n.institutionSettingsLoadFailed,
        isError: true,
      );
    }
  }

  Future<void> _loadSavedInstitutionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(
      () => _applyInstitutionSettings({
        'schoolName':
            prefs.getString('${_settingsPrefix}schoolName') ?? _schoolName,
        'schoolPhone':
            prefs.getString('${_settingsPrefix}schoolPhone') ?? _schoolPhone,
        'schoolEmail':
            prefs.getString('${_settingsPrefix}schoolEmail') ?? _schoolEmail,
        'academicYear':
            prefs.getString('${_settingsPrefix}academicYear') ?? _academicYear,
        'term': prefs.getString('${_settingsPrefix}term') ?? _term,
        'gradeScale':
            prefs.getString('${_settingsPrefix}gradeScale') ?? _gradeScale,
        'language': prefs.getString('${_settingsPrefix}language') ?? _language,
        'timezone': prefs.getString('${_settingsPrefix}timezone') ?? _timezone,
        'emailNotifications':
            prefs.getBool('${_settingsPrefix}emailNotifications') ??
                _emailNotifications,
        'pushNotifications':
            prefs.getBool('${_settingsPrefix}pushNotifications') ??
                _pushNotifications,
        'weeklyDigest':
            prefs.getBool('${_settingsPrefix}weeklyDigest') ?? _weeklyDigest,
        'sisIntegration': prefs.getBool('${_settingsPrefix}sisIntegration') ??
            _sisIntegration,
        'lmsIntegration': prefs.getBool('${_settingsPrefix}lmsIntegration') ??
            _lmsIntegration,
      }),
    );
  }

  Future<void> _saveInstitutionSettings({String? successMessage}) async {
    final validationError = _validateContactFields();
    if (validationError != null) {
      if (mounted) _showMessage(validationError, isError: true);
      return;
    }

    if (mounted) {
      setState(() {
        _isSavingSettings = true;
        _syncStatusMessage = _l10n.savingSettings;
      });
    }

    await _saveSettingsLocally();

    if (!_allowLocalOnlySettings) {
      try {
        final settings = await ref
            .read(adminRepositoryProvider)
            .updateInstitutionSettings(_institutionSettingsPayload());
        if (mounted) {
          setState(() {
            _applyInstitutionSettings(settings);
            _lastSyncedAt = DateTime.now();
            _syncStatusMessage = _l10n.syncedWithServer;
          });
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _syncStatusMessage = _l10n.savedLocallyOnly;
          _isSavingSettings = false;
        });
        _showMessage(
          _l10n.institutionSettingsServerSaveFailed,
          isError: true,
        );
        return;
      }
    } else if (mounted) {
      setState(() {
        _lastSyncedAt = DateTime.now();
        _syncStatusMessage = _l10n.savedLocally;
      });
    }

    if (mounted) setState(() => _isSavingSettings = false);
    if (!mounted || successMessage == null) return;
    _showMessage(successMessage);
  }

  Future<List<Map<String, dynamic>>> _loadAuditLogs() async {
    if (_allowLocalOnlySettings) return _demoAuditLogs;
    try {
      final logs = await ref.read(adminRepositoryProvider).getAuditLogs();
      return logs;
    } catch (_) {
      return const [
        {'__loadError': true},
      ];
    }
  }

  Future<void> _saveSettingsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_settingsPrefix}schoolName', _schoolName);
    await prefs.setString('${_settingsPrefix}schoolPhone', _schoolPhone);
    await prefs.setString('${_settingsPrefix}schoolEmail', _schoolEmail);
    await prefs.setString('${_settingsPrefix}academicYear', _academicYear);
    await prefs.setString('${_settingsPrefix}term', _term);
    await prefs.setString('${_settingsPrefix}gradeScale', _gradeScale);
    await prefs.setString('${_settingsPrefix}language', _language);
    await prefs.setString('${_settingsPrefix}timezone', _timezone);
    await prefs.setBool(
        '${_settingsPrefix}emailNotifications', _emailNotifications);
    await prefs.setBool(
        '${_settingsPrefix}pushNotifications', _pushNotifications);
    await prefs.setBool('${_settingsPrefix}weeklyDigest', _weeklyDigest);
    await prefs.setBool('${_settingsPrefix}sisIntegration', _sisIntegration);
    await prefs.setBool('${_settingsPrefix}lmsIntegration', _lmsIntegration);
  }

  Map<String, dynamic> _institutionSettingsPayload() => {
        'schoolName': _schoolName,
        'schoolPhone': _schoolPhone,
        'schoolEmail': _schoolEmail,
        'academicYear': _academicYear,
        'term': _term,
        'gradeScale': _gradeScale,
        'language': _language,
        'timezone': _timezone,
        'emailNotifications': _emailNotifications,
        'pushNotifications': _pushNotifications,
        'weeklyDigest': _weeklyDigest,
        'sisIntegration': _sisIntegration,
        'lmsIntegration': _lmsIntegration,
      };

  void _applyInstitutionSettings(Map<String, dynamic> settings) {
    _schoolName = settings['schoolName'] as String? ?? _schoolName;
    _schoolPhone = settings['schoolPhone'] as String? ?? _schoolPhone;
    _schoolEmail = settings['schoolEmail'] as String? ?? _schoolEmail;
    _academicYear = settings['academicYear'] as String? ?? _academicYear;
    _term = settings['term'] as String? ?? _term;
    _gradeScale = settings['gradeScale'] as String? ?? _gradeScale;
    _language = settings['language'] as String? ?? _language;
    _timezone = settings['timezone'] as String? ?? _timezone;
    _emailNotifications =
        settings['emailNotifications'] as bool? ?? _emailNotifications;
    _pushNotifications =
        settings['pushNotifications'] as bool? ?? _pushNotifications;
    _weeklyDigest = settings['weeklyDigest'] as bool? ?? _weeklyDigest;
    _sisIntegration = settings['sisIntegration'] as bool? ?? _sisIntegration;
    _lmsIntegration = settings['lmsIntegration'] as bool? ?? _lmsIntegration;
  }

  void _persistInstitutionSettingsSilently() {
    _saveInstitutionSettings();
  }

  String? _validateContactFields() {
    if (_schoolEmail.trim().isEmpty || !_isValidEmail(_schoolEmail)) {
      return _l10n.institutionEmailInvalid;
    }
    if (_schoolPhone.trim().isEmpty || !_isValidPhone(_schoolPhone)) {
      return _l10n.institutionPhoneInvalid;
    }
    return null;
  }

  bool _isValidEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 7 && RegExp(r'^[0-9+\s()-]+$').hasMatch(value);
  }

  String _formatSyncTime(DateTime? value) {
    if (value == null) return _l10n.noSavedSyncRecorded;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}/${value.month}/${value.day} - $hour:$minute';
  }

  String _formatAuditTime(dynamic value) {
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }
    if (date == null) return _l10n.unknownTime;
    return _formatSyncTime(date);
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSchoolProfile(),
                const SizedBox(height: 16),
                _buildSyncStatusCard(),
                const SizedBox(height: 16),
                _buildSettingsGroup(
                  title: _l10n.academicStructure,
                  items: [
                    _SettingsItem(
                      icon: Icons.calendar_today_outlined,
                      title: _l10n.academicYears,
                      subtitle: _l10n.academicYearsSubtitle,
                      action: _SettingsAction.academicYears,
                    ),
                    _SettingsItem(
                      icon: Icons.grade_outlined,
                      title: _l10n.gradeScales,
                      subtitle: _l10n.gradeScalesSubtitle,
                      action: _SettingsAction.gradeScale,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSettingsGroup(
                  title: _l10n.userManagement,
                  items: [
                    _SettingsItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: _l10n.rolesAndPermissions,
                      subtitle: _l10n.rolesAndPermissionsSubtitle,
                      action: _SettingsAction.roles,
                    ),
                    _SettingsItem(
                      icon: Icons.history_edu_outlined,
                      title: _l10n.activityLogs,
                      subtitle: _l10n.activityLogsSubtitle,
                      action: _SettingsAction.activityLog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSettingsGroup(
                  title: _l10n.systemPreferences,
                  items: [
                    _SettingsItem(
                      icon: Icons.notifications_active_outlined,
                      title: _l10n.alertSettings,
                      subtitle: _l10n.alertSettingsSubtitle,
                      action: _SettingsAction.notifications,
                    ),
                    _SettingsItem(
                      icon: Icons.translate_outlined,
                      title: _l10n.languageAndRegion,
                      subtitle: _l10n.languageAndRegionSubtitle,
                      action: _SettingsAction.locale,
                    ),
                    _SettingsItem(
                      icon: Icons.hub_outlined,
                      title: _l10n.systemIntegrations,
                      subtitle: _l10n.systemIntegrationsSubtitle,
                      action: _SettingsAction.integrations,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingsGroup(
                  title: _l10n.accountAndSupport,
                  items: [
                    _SettingsItem(
                      icon: Icons.account_circle_outlined,
                      title: _l10n.accountSettings,
                      subtitle: _l10n.accountSettingsInstitutionSubtitle,
                      action: _SettingsAction.accountSettings,
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline_rounded,
                      title: _l10n.aboutAndChangelog,
                      subtitle: _l10n.versionLabel(AppVersion.current),
                      action: _SettingsAction.about,
                    ),
                    _SettingsItem(
                      icon: Icons.support_agent_outlined,
                      title: _l10n.support,
                      subtitle: _l10n.supportAndHelpSubtitle,
                      action: _SettingsAction.support,
                    ),
                    _SettingsItem(
                      icon: Icons.logout_rounded,
                      title: _l10n.logout,
                      subtitle: _l10n.logoutAdminSessionSubtitle,
                      action: _SettingsAction.logout,
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDangerZone(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar:
              const AppBottomNav(currentIndex: 4, role: 'admin'),
        ),
      );

  Widget _buildSyncStatusCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSavingSettings
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isSavingSettings
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_done_outlined,
                      color: AppColors.success, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _syncStatusMessage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _l10n.lastSavedAt(_formatSyncTime(_lastSyncedAt)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: _l10n.syncSettings,
              onPressed: _isSavingSettings
                  ? null
                  : () => _saveInstitutionSettings(
                        successMessage: _l10n.institutionSettingsSynced,
                      ),
              icon: const Icon(Icons.sync_rounded),
              color: AppColors.primary,
            ),
          ],
        ),
      );

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF1E40AF),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'EduAssess',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: _l10n.notifications,
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => context.push(AppRoutes.notificationCenter),
        ),
      ],
    );
  }

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.institutionSettings,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _l10n.institutionSettingsSubtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      );

  Widget _buildSchoolProfile() => Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _l10n.schoolProfile,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _showSchoolProfileDialog,
                  child: Text(
                    _l10n.edit,
                    style:
                        const TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showMessage(_l10n.logoUploadStorageNotice),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school,
                            color: AppColors.primary, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          _l10n.logo,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_l10n.institutionName,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12)),
                      Text(
                        _schoolName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_l10n.contactInformation,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12)),
                      Text(_schoolPhone, style: const TextStyle(fontSize: 13)),
                      Text(_schoolEmail, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildSettingsGroup({
    required String title,
    required List<_SettingsItem> items,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: () => _handleSettingsAction(item.action),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (item.color ?? AppColors.primary)
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon,
                              color: item.color ?? AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: item.color ?? colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_left,
                          color: item.color ?? colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    color: colorScheme.outlineVariant,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDangerZone() => OutlinedButton.icon(
        onPressed: _showArchiveDialog,
        icon: const Icon(Icons.archive_outlined, color: AppColors.error),
        label: Text(
          _l10n.archiveInstitutionData,
          style: const TextStyle(
              color: AppColors.error, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 0),
        ),
      );

  void _handleSettingsAction(_SettingsAction action) {
    switch (action) {
      case _SettingsAction.academicYears:
        _showAcademicYearsSheet();
        break;
      case _SettingsAction.gradeScale:
        _showGradeScaleSheet();
        break;
      case _SettingsAction.roles:
        context.push(AppRoutes.adminUsers);
        break;
      case _SettingsAction.activityLog:
        _showActivityLogSheet();
        break;
      case _SettingsAction.notifications:
        _showNotificationSheet();
        break;
      case _SettingsAction.locale:
        _showLocaleSheet();
        break;
      case _SettingsAction.integrations:
        _showIntegrationsSheet();
        break;
      case _SettingsAction.accountSettings:
        context.push(AppRoutes.accountSettings);
        break;
      case _SettingsAction.about:
        context.push(AppRoutes.about);
        break;
      case _SettingsAction.support:
        context.push(AppRoutes.support);
        break;
      case _SettingsAction.logout:
        _confirmLogout();
        break;
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_l10n.logout),
        content: Text(_l10n.logoutAdminQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _l10n.logoutConfirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      ref.read(authProvider.notifier).logout();
      context.go(AppRoutes.login);
      await ref.read(authRepositoryProvider).logout();
    }
  }

  void _showSchoolProfileDialog() {
    final nameController = TextEditingController(text: _schoolName);
    final phoneController = TextEditingController(text: _schoolPhone);
    final emailController = TextEditingController(text: _schoolEmail);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_l10n.editSchoolProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: _l10n.institutionName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: _l10n.contactPhone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: _l10n.email),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              final newPhone = phoneController.text.trim();
              if (newEmail.isEmpty || !_isValidEmail(newEmail)) {
                _showMessage(_l10n.emailInvalid, isError: true);
                return;
              }
              if (newPhone.isEmpty || !_isValidPhone(newPhone)) {
                _showMessage(_l10n.institutionPhoneInvalid, isError: true);
                return;
              }
              setState(() {
                _schoolName = nameController.text.trim().isEmpty
                    ? _schoolName
                    : nameController.text.trim();
                _schoolPhone = newPhone;
                _schoolEmail = newEmail;
              });
              Navigator.pop(ctx);
              await _saveInstitutionSettings(
                successMessage: _l10n.institutionProfileSaved,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(_l10n.save),
          ),
        ],
      ),
    );
  }

  void _showAcademicYearsSheet() {
    _showSettingsSheet(
      title: _l10n.academicYears,
      icon: Icons.calendar_today_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dropdownField(
              label: _l10n.currentAcademicYear,
              value: _academicYear,
              values: const ['2024 / 2025', '2025 / 2026', '2026 / 2027'],
              onChanged: (value) {
                if (value == null) return;
                setSheetState(() => _academicYear = value);
                setState(() => _academicYear = value);
                _persistInstitutionSettingsSilently();
              },
            ),
            const SizedBox(height: 12),
            _dropdownField(
              label: _l10n.currentTerm,
              value: _term,
              values: const [
                'الفصل الدراسي الأول',
                'الفصل الدراسي الثاني',
                'الفصل الدراسي الثالث',
              ],
              onChanged: (value) {
                if (value == null) return;
                setSheetState(() => _term = value);
                setState(() => _term = value);
                _persistInstitutionSettingsSilently();
              },
            ),
            const SizedBox(height: 16),
            _infoTile(_l10n.classroomManagement,
                _l10n.classroomManagementSettingsSubtitle),
            const SizedBox(height: 12),
            _primaryButton(
              label: _l10n.openClassroomManagement,
              icon: Icons.class_outlined,
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.adminClassrooms);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGradeScaleSheet() {
    _showSettingsSheet(
      title: _l10n.gradeScales,
      icon: Icons.grade_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dropdownField(
              label: _l10n.gradeScale,
              value: _gradeScale,
              values: const [
                'A-F',
                'ممتاز / جيد جدًا / جيد / مقبول',
                'نسبة مئوية فقط'
              ],
              onChanged: (value) {
                if (value == null) return;
                setSheetState(() => _gradeScale = value);
                setState(() => _gradeScale = value);
                _persistInstitutionSettingsSilently();
              },
            ),
            const SizedBox(height: 12),
            _scaleRow('ممتاز', '90% - 100%'),
            _scaleRow('جيد جدًا', '80% - 89%'),
            _scaleRow('جيد', '70% - 79%'),
            _scaleRow('يحتاج دعم', 'أقل من 70%'),
            const SizedBox(height: 16),
            _primaryButton(
              label: _l10n.saveGradeScale,
              icon: Icons.save_outlined,
              onPressed: () async {
                Navigator.pop(context);
                await _saveInstitutionSettings(
                  successMessage: _l10n.gradeScaleSaved,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityLogSheet() {
    _showSettingsSheet(
      title: _l10n.auditLog,
      icon: Icons.history_edu_outlined,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: Future<List<Map<String, dynamic>>>.delayed(
          Duration.zero,
          _loadAuditLogs,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return _auditState(
              icon: Icons.warning_amber_rounded,
              title: _l10n.auditLogLoadFailed,
              message: _l10n.auditLogLoadFailedMessage,
              isError: true,
            );
          }

          final logs = snapshot.data ?? const <Map<String, dynamic>>[];
          if (logs.isNotEmpty && logs.first['__loadError'] == true) {
            return _auditState(
              icon: Icons.warning_amber_rounded,
              title: _l10n.auditLogLoadFailed,
              message: _l10n.auditLogLoadFailedMessage,
              isError: true,
            );
          }

          if (logs.isEmpty) {
            return _auditState(
              icon: Icons.manage_search_outlined,
              title: _l10n.noAuditEvents,
              message: _l10n.noAuditEventsMessage,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoTile(
                _l10n.sensitiveActions,
                _l10n.sensitiveActionsSubtitle,
              ),
              const SizedBox(height: 12),
              ...logs.map(_auditLogRow),
              const SizedBox(height: 16),
              _primaryButton(
                label: _l10n.openAdvancedSupervisorDashboard,
                icon: Icons.dashboard_customize_outlined,
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.supervisorDashboard);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNotificationSheet() {
    _showSettingsSheet(
      title: _l10n.alertSettings,
      icon: Icons.notifications_active_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          children: [
            SwitchListTile(
              value: _pushNotifications,
              onChanged: (value) {
                setSheetState(() => _pushNotifications = value);
                setState(() => _pushNotifications = value);
                _persistInstitutionSettingsSilently();
              },
              title: Text(_l10n.pushNotifications),
              subtitle: Text(_l10n.pushNotificationsInstitutionSubtitle),
            ),
            SwitchListTile(
              value: _emailNotifications,
              onChanged: (value) {
                setSheetState(() => _emailNotifications = value);
                setState(() => _emailNotifications = value);
                _persistInstitutionSettingsSilently();
              },
              title: Text(_l10n.emailAlerts),
              subtitle: Text(_l10n.emailAlertsSubtitle),
            ),
            SwitchListTile(
              value: _weeklyDigest,
              onChanged: (value) {
                setSheetState(() => _weeklyDigest = value);
                setState(() => _weeklyDigest = value);
                _persistInstitutionSettingsSilently();
              },
              title: Text(_l10n.weeklyDigest),
              subtitle: Text(_l10n.weeklyDigestSubtitle),
            ),
            const SizedBox(height: 12),
            _primaryButton(
              label: _l10n.advancedSettings,
              icon: Icons.tune_outlined,
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.notificationSettings);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLocaleSheet() {
    _showSettingsSheet(
      title: _l10n.languageAndRegion,
      icon: Icons.translate_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          children: [
            _dropdownField(
              label: _l10n.interfaceLanguage,
              value: _language,
              values: const ['العربية'],
              onChanged: (value) {
                if (value == null) return;
                setSheetState(() => _language = value);
                setState(() => _language = value);
                _persistInstitutionSettingsSilently();
              },
            ),
            const SizedBox(height: 12),
            _dropdownField(
              label: _l10n.timezone,
              value: _timezone,
              values: const ['Asia/Kuwait', 'Asia/Riyadh', 'Asia/Dubai'],
              onChanged: (value) {
                if (value == null) return;
                setSheetState(() => _timezone = value);
                setState(() => _timezone = value);
                _persistInstitutionSettingsSilently();
              },
            ),
            const SizedBox(height: 16),
            _primaryButton(
              label: _l10n.saveLanguageAndRegion,
              icon: Icons.save_outlined,
              onPressed: () async {
                Navigator.pop(context);
                await _saveInstitutionSettings(
                  successMessage: _l10n.languageAndRegionSaved,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showIntegrationsSheet() {
    _showSettingsSheet(
      title: _l10n.systemIntegrations,
      icon: Icons.hub_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile(_l10n.currentApiEndpoint, AppConstants.apiBaseUrl),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _sisIntegration,
              onChanged: (value) {
                setSheetState(() => _sisIntegration = value);
                setState(() => _sisIntegration = value);
                _persistInstitutionSettingsSilently();
              },
              title: Text(_l10n.sisIntegration),
              subtitle: Text(_l10n.sisIntegrationSubtitle),
            ),
            SwitchListTile(
              value: _lmsIntegration,
              onChanged: (value) {
                setSheetState(() => _lmsIntegration = value);
                setState(() => _lmsIntegration = value);
                _persistInstitutionSettingsSilently();
              },
              title: Text(_l10n.lmsIntegration),
              subtitle: Text(_l10n.lmsIntegrationSubtitle),
            ),
            const SizedBox(height: 12),
            _primaryButton(
              label: _l10n.requestIntegrationSupport,
              icon: Icons.support_agent_outlined,
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.support);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showArchiveDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_l10n.archiveDataWarning),
        content: Text(_l10n.archiveDataWarningMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveInstitutionSettings(
                successMessage: _l10n.archiveRequestSubmitted,
              );
            },
            child: Text(
              _l10n.submitRequest,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        initialValue: value,
        items: values
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  Widget _infoTile(String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _scaleRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _auditState({
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.error.withValues(alpha: 0.10)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? AppColors.error : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: isError ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isError ? AppColors.error : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _auditLogRow(Map<String, dynamic> log) {
    final colorScheme = Theme.of(context).colorScheme;
    final severity = (log['severity'] ?? log['level'] ?? 'medium').toString();
    final color = switch (severity) {
      'critical' => AppColors.error,
      'high' => AppColors.warning,
      'low' => AppColors.success,
      _ => AppColors.primary,
    };
    final action = (log['action'] ?? _l10n.unknownAction).toString();
    final actor = (log['actorName'] ?? _l10n.adminRole).toString();
    final target = (log['targetName'] ?? _l10n.system).toString();
    final time = _formatAuditTime(log['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(Icons.verified_user_outlined, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$actor • $target',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: colorScheme.outlineVariant),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.08),
          blurRadius: 6,
        ),
      ],
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }
}

enum _SettingsAction {
  academicYears,
  gradeScale,
  roles,
  activityLog,
  notifications,
  locale,
  integrations,
  accountSettings,
  about,
  support,
  logout,
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _SettingsAction action;
  final Color? color;
}
