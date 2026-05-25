// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'منصة التقييم التكيفي';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get chooseLanguage => 'اختيار اللغة';

  @override
  String get languageArabicSelected => 'اللغة: العربية';

  @override
  String get languageEnglishSelected => 'Language: English';

  @override
  String get languageChanged => 'تم تغيير لغة التطبيق';

  @override
  String get languageAndAppearance => 'المظهر واللغة';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get darkModeEnabled => 'مفعل على كل الشاشات المدعومة';

  @override
  String get darkModeDisabled => 'تطبيق المظهر الداكن على واجهات التطبيق';

  @override
  String get settings => 'الإعدادات';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get securityAndPrivacy => 'الأمان والخصوصية';

  @override
  String get other => 'أخرى';

  @override
  String get appearance => 'المظهر';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changePasswordSubtitle => 'تحديث كلمة مرور الحساب الحالي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get editNameTooltip => 'تعديل الاسم';

  @override
  String get profileSubtitle =>
      'تحكم في ملفك الشخصي وتفضيلات التطبيق من مكان واحد.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nameTooShort => 'الاسم يجب أن يحتوي على حرفين على الأقل';

  @override
  String get nameUpdated => 'تم تحديث الاسم بنجاح';

  @override
  String get saveFailed => 'تعذر حفظ التغييرات، يرجى المحاولة مرة أخرى';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get adminRole => 'مشرف';

  @override
  String get teacherRole => 'معلم';

  @override
  String get studentRole => 'طالب';

  @override
  String get userRole => 'مستخدم';

  @override
  String get notificationCenter => 'مركز الإشعارات';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get notificationSettingsSubtitle =>
      'الاختبارات، النتائج، التقارير والتنبيهات الفورية';

  @override
  String get assessmentNotifications => 'إشعارات الاختبارات';

  @override
  String get assessmentNotificationsSubtitle => 'تنبيهات الاختبارات الجديدة';

  @override
  String get resultNotifications => 'إشعارات النتائج';

  @override
  String get resultNotificationsSubtitle => 'تنبيهات عند صدور النتائج';

  @override
  String get resultNotificationSettings => 'إعدادات إشعارات النتائج';

  @override
  String get darkModeCurrentlyEnabled => 'مُفعّل حالياً';

  @override
  String get darkModeCurrentlyDisabled => 'مُعطّل حالياً';

  @override
  String get aboutAndChangelog => 'عن التطبيق وسجل الإصدارات';

  @override
  String versionLabel(Object version) {
    return 'الإصدار $version — EduAssess';
  }

  @override
  String get support => 'الدعم الفني';

  @override
  String get supportSubtitle => 'تواصل مع فريق الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get helpCenterSubtitle => 'الدعم الفني ومعلومات التطبيق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutQuestion => 'هل تريد تسجيل الخروج؟';

  @override
  String get logoutAccountQuestion => 'هل تريد تسجيل الخروج من حسابك؟';

  @override
  String get logoutConfirm => 'خروج';

  @override
  String get legalese => '© 2026 EduAssess. جميع الحقوق محفوظة.';

  @override
  String get smartAssessment => 'التقييم الذكي';

  @override
  String get studentFallbackName => 'طالب';

  @override
  String welcomeName(Object name) {
    return 'مرحباً بك، $name';
  }

  @override
  String registeredSubjectsCount(Object count) {
    return 'لديك $count مواد دراسية مسجلة لهذا الفصل';
  }

  @override
  String get searchSubjectHint => 'البحث عن مادة...';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterFirstTerm => 'الفصل الأول';

  @override
  String get filterScience => 'علمي';

  @override
  String get filterLiterary => 'أدبي';

  @override
  String get filterAcademic => 'أكاديمي';

  @override
  String get filterPractical => 'عملي';

  @override
  String get noMatchingSubjects => 'لا توجد مواد مطابقة';

  @override
  String get progressAchieved => 'التقدم المحرز';

  @override
  String get finalExamsPrepTitle => 'استعد للاختبارات النهائية!';

  @override
  String get finalExamsPrepSubtitle =>
      'راجع دروسك السابقة وقم بتقييم مستواك الآن من خلال قسم الاختبارات الذكية.';

  @override
  String get startNow => 'ابدأ الآن';
}
