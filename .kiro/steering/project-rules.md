# قواعد مشروع EduAssess — Adaptive Assessment Platform

## 1. نظام الإصدارات (Versioning)

### القاعدة الأساسية
كل تحديث أو إصلاح يجب أن يُرفق بإصدار جديد. لا يُقبل تعديل الكود دون رفع رقم الإصدار.

### تنسيق الإصدار
```
MAJOR.MINOR.PATCH+BUILD
مثال: 1.0.7+7
```

| النوع | متى يُرفع | مثال |
|-------|-----------|------|
| PATCH | إصلاح خطأ أو تحسين بسيط | 1.0.6 → 1.0.7 |
| MINOR | ميزة جديدة أو تحسين واضح | 1.0.7 → 1.1.0 |
| MAJOR | تغيير جوهري في البنية | 1.x.x → 2.0.0 |
| BUILD | يساوي دائماً رقم PATCH | +7 مع 1.0.7 |

### الملفات التي يجب تحديثها عند كل إصدار جديد

**1. `mobile/pubspec.yaml`**
```yaml
version: 1.0.X+X   # رفع PATCH والـ BUILD معاً
```

**2. `backend/package.json`**
```json
"version": "1.0.X"
```

**3. داخل التطبيق نفسه (إلزامي) — شاشة "عن التطبيق" وسجل الإصدارات الداخلي**
- يجب تحديث **رقم الإصدار المعروض داخل التطبيق** ليتطابق مع `pubspec.yaml`
- يجب تحديث **بطاقة "الإصدار الحالي"** داخل شاشة "عن التطبيق" (العنوان + النقاط)
- يجب إضافة نفس الإصدار في **سجل الإصدارات داخل التطبيق** مع وصف التغييرات
- لا يُعتمد أي إصلاح أو إصدار إذا كانت بيانات الإصدار داخل التطبيق غير محدثة

**4. `دليل_استخدام_التطبيق.md` — قسم "سجل التحديثات"**
- أضف قسماً جديداً بالتنسيق:
```markdown
### الإصدار X.X.X — [الشهر السنة]
#### ✅ [عنوان التحديث]
- [وصف التغيير 1]
- [وصف التغيير 2]
```

**5. `DEPLOY_GUIDE.md`**
- حدّث السطر الأخير: `آخر تحديث: [الشهر السنة] | EduAssess vX.X.X`

### تسمية ملفات APK
```
adaptive-mastery-v{VERSION}-{ENVIRONMENT}.apk
```
أمثلة:
- `adaptive-mastery-v1.0.7.apk` — الإصدار العام
- `adaptive-mastery-v1.0.7-railway.apk` — مع Railway backend
- `adaptive-mastery-v1.0.7-online.apk` — مع Render backend

### الإصدار الحالي
- **Flutter (mobile):** `1.0.7+7`
- **Backend (Node.js):** `1.0.0`
- **آخر APKs منشورة:** v1.0.0 → v1.0.6 (6 إصدارات سابقة)

---

## 2. قواعد بناء APK

### أمر البناء القياسي
```bash
cd "E:\Farid baghoza\Education study\adaptive-assessment-platform\mobile"

# APK مع Backend الحقيقي (Render)
flutter build apk --release ^
  --dart-define=API_URL=https://eduassess-backend-8cf4.onrender.com/api/v1

# APK مع Railway backend
flutter build apk --release ^
  --dart-define=API_URL=https://eduassess-backend-production.up.railway.app/api/v1

# APK Demo (بدون backend)
flutter build apk --release
```

### مسار APK الناتج
```
mobile\build\app\outputs\flutter-apk\app-release.apk
```

### بعد البناء — انسخ APK وأعد تسميته
```
app-release.apk → adaptive-mastery-v{VERSION}-{ENV}.apk
```
ثم انقله إلى جذر المشروع:
```
adaptive-assessment-platform\adaptive-mastery-v{VERSION}-{ENV}.apk
```

---

## 3. قواعد Backend

### بيانات الاتصال
- **Railway:** `https://eduassess-backend-production.up.railway.app`
- **Render:** `https://eduassess-backend-8cf4.onrender.com`
- **Health Check:** `{BASE_URL}/api/v1/health`
- **GitHub:** `https://github.com/fortyclean/adaptive-assessment-platform`

