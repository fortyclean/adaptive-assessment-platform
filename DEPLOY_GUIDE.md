# 🚀 دليل النشر المجاني الكامل — EduAssess
## نشر Backend + قاعدة البيانات + APK للاختبار الأونلاين

---

## 📋 ملخص الخطة

| الخدمة | المنصة | التكلفة | الرابط |
|--------|--------|---------|--------|
| Backend API | Railway.app | مجاني ($5 credit) | https://railway.app |
| قاعدة البيانات | MongoDB Atlas | مجاني (512MB) | https://mongodb.com/atlas |
| Redis Cache | اختياري | - | - |
| APK | GitHub Releases | مجاني | https://github.com |

**رابط GitHub:** `https://github.com/fortyclean/adaptive-assessment-platform`
**رابط Backend (Railway):** `https://eduassess-backend-production.up.railway.app`
**Health Check:** `https://eduassess-backend-production.up.railway.app/api/v1/health`

---

## 🔵 الخطوة 1: MongoDB Atlas (قاعدة البيانات)

### 1.1 إنشاء الحساب
1. اذهب إلى: **https://www.mongodb.com/cloud/atlas/register**
2. سجّل بـ Google أو بريد إلكتروني
3. اختر **"I'm learning MongoDB"** → **"Finish"**

### 1.2 إنشاء Cluster مجاني
1. اضغط **"Build a Database"**
2. اختر **"M0 FREE"** (الخيار المجاني)
3. Provider: **AWS** | Region: **Frankfurt (eu-central-1)**
4. Cluster Name: `EduAssess`
5. اضغط **"Create"**

### 1.3 إعداد المستخدم
1. Username: `eduassess_user`
2. Password: اضغط **"Autogenerate Secure Password"** واحفظها
3. اضغط **"Create User"**

### 1.4 إعداد الشبكة
1. اختر **"Cloud Environment"**
2. اضغط **"Add My Current IP Address"**
3. ثم اضغط **"Add Entry"** وأضف: `0.0.0.0/0` (للسماح لكل IP)
4. اضغط **"Finish and Close"**

### 1.5 الحصول على Connection String
1. اضغط **"Connect"** على الـ Cluster
2. اختر **"Drivers"**
3. Driver: **Node.js** | Version: **5.5 or later**
4. انسخ الـ Connection String:
```
mongodb+srv://eduassess_user:<password>@eduassess.xxxxx.mongodb.net/?retryWrites=true&w=majority&appName=EduAssess
```
5. استبدل `<password>` بكلمة المرور التي حفظتها
6. أضف اسم قاعدة البيانات قبل `?`:
```
mongodb+srv://eduassess_user:YOUR_PASSWORD@eduassess.xxxxx.mongodb.net/adaptive_assessment?retryWrites=true&w=majority&appName=EduAssess
```

---

## 🔴 الخطوة 2: Upstash Redis (Cache)

### 2.1 إنشاء الحساب
1. اذهب إلى: **https://upstash.com**
2. اضغط **"Sign Up"** → **"Continue with GitHub"**

### 2.2 إنشاء قاعدة Redis
1. اضغط **"Create Database"**
2. Name: `eduassess-redis`
3. Type: **Regional**
4. Region: **EU-West-1 (Ireland)** أو الأقرب لك
5. اضغط **"Create"**

### 2.3 الحصول على URL
1. من صفحة قاعدة البيانات، انسخ **"REDIS_URL"**:
```
rediss://default:XXXXXXXXXXXXXXXX@eu1-xxxxx-xxxxx.upstash.io:6379
```

---

## 🟢 الخطوة 3: النشر على Render.com

### 3.1 إنشاء الحساب
1. اذهب إلى: **https://render.com**
2. اضغط **"Get Started for Free"**
3. سجّل بـ **GitHub**

### 3.2 إنشاء Web Service
1. اضغط **"New +"** → **"Web Service"**
2. اختر **"Build and deploy from a Git repository"**
3. اضغط **"Connect"** بجانب: `fortyclean/adaptive-assessment-platform`
4. إعدادات الـ Service:
   - **Name:** `eduassess-backend`
   - **Region:** Frankfurt (EU Central)
   - **Branch:** `main`
   - **Root Directory:** `backend`
   - **Runtime:** `Node`
   - **Build Command:** `npm ci && npm run build`
   - **Start Command:** `node dist/app.js`
   - **Instance Type:** `Free`

### 3.3 إضافة Environment Variables
اضغط **"Advanced"** ثم أضف المتغيرات التالية:

```
NODE_ENV = production
PORT = 10000
MONGODB_URI = [الـ URI من الخطوة 1.5]
REDIS_URL = [الـ URL من الخطوة 2.3]
JWT_SECRET = EduAssess_JWT_Secret_Key_2024_Production_Secure_32chars
REFRESH_TOKEN_SECRET = EduAssess_Refresh_Secret_Key_2024_Production_Secure
JWT_EXPIRES_IN = 8h
REFRESH_TOKEN_EXPIRES_IN = 7d
ENCRYPTION_KEY = EduAssess_Enc_Key_2024_32chars!!
RATE_LIMIT_WINDOW_MS = 60000
RATE_LIMIT_MAX = 200
CORS_ORIGIN = *
```

