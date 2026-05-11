/// App version management — single source of truth for version info.
/// Update this file with every release.
class AppVersion {
  AppVersion._();

  static const String current = '1.0.12';
  static const int buildNumber = 12;
  static const String releaseDate = 'مايو 2026';

  /// Full version string shown in UI
  static String get display => 'الإصدار $current ($buildNumber)';

  /// Complete changelog — newest first
  static const List<VersionEntry> changelog = [
    VersionEntry(
      version: '1.0.12',
      buildNumber: 12,
      date: 'مايو 2026',
      title: 'تفعيل إعدادات المؤسسة للمشرف',
      changes: [
        'تفعيل أزرار إعدادات المؤسسة بدل رسائل قيد التطوير',
        'ربط الأعوام الدراسية بإدارة الفصول وربط الأدوار بإدارة المستخدمين',
        'إضافة إعدادات تفاعلية لمقاييس التقييم والتنبيهات واللغة والمنطقة',
        'إضافة لوحة تكامل الأنظمة مع عرض واجهة API الحالية وطلب دعم الربط',
        'ربط زر إشعارات إعدادات المؤسسة بمركز الإشعارات الحقيقي',
      ],
      type: VersionType.feature,
    ),
    VersionEntry(
      version: '1.0.11',
      buildNumber: 11,
      date: 'مايو 2026',
      title: 'توحيد تجربة المشرف وحراسة التنقل',
      changes: [
        'تثبيت عناصر المشرف الأساسية في الشاشات الرئيسية: الرئيسية والإعدادات وعن التطبيق وتسجيل الخروج',
        'توحيد شريط التنقل السفلي لشاشات المشرف وإضافة الإعدادات كوجهة ثابتة',
        'إضافة قائمة إجراءات مشتركة للمشرف تعمل بنفس السلوك في الشاشات الإدارية',
        'منع الوصول المباشر لمسارات أدوار غير مناسبة عبر حراسة مركزية في GoRouter',
        'تقليل اختلاف التنقل بين إدارة المستخدمين والفصول والتقارير وإعدادات المؤسسة',
      ],
      type: VersionType.fix,
    ),
    VersionEntry(
      version: '1.0.10',
      buildNumber: 10,
      date: 'مايو 2026',
      title: 'إصلاح التسجيل واعتماد الحسابات ومسارات المشرف',
      changes: [
        'ربط إنشاء الحساب بواجهة API حقيقية بدلا من المحاكاة',
        'جعل حسابات Google الجديدة طلبات انضمام بانتظار موافقة المشرف',
        'منع دخول الحساب قبل تفعيل المشرف وتحديد الصف أو الفصول المناسبة',
        'تفعيل الموافقة على طلبات الانضمام من شاشة إدارة المستخدمين',
        'تصحيح رسائل Google والتسجيل عند انتظار اعتماد الحساب',
        'إصلاح مسارات إعدادات المؤسسة والرئيسية والاختبارات في واجهات المشرف',
      ],
      type: VersionType.fix,
    ),
    VersionEntry(
      version: '1.0.9',
      buildNumber: 9,
      date: 'مايو 2026',
      title: 'تحسين لوحات المشرف وفصل الإنتاج عن البيانات التجريبية',
      changes: [
        'تصحيح مسارات المشرف في لوحة الإدارة وربط الإعدادات بواجهة المؤسسة',
        'تصحيح انتقال الإشعارات في إدارة الفصول لمسار مشرف عام',
        'منع fallback التجريبي الصامت في إدارة المستخدمين وإدارة الفصول في وضع الإنتاج',
        'إضافة حالات خطأ واضحة مع زر إعادة المحاولة عند فشل API في شاشات المشرف الأساسية',
        'الحفاظ على بيانات Mock فقط عند تفعيل useMockData صراحة',
      ],
      type: VersionType.fix,
    ),
    VersionEntry(
      version: '1.0.8',
      buildNumber: 8,
      date: 'مايو 2026',
      title: 'إصلاح تدفق الاختبار التكيفي والجلسة',
      changes: [
        'إصلاح جلب السؤال التالي وإعادة نفس السؤال غير المُجاب عليه عند إعادة الطلب',
        'حفظ السؤال المعروض في الجلسة قبل الإرسال لمنع عدم تطابق السؤال مع المحاولة',
        'تحسين تحديث مستوى الصعوبة بالاعتماد على مستوى الجلسة الحالي',
        'إصلاح login/refresh/session وتحديث refreshToken بشكل متسق',
        'فصل Demo Mode عن Production وعدم إخفاء فشل API ببيانات تجريبية',
      ],
      type: VersionType.fix,
    ),
    VersionEntry(
      version: '1.0.7',
      buildNumber: 7,
      date: 'مايو 2026',
      title: 'إصلاح أخطاء لوحة المشرف',
      changes: [
        'إصلاح حفظ الاسم في إعدادات المشرف',
        'تفعيل أقسام الدعم الفني (عام، تقني، فواتير)',
        'تفعيل الشروحات التعليمية في الدعم',
        'إصلاح فلتر المعلمين في بطاقة الإحصاءات',
        'إصلاح فلتر الطلاب في بطاقة الإحصاءات',
        'إصلاح تنبيه "طلاب لم يؤدوا الاختبار"',
        'إصلاح تنبيه "طلبات الانضمام" مع فلتر pending',
        'إصلاح تنبيه "انخفاض في الأداء" مع فلتر الصف والمادة',
      ],
      type: VersionType.fix,
    ),
    VersionEntry(
      version: '1.0.6',
      buildNumber: 6,
      date: 'مايو 2026',
      title: 'التحميل والمشاركة الحقيقية',
      changes: [
        'تفعيل تحميل قالب Excel للأسئلة',
        'تفعيل تصدير التقارير كملف CSV حقيقي',
        'تفعيل تحميل الشهادات ومشاركتها',
        'تفعيل إرسال الشهادات للطلاب',
        'إضافة حزمة share_plus و url_launcher',
        'إصلاح تصدير تقرير الاختبار',
      ],
      type: VersionType.feature,
    ),
    VersionEntry(
      version: '1.0.5',
      buildNumber: 5,
      date: 'مايو 2026',
      title: 'استيراد Excel الحقيقي',
      changes: [
        'تفعيل file picker لاختيار ملفات Excel',
        'رفع حقيقي بـ multipart/form-data',
        'شريط تقدم الرفع بالنسبة المئوية',
        'عرض نتيجة الاستيراد مع تفاصيل الأخطاء',
        'سجل الاستيرادات السابقة',
      ],
      type: VersionType.feature,
    ),
    VersionEntry(
      version: '1.0.4',
      buildNumber: 5,
      date: 'مايو 2026',
      title: 'إصلاح الأزرار والنماذج',
      changes: [
        'تعديل الاختبار: نموذج كامل مع تغيير الحالة',
        'زر تعديل الأسئلة ينقل لبنك الأسئلة',
        'إضافة حصة للجدول الدراسي تعمل فعلياً',
        'إنشاء شهادة باسم مخصص مع معاينة حية',
      ],
      type: VersionType.fix,
    ),
    VersionEntry(
      version: '1.0.3',
      buildNumber: 4,
      date: 'مايو 2026',
      title: 'نماذج الشهادات',
      changes: [
        'إضافة 3 نماذج للشهادات (كلاسيكي، ذهبي، أخضر)',
        'معاينة حية للشهادة عند اختيار النموذج',
        'إصدار شهادات لجميع الناجحين دفعة واحدة',
        'إحصاءات الناجحين والراسبين',
      ],
      type: VersionType.feature,
    ),
    VersionEntry(
      version: '1.0.2',
      buildNumber: 3,
      date: 'مايو 2026',
      title: 'الفصول والشهادات',
      changes: [
        'المعلم يستطيع إنشاء فصول دراسية',
        'endpoint جديد للشهادات في الـ Backend',
        'شاشة فصولي: إحصاءات وتفاصيل كل فصل',
        'ربط الشهادات بالبيانات الحقيقية من MongoDB',
      ],
      type: VersionType.feature,
    ),
    VersionEntry(
      version: '1.0.1',
      buildNumber: 2,
      date: 'مايو 2026',
      title: 'إصلاح الجلسة والتنقل',
      changes: [
        'إصلاح الخروج عند تبديل التطبيقات',
        'حفظ الجلسة في FlutterSecureStorage',
        'استعادة الجلسة عند إعادة فتح التطبيق',
        'استخدام refreshListenable بدلاً من ref.watch في الـ Router',
      ],
      type: VersionType.fix,
    ),
    VersionEntry(
      version: '1.0.0',
      buildNumber: 1,
      date: 'مايو 2026',
      title: 'الإصدار الأول',
      changes: [
        'نشر Backend على Railway.app',
        'ربط MongoDB Atlas',
        'تسجيل الدخول الحقيقي بدلاً من Demo',
        'إصلاح جميع أخطاء TypeScript',
        'واجهة كاملة بالعربية RTL',
        'لوحة تحكم المشرف والمعلم والطالب',
        'بنك الأسئلة والاختبارات التكيفية',
        'التقارير والإحصاءات',
      ],
      type: VersionType.release,
    ),
  ];
}

enum VersionType { release, feature, fix, hotfix }

class VersionEntry {
  const VersionEntry({
    required this.version,
    required this.buildNumber,
    required this.date,
    required this.title,
    required this.changes,
    required this.type,
  });

  final String version;
  final int buildNumber;
  final String date;
  final String title;
  final List<String> changes;
  final VersionType type;
}