### بيانات الدخول التجريبية (لا تُغيَّر)
| الدور | اسم المستخدم | كلمة المرور |
|-------|-------------|-------------|
| مشرف | admin | Admin@123 |
| معلم | teacher | Teacher@123 |
| طالب | student | Student@123 |

### قواعد API
- جميع الـ endpoints تبدأ بـ `/api/v1/`
- المصادقة عبر JWT (مدة 8 ساعات)
- Refresh Token عبر HttpOnly Secure cookie
- Rate Limiting: 100 طلب/دقيقة لكل مستخدم

---

## 4. قواعد Flutter (Mobile)

## قاعدة إلزامية: بقاء تسجيل الدخول متاحاً دائماً

- يجب أن يبقى تسجيل الدخول متاحاً بعد أي تعديل، وبكل صوره: اسم المستخدم وكلمة المرور، Google Sign-In، استرجاع الجلسة، refresh token، وحسابات الديمو.
- لا يجوز نشر أي تحديث قبل اختبار تسجيل الدخول للحسابات التجريبية الثلاثة:
  - `admin / Admin@123`
  - `teacher / Teacher@123`
  - `student / Student@123`
- يجب ألا يؤدي فشل Google Sign-In أو نقص إعداداته إلى تعطيل تسجيل الدخول العادي.
- عند تعذر Google Sign-In يجب عرض رسالة واضحة للمستخدم، وليس خطأ خادم عام أو توقف صامت.
- يجب الحفاظ على حسابات الديمو الخارجية متزامنة مع وضع الأونلاين، وتحديثها تلقائياً عند تشغيل الباكند أو seed الإنتاج.
- أي تعديل في `auth`, `session`, `refresh`, `Google Sign-In`, `CORS`, `JWT`, أو `API_URL` يعتبر تعديلاً عالي الخطورة، ويجب بعده اختبار:
  - `/api/v1/health`
  - `/api/v1/auth/login`
  - `/api/v1/auth/refresh`
  - تسجيل الدخول من التطبيق نفسه إن أمكن
- لا تعتمد أي رسالة "اسم المستخدم أو كلمة المرور غير صحيحة" قبل التأكد أن الخادم متصل بقاعدة البيانات الصحيحة وأن حسابات الاختبار محدثة.

---

### هيكل المشروع
```
lib/
├── features/     # ميزات التطبيق (auth, assessment, admin, teacher, student)
├── core/         # الأساسيات (theme, router, constants)
└── shared/       # مكونات مشتركة
```

### إدارة الحالة
- **Riverpod** فقط — لا تستخدم Provider أو Bloc
- كل feature لها providers خاصة بها

### التنقل
- **GoRouter** فقط — لا تستخدم Navigator مباشرة
- المسارات معرّفة في `AppRoutes`
- تمرير البيانات بين الشاشات عبر `extra` في GoRouter

### التصميم
- **اللغة:** عربية RTL بالكامل
- **الخط:** Almarai للعربية، Lexend للإنجليزية
- **الألوان:**
  - Primary: `#00288E`
  - Error: `#BA1A1A`
  - Success: `#047857`
- **المكونات:** Material Design 3

### قواعد الكود
- استخدم `context.push()` للتنقل مع إمكانية الرجوع
- استخدم `context.go()` للتنقل بدون إمكانية الرجوع
- زر الرجوع في AppBar يجب أن يكون مشروطاً: `leading: context.canPop() ? IconButton(...) : null`
- جميع الـ catch blocks يجب أن تعرض SnackBar للمستخدم — لا توجيه صامت

---

## 5. قواعد إصلاح الأخطاء (Bugfix)

### المنهجية المتبعة
1. **اكتب اختبار يُثبت الخطأ أولاً** (Bug Condition Test) — قبل أي إصلاح
2. **اكتب اختبارات الحفاظ** (Preservation Tests) — للسلوكيات الصحيحة
3. **طبّق الإصلاح**
4. **تحقق من نجاح اختبار Bug Condition**
5. **تحقق من استمرار نجاح اختبارات الحفاظ**

### قواعد الـ catch blocks
```dart
// ❌ خطأ — توجيه صامت
} catch (e) {
  context.push('/some-screen');
}

// ✅ صحيح — إظهار رسالة للمستخدم
} catch (e) {
  setState(() => _isLoading = false);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تعذر تنفيذ العملية، يرجى المحاولة مرة أخرى'),
      backgroundColor: AppColors.error,
      action: SnackBarAction(label: 'إعادة المحاولة', onPressed: _retry),
    ),
  );
}
```

