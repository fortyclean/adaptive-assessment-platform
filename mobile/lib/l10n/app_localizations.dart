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