### 3.4 النشر
1. اضغط **"Create Web Service"**
2. انتظر 3-5 دقائق حتى يكتمل البناء
3. ✅ **الـ Backend يعمل الآن على:**
   ```
   https://eduassess-backend-8cf4.onrender.com
   ```
4. تحقق من الـ Health Check:
   ```
   https://eduassess-backend-8cf4.onrender.com/api/v1/health
   ```
   يجب أن يرجع:
   ```json
   {"status": "healthy", ...}
   ```

---

## 🌱 الخطوة 4: تشغيل Seed (البيانات التجريبية)

### من Render Shell:
1. في Render Dashboard → اضغط على الـ Service
2. اضغط **"Shell"** (في القائمة العلوية)
3. شغّل:
```bash
MONGODB_URI="YOUR_MONGODB_URI" node scripts/seed-production.js
```

### أو من جهازك المحلي:
```bash
cd "E:\Farid baghoza\Education study\adaptive-assessment-platform\backend"
set MONGODB_URI=YOUR_MONGODB_URI
node scripts/seed-production.js
```

**بيانات الدخول بعد Seed:**
| الدور | اسم المستخدم | كلمة المرور |
|-------|-------------|-------------|
| مشرف | admin | Admin@123 |
| معلم | teacher | Teacher@123 |
| طالب | student | Student@123 |

---

## 📱 الخطوة 5: بناء APK مع Backend الحقيقي

```bash
cd "E:\Farid baghoza\Education study\adaptive-assessment-platform\mobile"

flutter build apk --release ^
  --dart-define=API_URL=https://eduassess-backend-8cf4.onrender.com/api/v1
```

الـ APK سيكون في:
```
mobile\build\app\outputs\flutter-apk\app-release.apk
```

> ✅ **تم بناء APK جاهز:** `adaptive-mastery-v1.0.0-online.apk` (63.2MB)

---

## 🔗 الخطوة 6: مشاركة APK للاختبار

### خيار 1: GitHub Releases (موصى به)
1. اذهب إلى: `https://github.com/fortyclean/adaptive-assessment-platform/releases`
2. اضغط **"Create a new release"**
3. Tag: `v1.0.0`
4. Title: `EduAssess v1.0.0 - Beta Release`
5. ارفع ملف APK
6. اضغط **"Publish release"**
7. شارك الرابط المباشر للـ APK

### خيار 2: Firebase App Distribution (مجاني)
1. اذهب إلى: **https://console.firebase.google.com**
2. أنشئ مشروعاً جديداً
3. اذهب إلى **App Distribution**
4. ارفع APK وأضف المختبرين بالبريد الإلكتروني

### خيار 3: Diawi (أسرع للاختبار)
1. اذهب إلى: **https://www.diawi.com**
2. ارفع APK
3. احصل على رابط مباشر

---

## ✅ التحقق من النشر

بعد اكتمال كل الخطوات، تحقق من:

1. **Health Check:**
   ```
   GET https://eduassess-backend-production.up.railway.app/api/v1/health
   ```

2. **تسجيل الدخول:**
   ```
   POST https://eduassess-backend-production.up.railway.app/api/v1/auth/login
   Body: {"username": "admin", "password": "Admin@123"}
   ```

3. **APK يتصل بالـ Backend:**
   - ثبّت `adaptive-mastery-v1.0.0-railway.apk`
   - سجّل الدخول بـ admin / Admin@123
   - يجب أن تظهر البيانات الحقيقية

---

## ⚠️ ملاحظات مهمة

- **Render Free Tier:** الـ service ينام بعد 15 دقيقة من عدم الاستخدام، أول طلب يستغرق 30-60 ثانية للاستيقاظ
- **MongoDB Atlas Free:** 512MB تخزين، كافٍ للاختبار
- **Upstash Free:** 10,000 طلب/يوم، كافٍ للاختبار
- للإنتاج الحقيقي: استخدم Railway ($5/شهر) أو Render Starter ($7/شهر)

---

## 🆘 حل المشاكل الشائعة

### المشكلة: "Cannot connect to MongoDB"
- تأكد من إضافة `0.0.0.0/0` في MongoDB Atlas Network Access
- تأكد من صحة كلمة المرور في الـ URI

### المشكلة: "Redis connection failed"
- تأكد من نسخ الـ URL الكامل من Upstash بما فيه `rediss://`

### المشكلة: APK لا يتصل بالـ Backend
- تأكد من بناء APK مع `--dart-define=API_URL=...`
- تأكد من أن الـ URL يبدأ بـ `https://`

---

*آخر تحديث: مايو 2026 | EduAssess v1.0.12*
