import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'منصة التقييم التكيفي'**
  String get appTitle;

  /// No description provided for @appLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get appLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get english;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختيار اللغة'**
  String get chooseLanguage;

  /// No description provided for @languageArabicSelected.
  ///
  /// In ar, this message translates to:
  /// **'اللغة: العربية'**
  String get languageArabicSelected;

  /// No description provided for @languageEnglishSelected.
  ///
  /// In ar, this message translates to:
  /// **'Language: English'**
  String get languageEnglishSelected;

  /// No description provided for @languageChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير لغة التطبيق'**
  String get languageChanged;

  /// No description provided for @languageAndAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر واللغة'**
  String get languageAndAppearance;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkMode;

  /// No description provided for @darkModeEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعل على كل الشاشات المدعومة'**
  String get darkModeEnabled;

  /// No description provided for @darkModeDisabled.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق المظهر الداكن على واجهات التطبيق'**
  String get darkModeDisabled;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @accountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get accountSettings;

  /// No description provided for @securityAndPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والخصوصية'**
  String get securityAndPrivacy;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث كلمة مرور الحساب الحالي'**
  String get changePasswordSubtitle;

  /// No description provided for @currentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get confirmNewPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور الحالية'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور الجديدة'**
  String get enterNewPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد كلمة المرور'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون 8 أحرف على الأقل'**
  String get passwordMinLength;

  /// No description provided for @passwordNeedsUppercase.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي على حرف كبير'**
  String get passwordNeedsUppercase;

  /// No description provided for @passwordNeedsDigit.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي على رقم'**
  String get passwordNeedsDigit;

  /// No description provided for @passwordRequirements.
  ///
  /// In ar, this message translates to:
  /// **'متطلبات كلمة المرور:'**
  String get passwordRequirements;

  /// No description provided for @passwordRequirementMin8.
  ///
  /// In ar, this message translates to:
  /// **'8 أحرف على الأقل'**
  String get passwordRequirementMin8;

  /// No description provided for @passwordRequirementUppercase.
  ///
  /// In ar, this message translates to:
  /// **'حرف كبير واحد على الأقل'**
  String get passwordRequirementUppercase;

  /// No description provided for @passwordRequirementDigit.
  ///
  /// In ar, this message translates to:
  /// **'رقم واحد على الأقل'**
  String get passwordRequirementDigit;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get passwordChangedSuccessfully;

  /// No description provided for @genericRetryError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ. يرجى المحاولة مرة أخرى'**
  String get genericRetryError;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @editName.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم'**
  String get editName;

  /// No description provided for @editNameTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاسم'**
  String get editNameTooltip;

  /// No description provided for @profileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحكم في ملفك الشخصي وتفضيلات التطبيق من مكان واحد.'**
  String get profileSubtitle;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @nameTooShort.
  ///
  /// In ar, this message translates to:
  /// **'الاسم يجب أن يحتوي على حرفين على الأقل'**
  String get nameTooShort;

  /// No description provided for @nameUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الاسم بنجاح'**
  String get nameUpdated;

  /// No description provided for @saveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ التغييرات، يرجى المحاولة مرة أخرى'**
  String get saveFailed;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @adminRole.
  ///
  /// In ar, this message translates to:
  /// **'مشرف'**
  String get adminRole;

  /// No description provided for @teacherRole.
  ///
  /// In ar, this message translates to:
  /// **'معلم'**
  String get teacherRole;

  /// No description provided for @studentRole.
  ///
  /// In ar, this message translates to:
  /// **'طالب'**
  String get studentRole;

  /// No description provided for @userRole.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get userRole;

  /// No description provided for @notificationCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز الإشعارات'**
  String get notificationCenter;

  /// No description provided for @notificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات، النتائج، التقارير والتنبيهات الفورية'**
  String get notificationSettingsSubtitle;

  /// No description provided for @assessmentNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الاختبارات'**
  String get assessmentNotifications;

  /// No description provided for @assessmentNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الاختبارات الجديدة'**
  String get assessmentNotificationsSubtitle;

  /// No description provided for @resultNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات النتائج'**
  String get resultNotifications;

  /// No description provided for @resultNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات عند صدور النتائج'**
  String get resultNotificationsSubtitle;

  /// No description provided for @resultNotificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات إشعارات النتائج'**
  String get resultNotificationSettings;

  /// No description provided for @darkModeCurrentlyEnabled.
  ///
  /// In ar, this message translates to:
  /// **'مُفعّل حالياً'**
  String get darkModeCurrentlyEnabled;

  /// No description provided for @darkModeCurrentlyDisabled.
  ///
  /// In ar, this message translates to:
  /// **'مُعطّل حالياً'**
  String get darkModeCurrentlyDisabled;

  /// No description provided for @aboutAndChangelog.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق وسجل الإصدارات'**
  String get aboutAndChangelog;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version} — EduAssess'**
  String versionLabel(Object version);

  /// No description provided for @support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get support;

  /// No description provided for @supportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع فريق الدعم'**
  String get supportSubtitle;

  /// No description provided for @helpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني ومعلومات التطبيق'**
  String get helpCenterSubtitle;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get logoutQuestion;

  /// No description provided for @logoutAccountQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج من حسابك؟'**
  String get logoutAccountQuestion;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get logoutConfirm;

  /// No description provided for @legalese.
  ///
  /// In ar, this message translates to:
  /// **'© 2026 EduAssess. جميع الحقوق محفوظة.'**
  String get legalese;

  /// No description provided for @smartAssessment.
  ///
  /// In ar, this message translates to:
  /// **'التقييم الذكي'**
  String get smartAssessment;

  /// No description provided for @studentFallbackName.
  ///
  /// In ar, this message translates to:
  /// **'طالب'**
  String get studentFallbackName;

  /// No description provided for @welcomeName.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك، {name}'**
  String welcomeName(Object name);

  /// No description provided for @registeredSubjectsCount.
  ///
  /// In ar, this message translates to:
  /// **'لديك {count} مواد دراسية مسجلة لهذا الفصل'**
  String registeredSubjectsCount(Object count);

  /// No description provided for @searchSubjectHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن مادة...'**
  String get searchSubjectHint;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterFirstTerm.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الأول'**
  String get filterFirstTerm;

  /// No description provided for @filterScience.
  ///
  /// In ar, this message translates to:
  /// **'علمي'**
  String get filterScience;

  /// No description provided for @filterLiterary.
  ///
  /// In ar, this message translates to:
  /// **'أدبي'**
  String get filterLiterary;

  /// No description provided for @filterAcademic.
  ///
  /// In ar, this message translates to:
  /// **'أكاديمي'**
  String get filterAcademic;

  /// No description provided for @filterPractical.
  ///
  /// In ar, this message translates to:
  /// **'عملي'**
  String get filterPractical;

  /// No description provided for @noMatchingSubjects.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواد مطابقة'**
  String get noMatchingSubjects;

  /// No description provided for @progressAchieved.
  ///
  /// In ar, this message translates to:
  /// **'التقدم المحرز'**
  String get progressAchieved;

  /// No description provided for @finalExamsPrepTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعد للاختبارات النهائية!'**
  String get finalExamsPrepTitle;

  /// No description provided for @finalExamsPrepSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'راجع دروسك السابقة وقم بتقييم مستواك الآن من خلال قسم الاختبارات الذكية.'**
  String get finalExamsPrepSubtitle;

  /// No description provided for @startNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get startNow;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @adminAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب المشرف'**
  String get adminAccount;

  /// No description provided for @fillBlankAnswerSemantics.
  ///
  /// In ar, this message translates to:
  /// **'أدخل إجابتك'**
  String get fillBlankAnswerSemantics;

  /// No description provided for @fillBlankAnswerHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك هنا...'**
  String get fillBlankAnswerHint;

  /// No description provided for @essayAnswerSemantics.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك المقالية'**
  String get essayAnswerSemantics;

  /// No description provided for @essayManualReviewNotice.
  ///
  /// In ar, this message translates to:
  /// **'هذا السؤال يتطلب مراجعة يدوية من المعلم'**
  String get essayManualReviewNotice;

  /// No description provided for @openAssessments.
  ///
  /// In ar, this message translates to:
  /// **'افتح الاختبارات'**
  String get openAssessments;

  /// No description provided for @flashcardPracticeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تدريب البطاقات'**
  String get flashcardPracticeTitle;

  /// No description provided for @flashcardLoadFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل البطاقات'**
  String get flashcardLoadFailedTitle;

  /// No description provided for @flashcardLoadFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تجهيز بطاقات التدريب. تحقق من الاتصال ثم حاول مرة أخرى.'**
  String get flashcardLoadFailedMessage;

  /// No description provided for @flashcardEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بطاقات بعد'**
  String get flashcardEmptyTitle;

  /// No description provided for @flashcardEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'أكمل اختبارًا واحدًا حتى نبني لك بطاقات مبنية على أدائك.'**
  String get flashcardEmptyMessage;

  /// No description provided for @flashcardSemanticsAnswerVisible.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة {skill}. الإجابة ظاهرة.'**
  String flashcardSemanticsAnswerVisible(Object skill);

  /// No description provided for @flashcardSemanticsTapToReveal.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة {skill}. اضغط لإظهار الإجابة.'**
  String flashcardSemanticsTapToReveal(Object skill);

  /// No description provided for @needReview.
  ///
  /// In ar, this message translates to:
  /// **'أحتاج مراجعة'**
  String get needReview;

  /// No description provided for @masteredIt.
  ///
  /// In ar, this message translates to:
  /// **'أتقنتها'**
  String get masteredIt;

  /// No description provided for @showAnswer.
  ///
  /// In ar, this message translates to:
  /// **'أظهر الإجابة'**
  String get showAnswer;

  /// No description provided for @answer.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة'**
  String get answer;

  /// No description provided for @flashcardSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنهيت تدريب البطاقات'**
  String get flashcardSummaryTitle;

  /// No description provided for @flashcardSummaryMessage.
  ///
  /// In ar, this message translates to:
  /// **'أتقنت {correctCount} من {totalCount} بطاقات. خصص مراجعة قصيرة للبطاقات التي احتجت فيها إلى إعادة.'**
  String flashcardSummaryMessage(Object correctCount, Object totalCount);

  /// No description provided for @mastery.
  ///
  /// In ar, this message translates to:
  /// **'الإتقان'**
  String get mastery;

  /// No description provided for @forReview.
  ///
  /// In ar, this message translates to:
  /// **'للمراجعة'**
  String get forReview;

  /// No description provided for @restartPractice.
  ///
  /// In ar, this message translates to:
  /// **'أعد التدريب'**
  String get restartPractice;

  /// No description provided for @backToLearningPlan.
  ///
  /// In ar, this message translates to:
  /// **'العودة لخطة التعلم'**
  String get backToLearningPlan;

  /// No description provided for @teacherFallbackName.
  ///
  /// In ar, this message translates to:
  /// **'المعلم'**
  String get teacherFallbackName;

  /// No description provided for @teacherWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا، {name}'**
  String teacherWelcome(Object name);

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @teacherDashboardLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات لوحة المعلم. تحقق من الاتصال ثم أعد المحاولة.'**
  String get teacherDashboardLoadFailed;

  /// No description provided for @totalStudents.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلاب'**
  String get totalStudents;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// No description provided for @draft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get draft;

  /// No description provided for @average.
  ///
  /// In ar, this message translates to:
  /// **'المتوسط'**
  String get average;

  /// No description provided for @createNewAssessment.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء اختبار جديد'**
  String get createNewAssessment;

  /// No description provided for @recentAssessments.
  ///
  /// In ar, this message translates to:
  /// **'آخر الاختبارات'**
  String get recentAssessments;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @noAssessmentsCreatedYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تنشئ أي اختبار بعد'**
  String get noAssessmentsCreatedYet;

  /// No description provided for @additionalTools.
  ///
  /// In ar, this message translates to:
  /// **'أدوات إضافية'**
  String get additionalTools;

  /// No description provided for @taskManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المهام'**
  String get taskManagement;

  /// No description provided for @certificates.
  ///
  /// In ar, this message translates to:
  /// **'الشهادات'**
  String get certificates;

  /// No description provided for @classSchedule.
  ///
  /// In ar, this message translates to:
  /// **'الجدول الدراسي'**
  String get classSchedule;

  /// No description provided for @myClasses.
  ///
  /// In ar, this message translates to:
  /// **'فصولي'**
  String get myClasses;

  /// No description provided for @assessmentReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الاختبار'**
  String get assessmentReport;

  /// No description provided for @exportCsv.
  ///
  /// In ar, this message translates to:
  /// **'تصدير CSV'**
  String get exportCsv;

  /// No description provided for @teacherReportLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل التقرير'**
  String get teacherReportLoadFailed;

  /// No description provided for @nameHeader.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get nameHeader;

  /// No description provided for @scoreHeader.
  ///
  /// In ar, this message translates to:
  /// **'النتيجة'**
  String get scoreHeader;

  /// No description provided for @statusHeader.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get statusHeader;

  /// No description provided for @timeMinutesHeader.
  ///
  /// In ar, this message translates to:
  /// **'الوقت (دقيقة)'**
  String get timeMinutesHeader;

  /// No description provided for @timeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت'**
  String get timeout;

  /// No description provided for @resultsSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص النتائج'**
  String get resultsSummary;

  /// No description provided for @classAverage.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الصف'**
  String get classAverage;

  /// No description provided for @highestScore.
  ///
  /// In ar, this message translates to:
  /// **'أعلى درجة'**
  String get highestScore;

  /// No description provided for @lowestScore.
  ///
  /// In ar, this message translates to:
  /// **'أدنى درجة'**
  String get lowestScore;

  /// No description provided for @scoreDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الدرجات'**
  String get scoreDistribution;

  /// No description provided for @skillMasteryLevels.
  ///
  /// In ar, this message translates to:
  /// **'مستويات إتقان المهارات'**
  String get skillMasteryLevels;

  /// No description provided for @studentResults.
  ///
  /// In ar, this message translates to:
  /// **'نتائج الطلاب'**
  String get studentResults;

  /// No description provided for @noResultsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج بعد'**
  String get noResultsYet;

  /// No description provided for @coreConceptAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل مفصل للمفاهيم الأساسية'**
  String get coreConceptAnalysis;

  /// No description provided for @goodMastery.
  ///
  /// In ar, this message translates to:
  /// **'إتقان جيد'**
  String get goodMastery;

  /// No description provided for @needsImprovement.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج تطوير'**
  String get needsImprovement;

  /// No description provided for @targetPercent.
  ///
  /// In ar, this message translates to:
  /// **'الهدف: {percent}%'**
  String targetPercent(Object percent);

  /// No description provided for @minutesSeconds.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة {seconds} ثانية'**
  String minutesSeconds(Object minutes, Object seconds);

  /// No description provided for @studentPerformanceReportType.
  ///
  /// In ar, this message translates to:
  /// **'أداء الطلاب العام'**
  String get studentPerformanceReportType;

  /// No description provided for @questionQualityReportType.
  ///
  /// In ar, this message translates to:
  /// **'جودة بنك الأسئلة'**
  String get questionQualityReportType;

  /// No description provided for @classroomComparisonReportType.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة الفصول الدراسية'**
  String get classroomComparisonReportType;

  /// No description provided for @skillAnalysisReportType.
  ///
  /// In ar, this message translates to:
  /// **'تقرير تحليل المهارات'**
  String get skillAnalysisReportType;

  /// No description provided for @daily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get monthly;

  /// No description provided for @reportSchedulesLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل جداول التقارير. تحقق من الاتصال ثم أعد المحاولة.'**
  String get reportSchedulesLoadFailed;

  /// No description provided for @addAtLeastOneEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إضافة بريد إلكتروني واحد على الأقل'**
  String get addAtLeastOneEmail;

  /// No description provided for @scheduleSavedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الجدول الزمني بنجاح'**
  String get scheduleSavedSuccessfully;

  /// No description provided for @scheduleSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ الجدول الزمني: {error}'**
  String scheduleSaveFailed(Object error);

  /// No description provided for @scheduleSavedDemo.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الجدول الزمني بنجاح (وضع تجريبي)'**
  String get scheduleSavedDemo;

  /// No description provided for @deleteScheduleTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الجدول'**
  String get deleteScheduleTitle;

  /// No description provided for @deleteScheduleConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الجدول الزمني؟'**
  String get deleteScheduleConfirmation;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @scheduleDeletedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الجدول بنجاح'**
  String get scheduleDeletedSuccessfully;

  /// No description provided for @scheduleDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف: {error}'**
  String scheduleDeleteFailed(Object error);

  /// No description provided for @scheduleToggleFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تغيير الحالة: {error}'**
  String scheduleToggleFailed(Object error);

  /// No description provided for @enterValidEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get enterValidEmail;

  /// No description provided for @reportScheduling.
  ///
  /// In ar, this message translates to:
  /// **'جدولة التقارير'**
  String get reportScheduling;

  /// No description provided for @reportSchedulingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بإعداد تقارير دورية يتم إرسالها تلقائياً إلى بريدك الإلكتروني.'**
  String get reportSchedulingSubtitle;

  /// No description provided for @newScheduleSetup.
  ///
  /// In ar, this message translates to:
  /// **'إعداد جدول جديد'**
  String get newScheduleSetup;

  /// No description provided for @reportType.
  ///
  /// In ar, this message translates to:
  /// **'نوع التقرير'**
  String get reportType;

  /// No description provided for @selectClasses.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الفصول'**
  String get selectClasses;

  /// No description provided for @frequency.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get frequency;

  /// No description provided for @deliveryTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التسليم'**
  String get deliveryTime;

  /// No description provided for @recipientEmails.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني للمستلمين'**
  String get recipientEmails;

  /// No description provided for @fileFormat.
  ///
  /// In ar, this message translates to:
  /// **'صيغة الملف'**
  String get fileFormat;

  /// No description provided for @saving.
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get saving;

  /// No description provided for @saveSchedule.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الجدول الزمني'**
  String get saveSchedule;

  /// No description provided for @enable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get enable;

  /// No description provided for @addClassSoon.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فصل جديد قريباً'**
  String get addClassSoon;

  /// No description provided for @addClass.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فصل'**
  String get addClass;

  /// No description provided for @activeSchedules.
  ///
  /// In ar, this message translates to:
  /// **'الجداول النشطة'**
  String get activeSchedules;

  /// No description provided for @reportsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تقارير'**
  String reportsCount(Object count);

  /// No description provided for @noActiveSchedules.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد جداول نشطة'**
  String get noActiveSchedules;

  /// No description provided for @createScheduleUsingForm.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ جدولاً جديداً باستخدام النموذج أعلاه'**
  String get createScheduleUsingForm;

  /// No description provided for @paused.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get paused;

  /// No description provided for @pendingEssaysTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة المقالية — بانتظار التصحيح'**
  String get pendingEssaysTitle;

  /// No description provided for @pendingEssaysLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الجلسات المعلقة'**
  String get pendingEssaysLoadFailed;

  /// No description provided for @noPendingEssaysTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسئلة مقالية بانتظار التصحيح'**
  String get noPendingEssaysTitle;

  /// No description provided for @noPendingEssaysMessage.
  ///
  /// In ar, this message translates to:
  /// **'جميع الجلسات المقالية تم تصحيحها'**
  String get noPendingEssaysMessage;

  /// No description provided for @assessmentFallbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبار'**
  String get assessmentFallbackTitle;

  /// No description provided for @startGrading.
  ///
  /// In ar, this message translates to:
  /// **'بدء التصحيح'**
  String get startGrading;

  /// No description provided for @questionsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سؤال'**
  String questionsCount(Object count);

  /// No description provided for @resultScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الاختبار'**
  String get resultScreenTitle;

  /// No description provided for @resultLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل النتيجة. يرجى المحاولة مرة أخرى.'**
  String get resultLoadFailed;

  /// No description provided for @skillAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'تحليل المهارات'**
  String get skillAnalysis;

  /// No description provided for @wrongQuestions.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الخاطئة'**
  String get wrongQuestions;

  /// No description provided for @pendingReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'في انتظار المراجعة'**
  String get pendingReviewTitle;

  /// No description provided for @pendingReviewMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم اختبارك بنجاح. يحتوي على {countText} أسئلة مقالية تحتاج إلى مراجعة يدوية من المعلم.\n\nستصلك إشعاراً عند اكتمال التصحيح.'**
  String pendingReviewMessage(Object countText);

  /// No description provided for @someQuestions.
  ///
  /// In ar, this message translates to:
  /// **'بعض'**
  String get someQuestions;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get backToHome;

  /// No description provided for @scoreExcellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get scoreExcellent;

  /// No description provided for @scoreGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get scoreGood;

  /// No description provided for @scoreNeedsImprovement.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج تحسين'**
  String get scoreNeedsImprovement;

  /// No description provided for @greatAchievement.
  ///
  /// In ar, this message translates to:
  /// **'إنجاز رائع!'**
  String get greatAchievement;

  /// No description provided for @earnedExcellenceBadge.
  ///
  /// In ar, this message translates to:
  /// **'حصلت على شارة التميز'**
  String get earnedExcellenceBadge;

  /// No description provided for @pointsEarnedLabel.
  ///
  /// In ar, this message translates to:
  /// **'+{points} نقطة'**
  String pointsEarnedLabel(Object points);

  /// No description provided for @bonusPointsLabel.
  ///
  /// In ar, this message translates to:
  /// **'+{points} مكافأة'**
  String bonusPointsLabel(Object points);

  /// No description provided for @strengthPoint.
  ///
  /// In ar, this message translates to:
  /// **'نقطة قوة'**
  String get strengthPoint;

  /// No description provided for @yourAnswer.
  ///
  /// In ar, this message translates to:
  /// **'إجابتك'**
  String get yourAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة الصحيحة'**
  String get correctAnswer;

  /// No description provided for @studentAssessmentsLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الاختبارات. تحقق من الاتصال ثم أعد المحاولة.'**
  String get studentAssessmentsLoadFailed;

  /// No description provided for @studentAssessmentsGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك، {name}'**
  String studentAssessmentsGreeting(Object name);

  /// No description provided for @studentAssessmentsAvailableToday.
  ///
  /// In ar, this message translates to:
  /// **'لديك {count} {label} اليوم للبدء بها.'**
  String studentAssessmentsAvailableToday(Object count, Object label);

  /// No description provided for @availableAssessmentSingular.
  ///
  /// In ar, this message translates to:
  /// **'اختبار متاح'**
  String get availableAssessmentSingular;

  /// No description provided for @availableAssessmentPlural.
  ///
  /// In ar, this message translates to:
  /// **'اختبارات متاحة'**
  String get availableAssessmentPlural;

  /// No description provided for @availableAssessments.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات المتاحة'**
  String get availableAssessments;

  /// No description provided for @upcomingAssessments.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get upcomingAssessments;

  /// No description provided for @previousResults.
  ///
  /// In ar, this message translates to:
  /// **'النتائج السابقة'**
  String get previousResults;

  /// No description provided for @noAvailableAssessmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اختبارات متاحة'**
  String get noAvailableAssessmentsTitle;

  /// No description provided for @noAvailableAssessmentsMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الاختبارات المتاحة هنا عند نشرها من قِبل المعلم'**
  String get noAvailableAssessmentsMessage;

  /// No description provided for @noUpcomingAssessmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اختبارات قادمة'**
  String get noUpcomingAssessmentsTitle;

  /// No description provided for @noUpcomingAssessmentsMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر الاختبارات المجدولة مستقبلاً هنا'**
  String get noUpcomingAssessmentsMessage;

  /// No description provided for @noPreviousResultsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج سابقة'**
  String get noPreviousResultsTitle;

  /// No description provided for @noPreviousResultsMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر نتائج اختباراتك المكتملة هنا'**
  String get noPreviousResultsMessage;

  /// No description provided for @assessmentFallback.
  ///
  /// In ar, this message translates to:
  /// **'اختبار'**
  String get assessmentFallback;

  /// No description provided for @notStartedYet.
  ///
  /// In ar, this message translates to:
  /// **'لم يبدأ بعد'**
  String get notStartedYet;

  /// No description provided for @questionCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} سؤال'**
  String questionCountLabel(Object count);

  /// No description provided for @minuteCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String minuteCountLabel(Object count);

  /// No description provided for @finalReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'المراجعة النهائية'**
  String get finalReviewTitle;

  /// No description provided for @finalReviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استعد لاختبارات نهاية العام مع نماذجنا الذكية'**
  String get finalReviewSubtitle;

  /// No description provided for @recentResults.
  ///
  /// In ar, this message translates to:
  /// **'النتائج الأخيرة'**
  String get recentResults;

  /// No description provided for @day.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get day;

  /// No description provided for @completedOn.
  ///
  /// In ar, this message translates to:
  /// **'تم الانتهاء: {day} {month}'**
  String completedOn(Object day, Object month);

  /// No description provided for @review.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get review;

  /// No description provided for @unexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get unexpectedError;

  /// No description provided for @monthJanuary.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In ar, this message translates to:
  /// **'يوليو'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In ar, this message translates to:
  /// **'أغسطس'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In ar, this message translates to:
  /// **'أكتوبر'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In ar, this message translates to:
  /// **'نوفمبر'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In ar, this message translates to:
  /// **'ديسمبر'**
  String get monthDecember;

  /// No description provided for @assessmentStartTitle.
  ///
  /// In ar, this message translates to:
  /// **'بدء الاختبار'**
  String get assessmentStartTitle;

  /// No description provided for @assessmentLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات الاختبار. تحقق من الاتصال ثم أعد المحاولة.'**
  String get assessmentLoadFailed;

  /// No description provided for @assessmentStartFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر بدء الاختبار. يرجى المحاولة مرة أخرى.'**
  String get assessmentStartFailed;

  /// No description provided for @assessmentTypeAdaptive.
  ///
  /// In ar, this message translates to:
  /// **'تكيفي'**
  String get assessmentTypeAdaptive;

  /// No description provided for @assessmentTypeRandom.
  ///
  /// In ar, this message translates to:
  /// **'عشوائي'**
  String get assessmentTypeRandom;

  /// No description provided for @questionCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأسئلة'**
  String get questionCount;

  /// No description provided for @timeLimit.
  ///
  /// In ar, this message translates to:
  /// **'الوقت المحدد'**
  String get timeLimit;

  /// No description provided for @teacher.
  ///
  /// In ar, this message translates to:
  /// **'المعلم'**
  String get teacher;

  /// No description provided for @previousScore.
  ///
  /// In ar, this message translates to:
  /// **'نتيجتك السابقة'**
  String get previousScore;

  /// No description provided for @navigationWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تسجيل أي محاولة للخروج من شاشة الاختبار'**
  String get navigationWarning;

  /// No description provided for @startAssessmentNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الاختبار الآن'**
  String get startAssessmentNow;

  /// No description provided for @assessmentUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الاختبار غير متاح'**
  String get assessmentUnavailable;

  /// No description provided for @answerSubmitFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال الإجابة. تحقق من الاتصال ثم أعد المحاولة.'**
  String get answerSubmitFailed;

  /// No description provided for @assessmentSubmitFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تسليم الاختبار. يرجى المحاولة مرة أخرى.'**
  String get assessmentSubmitFailed;

  /// No description provided for @questionLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل السؤال من الخادم. يرجى إعادة المحاولة أو الرجوع.'**
  String get questionLoadFailed;

  /// No description provided for @confirmExit.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الخروج'**
  String get confirmExit;

  /// No description provided for @exitAssessmentPrompt.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد الخروج من الاختبار؟ سيتم حفظ إجاباتك.'**
  String get exitAssessmentPrompt;

  /// No description provided for @exit.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get exit;

  /// No description provided for @questionProgress.
  ///
  /// In ar, this message translates to:
  /// **'السؤال {current} من {total}'**
  String questionProgress(Object current, Object total);

  /// No description provided for @submitAssessment.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الاختبار'**
  String get submitAssessment;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @noQuestions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسئلة'**
  String get noQuestions;

  /// No description provided for @chooseCorrectAnswer.
  ///
  /// In ar, this message translates to:
  /// **'اختر الإجابة الصحيحة:'**
  String get chooseCorrectAnswer;

  /// No description provided for @trueLabel.
  ///
  /// In ar, this message translates to:
  /// **'صحيح'**
  String get trueLabel;

  /// No description provided for @falseLabel.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get falseLabel;

  /// No description provided for @questionTypeMcq.
  ///
  /// In ar, this message translates to:
  /// **'اختيار متعدد'**
  String get questionTypeMcq;

  /// No description provided for @questionTypeTrueFalse.
  ///
  /// In ar, this message translates to:
  /// **'صح أو خطأ'**
  String get questionTypeTrueFalse;

  /// No description provided for @questionTypeFillBlank.
  ///
  /// In ar, this message translates to:
  /// **'ملء الفراغ'**
  String get questionTypeFillBlank;

  /// No description provided for @questionTypeEssay.
  ///
  /// In ar, this message translates to:
  /// **'مقالي'**
  String get questionTypeEssay;

  /// No description provided for @questionTypeGeneric.
  ///
  /// In ar, this message translates to:
  /// **'سؤال'**
  String get questionTypeGeneric;

  /// No description provided for @writeAnswerHere.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك هنا...'**
  String get writeAnswerHere;

  /// No description provided for @confirmAnswer.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإجابة'**
  String get confirmAnswer;

  /// No description provided for @essayReviewNotice.
  ///
  /// In ar, this message translates to:
  /// **'سيتم مراجعة إجابتك من قِبل المعلم وتحديد الدرجة لاحقاً'**
  String get essayReviewNotice;

  /// No description provided for @writeEssayAnswerHere.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك المقالية هنا...'**
  String get writeEssayAnswerHere;

  /// No description provided for @submitAnswer.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الإجابة'**
  String get submitAnswer;

  /// No description provided for @marketplaceTabAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get marketplaceTabAll;

  /// No description provided for @marketplaceTabAvatars.
  ///
  /// In ar, this message translates to:
  /// **'الأفاتار'**
  String get marketplaceTabAvatars;

  /// No description provided for @marketplaceTabThemes.
  ///
  /// In ar, this message translates to:
  /// **'القوالب'**
  String get marketplaceTabThemes;

  /// No description provided for @marketplaceTabGuides.
  ///
  /// In ar, this message translates to:
  /// **'الأدلة'**
  String get marketplaceTabGuides;

  /// No description provided for @marketplaceNotificationsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get marketplaceNotificationsTooltip;

  /// No description provided for @currentBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get currentBalance;

  /// No description provided for @marketplaceLevelLabel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى 14: عبقري رياضيات'**
  String get marketplaceLevelLabel;

  /// No description provided for @myCollection.
  ///
  /// In ar, this message translates to:
  /// **'مجموعتي'**
  String get myCollection;

  /// No description provided for @ownedActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get ownedActive;

  /// No description provided for @emptyCollectionMessage.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف أي مقتنيات بعد. اشترِ أول مكافأة وستظهر هنا.'**
  String get emptyCollectionMessage;

  /// No description provided for @marketplaceEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر في هذا القسم'**
  String get marketplaceEmptyTitle;

  /// No description provided for @marketplaceEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'جرّب قسمًا آخر أو عد لاحقًا عند إضافة مكافآت جديدة.'**
  String get marketplaceEmptyMessage;

  /// No description provided for @insufficientBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد غير كافٍ'**
  String get insufficientBalance;

  /// No description provided for @activate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get activate;

  /// No description provided for @purchase.
  ///
  /// In ar, this message translates to:
  /// **'شراء'**
  String get purchase;

  /// No description provided for @confirmPurchase.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الشراء'**
  String get confirmPurchase;

  /// No description provided for @purchaseConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم خصم {price} نقطة من رصيدك لشراء \"{title}\".'**
  String purchaseConfirmMessage(Object price, Object title);

  /// No description provided for @purchaseNeedMorePoints.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج إلى {points} نقطة إضافية لشراء \"{title}\".'**
  String purchaseNeedMorePoints(Object points, Object title);

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get ok;

  /// No description provided for @addedToCollection.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى مجموعتك'**
  String get addedToCollection;

  /// No description provided for @purchaseSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم شراء \"{title}\" بنجاح. الرصيد المتبقي: {balance} نقطة.'**
  String purchaseSuccessMessage(Object title, Object balance);

  /// No description provided for @activated.
  ///
  /// In ar, this message translates to:
  /// **'تم التفعيل'**
  String get activated;

  /// No description provided for @activationSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل \"{title}\" داخل مجموعتك.'**
  String activationSuccessMessage(Object title);

  /// No description provided for @emptyCollectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مقتنيات'**
  String get emptyCollectionTitle;

  /// No description provided for @emptyCollectionSheetMessage.
  ///
  /// In ar, this message translates to:
  /// **'اشترِ عنصرًا من المتجر ليظهر هنا.'**
  String get emptyCollectionSheetMessage;

  /// No description provided for @activeNow.
  ///
  /// In ar, this message translates to:
  /// **'نشط الآن'**
  String get activeNow;

  /// No description provided for @availableToActivate.
  ///
  /// In ar, this message translates to:
  /// **'متاح للتفعيل'**
  String get availableToActivate;

  /// No description provided for @recentTransactions.
  ///
  /// In ar, this message translates to:
  /// **'آخر العمليات'**
  String get recentTransactions;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @owned.
  ///
  /// In ar, this message translates to:
  /// **'مملوك'**
  String get owned;

  /// No description provided for @extraTimeShortTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت إضافي'**
  String get extraTimeShortTitle;

  /// No description provided for @marketItemExplorerAvatarTitle.
  ///
  /// In ar, this message translates to:
  /// **'أفاتار: المستكشف'**
  String get marketItemExplorerAvatarTitle;

  /// No description provided for @marketItemExplorerAvatarDescription.
  ///
  /// In ar, this message translates to:
  /// **'أفاتار مميز يظهر في ملفك الشخصي ولوحة التحديات.'**
  String get marketItemExplorerAvatarDescription;

  /// No description provided for @marketItemRareBadge.
  ///
  /// In ar, this message translates to:
  /// **'نادر'**
  String get marketItemRareBadge;

  /// No description provided for @marketItemGoldenThemeTitle.
  ///
  /// In ar, this message translates to:
  /// **'قالب: الغروب الذهبي'**
  String get marketItemGoldenThemeTitle;

  /// No description provided for @marketItemGoldenThemeDescription.
  ///
  /// In ar, this message translates to:
  /// **'قالب لوني خاص لتخصيص تجربة التعلم.'**
  String get marketItemGoldenThemeDescription;

  /// No description provided for @marketItemExclusiveBadge.
  ///
  /// In ar, this message translates to:
  /// **'حصري'**
  String get marketItemExclusiveBadge;

  /// No description provided for @marketItemAlgebraGuideTitle.
  ///
  /// In ar, this message translates to:
  /// **'أسرار الجبر المتقدم'**
  String get marketItemAlgebraGuideTitle;

  /// No description provided for @marketItemAlgebraGuideDescription.
  ///
  /// In ar, this message translates to:
  /// **'دليل شامل مع تمارين تفاعلية وحلول مختصرة.'**
  String get marketItemAlgebraGuideDescription;

  /// No description provided for @marketItemStudyGuideBadge.
  ///
  /// In ar, this message translates to:
  /// **'دليل دراسي'**
  String get marketItemStudyGuideBadge;

  /// No description provided for @marketItemTopStudentAvatarTitle.
  ///
  /// In ar, this message translates to:
  /// **'أفاتار: المتفوقة'**
  String get marketItemTopStudentAvatarTitle;

  /// No description provided for @marketItemTopStudentAvatarDescription.
  ///
  /// In ar, this message translates to:
  /// **'أفاتار احتفالي للطلاب أصحاب الإنجازات العالية.'**
  String get marketItemTopStudentAvatarDescription;

  /// No description provided for @marketItemXpBoosterTitle.
  ///
  /// In ar, this message translates to:
  /// **'مضاعف XP لمدة ساعة'**
  String get marketItemXpBoosterTitle;

  /// No description provided for @marketItemXpBoosterDescription.
  ///
  /// In ar, this message translates to:
  /// **'يزيد نقاط الخبرة المكتسبة في الجلسة القادمة.'**
  String get marketItemXpBoosterDescription;

  /// No description provided for @marketItemExtraTimeTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكافأة وقت إضافي'**
  String get marketItemExtraTimeTitle;

  /// No description provided for @marketItemExtraTimeDescription.
  ///
  /// In ar, this message translates to:
  /// **'مقتنى تجريبي نشط يظهر كيف تبدو العناصر المملوكة.'**
  String get marketItemExtraTimeDescription;

  /// No description provided for @myClassesTitle.
  ///
  /// In ar, this message translates to:
  /// **'فصولي الدراسية'**
  String get myClassesTitle;

  /// No description provided for @addNewClass.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فصل جديد'**
  String get addNewClass;

  /// No description provided for @className.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفصل'**
  String get className;

  /// No description provided for @classNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أولى متوسط (أ)'**
  String get classNameHint;

  /// No description provided for @gradeLevel.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الدراسية'**
  String get gradeLevel;

  /// No description provided for @gradeLevelHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الصف الأول المتوسط'**
  String get gradeLevelHint;

  /// No description provided for @create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get create;

  /// No description provided for @unspecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get unspecified;

  /// No description provided for @classCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الفصل: {name}'**
  String classCreated(Object name);

  /// No description provided for @createClassForbidden.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك صلاحية إنشاء فصل'**
  String get createClassForbidden;

  /// No description provided for @serverConnectionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالخادم'**
  String get serverConnectionFailed;

  /// No description provided for @students.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get students;

  /// No description provided for @activeAssessments.
  ///
  /// In ar, this message translates to:
  /// **'اختبارات نشطة'**
  String get activeAssessments;

  /// No description provided for @averagePerformance.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الأداء'**
  String get averagePerformance;

  /// No description provided for @createAssessmentForClass.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء اختبار لهذا الفصل'**
  String get createAssessmentForClass;

  /// No description provided for @viewClassReport.
  ///
  /// In ar, this message translates to:
  /// **'عرض تقرير الفصل'**
  String get viewClassReport;

  /// No description provided for @classCertificates.
  ///
  /// In ar, this message translates to:
  /// **'شهادات الفصل'**
  String get classCertificates;

  /// No description provided for @addClassTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فصل'**
  String get addClassTooltip;

  /// No description provided for @newClass.
  ///
  /// In ar, this message translates to:
  /// **'فصل جديد'**
  String get newClass;

  /// No description provided for @classes.
  ///
  /// In ar, this message translates to:
  /// **'الفصول'**
  String get classes;

  /// No description provided for @studentCountCompact.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب'**
  String studentCountCompact(Object count);

  /// No description provided for @activeAssessmentCountCompact.
  ///
  /// In ar, this message translates to:
  /// **'{count} نشط'**
  String activeAssessmentCountCompact(Object count);

  /// No description provided for @averageScoreCompact.
  ///
  /// In ar, this message translates to:
  /// **'{score}% متوسط'**
  String averageScoreCompact(Object score);

  /// No description provided for @report.
  ///
  /// In ar, this message translates to:
  /// **'التقرير'**
  String get report;

  /// No description provided for @assessment.
  ///
  /// In ar, this message translates to:
  /// **'اختبار'**
  String get assessment;

  /// No description provided for @noClassesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فصول دراسية بعد'**
  String get noClassesYet;

  /// No description provided for @noClassesMessage.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإنشاء فصل دراسي لتنظيم طلابك وإدارة اختباراتهم.'**
  String get noClassesMessage;

  /// No description provided for @manageAssessmentsLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الاختبارات من الخادم. تحقق من الاتصال ثم أعد المحاولة.'**
  String get manageAssessmentsLoadFailed;

  /// No description provided for @editAssessment.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاختبار'**
  String get editAssessment;

  /// No description provided for @assessmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الاختبار'**
  String get assessmentTitle;

  /// No description provided for @subject.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get subject;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @archived.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get archived;

  /// No description provided for @editQuestionsFromBank.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الأسئلة من بنك الأسئلة'**
  String get editQuestionsFromBank;

  /// No description provided for @changesSavedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات بنجاح'**
  String get changesSavedSuccessfully;

  /// No description provided for @savedLocally.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ محلياً'**
  String get savedLocally;

  /// No description provided for @assessmentPublishedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر الاختبار بنجاح'**
  String get assessmentPublishedSuccessfully;

  /// No description provided for @assessmentPublishFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر نشر الاختبار. تحقق من الاتصال ثم حاول مرة أخرى.'**
  String get assessmentPublishFailed;

  /// No description provided for @manageAssessmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get manageAssessmentsTitle;

  /// No description provided for @manageAssessmentsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة وتتبع جميع الاختبارات الخاصة بك.'**
  String get manageAssessmentsSubtitle;

  /// No description provided for @noTeacherAssessmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اختبارات'**
  String get noTeacherAssessmentsTitle;

  /// No description provided for @noTeacherAssessmentsMessage.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإنشاء اختبارك الأول.'**
  String get noTeacherAssessmentsMessage;

  /// No description provided for @questionsCountUnknown.
  ///
  /// In ar, this message translates to:
  /// **'-- سؤال'**
  String get questionsCountUnknown;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @deleteAssessmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الاختبار'**
  String get deleteAssessmentTitle;

  /// No description provided for @deleteAssessmentConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا الاختبار؟'**
  String get deleteAssessmentConfirmation;

  /// No description provided for @assessmentDeletedLocally.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الاختبار'**
  String get assessmentDeletedLocally;

  /// No description provided for @publish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get publish;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @live.
  ///
  /// In ar, this message translates to:
  /// **'مباشر'**
  String get live;

  /// No description provided for @assessmentCreatedAndPublishedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الاختبار ونشره بنجاح'**
  String get assessmentCreatedAndPublishedSuccessfully;

  /// No description provided for @assessmentSavedAsDraftSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الاختبار كمسودة بنجاح'**
  String get assessmentSavedAsDraftSuccessfully;

  /// No description provided for @insufficientQuestionsWarning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير: عدد الأسئلة المتاحة أقل من المطلوب'**
  String get insufficientQuestionsWarning;

  /// No description provided for @assessmentCreatedDemoMode.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الاختبار بنجاح (وضع تجريبي)'**
  String get assessmentCreatedDemoMode;

  /// No description provided for @assessmentCreateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء الاختبار. تحقق من الاتصال والبيانات ثم حاول مرة أخرى.'**
  String get assessmentCreateFailed;

  /// No description provided for @assessmentTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: اختبار الوحدة الأولى'**
  String get assessmentTitleHint;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get requiredField;

  /// No description provided for @chooseSubject.
  ///
  /// In ar, this message translates to:
  /// **'اختر المادة'**
  String get chooseSubject;

  /// No description provided for @unitOrChapter.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة / الفصل'**
  String get unitOrChapter;

  /// No description provided for @unitHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الوحدة الأولى'**
  String get unitHint;

  /// No description provided for @assessmentType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الاختبار'**
  String get assessmentType;

  /// No description provided for @randomAssessment.
  ///
  /// In ar, this message translates to:
  /// **'اختبار عشوائي'**
  String get randomAssessment;

  /// No description provided for @randomAssessmentDescription.
  ///
  /// In ar, this message translates to:
  /// **'يتم اختيار الأسئلة بشكل عشوائي من بنك الأسئلة.'**
  String get randomAssessmentDescription;

  /// No description provided for @adaptiveAssessment.
  ///
  /// In ar, this message translates to:
  /// **'اختبار تكيفي'**
  String get adaptiveAssessment;

  /// No description provided for @adaptiveAssessmentDescription.
  ///
  /// In ar, this message translates to:
  /// **'تتغير صعوبة الأسئلة بناءً على إجابات الطالب.'**
  String get adaptiveAssessmentDescription;

  /// No description provided for @questionUnit.
  ///
  /// In ar, this message translates to:
  /// **'سؤال'**
  String get questionUnit;

  /// No description provided for @timeInMinutes.
  ///
  /// In ar, this message translates to:
  /// **'الزمن (بالدقائق)'**
  String get timeInMinutes;

  /// No description provided for @minuteUnit.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get minuteUnit;

  /// No description provided for @chooseGradeLevel.
  ///
  /// In ar, this message translates to:
  /// **'اختر المرحلة...'**
  String get chooseGradeLevel;

  /// No description provided for @classrooms.
  ///
  /// In ar, this message translates to:
  /// **'الفصول الدراسية'**
  String get classrooms;

  /// No description provided for @noLinkedClassroomsMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فصول مرتبطة بعد. يمكنك حفظ الاختبار كمسودة، لكن النشر يحتاج فصلًا واحدًا على الأقل.'**
  String get noLinkedClassroomsMessage;

  /// No description provided for @availabilityWindow.
  ///
  /// In ar, this message translates to:
  /// **'نافذة التوفر'**
  String get availabilityWindow;

  /// No description provided for @startDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get endDate;

  /// No description provided for @publishImmediatelyTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشر الاختبار مباشرة بعد الإنشاء'**
  String get publishImmediatelyTitle;

  /// No description provided for @publishImmediatelySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يتطلب اختيار فصل واحد على الأقل حتى تصل الإشعارات للطلاب.'**
  String get publishImmediatelySubtitle;

  /// No description provided for @confirmCreateAndPublishAssessment.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد وإنشاء ونشر الاختبار'**
  String get confirmCreateAndPublishAssessment;

  /// No description provided for @saveAssessmentAsDraft.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الاختبار كمسودة'**
  String get saveAssessmentAsDraft;

  /// No description provided for @classScheduleTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجداول الدراسية'**
  String get classScheduleTitle;

  /// No description provided for @scheduleOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات الجدول'**
  String get scheduleOptions;

  /// No description provided for @currentWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع الحالي'**
  String get currentWeek;

  /// No description provided for @weeklySchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول الأسبوع'**
  String get weeklySchedule;

  /// No description provided for @scheduleLocalOnlyMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد API للجدول الدراسي بعد. ستظهر الحصص الحقيقية هنا عند الربط، ويمكنك الآن إضافة حصص محلية لليوم المحدد بدون عرض بيانات وهمية.'**
  String get scheduleLocalOnlyMessage;

  /// No description provided for @addOrEditLesson.
  ///
  /// In ar, this message translates to:
  /// **'إضافة / تعديل حصة'**
  String get addOrEditLesson;

  /// No description provided for @addLessonForDay.
  ///
  /// In ar, this message translates to:
  /// **'إضافة حصة - {day}'**
  String addLessonForDay(Object day);

  /// No description provided for @subjectRequired.
  ///
  /// In ar, this message translates to:
  /// **'المادة الدراسية *'**
  String get subjectRequired;

  /// No description provided for @teacherName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المعلم'**
  String get teacherName;

  /// No description provided for @roomOrLocation.
  ///
  /// In ar, this message translates to:
  /// **'القاعة / الموقع'**
  String get roomOrLocation;

  /// No description provided for @lessonTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت الحصة:'**
  String get lessonTime;

  /// No description provided for @enterSubjectName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم المادة'**
  String get enterSubjectName;

  /// No description provided for @lessonAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة حصة {subject}'**
  String lessonAdded(Object subject);

  /// No description provided for @addLesson.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الحصة'**
  String get addLesson;

  /// No description provided for @noLessonsForDay.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حصص ليوم {day}'**
  String noLessonsForDay(Object day);

  /// No description provided for @emptyScheduleMessage.
  ///
  /// In ar, this message translates to:
  /// **'عند ربط API الجدول الدراسي ستظهر الحصص هنا تلقائيًا. يمكنك إضافة حصة محلية الآن للمراجعة والتجربة.'**
  String get emptyScheduleMessage;

  /// No description provided for @addLessonForThisDay.
  ///
  /// In ar, this message translates to:
  /// **'إضافة حصة لهذا اليوم'**
  String get addLessonForThisDay;

  /// No description provided for @activeTasks.
  ///
  /// In ar, this message translates to:
  /// **'المهام النشطة'**
  String get activeTasks;

  /// No description provided for @drafts.
  ///
  /// In ar, this message translates to:
  /// **'المسودات'**
  String get drafts;

  /// No description provided for @completedTasks.
  ///
  /// In ar, this message translates to:
  /// **'المكتملة'**
  String get completedTasks;

  /// No description provided for @activeSummaryLabel.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get activeSummaryLabel;

  /// No description provided for @draftsSummaryLabel.
  ///
  /// In ar, this message translates to:
  /// **'مسودات'**
  String get draftsSummaryLabel;

  /// No description provided for @completedSummaryLabel.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completedSummaryLabel;

  /// No description provided for @newTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة جديدة'**
  String get newTask;

  /// No description provided for @taskManagementTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المهام'**
  String get taskManagementTitle;

  /// No description provided for @taskManagementSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تابع واجبات طلابك ونسب الإنجاز، وأنشئ مهامًا محلية قابلة للمراجعة أثناء الاختبار.'**
  String get taskManagementSubtitle;

  /// No description provided for @taskManagementLocalOnlyMessage.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المهام تعمل الآن بحالة محلية واضحة. للحفظ الدائم والمزامنة مع الطلاب يجب ربط API المهام في المرحلة القادمة.'**
  String get taskManagementLocalOnlyMessage;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة؟'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف \"{title}\" من القائمة المحلية فقط. لا توجد مزامنة خلفية حتى يتوفر API المهام.'**
  String deleteTaskConfirmation(Object title);

  /// No description provided for @taskOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات المهمة'**
  String get taskOptions;

  /// No description provided for @editTask.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المهمة'**
  String get editTask;

  /// No description provided for @publishDraft.
  ///
  /// In ar, this message translates to:
  /// **'نشر المسودة'**
  String get publishDraft;

  /// No description provided for @markAsCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تعليم كمكتملة'**
  String get markAsCompleted;

  /// No description provided for @deleteTask.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهمة'**
  String get deleteTask;

  /// No description provided for @completionRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل الإنجاز'**
  String get completionRate;

  /// No description provided for @dueWithinWeek.
  ///
  /// In ar, this message translates to:
  /// **'تسليم: خلال أسبوع'**
  String get dueWithinWeek;

  /// No description provided for @createNewTask.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مهمة جديدة'**
  String get createNewTask;

  /// No description provided for @taskEditorLocalOnlyMessage.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفصل المستهدف حتى تكون المهمة مرتبطة بعدد الطلاب المتوقع، وسيتم حفظ التغيير داخل هذه الجلسة فقط حتى يتم ربط API المهام.'**
  String get taskEditorLocalOnlyMessage;

  /// No description provided for @taskTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان المهمة'**
  String get taskTitle;

  /// No description provided for @enterClearTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب عنوانًا واضحًا للمهمة'**
  String get enterClearTaskTitle;

  /// No description provided for @classLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفصل'**
  String get classLabel;

  /// No description provided for @selectTargetClass.
  ///
  /// In ar, this message translates to:
  /// **'حدد الفصل المستهدف'**
  String get selectTargetClass;

  /// No description provided for @chooseSuggestedClass.
  ///
  /// In ar, this message translates to:
  /// **'اختر فصلًا من الفصول المقترحة حتى يتم تعيين الطلاب بدقة'**
  String get chooseSuggestedClass;

  /// No description provided for @dueDate.
  ///
  /// In ar, this message translates to:
  /// **'موعد التسليم'**
  String get dueDate;

  /// No description provided for @enterDueDate.
  ///
  /// In ar, this message translates to:
  /// **'حدد موعد التسليم'**
  String get enterDueDate;

  /// No description provided for @createTask.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء المهمة'**
  String get createTask;

  /// No description provided for @noTasksInTab.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام في \"{tab}\"'**
  String noTasksInTab(Object tab);

  /// No description provided for @emptyTasksMessage.
  ///
  /// In ar, this message translates to:
  /// **'غيّر الفلتر أو أنشئ مهمة جديدة للطلاب.'**
  String get emptyTasksMessage;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navAssessments.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get navAssessments;

  /// No description provided for @navProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدم'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @navQuestionBank.
  ///
  /// In ar, this message translates to:
  /// **'بنك الأسئلة'**
  String get navQuestionBank;

  /// No description provided for @navReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get navReports;

  /// No description provided for @navUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get navUsers;

  /// No description provided for @navClassrooms.
  ///
  /// In ar, this message translates to:
  /// **'الفصول'**
  String get navClassrooms;

  /// No description provided for @mcqOptionSemanticLabel.
  ///
  /// In ar, this message translates to:
  /// **'الخيار {optionKey}: {value}'**
  String mcqOptionSemanticLabel(Object optionKey, Object value);

  /// No description provided for @questionImageAlt.
  ///
  /// In ar, this message translates to:
  /// **'صورة السؤال'**
  String get questionImageAlt;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح الرابط'**
  String get couldNotOpenLink;

  /// No description provided for @downloadingFile.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل {fileName}...'**
  String downloadingFile(Object fileName);

  /// No description provided for @downloadFailedWithReason.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحميل: {reason}'**
  String downloadFailedWithReason(Object reason);

  /// No description provided for @exportFailedWithReason.
  ///
  /// In ar, this message translates to:
  /// **'فشل التصدير: {reason}'**
  String exportFailedWithReason(Object reason);

  /// No description provided for @shareFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل المشاركة'**
  String get shareFailed;

  /// No description provided for @downloadingQuestionTemplate.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل قالب الأسئلة...'**
  String get downloadingQuestionTemplate;

  /// No description provided for @questionTemplateImportSubject.
  ///
  /// In ar, this message translates to:
  /// **'قالب استيراد الأسئلة - EduAssess'**
  String get questionTemplateImportSubject;

  /// No description provided for @questionTemplateSubject.
  ///
  /// In ar, this message translates to:
  /// **'قالب استيراد الأسئلة'**
  String get questionTemplateSubject;

  /// No description provided for @completionCertificateSubject.
  ///
  /// In ar, this message translates to:
  /// **'شهادة إتمام - {studentName}'**
  String completionCertificateSubject(Object studentName);

  /// No description provided for @completionCertificateContent.
  ///
  /// In ar, this message translates to:
  /// **'شهادة إتمام\n═══════════════════════════════\n\nتُمنح هذه الشهادة إلى:\n{studentName}\n\nلإتمامه بنجاح مادة: {classroomName}\n\nالدرجة: {score}%\nالتقدير: {grade}\n\nالعام الدراسي: 2024-2025\nتاريخ الإصدار: {issueDate}\n\n═══════════════════════════════\nمنصة EduAssess للتقييم التكيفي\n'**
  String completionCertificateContent(Object studentName, Object classroomName,
      Object score, Object grade, Object issueDate);

  /// No description provided for @connectionTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال'**
  String get connectionTimeout;

  /// No description provided for @unauthorizedError.
  ///
  /// In ar, this message translates to:
  /// **'غير مصرح'**
  String get unauthorizedError;

  /// No description provided for @fileNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير موجود'**
  String get fileNotFound;

  /// No description provided for @connectionError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال'**
  String get connectionError;

  /// No description provided for @schoolReportExportSection.
  ///
  /// In ar, this message translates to:
  /// **'القسم'**
  String get schoolReportExportSection;

  /// No description provided for @schoolReportExportMetric.
  ///
  /// In ar, this message translates to:
  /// **'المؤشر'**
  String get schoolReportExportMetric;

  /// No description provided for @schoolReportExportValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get schoolReportExportValue;

  /// No description provided for @schoolReportExportReport.
  ///
  /// In ar, this message translates to:
  /// **'التقرير'**
  String get schoolReportExportReport;

  /// No description provided for @schoolReportExportGeneratedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get schoolReportExportGeneratedAt;

  /// No description provided for @schoolReportExportFilterScope.
  ///
  /// In ar, this message translates to:
  /// **'نطاق الفلاتر'**
  String get schoolReportExportFilterScope;

  /// No description provided for @schoolReportExportSummary.
  ///
  /// In ar, this message translates to:
  /// **'الملخص'**
  String get schoolReportExportSummary;

  /// No description provided for @schoolReportExportClassroomComparison.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة الفصول'**
  String get schoolReportExportClassroomComparison;

  /// No description provided for @schoolReportExportWeakSkills.
  ///
  /// In ar, this message translates to:
  /// **'مهارات تحتاج دعماً'**
  String get schoolReportExportWeakSkills;

  /// No description provided for @schoolReportExportComparisonValue.
  ///
  /// In ar, this message translates to:
  /// **'متوسط: {averageScore} | إكمال: {completionRate} | مهارة: {topSkill}'**
  String schoolReportExportComparisonValue(
      Object averageScore, Object completionRate, Object topSkill);

  /// No description provided for @schoolReportExportFailure.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تصدير تقرير المدرسة. تحقق من الاتصال ثم حاول مرة أخرى.'**
  String get schoolReportExportFailure;

  /// No description provided for @questionBankQualityTitle.
  ///
  /// In ar, this message translates to:
  /// **'جودة بنك الأسئلة'**
  String get questionBankQualityTitle;

  /// No description provided for @qualityDataLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل البيانات'**
  String get qualityDataLoadFailed;

  /// No description provided for @totalQuestionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأسئلة'**
  String get totalQuestionsLabel;

  /// No description provided for @qualityStatusLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get qualityStatusLabel;

  /// No description provided for @balancedStatus.
  ///
  /// In ar, this message translates to:
  /// **'متوازن'**
  String get balancedStatus;

  /// No description provided for @insufficientStatus.
  ///
  /// In ar, this message translates to:
  /// **'غير كافٍ'**
  String get insufficientStatus;

  /// No description provided for @questionDifficultyDistribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الأسئلة حسب الصعوبة'**
  String get questionDifficultyDistribution;

  /// No description provided for @easyDifficulty.
  ///
  /// In ar, this message translates to:
  /// **'سهل'**
  String get easyDifficulty;

  /// No description provided for @mediumDifficulty.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get mediumDifficulty;

  /// No description provided for @hardDifficulty.
  ///
  /// In ar, this message translates to:
  /// **'صعب'**
  String get hardDifficulty;

  /// No description provided for @addQuestions.
  ///
  /// In ar, this message translates to:
  /// **'إضافة أسئلة'**
  String get addQuestions;

  /// No description provided for @questionCountCompact.
  ///
  /// In ar, this message translates to:
  /// **'{count} سؤال'**
  String questionCountCompact(int count);

  /// No description provided for @minimumQuestionsRequired.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى: {count} أسئلة'**
  String minimumQuestionsRequired(int count);

  /// No description provided for @addNewQuestionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سؤال جديد'**
  String get addNewQuestionTitle;

  /// No description provided for @questionClassification.
  ///
  /// In ar, this message translates to:
  /// **'تصنيف السؤال'**
  String get questionClassification;

  /// No description provided for @subjectLabel.
  ///
  /// In ar, this message translates to:
  /// **'المادة الدراسية'**
  String get subjectLabel;

  /// No description provided for @gradeLevelLabel.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الدراسية'**
  String get gradeLevelLabel;

  /// No description provided for @chooseGrade.
  ///
  /// In ar, this message translates to:
  /// **'اختر المرحلة'**
  String get chooseGrade;

  /// No description provided for @gradeSeven.
  ///
  /// In ar, this message translates to:
  /// **'الصف السابع'**
  String get gradeSeven;

  /// No description provided for @gradeEight.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثامن'**
  String get gradeEight;

  /// No description provided for @gradeNine.
  ///
  /// In ar, this message translates to:
  /// **'الصف التاسع'**
  String get gradeNine;

  /// No description provided for @gradeTen.
  ///
  /// In ar, this message translates to:
  /// **'الصف العاشر'**
  String get gradeTen;

  /// No description provided for @gradeEleven.
  ///
  /// In ar, this message translates to:
  /// **'الصف الحادي عشر'**
  String get gradeEleven;

  /// No description provided for @gradeTwelve.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثاني عشر'**
  String get gradeTwelve;

  /// No description provided for @unitLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة الدراسية'**
  String get unitLabel;

  /// No description provided for @mainSkillLabel.
  ///
  /// In ar, this message translates to:
  /// **'المهارة الرئيسية'**
  String get mainSkillLabel;

  /// No description provided for @mainSkillHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الجمع والطرح'**
  String get mainSkillHint;

  /// No description provided for @questionTypeSection.
  ///
  /// In ar, this message translates to:
  /// **'نوع السؤال'**
  String get questionTypeSection;

  /// No description provided for @questionTypeTrueFalseShort.
  ///
  /// In ar, this message translates to:
  /// **'صح / خطأ'**
  String get questionTypeTrueFalseShort;

  /// No description provided for @questionContent.
  ///
  /// In ar, this message translates to:
  /// **'محتوى السؤال'**
  String get questionContent;

  /// No description provided for @questionTextLabel.
  ///
  /// In ar, this message translates to:
  /// **'نص السؤال'**
  String get questionTextLabel;

  /// No description provided for @questionTextHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب نص السؤال هنا...'**
  String get questionTextHint;

  /// No description provided for @answerOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات الإجابة'**
  String get answerOptions;

  /// No description provided for @optionHint.
  ///
  /// In ar, this message translates to:
  /// **'الخيار {optionLabel}'**
  String optionHint(Object optionLabel);

  /// No description provided for @selectCorrectAnswerHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الخيار لتحديد الإجابة الصحيحة'**
  String get selectCorrectAnswerHint;

  /// No description provided for @chooseDifficultyError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار مستوى الصعوبة'**
  String get chooseDifficultyError;

  /// No description provided for @saveQuestion.
  ///
  /// In ar, this message translates to:
  /// **'حفظ السؤال'**
  String get saveQuestion;

  /// No description provided for @questionSavedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ السؤال بنجاح'**
  String get questionSavedSuccessfully;

  /// No description provided for @questionSavedInDemoBank.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ السؤال بنجاح في البنك التجريبي'**
  String get questionSavedInDemoBank;

  /// No description provided for @returningMessage.
  ///
  /// In ar, this message translates to:
  /// **'جاري العودة...'**
  String get returningMessage;

  /// No description provided for @difficultyLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الصعوبة'**
  String get difficultyLevel;

  /// No description provided for @importFromExcelTitle.
  ///
  /// In ar, this message translates to:
  /// **'استيراد من Excel'**
  String get importFromExcelTitle;

  /// No description provided for @downloadTemplate.
  ///
  /// In ar, this message translates to:
  /// **'تحميل القالب'**
  String get downloadTemplate;

  /// No description provided for @importHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الاستيراد'**
  String get importHistory;

  /// No description provided for @importInstructions.
  ///
  /// In ar, this message translates to:
  /// **'تعليمات الاستيراد'**
  String get importInstructions;

  /// No description provided for @importInstructionDownloadTemplate.
  ///
  /// In ar, this message translates to:
  /// **'حمّل القالب من الزر أعلاه'**
  String get importInstructionDownloadTemplate;

  /// No description provided for @importInstructionFillColumns.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الأسئلة في الأعمدة المحددة'**
  String get importInstructionFillColumns;

  /// No description provided for @importInstructionSaveFile.
  ///
  /// In ar, this message translates to:
  /// **'احفظ الملف بصيغة .xlsx أو .xls'**
  String get importInstructionSaveFile;

  /// No description provided for @importInstructionTapUpload.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على منطقة الرفع لاختيار الملف'**
  String get importInstructionTapUpload;

  /// No description provided for @importRequiredColumns.
  ///
  /// In ar, this message translates to:
  /// **'الأعمدة المطلوبة: نص السؤال، المادة، المستوى، الصعوبة، الخيارات (أ-د)، الإجابة الصحيحة'**
  String get importRequiredColumns;

  /// No description provided for @excelFileAccessFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الوصول إلى الملف'**
  String get excelFileAccessFailed;

  /// No description provided for @excelFileTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'حجم الملف يتجاوز 10MB'**
  String get excelFileTooLarge;

  /// No description provided for @excelUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل رفع الملف — تحقق من الاتصال'**
  String get excelUploadFailed;

  /// No description provided for @unexpectedImportError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع: {error}'**
  String unexpectedImportError(Object error);

  /// No description provided for @demoMissingSubjectError.
  ///
  /// In ar, this message translates to:
  /// **'حقل المادة مفقود في الصف 5'**
  String get demoMissingSubjectError;

  /// No description provided for @demoDuplicateQuestionError.
  ///
  /// In ar, this message translates to:
  /// **'سؤال مكرر في الصف 12'**
  String get demoDuplicateQuestionError;

  /// No description provided for @uploadInProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري الرفع... {percent}%'**
  String uploadInProgress(int percent);

  /// No description provided for @processingFile.
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الملف...'**
  String get processingFile;

  /// No description provided for @tapToChooseExcelFile.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لاختيار ملف Excel'**
  String get tapToChooseExcelFile;

  /// No description provided for @excelAllowedTypes.
  ///
  /// In ar, this message translates to:
  /// **'.xlsx أو .xls أو .csv (حتى 10MB)'**
  String get excelAllowedTypes;

  /// No description provided for @chooseFile.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملفاً'**
  String get chooseFile;

  /// No description provided for @importResult.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة الاستيراد'**
  String get importResult;

  /// No description provided for @importedLabel.
  ///
  /// In ar, this message translates to:
  /// **'مستورد'**
  String get importedLabel;

  /// No description provided for @skippedLabel.
  ///
  /// In ar, this message translates to:
  /// **'متخطى'**
  String get skippedLabel;

  /// No description provided for @failedLabel.
  ///
  /// In ar, this message translates to:
  /// **'فاشل'**
  String get failedLabel;

  /// No description provided for @errorDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الأخطاء:'**
  String get errorDetails;

  /// No description provided for @rowNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'صف {row}'**
  String rowNumberLabel(Object row);

  /// No description provided for @doneAddedQuestions.
  ///
  /// In ar, this message translates to:
  /// **'تم — تمت إضافة {count} سؤال'**
  String doneAddedQuestions(int count);

  /// No description provided for @excelFileFallbackName.
  ///
  /// In ar, this message translates to:
  /// **'ملف Excel'**
  String get excelFileFallbackName;

  /// No description provided for @importHistorySummary.
  ///
  /// In ar, this message translates to:
  /// **'{imported} مستورد • {skipped} متخطى • {failed} فاشل'**
  String importHistorySummary(Object imported, Object skipped, Object failed);

  /// No description provided for @markAllAsRead.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get markAllAsRead;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا إشعاراتك الجديدة'**
  String get noNotificationsSubtitle;

  /// No description provided for @notificationsToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get notificationsToday;

  /// No description provided for @notificationsPrevious.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get notificationsPrevious;

  /// No description provided for @demoNotificationAssessmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبار جديد متاح'**
  String get demoNotificationAssessmentTitle;

  /// No description provided for @demoNotificationAssessmentBody.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر اختبار الرياضيات الدوري. يمكنك البدء الآن.'**
  String get demoNotificationAssessmentBody;

  /// No description provided for @demoNotificationGradeTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة اختبارك'**
  String get demoNotificationGradeTitle;

  /// No description provided for @demoNotificationGradeBody.
  ///
  /// In ar, this message translates to:
  /// **'حصلت على 78% في اختبار اللغة العربية. أحسنت!'**
  String get demoNotificationGradeBody;

  /// No description provided for @demoNotificationAlertTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه أداء'**
  String get demoNotificationAlertTitle;

  /// No description provided for @demoNotificationAlertBody.
  ///
  /// In ar, this message translates to:
  /// **'انخفض متوسط أداء الطالب أحمد في مادة الفيزياء.'**
  String get demoNotificationAlertBody;

  /// No description provided for @demoNotificationMessageTitle.
  ///
  /// In ar, this message translates to:
  /// **'رسالة من المعلم'**
  String get demoNotificationMessageTitle;

  /// No description provided for @demoNotificationMessageBody.
  ///
  /// In ar, this message translates to:
  /// **'يرجى مراجعة الوحدة الثالثة قبل الاختبار القادم.'**
  String get demoNotificationMessageBody;

  /// No description provided for @smartAssessmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقييم الذكي'**
  String get smartAssessmentTitle;

  /// No description provided for @enableOneChannelPerNotificationGroup.
  ///
  /// In ar, this message translates to:
  /// **'فعّل قناة واحدة على الأقل لكل مجموعة إشعارات'**
  String get enableOneChannelPerNotificationGroup;

  /// No description provided for @notificationSettingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ إعدادات التنبيهات بنجاح'**
  String get notificationSettingsSaved;

  /// No description provided for @notificationSettingsSavedLocally.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات محلياً'**
  String get notificationSettingsSavedLocally;

  /// No description provided for @studentPerformanceNotificationsGroup.
  ///
  /// In ar, this message translates to:
  /// **'أداء الطلاب'**
  String get studentPerformanceNotificationsGroup;

  /// No description provided for @pushNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات لحظية (Push)'**
  String get pushNotificationsTitle;

  /// No description provided for @studentPerformancePushSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استلم إشعارات فورية عند تغير مستوى أداء الطلاب.'**
  String get studentPerformancePushSubtitle;

  /// No description provided for @emailNotificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailNotificationTitle;

  /// No description provided for @studentPerformanceEmailSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص أسبوعي للأداء الأكاديمي.'**
  String get studentPerformanceEmailSubtitle;

  /// No description provided for @questionBankNotificationsGroup.
  ///
  /// In ar, this message translates to:
  /// **'بنك الأسئلة'**
  String get questionBankNotificationsGroup;

  /// No description provided for @contentUpdatesNotificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديثات المحتوى'**
  String get contentUpdatesNotificationTitle;

  /// No description provided for @questionBankContentUpdatesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات عند إضافة أسئلة جديدة أو تحديث معايير التقييم.'**
  String get questionBankContentUpdatesSubtitle;

  /// No description provided for @smsNotificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'رسائل قصيرة (SMS)'**
  String get smsNotificationTitle;

  /// No description provided for @questionBankSmsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'للتنبيهات العاجلة المتعلقة بالاختبارات النهائية.'**
  String get questionBankSmsSubtitle;

  /// No description provided for @periodicReportsNotificationsGroup.
  ///
  /// In ar, this message translates to:
  /// **'تقارير دورية'**
  String get periodicReportsNotificationsGroup;

  /// No description provided for @periodicReportsEmailSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقارير الشهرية الشاملة للمشرفين.'**
  String get periodicReportsEmailSubtitle;

  /// No description provided for @notificationSettingsPageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خصص الطريقة التي تود بها البقاء على اطلاع بأحدث التطورات.'**
  String get notificationSettingsPageSubtitle;

  /// No description provided for @notificationsYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get notificationsYesterday;

  /// No description provided for @unreadNotificationsCount.
  ///
  /// In ar, this message translates to:
  /// **'لديك {count} تنبيهات جديدة غير مقروءة'**
  String unreadNotificationsCount(int count);

  /// No description provided for @noUnreadNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات غير مقروءة'**
  String get noUnreadNotifications;

  /// No description provided for @noOlderNotificationsToShow.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات أقدم لعرضها'**
  String get noOlderNotificationsToShow;

  /// No description provided for @yesterdayDatePrefix.
  ///
  /// In ar, this message translates to:
  /// **'أمس،'**
  String get yesterdayDatePrefix;

  /// No description provided for @questionBankTitle.
  ///
  /// In ar, this message translates to:
  /// **'بنك الأسئلة'**
  String get questionBankTitle;

  /// No description provided for @subjectMathematics.
  ///
  /// In ar, this message translates to:
  /// **'رياضيات'**
  String get subjectMathematics;

  /// No description provided for @subjectScience.
  ///
  /// In ar, this message translates to:
  /// **'علوم'**
  String get subjectScience;

  /// No description provided for @subjectArabic.
  ///
  /// In ar, this message translates to:
  /// **'لغة عربية'**
  String get subjectArabic;

  /// No description provided for @subjectEnglish.
  ///
  /// In ar, this message translates to:
  /// **'إنجليزي'**
  String get subjectEnglish;

  /// No description provided for @generalSkillFallback.
  ///
  /// In ar, this message translates to:
  /// **'مهارة عامة'**
  String get generalSkillFallback;

  /// No description provided for @editQuestionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل السؤال'**
  String get editQuestionTitle;

  /// No description provided for @questionUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث السؤال'**
  String get questionUpdated;

  /// No description provided for @saveEdits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديل'**
  String get saveEdits;

  /// No description provided for @deleteQuestionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف السؤال'**
  String get deleteQuestionTitle;

  /// No description provided for @deleteQuestionConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا السؤال نهائياً؟'**
  String get deleteQuestionConfirmation;

  /// No description provided for @questionDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف السؤال'**
  String get questionDeleted;

  /// No description provided for @activeFilters.
  ///
  /// In ar, this message translates to:
  /// **'فلاتر نشطة'**
  String get activeFilters;

  /// No description provided for @addQuestion.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سؤال'**
  String get addQuestion;

  /// No description provided for @importExcel.
  ///
  /// In ar, this message translates to:
  /// **'استيراد Excel'**
  String get importExcel;

  /// No description provided for @noQuestionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أسئلة'**
  String get noQuestionsTitle;

  /// No description provided for @noQuestionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة أسئلة إلى بنك الأسئلة'**
  String get noQuestionsSubtitle;

  /// No description provided for @filterQuestionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصفية الأسئلة'**
  String get filterQuestionsTitle;

  /// No description provided for @unitNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم الوحدة...'**
  String get unitNameHint;

  /// No description provided for @applyFilters.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الفلاتر'**
  String get applyFilters;

  /// No description provided for @advancedQuestionTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء سؤال متقدم'**
  String get advancedQuestionTitle;

  /// No description provided for @advancedQuestionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'صمّم أسئلة تقييم متقدمة مع وسائط غنية وعناصر تفاعلية.'**
  String get advancedQuestionSubtitle;

  /// No description provided for @advancedUnitQuantum.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة 4: ميكانيكا الكم المتقدمة'**
  String get advancedUnitQuantum;

  /// No description provided for @advancedUnitThermodynamics.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة 5: الديناميكا الحرارية والإنتروبيا'**
  String get advancedUnitThermodynamics;

  /// No description provided for @advancedUnitParticles.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة 6: أساسيات فيزياء الجسيمات'**
  String get advancedUnitParticles;

  /// No description provided for @assignUnit.
  ///
  /// In ar, this message translates to:
  /// **'تعيين الوحدة'**
  String get assignUnit;

  /// No description provided for @essayQuestionEditor.
  ///
  /// In ar, this message translates to:
  /// **'محرر السؤال المقالي'**
  String get essayQuestionEditor;

  /// No description provided for @wordLimitLabel.
  ///
  /// In ar, this message translates to:
  /// **'حد الكلمات:'**
  String get wordLimitLabel;

  /// No description provided for @autoGradingEnabled.
  ///
  /// In ar, this message translates to:
  /// **'التصحيح التلقائي مفعّل'**
  String get autoGradingEnabled;

  /// No description provided for @matchingQuestionInterface.
  ///
  /// In ar, this message translates to:
  /// **'واجهة أسئلة المطابقة'**
  String get matchingQuestionInterface;

  /// No description provided for @addAnotherPair.
  ///
  /// In ar, this message translates to:
  /// **'إضافة زوج آخر'**
  String get addAnotherPair;

  /// No description provided for @matchingItemA.
  ///
  /// In ar, this message translates to:
  /// **'العنصر أ'**
  String get matchingItemA;

  /// No description provided for @matchingMatchB.
  ///
  /// In ar, this message translates to:
  /// **'المطابق ب'**
  String get matchingMatchB;

  /// No description provided for @questionSavedAsDraft.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ السؤال كمسودة'**
  String get questionSavedAsDraft;

  /// No description provided for @saveAsDraft.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كمسودة'**
  String get saveAsDraft;

  /// No description provided for @writeQuestionFirst.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة نص السؤال أولاً'**
  String get writeQuestionFirst;

  /// No description provided for @publishQuestionTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشر السؤال'**
  String get publishQuestionTitle;

  /// No description provided for @publishQuestionConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد نشر هذا السؤال في بنك الأسئلة؟'**
  String get publishQuestionConfirmation;

  /// No description provided for @questionPublishedToBank.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر السؤال في بنك الأسئلة'**
  String get questionPublishedToBank;

  /// No description provided for @publishQuestion.
  ///
  /// In ar, this message translates to:
  /// **'نشر السؤال'**
  String get publishQuestion;

  /// No description provided for @plannedStatus.
  ///
  /// In ar, this message translates to:
  /// **'قيد التخطيط'**
  String get plannedStatus;

  /// No description provided for @aiQuestionAssistant.
  ///
  /// In ar, this message translates to:
  /// **'مساعد توليد الأسئلة'**
  String get aiQuestionAssistant;

  /// No description provided for @aiQuestionAssistantDisabledMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة غير مفعلة في هذا الإصدار حتى يتم ربط خدمة توليد آمنة، مراجعة جودة السؤال، وتسجيل مصدر السؤال قبل نشره.'**
  String get aiQuestionAssistantDisabledMessage;

  /// No description provided for @autoGenerationPlanned.
  ///
  /// In ar, this message translates to:
  /// **'التوليد التلقائي قيد التخطيط'**
  String get autoGenerationPlanned;

  /// No description provided for @classroomManagementTitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفصول الدراسية'**
  String get classroomManagementTitle;

  /// No description provided for @classroomSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن فصل دراسي...'**
  String get classroomSearchHint;

  /// No description provided for @demoClassroomGradeTenA.
  ///
  /// In ar, this message translates to:
  /// **'الفصل العاشر (أ)'**
  String get demoClassroomGradeTenA;

  /// No description provided for @demoClassroomGradeTwelveC.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الثاني عشر (ج)'**
  String get demoClassroomGradeTwelveC;

  /// No description provided for @demoClassroomIntermediateB.
  ///
  /// In ar, this message translates to:
  /// **'المستوى المتوسط (ب)'**
  String get demoClassroomIntermediateB;

  /// No description provided for @demoSubjectMathAdvanced.
  ///
  /// In ar, this message translates to:
  /// **'الرياضيات - المستوى المتقدم'**
  String get demoSubjectMathAdvanced;

  /// No description provided for @demoSubjectPhysicsScienceTrack.
  ///
  /// In ar, this message translates to:
  /// **'الفيزياء - مسار علمي'**
  String get demoSubjectPhysicsScienceTrack;

  /// No description provided for @demoSubjectEnglishLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الإنجليزية'**
  String get demoSubjectEnglishLanguage;

  /// No description provided for @viewStudentsForClass.
  ///
  /// In ar, this message translates to:
  /// **'عرض طلاب {name}'**
  String viewStudentsForClass(Object name);

  /// No description provided for @reportsForClass.
  ///
  /// In ar, this message translates to:
  /// **'تقارير {name}'**
  String reportsForClass(Object name);

  /// No description provided for @urgentAlerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات العاجلة'**
  String get urgentAlerts;

  /// No description provided for @missingAssessmentSubmissionsAlert.
  ///
  /// In ar, this message translates to:
  /// **'5 طلاب لم يسلموا الاختبار'**
  String get missingAssessmentSubmissionsAlert;

  /// No description provided for @mathGradeTenASubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الرياضيات - الفصل العاشر (أ)'**
  String get mathGradeTenASubtitle;

  /// No description provided for @newJoinRequestAlert.
  ///
  /// In ar, this message translates to:
  /// **'طلب انضمام جديد'**
  String get newJoinRequestAlert;

  /// No description provided for @englishClassSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فصل اللغة الإنجليزية'**
  String get englishClassSubtitle;

  /// No description provided for @viewAllAlerts.
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع التنبيهات'**
  String get viewAllAlerts;

  /// No description provided for @academicPerformanceOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على الأداء الأكاديمي'**
  String get academicPerformanceOverview;

  /// No description provided for @academicPerformanceOverviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تظهر البيانات تحسناً بنسبة 12% في متوسط درجات الطلاب خلال الشهر الحالي.'**
  String get academicPerformanceOverviewSubtitle;

  /// No description provided for @loadingFullReport.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل التقرير الكامل...'**
  String get loadingFullReport;

  /// No description provided for @downloadFullReport.
  ///
  /// In ar, this message translates to:
  /// **'تحميل التقرير الكامل'**
  String get downloadFullReport;

  /// No description provided for @viewStudents.
  ///
  /// In ar, this message translates to:
  /// **'عرض الطلاب'**
  String get viewStudents;

  /// No description provided for @assessments.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get assessments;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @navResources.
  ///
  /// In ar, this message translates to:
  /// **'المصادر'**
  String get navResources;

  /// No description provided for @supportCenterTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني والمساعدة'**
  String get supportCenterTitle;

  /// No description provided for @supportCenterSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نحن هنا للإجابة على استفساراتك ومساعدتك في رحلتك التعليمية.'**
  String get supportCenterSubtitle;

  /// No description provided for @supportSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكننا مساعدتك اليوم؟'**
  String get supportSearchHint;

  /// No description provided for @supportMainSections.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام الرئيسية'**
  String get supportMainSections;

  /// No description provided for @supportGeneralCategory.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get supportGeneralCategory;

  /// No description provided for @supportGeneralCategorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة حول المنصة'**
  String get supportGeneralCategorySubtitle;

  /// No description provided for @supportGeneralDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'قسم عام'**
  String get supportGeneralDialogTitle;

  /// No description provided for @supportGeneralDialogHeading.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة:'**
  String get supportGeneralDialogHeading;

  /// No description provided for @supportGeneralFaqStart.
  ///
  /// In ar, this message translates to:
  /// **'كيف أبدأ استخدام المنصة؟'**
  String get supportGeneralFaqStart;

  /// No description provided for @supportGeneralFaqCreateAssessment.
  ///
  /// In ar, this message translates to:
  /// **'كيف أنشئ اختبارًا جديدًا؟'**
  String get supportGeneralFaqCreateAssessment;

  /// No description provided for @supportGeneralFaqAddStudents.
  ///
  /// In ar, this message translates to:
  /// **'كيف أضيف طلابًا إلى الفصل؟'**
  String get supportGeneralFaqAddStudents;

  /// No description provided for @supportGeneralFaqReports.
  ///
  /// In ar, this message translates to:
  /// **'كيف أعرض التقارير؟'**
  String get supportGeneralFaqReports;

  /// No description provided for @supportGeneralDialogFooter.
  ///
  /// In ar, this message translates to:
  /// **'للمزيد من المساعدة، تواصل مع فريق الدعم.'**
  String get supportGeneralDialogFooter;

  /// No description provided for @supportTechnicalCategory.
  ///
  /// In ar, this message translates to:
  /// **'تقني'**
  String get supportTechnicalCategory;

  /// No description provided for @supportTechnicalCategorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حلول المشاكل الفنية'**
  String get supportTechnicalCategorySubtitle;

  /// No description provided for @supportTechnicalDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'قسم تقني'**
  String get supportTechnicalDialogTitle;

  /// No description provided for @supportTechnicalDialogHeading.
  ///
  /// In ar, this message translates to:
  /// **'المشاكل الفنية الشائعة:'**
  String get supportTechnicalDialogHeading;

  /// No description provided for @supportTechnicalIssueLogin.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة في تسجيل الدخول'**
  String get supportTechnicalIssueLogin;

  /// No description provided for @supportTechnicalIssueSlowPages.
  ///
  /// In ar, this message translates to:
  /// **'بطء في تحميل الصفحات'**
  String get supportTechnicalIssueSlowPages;

  /// No description provided for @supportTechnicalIssueSaveError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حفظ البيانات'**
  String get supportTechnicalIssueSaveError;

  /// No description provided for @supportTechnicalIssueUpload.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة في رفع الملفات'**
  String get supportTechnicalIssueUpload;

  /// No description provided for @supportTechnicalDialogFooter.
  ///
  /// In ar, this message translates to:
  /// **'إذا استمرت المشكلة، تواصل مع الدعم الفني.'**
  String get supportTechnicalDialogFooter;

  /// No description provided for @supportBillingCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get supportBillingCategory;

  /// No description provided for @supportBillingCategorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات والمدفوعات'**
  String get supportBillingCategorySubtitle;

  /// No description provided for @supportBillingDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'قسم الفواتير'**
  String get supportBillingDialogTitle;

  /// No description provided for @supportBillingDialogHeading.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الاشتراك:'**
  String get supportBillingDialogHeading;

  /// No description provided for @supportBillingCurrentPlan.
  ///
  /// In ar, this message translates to:
  /// **'الخطة الحالية: مجانية'**
  String get supportBillingCurrentPlan;

  /// No description provided for @supportBillingExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء: غير محدد'**
  String get supportBillingExpiry;

  /// No description provided for @supportBillingUsers.
  ///
  /// In ar, this message translates to:
  /// **'عدد المستخدمين: غير محدود'**
  String get supportBillingUsers;

  /// No description provided for @supportBillingDialogFooter.
  ///
  /// In ar, this message translates to:
  /// **'للترقية أو الاستفسار عن الفواتير، تواصل مع قسم المبيعات.'**
  String get supportBillingDialogFooter;

  /// No description provided for @supportBulletItem.
  ///
  /// In ar, this message translates to:
  /// **'• {item}'**
  String supportBulletItem(Object item);

  /// No description provided for @supportContactTitle.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get supportContactTitle;

  /// No description provided for @supportContactSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فريقنا متواجد 24/7 لمساعدتك'**
  String get supportContactSubtitle;

  /// No description provided for @supportStartLiveChat.
  ///
  /// In ar, this message translates to:
  /// **'بدء محادثة فورية'**
  String get supportStartLiveChat;

  /// No description provided for @supportLiveDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني المباشر'**
  String get supportLiveDialogTitle;

  /// No description provided for @supportTeamAvailable.
  ///
  /// In ar, this message translates to:
  /// **'فريق الدعم متواجد 24/7'**
  String get supportTeamAvailable;

  /// No description provided for @supportDirectContact.
  ///
  /// In ar, this message translates to:
  /// **'للتواصل المباشر: support@adaptive-mastery.com'**
  String get supportDirectContact;

  /// No description provided for @supportOpenTicket.
  ///
  /// In ar, this message translates to:
  /// **'فتح تذكرة دعم'**
  String get supportOpenTicket;

  /// No description provided for @supportTicketHint.
  ///
  /// In ar, this message translates to:
  /// **'اشرح مشكلتك بالتفصيل...'**
  String get supportTicketHint;

  /// No description provided for @supportTicketSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال تذكرة الدعم. سنتواصل معك خلال 24 ساعة.'**
  String get supportTicketSent;

  /// No description provided for @supportSubmitTicket.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التذكرة'**
  String get supportSubmitTicket;

  /// No description provided for @supportTutorialFirstAssessment.
  ///
  /// In ar, this message translates to:
  /// **'كيفية بدء اختبارك الأول'**
  String get supportTutorialFirstAssessment;

  /// No description provided for @supportTutorialFirstDuration.
  ///
  /// In ar, this message translates to:
  /// **'3 دقائق • فيديو'**
  String get supportTutorialFirstDuration;

  /// No description provided for @supportTutorialReports.
  ///
  /// In ar, this message translates to:
  /// **'فهم تقارير الأداء'**
  String get supportTutorialReports;

  /// No description provided for @supportTutorialReportsDuration.
  ///
  /// In ar, this message translates to:
  /// **'5 دقائق • مقال'**
  String get supportTutorialReportsDuration;

  /// No description provided for @supportTutorialsTitle.
  ///
  /// In ar, this message translates to:
  /// **'شروحات تعليمية'**
  String get supportTutorialsTitle;

  /// No description provided for @supportAllTutorialsTitle.
  ///
  /// In ar, this message translates to:
  /// **'جميع الشروحات التعليمية'**
  String get supportAllTutorialsTitle;

  /// No description provided for @supportAvailableTutorials.
  ///
  /// In ar, this message translates to:
  /// **'الشروحات المتاحة:'**
  String get supportAvailableTutorials;

  /// No description provided for @supportTutorialClassrooms.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفصول الدراسية'**
  String get supportTutorialClassrooms;

  /// No description provided for @supportTutorialQuestionBank.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء بنك الأسئلة'**
  String get supportTutorialQuestionBank;

  /// No description provided for @supportTutorialAdaptiveAssessment.
  ///
  /// In ar, this message translates to:
  /// **'استخدام التقييم التكيفي'**
  String get supportTutorialAdaptiveAssessment;

  /// No description provided for @supportMoreTutorialsSoon.
  ///
  /// In ar, this message translates to:
  /// **'المزيد من الشروحات قريبًا...'**
  String get supportMoreTutorialsSoon;

  /// No description provided for @supportTutorialDialogMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشرح التعليمي سيساعدك على فهم كيفية استخدام المنصة بشكل أفضل.'**
  String get supportTutorialDialogMessage;

  /// No description provided for @supportTutorialDialogFooter.
  ///
  /// In ar, this message translates to:
  /// **'للوصول إلى المحتوى الكامل، يرجى زيارة مركز المساعدة.'**
  String get supportTutorialDialogFooter;

  /// No description provided for @uiFeedbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكوّنات رسائل النظام'**
  String get uiFeedbackTitle;

  /// No description provided for @uiFeedbackSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'راجع تصميم التنبيهات والنوافذ المنبثقة داخل واجهة المنصة.'**
  String get uiFeedbackSubtitle;

  /// No description provided for @uiFeedbackSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم استيراد البيانات بنجاح'**
  String get uiFeedbackSuccessTitle;

  /// No description provided for @uiFeedbackSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة 32 سؤالًا تكيفيًا جديدًا إلى بنك الأحياء المتقدم.'**
  String get uiFeedbackSuccessMessage;

  /// No description provided for @uiFeedbackErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'فشل حفظ السؤال'**
  String get uiFeedbackErrorTitle;

  /// No description provided for @uiFeedbackErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'انقطع اتصال الشبكة. لم تتم مزامنة تقدمك في العنصر رقم 402.'**
  String get uiFeedbackErrorMessage;

  /// No description provided for @uiFeedbackDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف اختبار'**
  String get uiFeedbackDeleteTitle;

  /// No description provided for @uiFeedbackDeleteMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء. سيتم حذف بيانات تقدم الطلاب والتحليلات المرتبطة باختبار فيزياء منتصف الفصل نهائيًا.'**
  String get uiFeedbackDeleteMessage;

  /// No description provided for @uiFeedbackDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائي'**
  String get uiFeedbackDeleteConfirm;

  /// No description provided for @uiFeedbackSyncStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة المزامنة الحالية'**
  String get uiFeedbackSyncStatus;

  /// No description provided for @uiFeedbackPendingAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات معلّقة'**
  String get uiFeedbackPendingAlerts;

  /// No description provided for @uiFeedbackSafeStatus.
  ///
  /// In ar, this message translates to:
  /// **'آمن'**
  String get uiFeedbackSafeStatus;

  /// No description provided for @uiFeedbackAccessLogged.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الوصول'**
  String get uiFeedbackAccessLogged;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @username.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @loginLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الدخول...'**
  String get loginLoading;

  /// No description provided for @loginServerStarting.
  ///
  /// In ar, this message translates to:
  /// **'جاري تشغيل الخادم... ({seconds} ث)'**
  String loginServerStarting(int seconds);

  /// No description provided for @loginServerWaking.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار، الخادم يستيقظ...'**
  String get loginServerWaking;

  /// No description provided for @loginServerWakeRetry.
  ///
  /// In ar, this message translates to:
  /// **'الخادم يستيقظ، يرجى الانتظار 30 ثانية والمحاولة مجددًا'**
  String get loginServerWakeRetry;

  /// No description provided for @loginPendingApproval.
  ///
  /// In ar, this message translates to:
  /// **'الحساب بانتظار اعتماد المشرف. تواصل مع إدارة المؤسسة.'**
  String get loginPendingApproval;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم أو كلمة المرور غير صحيحة'**
  String get loginInvalidCredentials;

  /// No description provided for @loginForbiddenOrDisabled.
  ///
  /// In ar, this message translates to:
  /// **'الحساب بانتظار اعتماد المشرف أو تم تعطيله. تواصل مع المشرف.'**
  String get loginForbiddenOrDisabled;

  /// No description provided for @loginNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get loginNoInternet;

  /// No description provided for @loginGenericError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، يرجى المحاولة مجددًا'**
  String get loginGenericError;

  /// No description provided for @loginUnexpectedError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع، يرجى المحاولة مجددًا'**
  String get loginUnexpectedError;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPasswordQuestion;

  /// No description provided for @rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get rememberMe;

  /// No description provided for @createNewAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createNewAccount;

  /// No description provided for @noAccountQuestion.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get noAccountQuestion;

  /// No description provided for @adaptiveAssessmentPlatformShort.
  ///
  /// In ar, this message translates to:
  /// **'منصة التقييم التكيفي'**
  String get adaptiveAssessmentPlatformShort;

  /// No description provided for @signInToYourAccount.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول إلى حسابك'**
  String get signInToYourAccount;

  /// No description provided for @enterUsernameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم'**
  String get enterUsernameHint;

  /// No description provided for @enterUsernameRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم المستخدم'**
  String get enterUsernameRequired;

  /// No description provided for @enterPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPasswordHint;

  /// No description provided for @enterPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور'**
  String get enterPasswordRequired;

  /// No description provided for @or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get or;

  /// No description provided for @signInWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بـ Google'**
  String get signInWithGoogle;

  /// No description provided for @googleLoginLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الدخول بـ Google...'**
  String get googleLoginLoading;

  /// No description provided for @googlePendingApprovalMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الانضمام بحساب Google. سيحتاج المشرف إلى الموافقة قبل الدخول.'**
  String get googlePendingApprovalMessage;

  /// No description provided for @googleLoginDisabledOnServer.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بـ Google غير مفعّل على الخادم حاليًا'**
  String get googleLoginDisabledOnServer;

  /// No description provided for @googleLoginFailedRetry.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول بـ Google، يرجى المحاولة مجددًا'**
  String get googleLoginFailedRetry;

  /// No description provided for @loginCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء تسجيل الدخول'**
  String get loginCancelled;

  /// No description provided for @googleLoginFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول بـ Google'**
  String get googleLoginFailed;

  /// No description provided for @tryDemoMode.
  ///
  /// In ar, this message translates to:
  /// **'أو جرّب وضع العرض'**
  String get tryDemoMode;

  /// No description provided for @demoDataOfflineNotice.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية - لا يتطلب اتصالًا بالإنترنت'**
  String get demoDataOfflineNotice;

  /// No description provided for @demoStudentFullName.
  ///
  /// In ar, this message translates to:
  /// **'أحمد محمد الطالب'**
  String get demoStudentFullName;

  /// No description provided for @demoTeacherFullName.
  ///
  /// In ar, this message translates to:
  /// **'سارة أحمد المعلمة'**
  String get demoTeacherFullName;

  /// No description provided for @demoAdminFullName.
  ///
  /// In ar, this message translates to:
  /// **'محمد علي المشرف'**
  String get demoAdminFullName;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get getStarted;

  /// No description provided for @onboardingAdaptiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقييم التكيفي'**
  String get onboardingAdaptiveTitle;

  /// No description provided for @onboardingAdaptiveSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختبارات تتكيف مع مستواك'**
  String get onboardingAdaptiveSubtitle;

  /// No description provided for @onboardingAdaptiveDescription.
  ///
  /// In ar, this message translates to:
  /// **'يتكيف نظام التقييم الذكي مع مستوى أدائك الفعلي، فيختار أسئلة تناسب قدراتك بدقة لتحصل على تقييم يعكس فهمك الحقيقي.'**
  String get onboardingAdaptiveDescription;

  /// No description provided for @onboardingAnalyticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات متقدمة'**
  String get onboardingAnalyticsTitle;

  /// No description provided for @onboardingAnalyticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'افهم نقاط قوتك وضعفك'**
  String get onboardingAnalyticsSubtitle;

  /// No description provided for @onboardingAnalyticsDescription.
  ///
  /// In ar, this message translates to:
  /// **'احصل على تقارير بيانية تفصيلية تظهر أداءك في كل مهارة وتصنف نقاط قوتك وضعفك بوضوح حتى تعرف ما الذي تحتاج إلى مراجعته.'**
  String get onboardingAnalyticsDescription;

  /// No description provided for @onboardingRewardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'نقاط وإنجازات'**
  String get onboardingRewardsTitle;

  /// No description provided for @onboardingRewardsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تعلّم وتحفّز في آنٍ واحد'**
  String get onboardingRewardsSubtitle;

  /// No description provided for @onboardingRewardsDescription.
  ///
  /// In ar, this message translates to:
  /// **'اكسب نقاطًا مقابل كل اختبار تكمله وحقق شارات الإنجاز عند تميزك. تابع تقدمك وتنافس مع نفسك لتحقيق مستويات أعلى من الإتقان.'**
  String get onboardingRewardsDescription;

  /// No description provided for @onboardingStepLabel.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {current} من {total}'**
  String onboardingStepLabel(int current, int total);

  /// No description provided for @extendedOnboardingChooseRoleWarning.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار أحد الأدوار للمتابعة'**
  String get extendedOnboardingChooseRoleWarning;

  /// No description provided for @extendedOnboardingWelcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا بك في مستقبل التعليم الذكي'**
  String get extendedOnboardingWelcomeTitle;

  /// No description provided for @extendedOnboardingWelcomeDescription.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف تجربة تعليمية مخصصة تعتمد على الذكاء الاصطناعي لتحقيق أفضل النتائج الدراسية.'**
  String get extendedOnboardingWelcomeDescription;

  /// No description provided for @extendedOnboardingAssessmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييمات ذكية ومخصصة'**
  String get extendedOnboardingAssessmentTitle;

  /// No description provided for @extendedOnboardingAssessmentDescription.
  ///
  /// In ar, this message translates to:
  /// **'خوارزميات متطورة تصمم اختبارات تناسب مستوى كل طالب وتحدد نقاط القوة والضعف بدقة.'**
  String get extendedOnboardingAssessmentDescription;

  /// No description provided for @extendedOnboardingAveragePerformance.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الأداء الأكاديمي'**
  String get extendedOnboardingAveragePerformance;

  /// No description provided for @extendedOnboardingStudentGrowth.
  ///
  /// In ar, this message translates to:
  /// **'نمو الطلاب'**
  String get extendedOnboardingStudentGrowth;

  /// No description provided for @extendedOnboardingAnalyticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقارير تحليلية عميقة'**
  String get extendedOnboardingAnalyticsTitle;

  /// No description provided for @extendedOnboardingAnalyticsDescription.
  ///
  /// In ar, this message translates to:
  /// **'حوّل بيانات الطلاب إلى رؤى واضحة تساعدك على اتخاذ قرارات تعليمية أفضل وتتبع التطور لحظة بلحظة.'**
  String get extendedOnboardingAnalyticsDescription;

  /// No description provided for @extendedOnboardingRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ رحلتك التعليمية'**
  String get extendedOnboardingRoleTitle;

  /// No description provided for @extendedOnboardingRoleSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر دورك للبدء في تخصيص تجربتك'**
  String get extendedOnboardingRoleSubtitle;

  /// No description provided for @extendedOnboardingTeacherRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنا معلم'**
  String get extendedOnboardingTeacherRoleTitle;

  /// No description provided for @extendedOnboardingTeacherRoleSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الاختبارات وإدارة الفصول'**
  String get extendedOnboardingTeacherRoleSubtitle;

  /// No description provided for @extendedOnboardingStudentRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنا طالب'**
  String get extendedOnboardingStudentRoleTitle;

  /// No description provided for @extendedOnboardingStudentRoleSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خوض الاختبارات ومتابعة التقدم'**
  String get extendedOnboardingStudentRoleSubtitle;

  /// No description provided for @signupCreateTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get signupCreateTitle;

  /// No description provided for @signupCreateSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى مجتمع التعلم الذكي وباشر رحلتك التعليمية'**
  String get signupCreateSubtitle;

  /// No description provided for @signupFullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الثلاثي'**
  String get signupFullNameHint;

  /// No description provided for @signupFullNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل مطلوب'**
  String get signupFullNameRequired;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مطلوبة'**
  String get passwordRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// No description provided for @termsAndConditions.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsAndConditions;

  /// No description provided for @signupTermsRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الموافقة على الشروط والأحكام'**
  String get signupTermsRequired;

  /// No description provided for @signupRequestSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الانضمام. سيظهر للمشرف للموافقة قبل تسجيل الدخول.'**
  String get signupRequestSubmitted;

  /// No description provided for @signupUsernameTaken.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم مستخدم بالفعل. اختر اسمًا آخر.'**
  String get signupUsernameTaken;

  /// No description provided for @signupEmailAlreadyRegistered.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد مسجل بالفعل. استخدم تسجيل الدخول أو تواصل مع المشرف.'**
  String get signupEmailAlreadyRegistered;

  /// No description provided for @signupRequestFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء طلب الانضمام، تحقق من البيانات وحاول مرة أخرى.'**
  String get signupRequestFailed;

  /// No description provided for @signupCreateAccountError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء إنشاء الحساب: {error}'**
  String signupCreateAccountError(Object error);

  /// No description provided for @signupUsernameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم مطلوب'**
  String get signupUsernameRequired;

  /// No description provided for @signupUsernameMinLength.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم يجب أن يكون 3 أحرف على الأقل'**
  String get signupUsernameMinLength;

  /// No description provided for @signupUsernameAllowedChars.
  ///
  /// In ar, this message translates to:
  /// **'يسمح بالحروف الإنجليزية والأرقام و_ فقط'**
  String get signupUsernameAllowedChars;

  /// No description provided for @signupTeacherAccountsManagedByAdmin.
  ///
  /// In ar, this message translates to:
  /// **'حسابات المعلمين يضيفها المشرف من إدارة المستخدمين.'**
  String get signupTeacherAccountsManagedByAdmin;

  /// No description provided for @signupAgreePrefix.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على '**
  String get signupAgreePrefix;

  /// No description provided for @signupPrivacySuffix.
  ///
  /// In ar, this message translates to:
  /// **' وسياسة الخصوصية الخاصة بالمنصة.'**
  String get signupPrivacySuffix;

  /// No description provided for @signupTermsDialogBody.
  ///
  /// In ar, this message translates to:
  /// **'باستخدام منصة التقييم التكيفي، أنت توافق على:\n\n1. استخدام المنصة للأغراض التعليمية فقط.\n2. الحفاظ على سرية بيانات الدخول.\n3. عدم مشاركة محتوى الاختبارات مع الآخرين.\n4. الالتزام بقواعد النزاهة الأكاديمية.\n5. قبول سياسة الخصوصية الخاصة بالمنصة.\n\nللاستفسار: support@adaptive-mastery.com'**
  String get signupTermsDialogBody;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'منصة التقييم التكيفي الذكي'**
  String get aboutAppSubtitle;

  /// No description provided for @versionHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الإصدارات'**
  String get versionHistory;

  /// No description provided for @currentVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار الحالي'**
  String get currentVersion;

  /// No description provided for @versionTypeRelease.
  ///
  /// In ar, this message translates to:
  /// **'إصدار'**
  String get versionTypeRelease;

  /// No description provided for @versionTypeFeature.
  ///
  /// In ar, this message translates to:
  /// **'ميزة'**
  String get versionTypeFeature;

  /// No description provided for @versionTypeFix.
  ///
  /// In ar, this message translates to:
  /// **'إصلاح'**
  String get versionTypeFix;

  /// No description provided for @versionTypeHotfix.
  ///
  /// In ar, this message translates to:
  /// **'طارئ'**
  String get versionTypeHotfix;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordResetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get forgotPasswordResetTitle;

  /// No description provided for @forgotPasswordResetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك رمز إعادة التعيين'**
  String get forgotPasswordResetSubtitle;

  /// No description provided for @forgotPasswordGenericError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ. يرجى المحاولة مرة أخرى'**
  String get forgotPasswordGenericError;

  /// No description provided for @forgotPasswordSendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز التحقق'**
  String get forgotPasswordSendCode;

  /// No description provided for @forgotPasswordSentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال بنجاح'**
  String get forgotPasswordSentTitle;

  /// No description provided for @forgotPasswordSentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني للحصول على رمز إعادة التعيين'**
  String get forgotPasswordSentSubtitle;

  /// No description provided for @backToLogin.
  ///
  /// In ar, this message translates to:
  /// **'العودة لتسجيل الدخول'**
  String get backToLogin;

  /// No description provided for @adminDashboardLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل بيانات لوحة المشرف. تحقق من الاتصال ثم أعد المحاولة.'**
  String get adminDashboardLoadFailed;

  /// No description provided for @adminDashboardGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، {name}'**
  String adminDashboardGreeting(Object name);

  /// No description provided for @adminDashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة تحكم المشرف'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardSchoolStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات المدرسة'**
  String get adminDashboardSchoolStats;

  /// No description provided for @adminDashboardTeachers.
  ///
  /// In ar, this message translates to:
  /// **'المعلمون'**
  String get adminDashboardTeachers;

  /// No description provided for @adminDashboardAdminAlerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات الإدارية'**
  String get adminDashboardAdminAlerts;

  /// No description provided for @adminDashboardPendingStudentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلاب لم يؤدوا الاختبار'**
  String get adminDashboardPendingStudentsTitle;

  /// No description provided for @adminDashboardPendingStudentsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يوجد {count} طلاب لم يسلموا الاختبار الأخير'**
  String adminDashboardPendingStudentsSubtitle(Object count);

  /// No description provided for @adminDashboardPendingRequestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات انضمام جديدة'**
  String get adminDashboardPendingRequestsTitle;

  /// No description provided for @adminDashboardPendingRequestsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يوجد {count} طلبات انضمام تنتظر الموافقة'**
  String adminDashboardPendingRequestsSubtitle(Object count);

  /// No description provided for @adminDashboardPerformanceDropTitle.
  ///
  /// In ar, this message translates to:
  /// **'انخفاض في الأداء'**
  String get adminDashboardPerformanceDropTitle;

  /// No description provided for @adminDashboardMathClassLevelTen.
  ///
  /// In ar, this message translates to:
  /// **'فصل الرياضيات - المستوى العاشر'**
  String get adminDashboardMathClassLevelTen;

  /// No description provided for @quickLinks.
  ///
  /// In ar, this message translates to:
  /// **'روابط سريعة'**
  String get quickLinks;

  /// No description provided for @userManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get userManagement;

  /// No description provided for @adminDashboardUserManagementSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وتعديل حسابات المعلمين والطلاب'**
  String get adminDashboardUserManagementSubtitle;

  /// No description provided for @classroomManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفصول'**
  String get classroomManagement;

  /// No description provided for @adminDashboardClassroomManagementSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض وتنظيم الفصول الدراسية'**
  String get adminDashboardClassroomManagementSubtitle;

  /// No description provided for @schoolReports.
  ///
  /// In ar, this message translates to:
  /// **'تقارير المدرسة'**
  String get schoolReports;

  /// No description provided for @adminDashboardSchoolReportsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليلات شاملة لأداء المدرسة'**
  String get adminDashboardSchoolReportsSubtitle;

  /// No description provided for @adminDashboardAdvancedDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم المتقدمة'**
  String get adminDashboardAdvancedDashboard;

  /// No description provided for @adminDashboardAdvancedDashboardSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات وتحليلات تفصيلية للمشرف'**
  String get adminDashboardAdvancedDashboardSubtitle;

  /// No description provided for @adminDashboardSupervisorDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المشرف المتقدمة'**
  String get adminDashboardSupervisorDashboard;

  /// No description provided for @adminDashboardSupervisorDashboardSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات وتحليلات تفصيلية'**
  String get adminDashboardSupervisorDashboardSubtitle;

  /// No description provided for @institutionSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المؤسسة'**
  String get institutionSettings;

  /// No description provided for @adminDashboardInstitutionSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ضبط إعدادات المؤسسة التعليمية'**
  String get adminDashboardInstitutionSettingsSubtitle;

  /// No description provided for @performanceOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على الأداء'**
  String get performanceOverview;

  /// No description provided for @adminDashboardPerformanceOverviewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'متوسط أداء المدرسة هذا الشهر'**
  String get adminDashboardPerformanceOverviewSubtitle;

  /// No description provided for @adminDashboardMonthlyPerformanceChange.
  ///
  /// In ar, this message translates to:
  /// **'{direction} بنسبة {percentage}% هذا الشهر'**
  String adminDashboardMonthlyPerformanceChange(
      Object direction, Object percentage);

  /// No description provided for @adminDashboardSchoolAverage.
  ///
  /// In ar, this message translates to:
  /// **'متوسط أداء المدرسة'**
  String get adminDashboardSchoolAverage;

  /// No description provided for @improvement.
  ///
  /// In ar, this message translates to:
  /// **'تحسن'**
  String get improvement;

  /// No description provided for @decline.
  ///
  /// In ar, this message translates to:
  /// **'انخفاض'**
  String get decline;

  /// No description provided for @math.
  ///
  /// In ar, this message translates to:
  /// **'الرياضيات'**
  String get math;

  /// No description provided for @adminDashboardV2Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك مجدداً، إليك ملخص أداء المدرسة اليوم.'**
  String get adminDashboardV2Subtitle;

  /// No description provided for @adminDashboardTotalStudents.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلاب'**
  String get adminDashboardTotalStudents;

  /// No description provided for @adminDashboardActiveTeachers.
  ///
  /// In ar, this message translates to:
  /// **'المعلمون النشطون'**
  String get adminDashboardActiveTeachers;

  /// No description provided for @adminDashboardOverallAverage.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الأداء العام'**
  String get adminDashboardOverallAverage;

  /// No description provided for @adminDashboardRunningAssessments.
  ///
  /// In ar, this message translates to:
  /// **'اختبارات جارية'**
  String get adminDashboardRunningAssessments;

  /// No description provided for @currentTerm.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الدراسي الحالي'**
  String get currentTerm;

  /// No description provided for @adminDashboardSubjectPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء المواد الدراسية'**
  String get adminDashboardSubjectPerformance;

  /// No description provided for @science.
  ///
  /// In ar, this message translates to:
  /// **'العلوم'**
  String get science;

  /// No description provided for @arabicSubject.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabicSubject;

  /// No description provided for @englishSubject.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get englishSubject;

  /// No description provided for @historySubject.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get historySubject;

  /// No description provided for @adminDashboardTopTeacherOneName.
  ///
  /// In ar, this message translates to:
  /// **'أ. محمد أحمد'**
  String get adminDashboardTopTeacherOneName;

  /// No description provided for @adminDashboardTopTeacherOneRole.
  ///
  /// In ar, this message translates to:
  /// **'معلم علوم - تفاعل عالي (98%)'**
  String get adminDashboardTopTeacherOneRole;

  /// No description provided for @adminDashboardTopTeacherOneInitials.
  ///
  /// In ar, this message translates to:
  /// **'م.أ'**
  String get adminDashboardTopTeacherOneInitials;

  /// No description provided for @adminDashboardTopTeacherTwoName.
  ///
  /// In ar, this message translates to:
  /// **'أ. سارة خالد'**
  String get adminDashboardTopTeacherTwoName;

  /// No description provided for @adminDashboardTopTeacherTwoRole.
  ///
  /// In ar, this message translates to:
  /// **'معلمة رياضيات - تقدم طلابي (92%)'**
  String get adminDashboardTopTeacherTwoRole;

  /// No description provided for @adminDashboardTopTeacherTwoInitials.
  ///
  /// In ar, this message translates to:
  /// **'س.خ'**
  String get adminDashboardTopTeacherTwoInitials;

  /// No description provided for @adminDashboardTopTeachersThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'المعلمون المتميزون (هذا الشهر)'**
  String get adminDashboardTopTeachersThisMonth;

  /// No description provided for @adminDashboardReviewRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة مطلوبة'**
  String get adminDashboardReviewRequiredTitle;

  /// No description provided for @adminDashboardReviewRequiredBody.
  ///
  /// In ar, this message translates to:
  /// **'فصل 10-أ يحتاج لمراجعة درجات اختبار العلوم.'**
  String get adminDashboardReviewRequiredBody;

  /// No description provided for @adminDashboardReportsReadyTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقارير جاهزة'**
  String get adminDashboardReportsReadyTitle;

  /// No description provided for @adminDashboardReportsReadyBody.
  ///
  /// In ar, this message translates to:
  /// **'تقارير الأداء الشهري للطلاب متاحة الآن للتحميل.'**
  String get adminDashboardReportsReadyBody;

  /// No description provided for @adminDashboardScheduleUpdateTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الجداول'**
  String get adminDashboardScheduleUpdateTitle;

  /// No description provided for @adminDashboardScheduleUpdateBody.
  ///
  /// In ar, this message translates to:
  /// **'تم تعديل جدول حصص المرحلة الثانوية ليوم الثلاثاء.'**
  String get adminDashboardScheduleUpdateBody;

  /// No description provided for @adminDashboardManagementAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الإدارة'**
  String get adminDashboardManagementAlerts;

  /// No description provided for @adminDashboardSchedules.
  ///
  /// In ar, this message translates to:
  /// **'الجداول'**
  String get adminDashboardSchedules;

  /// No description provided for @adminDashboardAddStudent.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طالب'**
  String get adminDashboardAddStudent;

  /// No description provided for @quickAccess.
  ///
  /// In ar, this message translates to:
  /// **'وصول سريع'**
  String get quickAccess;

  /// No description provided for @userManagementLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المستخدمين. تحقق من الاتصال ثم أعد المحاولة.'**
  String get userManagementLoadFailed;

  /// No description provided for @disableAccount.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل الحساب'**
  String get disableAccount;

  /// No description provided for @disableAccountQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تعطيل حساب {name}؟'**
  String disableAccountQuestion(Object name);

  /// No description provided for @disable.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل'**
  String get disable;

  /// No description provided for @accountDisabled.
  ///
  /// In ar, this message translates to:
  /// **'تم تعطيل الحساب'**
  String get accountDisabled;

  /// No description provided for @accountDisableFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تعطيل الحساب. يرجى المحاولة مرة أخرى'**
  String get accountDisableFailed;

  /// No description provided for @accountActivated.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل حساب {name}'**
  String accountActivated(Object name);

  /// No description provided for @accountActivateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تفعيل الحساب. يرجى المحاولة مرة أخرى'**
  String get accountActivateFailed;

  /// No description provided for @selectedClassroom.
  ///
  /// In ar, this message translates to:
  /// **'فصل محدد'**
  String get selectedClassroom;

  /// No description provided for @addUser.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم'**
  String get addUser;

  /// No description provided for @userManagementSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'التحكم في حسابات المعلمين والطلاب والصلاحيات'**
  String get userManagementSubtitle;

  /// No description provided for @userManagementSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'البحث بالاسم، البريد الإلكتروني، أو الرقم التعريفي...'**
  String get userManagementSearchHint;

  /// No description provided for @allRoles.
  ///
  /// In ar, this message translates to:
  /// **'كل الأدوار'**
  String get allRoles;

  /// No description provided for @pendingApproval.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاعتماد'**
  String get pendingApproval;

  /// No description provided for @filterByClassroom.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب الفصل'**
  String get filterByClassroom;

  /// No description provided for @clearClassroomFilter.
  ///
  /// In ar, this message translates to:
  /// **'مسح فلتر الفصل'**
  String get clearClassroomFilter;

  /// No description provided for @allClassrooms.
  ///
  /// In ar, this message translates to:
  /// **'كل الفصول'**
  String get allClassrooms;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @tryChangingSearchCriteria.
  ///
  /// In ar, this message translates to:
  /// **'جرب تغيير معايير البحث'**
  String get tryChangingSearchCriteria;

  /// No description provided for @classroomsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} فصول'**
  String classroomsCount(Object count);

  /// No description provided for @listSeparator.
  ///
  /// In ar, this message translates to:
  /// **'، '**
  String get listSeparator;

  /// No description provided for @grade.
  ///
  /// In ar, this message translates to:
  /// **'الصف'**
  String get grade;

  /// No description provided for @lastActivity.
  ///
  /// In ar, this message translates to:
  /// **'النشاط الأخير'**
  String get lastActivity;

  /// No description provided for @stop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get stop;

  /// No description provided for @approve.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد'**
  String get approve;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get disabled;

  /// No description provided for @addNewUser.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم جديد'**
  String get addNewUser;

  /// No description provided for @role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get role;

  /// No description provided for @userCreateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إنشاء المستخدم. يرجى المحاولة مرة أخرى'**
  String get userCreateFailed;

  /// No description provided for @userCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء حساب \"{name}\" بنجاح'**
  String userCreated(Object name);

  /// No description provided for @classroom.
  ///
  /// In ar, this message translates to:
  /// **'فصل دراسي'**
  String get classroom;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
