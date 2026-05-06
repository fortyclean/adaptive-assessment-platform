# دليل الإعداد والتشغيل — منصة التقييم التكيفي

## المتطلبات الأساسية

قبل البدء، تأكد من تثبيت البرامج التالية على جهازك:

| البرنامج | الإصدار المطلوب | رابط التحميل |
|---------|----------------|-------------|
| Node.js | 18 أو أحدث | https://nodejs.org |
| Docker Desktop | أحدث إصدار | https://www.docker.com/products/docker-desktop |
| Flutter SDK | 3.19 أو أحدث | https://flutter.dev/docs/get-started/install |
| Git | أي إصدار | https://git-scm.com |
| Android Studio أو VS Code | أحدث إصدار | للتطوير والمحاكاة |

---

## الخطوة 1: تشغيل الباكند

### 1.1 إعداد متغيرات البيئة

```bash
cd adaptive-assessment-platform/backend
copy .env.example .env
```

افتح ملف `.env` وعدّل القيم التالية:

```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/adaptive_assessment
REDIS_URL=redis://localhost:6379
JWT_SECRET=change-this-to-a-32-char-secret-key-here
JWT_REFRESH_SECRET=change-this-to-another-32-char-secret
ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
BCRYPT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=100
```

> **ملاحظة:** `ENCRYPTION_KEY` يجب أن يكون 64 حرف hex (32 بايت). يمكن توليده بـ:
> ```bash
> node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
> ```

### 1.2 تشغيل MongoDB و Redis

```bash
cd adaptive-assessment-platform
docker-compose up -d
```

تحقق أن الحاويات تعمل:
```bash
docker ps
```

يجب أن ترى `mongodb` و `redis` في القائمة.

### 1.3 تثبيت الحزم وتشغيل الباكند

```bash
cd adaptive-assessment-platform/backend
npm install
npm run dev
```

تحقق أن الباكند يعمل:
```bash
# Windows
curl http://localhost:3000/api/v1/health

# أو افتح في المتصفح:
# http://localhost:3000/api/v1/health
```

يجب أن ترى:
```json
{
  "status": "healthy",
  "services": {
    "api": { "status": "up" },
    "mongodb": { "status": "up" },
    "redis": { "status": "up" }
  }
}
```

---

## الخطوة 2: إنشاء حساب Admin أولي

```bash
cd adaptive-assessment-platform/backend
node -e "
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI).then(async () => {
  const hash = await bcrypt.hash('Admin@1234', 12);
  const result = await mongoose.connection.db.collection('users').insertOne({
    username: 'admin',
    passwordHash: hash,
    email: 'admin@school.edu',
    fullName: 'مشرف النظام',
    role: 'admin',
    isActive: true,
    classroomIds: [],
    failedLoginAttempts: 0,
    activeSessions: [],
    createdAt: new Date(),
    updatedAt: new Date()
  });
  console.log('✅ Admin created successfully!');
  console.log('   Username: admin');
  console.log('   Password: Admin@1234');
  process.exit(0);
}).catch(err => {
  console.error('❌ Error:', err.message);
  process.exit(1);
});
"
```

---

## الخطوة 3: تشغيل تطبيق Flutter

### 3.1 تثبيت الحزم

```bash
cd adaptive-assessment-platform/mobile
flutter pub get
```

### 3.2 تعديل عنوان API

افتح الملف: `lib/core/constants/app_constants.dart`

عدّل `apiBaseUrl` حسب بيئتك:

```dart
// ─── للمحاكي (Android Emulator) ───────────────────────────────────────────
static const String apiBaseUrl = 'http://10.0.2.2:3000/api/v1';

// ─── للجهاز الحقيقي (Android/iOS) ────────────────────────────────────────
// استبدل 192.168.1.X بـ IP جهاز الكمبيوتر على الشبكة المحلية
static const String apiBaseUrl = 'http://192.168.1.X:3000/api/v1';

// ─── للـ iOS Simulator ────────────────────────────────────────────────────
static const String apiBaseUrl = 'http://localhost:3000/api/v1';
```

> **كيف تعرف IP جهازك؟**
> ```bash
> # Windows
> ipconfig
> # ابحث عن "IPv4 Address" تحت اتصال الشبكة
> ```

### 3.3 تشغيل التطبيق

```bash
# عرض الأجهزة المتاحة
flutter devices

# تشغيل على محاكي Android
flutter run -d emulator-5554

# تشغيل على جهاز Android حقيقي (تأكد من تفعيل USB Debugging)
flutter run -d <device-id>

# تشغيل على iOS Simulator (macOS فقط)
flutter run -d iPhone

# تشغيل وتحديد الجهاز تفاعلياً
flutter run
```

---

## الخطوة 4: سيناريو الاختبار الكامل

### 4.1 تسجيل الدخول كمشرف
- **اسم المستخدم:** `admin`
- **كلمة المرور:** `Admin@1234`

### 4.2 إنشاء معلم
1. اذهب إلى **إدارة المستخدمين**
2. اضغط **إضافة مستخدم**
3. أدخل البيانات واختر دور **معلم**
4. مثال: `teacher1 / Teacher@1234`

