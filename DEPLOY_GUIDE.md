# دليل النشر والتشغيل — EduAssess

> الإصدار المرجعي: `1.0.88`
> آخر تحديث: مايو 2026

---

## 1) الهدف من هذا الدليل

هذا الدليل يوضح خطوات نشر وتشغيل المنصة (Backend + Mobile) بشكل آمن وواضح، مع الحفاظ على نفس سلوك بيئة الإنتاج.

---

## 2) المتطلبات الأساسية

- Node.js `18+`
- Flutter `3.19+`
- MongoDB Atlas
- حساب استضافة للـ Backend (Render / Railway / VPS)
- GitHub (للتحديثات والنشر المستمر)

---

## 3) إعداد متغيرات البيئة للـ Backend

أنشئ ملف `.env` داخل `backend/` وتأكد من القيم التالية:

```env
NODE_ENV=production
PORT=3000
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_strong_jwt_secret
JWT_REFRESH_SECRET=your_strong_refresh_secret
ENCRYPTION_KEY=64_hex_chars
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=100
```

توليد `ENCRYPTION_KEY`:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## 4) تجهيز قاعدة البيانات

1. تأكد أن `MONGODB_URI` يشير إلى قاعدة الإنتاج الصحيحة.
2. فعّل فهارس المجموعات المهمة (Users, Classrooms, Assessments, Attempts).
3. لا تستخدم بيانات Demo داخل قاعدة الإنتاج.

---

## 5) نشر الـ Backend

### عبر GitHub

1. ادفع آخر تغييرات الفرع الرئيسي.
2. اربط خدمة الاستضافة بالمستودع.
3. اضبط:
   - Build Command: `npm install && npm run build`
   - Start Command: `npm run start`
4. أضف متغيرات البيئة من لوحة الاستضافة.

### فحص الصحة بعد النشر

اختبر نقطة الصحة:

```bash
GET /api/v1/health
```

يجب أن تكون الاستجابة `healthy`.

### إصدار GitHub Release (رفع الـ APK)

بعد بناء وتسمية الملف `adaptive-mastery-v{VERSION}.apk` في جذر المشروع، ومع تثبيت [GitHub CLI](https://cli.github.com/) وتسجيل الدخول (`gh auth login`):

```bash
cd adaptive-assessment-platform
gh release create v1.0.88 --title "EduAssess v1.0.88 - Onboarding localization" --generate-notes
gh release upload v1.0.88 adaptive-mastery-v1.0.88.apk --clobber
```

إن لم يكن `gh` متاحاً، أنشئ الإصدار يدوياً من صفحة المستودع على GitHub وارفع نفس ملف الـ APK.

---

## 6) ربط تطبيق الجوال ببيئة الإنتاج

داخل تطبيق Flutter تأكد أن `apiBaseUrl` يشير إلى رابط الـ Backend المنشور (وليس المحلي).

أمثلة:

- `https://your-domain.com/api/v1`

ثم نفذ:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

لتفعيل Push Notifications الحقيقي في نسخة الإنتاج، أضف OneSignal App ID أثناء البناء:

```bash
flutter build apk --release --dart-define=ONESIGNAL_APP_ID=your_onesignal_app_id
```

لتفعيل تتبع الأعطال الإنتاجي، أضف Sentry DSN بدون حفظه داخل المستودع:

```bash
flutter build apk --release --dart-define=SENTRY_DSN=https://public@sentry.example/project --dart-define=APP_RELEASE=adaptive-mastery@1.0.88+88 --dart-define=APP_ENV=production
```

---

## 7) قواعد مهمة قبل أي إصدار

1. أي تعديل وظيفي أو إصلاح يجب أن يُذكر في **سجل الإصدارات داخل التطبيق**.
2. اسم ملف الإصدار لا يتضمن كلمة `railway`.
3. لا يتم تغيير الهوية البصرية أو نمط التصميم المعتمد بدون طلب صريح.
4. عند وجود ميزة غير مكتملة (مثل ثيم جزئي)، تُخفى مؤقتًا بدل إظهار سلوك مضلل.
5. وضع Demo يجب أن يحاكي إعدادات Online قدر الإمكان لاختبارات الصلاحيات والتنقل.

---

## 8) Checklist ما قبل التسليم

- [ ] تسجيل الدخول / Refresh / Session يعمل بدون انقطاع
- [ ] تدفق الاختبار التكيفي كامل: جلب السؤال → حفظ الإجابة → النتيجة
- [ ] صلاحيات الأدوار (مشرف/معلم/طالب) متطابقة مع المتطلبات
- [ ] النصوص العربية لا تحتوي على ألفاظ إنجليزية غير مقصودة
- [ ] لا يوجد Overflow بصري في الشاشات أو سجل الإصدارات
- [ ] زر تسجيل الخروج + عن التطبيق + الإعدادات متاحة في أماكنها
- [ ] البناء النهائي يعمل: `flutter build apk --release`

---

## 9) ملاحظة تشغيلية

إذا اختلف سلوك نسخة Demo عن Online:

1. راجع مصدر البيانات في وضع Demo.
2. راجع صلاحيات الحسابات التجريبية.
3. راجع مسارات التنقل المحمية (Protected Routes).

الهدف أن تكون تجربة الاختبار الخارجية قريبة جدًا من الإنتاج.

آخر تحديث: يونيو 2026 | EduAssess v1.0.88
