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

  @override
  String get back => 'رجوع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get openAssessments => 'افتح الاختبارات';

  @override
  String get flashcardPracticeTitle => 'تدريب البطاقات';

  @override
  String get flashcardLoadFailedTitle => 'تعذر تحميل البطاقات';

  @override
  String get flashcardLoadFailedMessage =>
      'تعذر تجهيز بطاقات التدريب. تحقق من الاتصال ثم حاول مرة أخرى.';

  @override
  String get flashcardEmptyTitle => 'لا توجد بطاقات بعد';

  @override
  String get flashcardEmptyMessage =>
      'أكمل اختبارًا واحدًا حتى نبني لك بطاقات مبنية على أدائك.';

  @override
  String flashcardSemanticsAnswerVisible(Object skill) {
    return 'بطاقة $skill. الإجابة ظاهرة.';
  }

  @override
  String flashcardSemanticsTapToReveal(Object skill) {
    return 'بطاقة $skill. اضغط لإظهار الإجابة.';
  }

  @override
  String get needReview => 'أحتاج مراجعة';

  @override
  String get masteredIt => 'أتقنتها';

  @override
  String get showAnswer => 'أظهر الإجابة';

  @override
  String get answer => 'الإجابة';

  @override
  String get flashcardSummaryTitle => 'أنهيت تدريب البطاقات';

  @override
  String flashcardSummaryMessage(Object correctCount, Object totalCount) {
    return 'أتقنت $correctCount من $totalCount بطاقات. خصص مراجعة قصيرة للبطاقات التي احتجت فيها إلى إعادة.';
  }

  @override
  String get mastery => 'الإتقان';

  @override
  String get forReview => 'للمراجعة';

  @override
  String get restartPractice => 'أعد التدريب';

  @override
  String get backToLearningPlan => 'العودة لخطة التعلم';

  @override
  String get teacherFallbackName => 'المعلم';

  @override
  String teacherWelcome(Object name) {
    return 'مرحبًا، $name';
  }

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get search => 'بحث';

  @override
  String get teacherDashboardLoadFailed =>
      'تعذر تحميل بيانات لوحة المعلم. تحقق من الاتصال ثم أعد المحاولة.';

  @override
  String get totalStudents => 'إجمالي الطلاب';

  @override
  String get active => 'نشط';

  @override
  String get completed => 'مكتمل';

  @override
  String get draft => 'مسودة';

  @override
  String get average => 'المتوسط';

  @override
  String get createNewAssessment => 'إنشاء اختبار جديد';

  @override
  String get recentAssessments => 'آخر الاختبارات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noAssessmentsCreatedYet => 'لم تنشئ أي اختبار بعد';

  @override
  String get additionalTools => 'أدوات إضافية';

  @override
  String get taskManagement => 'إدارة المهام';

  @override
  String get certificates => 'الشهادات';

  @override
  String get classSchedule => 'الجدول الدراسي';

  @override
  String get myClasses => 'فصولي';

  @override
  String get assessmentReport => 'تقرير الاختبار';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get teacherReportLoadFailed => 'تعذر تحميل التقرير';

  @override
  String get nameHeader => 'الاسم';

  @override
  String get scoreHeader => 'النتيجة';

  @override
  String get statusHeader => 'الحالة';

  @override
  String get timeMinutesHeader => 'الوقت (دقيقة)';

  @override
  String get timeout => 'انتهى الوقت';

  @override
  String get resultsSummary => 'ملخص النتائج';

  @override
  String get classAverage => 'متوسط الصف';

  @override
  String get highestScore => 'أعلى درجة';

  @override
  String get lowestScore => 'أدنى درجة';

  @override
  String get scoreDistribution => 'توزيع الدرجات';

  @override
  String get skillMasteryLevels => 'مستويات إتقان المهارات';

  @override
  String get studentResults => 'نتائج الطلاب';

  @override
  String get noResultsYet => 'لا توجد نتائج بعد';

  @override
  String get coreConceptAnalysis => 'تحليل مفصل للمفاهيم الأساسية';

  @override
  String get goodMastery => 'إتقان جيد';

  @override
  String get needsImprovement => 'يحتاج تطوير';

  @override
  String targetPercent(Object percent) {
    return 'الهدف: $percent%';
  }

  @override
  String minutesSeconds(Object minutes, Object seconds) {
    return '$minutes دقيقة $seconds ثانية';
  }
}
