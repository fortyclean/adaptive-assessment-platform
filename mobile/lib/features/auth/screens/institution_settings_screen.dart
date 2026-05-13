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

  Future<void> _loadInstitutionSettings() async {
    await _loadSavedInstitutionSettings();

    if (_allowLocalOnlySettings) return;

    try {
      final settings =
          await ref.read(adminRepositoryProvider).getInstitutionSettings();
      if (!mounted) return;
      setState(() => _applyInstitutionSettings(settings));
      await _saveSettingsLocally();
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        'تعذر تحميل إعدادات المؤسسة من الخادم. تم عرض آخر نسخة محفوظة.',
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
        'academicYear': prefs.getString('${_settingsPrefix}academicYear') ??
            _academicYear,
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
        'sisIntegration':
            prefs.getBool('${_settingsPrefix}sisIntegration') ??
                _sisIntegration,
        'lmsIntegration':
            prefs.getBool('${_settingsPrefix}lmsIntegration') ??
                _lmsIntegration,
      }),
    );
  }

  Future<void> _saveInstitutionSettings({String? successMessage}) async {
    await _saveSettingsLocally();

    if (!_allowLocalOnlySettings) {
      try {
        final settings = await ref
            .read(adminRepositoryProvider)
            .updateInstitutionSettings(_institutionSettingsPayload());
        if (mounted) setState(() => _applyInstitutionSettings(settings));
      } catch (_) {
        if (!mounted || successMessage == null) return;
        _showMessage(
          'تم الحفظ محلياً، لكن تعذر تحديث إعدادات المؤسسة على الخادم.',
          isError: true,
        );
        return;
      }
    }

    if (!mounted || successMessage == null) return;
    _showMessage(successMessage);
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

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFFBF8FF),
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
                _buildSettingsGroup(
                  title: 'الهيكل الأكاديمي',
                  items: const [
                    _SettingsItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'الأعوام الدراسية',
                      subtitle: 'إدارة الفصول والتواريخ الدراسية',
                      action: _SettingsAction.academicYears,
                    ),
                    _SettingsItem(
                      icon: Icons.grade_outlined,
                      title: 'مقاييس التقييم',
                      subtitle: 'تحديد سلم الدرجات والتقديرات',
                      action: _SettingsAction.gradeScale,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSettingsGroup(
                  title: 'إدارة المستخدمين',
                  items: const [
                    _SettingsItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'الأدوار والصلاحيات',
                      subtitle: 'تخصيص وصول المعلمين والإداريين',
                      action: _SettingsAction.roles,
                    ),
                    _SettingsItem(
                      icon: Icons.history_edu_outlined,
                      title: 'سجلات الأنشطة',
                      subtitle: 'تتبع الدخول وتغييرات النظام',
                      action: _SettingsAction.activityLog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSettingsGroup(
                  title: 'تفضيلات النظام',
                  items: const [
                    _SettingsItem(
                      icon: Icons.notifications_active_outlined,
                      title: 'إعدادات التنبيهات',
                      subtitle: 'البريد الإلكتروني والإشعارات الفورية',
                      action: _SettingsAction.notifications,
                    ),
                    _SettingsItem(
                      icon: Icons.translate_outlined,
                      title: 'اللغة والمنطقة',
                      subtitle: 'اللغة العربية، التوقيت المحلي',
                      action: _SettingsAction.locale,
                    ),
                    _SettingsItem(
                      icon: Icons.hub_outlined,
                      title: 'تكامل الأنظمة',
                      subtitle: 'ربط API والمزودين الخارجيين',
                      action: _SettingsAction.integrations,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSettingsGroup(
                  title: 'الحساب والدعم',
                  items: const [
                    _SettingsItem(
                      icon: Icons.account_circle_outlined,
                      title: 'إعدادات الحساب',
                      subtitle: 'الملف الشخصي وكلمة المرور وتفضيلات الحساب',
                      action: _SettingsAction.accountSettings,
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline_rounded,
                      title: 'عن التطبيق وسجل الإصدارات',
                      subtitle: 'الإصدار ${AppVersion.current} — EduAssess',
                      action: _SettingsAction.about,
                    ),
                    _SettingsItem(
                      icon: Icons.support_agent_outlined,
                      title: 'الدعم الفني',
                      subtitle: 'التواصل مع فريق الدعم والمساعدة',
                      action: _SettingsAction.support,
                    ),
                    _SettingsItem(
                      icon: Icons.logout_rounded,
                      title: 'تسجيل الخروج',
                      subtitle: 'إنهاء جلسة المشرف الحالية',
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

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF1E40AF),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'EduAssess',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () => context.push(AppRoutes.notificationCenter),
          ),
        ],
      );

  Widget _buildHeader() => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات المؤسسة',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'إدارة الهوية الأكاديمية وصلاحيات النظام',
            style: TextStyle(color: AppColors.outline, fontSize: 14),
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
                const Row(
                  children: [
                    Icon(Icons.school_outlined,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ملف المدرسة',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _showSchoolProfileDialog,
                  child: const Text(
                    'تعديل',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showMessage(
                      'يمكن تغيير الشعار من لوحة ربط التخزين عند تفعيل رفع الملفات.'),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC4C5D5)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, color: AppColors.primary, size: 32),
                        SizedBox(height: 4),
                        Text(
                          'الشعار',
                          style:
                              TextStyle(fontSize: 10, color: AppColors.outline),
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
                      const Text('اسم المؤسسة',
                          style: TextStyle(
                              color: AppColors.outline, fontSize: 12)),
                      Text(
                        _schoolName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('معلومات التواصل',
                          style: TextStyle(
                              color: AppColors.outline, fontSize: 12)),
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
  }) =>
      Container(
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F2FC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Color(0xFFC4C5D5))),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
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
                                color: item.color ?? AppColors.primary,
                                size: 20),
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
                                    color: item.color ?? AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    color: AppColors.outline,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_left,
                            color: item.color ?? AppColors.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < items.length - 1)
                    const Divider(
                      height: 1,
                      color: Color(0xFFC4C5D5),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ],
        ),
      );

  Widget _buildDangerZone() => OutlinedButton.icon(
        onPressed: _showArchiveDialog,
        icon: const Icon(Icons.archive_outlined, color: AppColors.error),
        label: const Text(
          'أرشفة بيانات المؤسسة',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
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
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حساب المشرف؟'),
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
        title: const Text('تعديل ملف المدرسة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المؤسسة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم التواصل'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration:
                    const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isNotEmpty && !newEmail.contains('@')) {
                _showMessage('البريد الإلكتروني غير صحيح', isError: true);
                return;
              }
              setState(() {
                _schoolName = nameController.text.trim().isEmpty
                    ? _schoolName
                    : nameController.text.trim();
                _schoolPhone = phoneController.text.trim().isEmpty
                    ? _schoolPhone
                    : phoneController.text.trim();
                _schoolEmail = newEmail.isEmpty ? _schoolEmail : newEmail;
              });
              Navigator.pop(ctx);
              await _saveInstitutionSettings(
                successMessage: 'تم حفظ بيانات المؤسسة',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showAcademicYearsSheet() {
    _showSettingsSheet(
      title: 'الأعوام الدراسية',
      icon: Icons.calendar_today_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dropdownField(
              label: 'العام الدراسي الحالي',
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
              label: 'الفصل الدراسي الحالي',
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
            _infoTile('إدارة الفصول',
                'افتح شاشة الفصول لتعديل الصفوف وربط المعلمين والطلاب.'),
            const SizedBox(height: 12),
            _primaryButton(
              label: 'فتح إدارة الفصول',
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
      title: 'مقاييس التقييم',
      icon: Icons.grade_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dropdownField(
              label: 'سلم التقديرات',
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
              label: 'حفظ مقياس التقييم',
              icon: Icons.save_outlined,
              onPressed: () async {
                Navigator.pop(context);
                await _saveInstitutionSettings(
                  successMessage: 'تم حفظ مقياس التقييم',
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
      title: 'سجلات الأنشطة',
      icon: Icons.history_edu_outlined,
      child: Column(
        children: [
          _activityRow('تحديث إعدادات المؤسسة', 'منذ قليل'),
          _activityRow('فتح إدارة المستخدمين', 'اليوم'),
          _activityRow('مراجعة تقارير المدرسة', 'هذا الأسبوع'),
          const SizedBox(height: 16),
          _primaryButton(
            label: 'فتح لوحة المشرف المتقدمة',
            icon: Icons.dashboard_customize_outlined,
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.supervisorDashboard);
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationSheet() {
    _showSettingsSheet(
      title: 'إعدادات التنبيهات',
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
              title: const Text('الإشعارات الفورية'),
              subtitle: const Text('تنبيهات داخل التطبيق للمشرف والمعلمين'),
            ),
            SwitchListTile(
              value: _emailNotifications,
              onChanged: (value) {
                setSheetState(() => _emailNotifications = value);
                setState(() => _emailNotifications = value);
                _persistInstitutionSettingsSilently();
              },
              title: const Text('تنبيهات البريد الإلكتروني'),
              subtitle: const Text('إرسال ملخصات وتنبيهات مهمة عبر البريد'),
            ),
            SwitchListTile(
              value: _weeklyDigest,
              onChanged: (value) {
                setSheetState(() => _weeklyDigest = value);
                setState(() => _weeklyDigest = value);
                _persistInstitutionSettingsSilently();
              },
              title: const Text('ملخص أسبوعي'),
              subtitle: const Text('ملخص أداء المؤسسة كل أسبوع'),
            ),
            const SizedBox(height: 12),
            _primaryButton(
              label: 'الإعدادات المتقدمة',
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
      title: 'اللغة والمنطقة',
      icon: Icons.translate_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          children: [
            _dropdownField(
              label: 'لغة الواجهة',
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
              label: 'المنطقة الزمنية',
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
              label: 'حفظ اللغة والمنطقة',
              icon: Icons.save_outlined,
              onPressed: () async {
                Navigator.pop(context);
                await _saveInstitutionSettings(
                  successMessage: 'تم حفظ اللغة والمنطقة',
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
      title: 'تكامل الأنظمة',
      icon: Icons.hub_outlined,
      child: StatefulBuilder(
        builder: (context, setSheetState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('واجهة API الحالية', AppConstants.apiBaseUrl),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _sisIntegration,
              onChanged: (value) {
                setSheetState(() => _sisIntegration = value);
                setState(() => _sisIntegration = value);
                _persistInstitutionSettingsSilently();
              },
              title: const Text('نظام معلومات الطلاب SIS'),
              subtitle: const Text('تجهيز الربط مع أنظمة سجلات الطلاب'),
            ),
            SwitchListTile(
              value: _lmsIntegration,
              onChanged: (value) {
                setSheetState(() => _lmsIntegration = value);
                setState(() => _lmsIntegration = value);
                _persistInstitutionSettingsSilently();
              },
              title: const Text('نظام إدارة التعلم LMS'),
              subtitle: const Text('تجهيز الربط مع منصات التعلم الخارجية'),
            ),
            const SizedBox(height: 12),
            _primaryButton(
              label: 'طلب دعم الربط',
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
        title: const Text('تحذير: أرشفة البيانات'),
        content: const Text(
          'سيتم إرسال طلب أرشفة بيانات المؤسسة للمراجعة الإدارية قبل التنفيذ، ولن تُحذف البيانات فورًا من هذا الزر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveInstitutionSettings(
                successMessage: 'تم تسجيل طلب الأرشفة للمراجعة',
              );
            },
            child: const Text(
              'إرسال الطلب',
              style: TextStyle(color: AppColors.error),
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

  Widget _infoTile(String title, String subtitle) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.outline)),
          ],
        ),
      );

  Widget _scaleRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _activityRow(String title, String time) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEFF6FF),
          child: Icon(Icons.check_circle_outline, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(time),
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      );

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