### 4.3 إنشاء طالب
1. نفس الخطوات، اختر دور **طالب**
2. مثال: `student1 / Student@1234`

### 4.4 إنشاء فصل دراسي
1. اذهب إلى **إدارة الفصول**
2. أنشئ فصلاً وأضف الطالب والمعلم إليه

### 4.5 إضافة أسئلة (كمعلم)
1. سجّل دخول بحساب المعلم
2. اذهب إلى **بنك الأسئلة** → **إضافة سؤال**
3. أضف على الأقل **9 أسئلة** (3 سهل + 3 متوسط + 3 صعب) لنفس المادة والوحدة

### 4.6 إنشاء اختبار ونشره
1. اضغط **إنشاء اختبار جديد**
2. اختر النوع **تكيفي**، حدد المادة والوحدة
3. اضبط عدد الأسئلة (مثلاً 5) والوقت (مثلاً 10 دقائق)
4. أضف الفصل الدراسي
5. اضغط **نشر الاختبار**

### 4.7 أداء الاختبار (كطالب)
1. سجّل دخول بحساب الطالب
2. ستظهر إشعار بالاختبار الجديد
3. اضغط على الاختبار → **ابدأ الاختبار الآن**
4. أجب على الأسئلة
5. اضغط **إنهاء الاختبار**
6. شاهد النتيجة والنقاط

---

## الخطوة 5: تشغيل الاختبارات الآلية

### اختبارات الباكند
```bash
cd adaptive-assessment-platform/backend

# كل الاختبارات
npm test

# اختبارات المحرك التكيفي فقط
npm test -- --testPathPattern=adaptiveEngine

# اختبارات الخصائص (PBT)
npm test -- --testPathPattern=adaptiveEngine.pbt

# اختبار التكامل
npm test -- --testPathPattern=fullSessionFlow

# اختبار الأداء (20 جلسة متزامنة)
npm test -- --testPathPattern=performanceConcurrent

# تقرير التغطية
npm run test:coverage
```

### اختبارات Flutter
```bash
cd adaptive-assessment-platform/mobile

# كل الاختبارات
flutter test

# اختبارات المصادقة
flutter test test/auth/

# اختبارات الطالب
flutter test test/student/

# اختبارات المعلم
flutter test test/teacher/

# اختبارات المشرف
flutter test test/admin/
```

---

## حل المشاكل الشائعة

### ❌ `Connection refused` على Android Emulator
```dart
// غيّر في app_constants.dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api/v1';
```

### ❌ `Network error` على جهاز حقيقي
- تأكد أن الجهاز والكمبيوتر على **نفس شبكة WiFi**
- استخدم IP الكمبيوتر: `http://192.168.1.X:3000/api/v1`
- تأكد أن جدار الحماية (Firewall) لا يحجب المنفذ 3000

### ❌ `MongoDB connection failed`
```bash
# تأكد أن Docker يعمل
docker ps
# إذا لم يعمل
docker-compose up -d
```

### ❌ `flutter pub get` يفشل
```bash
flutter clean
flutter pub get
```

### ❌ خطأ في JWT_SECRET
تأكد أن `JWT_SECRET` في `.env` يحتوي على **32 حرف على الأقل**.

---

## بناء APK للاختبار على Android

```bash
cd adaptive-assessment-platform/mobile

# APK للاختبار (debug)
flutter build apk --debug

# APK للإنتاج (release)
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=API_URL=http://YOUR_SERVER_IP:3000/api/v1

# الملف سيكون في:
# build/app/outputs/flutter-apk/app-debug.apk
# أو
# build/app/outputs/flutter-apk/app-release.apk
```

لتثبيت APK مباشرة على جهاز متصل:
```bash
flutter install
```

---

## هيكل المشروع

```
adaptive-assessment-platform/
├── backend/                    # Node.js + Express + TypeScript
│   ├── src/
│   │   ├── models/            # نماذج MongoDB
│   │   ├── routes/            # نقاط نهاية API
│   │   ├── services/          # منطق الأعمال (محرك التكيف، التشفير...)
│   │   ├── middleware/        # المصادقة، معالجة الأخطاء...
│   │   └── config/            # إعدادات DB و Redis
│   └── tests/
│       ├── unit/              # اختبارات الوحدة
│       └── integration/       # اختبارات التكامل والأداء
│
└── mobile/                    # Flutter + Dart
    ├── lib/
    │   ├── core/              # الثوابت، الألوان، التنقل
    │   ├── features/          # الشاشات والمستودعات
    │   └── shared/            # الودجات المشتركة
    └── test/                  # اختبارات Flutter
```

---

## بيانات الدخول الافتراضية

| الدور | اسم المستخدم | كلمة المرور |
|------|-------------|------------|
| مشرف | `admin` | `Admin@1234` |
| معلم | أنشئه من لوحة المشرف | حسب ما تحدده |
| طالب | أنشئه من لوحة المشرف | حسب ما تحدده |
