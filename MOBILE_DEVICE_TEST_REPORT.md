# تقرير اختبار الهاتف للتطبيق

تاريخ الاختبار: 2026-06-06
المشروع: Adaptive Assessment Platform / EduAssess
المسار: `mobile`
الحزمة: `com.adaptivemastery.app`
الإصدار: `1.0.98+98`

## الملخص

تم تنفيذ اختبار فعلي على هاتف Android متصل عبر ADB:

- الجهاز: `2306EPN60G`
- Android: 15 / API 35
- Device ID: `7TSO9XW8897PKFTW`
- نوع البناء: Debug APK
- APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`

تمت معالجة مشكلة خلط الثيم الليلي القديم مع شاشات ذات أسطح فاتحة. السبب العملي كان وجود حالة `dark` محفوظة من إصدار سابق، بينما بعض الشاشات لا تزال تستخدم ألوان سطح فاتحة ثابتة. تم منع استرجاع الثيم الليلي القديم تلقائيا عند التشغيل حتى تظل الواجهة فاتحة ومتسقة، مع بقاء تفعيل الوضع الليلي من الإعدادات ممكنا بعد ذلك.

تم أيضا تقليل احتمالات overflow في شريط التنقل السفلي على الهاتف عبر تبسيط محتوى عناصر التنقل إلى أيقونات مع تسميات دلالية.

## الأوامر المنفذة

| الأمر | النتيجة |
|---|---|
| `flutter clean` | نجح |
| `flutter pub get` | نجح |
| `flutter analyze` | نجح بدون مشاكل |
| `flutter build apk --debug` | نجح |
| `adb install -r build/app/outputs/flutter-apk/app-debug.apk` | نجح |
| تشغيل التطبيق عبر `adb shell am start` | نجح |
| فحص `logcat` لعملية التطبيق | لا توجد `FATAL EXCEPTION` أو `FlutterError` أو `RenderFlex overflowed` |

## نتيجة الفحص على الهاتف

| الشاشة | النتيجة | ملاحظات |
|---|---|---|
| شاشة تسجيل الدخول | نجحت | ظهرت بعد التشغيل بدون توقف أو شاشة سوداء |
| الدخول بوضع الطالب التجريبي | نجح | تم الانتقال إلى لوحة الطالب |
| لوحة الطالب | نجحت بعد clean build | التباين واضح بعد إلغاء استرجاع الثيم الليلي القديم |
| شريط التنقل السفلي | نجح | أزيل overflow الأحمر بعد تبسيط العناصر |

## الأدلة

- `qa-artifacts/eduassess_clean_build_student.png`
- `qa-artifacts/clean_build_pid_logcat.txt`
- `qa-artifacts/clean_build_current.xml`

## الملفات المعدلة

| الملف | التعديل |
|---|---|
| `mobile/lib/core/theme/app_theme.dart` | إضافة قيم سطح ناقصة للثيم الفاتح مثل `onSurfaceVariant` ودرجات `surfaceContainer` |
| `mobile/lib/shared/providers/theme_provider.dart` | منع استرجاع حالة dark قديمة تلقائيا عند التشغيل |
| `mobile/lib/shared/widgets/app_bottom_nav.dart` | تبسيط عناصر التنقل إلى أيقونات مع `Semantics` لمنع overflow |

## ملاحظات متبقية

- الوضع الليلي يحتاج جولة مراجعة منفصلة لكل الشاشات قبل اعتماده افتراضيا، لأن بعض الشاشات ما زالت تستخدم أسطحا فاتحة ثابتة.
- لم يتم رفع أي تغييرات إلى GitHub حسب تعليمات البرومت.
