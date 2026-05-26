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
  /// **'صح'**
  String get trueLabel;

  /// No description provided for @falseLabel.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get falseLabel;

  /// No description provided for @questionTypeMcq.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من متعدد'**
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
  /// **'المادة الدراسية'**
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
  /// **'تم حفظ التغييرات'**
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