### قواعد التنقل من البطاقات والتنبيهات
- كل بطاقة أو تنبيه يجب أن يفتح شاشة حقيقية — لا SnackBar فقط
- عند فتح شاشة مع تصفية، مرّر `extra: {'initialFilter': '...'}` عبر GoRouter
- الشاشة المستقبِلة تقرأ `extra` في `initState` وتطبّق الفلتر

---

## 6. قواعد قاعدة البيانات

### MongoDB Atlas
- Cluster: `EduAssess` — AWS Frankfurt
- قاعدة البيانات: `adaptive_assessment`
- نسخ احتياطي: يومي، احتفاظ 30 يوم

### Redis (Upstash)
- TTL للأسئلة: 1 ساعة
- TTL للاختبار: 24 ساعة
- TTL للجلسة: 8 ساعات
- TTL للفصل: 30 دقيقة

---

## 7. قواعد النشر (Deployment)

### ترتيب النشر
1. تحديث رقم الإصدار في `pubspec.yaml` و`package.json`
2. بناء Backend وتشغيل الاختبارات
3. نشر Backend على Railway/Render
4. بناء APK مع الـ API URL الصحيح
5. تسمية APK بالإصدار الصحيح
6. تحديث `دليل_استخدام_التطبيق.md` بسجل التحديثات
7. تحديث `DEPLOY_GUIDE.md`
8. رفع APK على GitHub Releases

### GitHub Releases
- Tag: `v{VERSION}` (مثل `v1.0.7`)
- Title: `EduAssess v{VERSION} - [وصف مختصر]`
- ارفع جميع ملفات APK للإصدار

---

## 8. قواعد الأمان

- لا تُعرض stack traces أو مسارات داخلية في responses
- لا ترسل الإجابة الصحيحة للعميل قبل انتهاء الاختبار
- تشفير AES-256 للحقول الحساسة في MongoDB
- HTTPS/TLS 1.2+ إلزامي على جميع الـ routes
- تحديد الجلسات المتزامنة: 2 أجهزة كحد أقصى

---

## 9. قواعد الاختبارات

### Backend (Jest)
- اختبارات وحدة لكل module
- اختبارات تكامل للـ session flow الكامل
- Property-Based Testing للـ adaptive engine

### Flutter (Widget Tests)
- اختبار كل شاشة رئيسية
- اختبار التنقل بين الشاشات
- اختبار حالات الخطأ والـ edge cases

---

## 10. المواد الدراسية المدعومة (MVP)

1. Mathematics (الرياضيات)
2. English (الإنجليزية)
3. Arabic — لغتي (العربية)
4. Physics (الفيزياء)
5. Chemistry (الكيمياء)
6. Biology (الأحياء)

---

## 11. حدود النظام

| المعيار | القيمة |
|---------|--------|
| عدد الأسئلة في الاختبار | 5 — 50 سؤال |
| مدة الاختبار | 5 — 120 دقيقة |
| حجم ملف Excel للاستيراد | حتى 10MB |
| الإشعارات المحفوظة | آخر 50 لكل مستخدم |
| سجل تسجيل الدخول | آخر 100 حدث |
| الطلاب المدعومون | 10,000 طالب |
| المعلمون المدعومون | 500 معلم |
| الأسئلة المدعومة | 1,000,000 سؤال |

---

## 12. قاعدة إلزامية للحفاظ على التصاميم

- يجب اعتبار ملفات التصميم الأصلية في `stitch_adaptive_assessment_platform` مرجعاً ملزماً للشكل والتجربة عند تعديل أي شاشة.
- لا يجوز تغيير الطابع البصري أو أماكن العناصر الأساسية أو أسلوب البطاقات والتنقل إلا إذا كان التغيير مطلوباً صراحة أو يعالج خللاً واضحاً.
- عند إضافة وظيفة إلى شاشة موجودة، يجب دمجها داخل نفس لغة التصميم الأصلية للشاشة، وليس إنشاء نمط واجهة جديد يختلف عنها.
- يجب الحفاظ على وضوح العناصر الأساسية مثل تسجيل الخروج، عن التطبيق، الدعم، والإعدادات دون إخفائها بطريقة تضعف شعور المستخدم بالثبات والثقة.
- أي تعديل بصري على شاشة رئيسية يجب أن يراجع مقابل ملفها المرجعي في `stitch_adaptive_assessment_platform` قبل البناء والإصدار.
