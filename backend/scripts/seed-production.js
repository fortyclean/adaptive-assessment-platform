/**
 * Production Seed Script — EduAssess
 * ====================================
 * ينشئ بيانات تجريبية كاملة للاختبار على الإنتاج
 *
 * تشغيل: MONGODB_URI=<your_uri> node scripts/seed-production.js
 */

const { MongoClient, ObjectId } = require('mongodb');
const bcrypt = require('bcrypt');

const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/adaptive_assessment';
const COST_FACTOR = 10; // أقل في الإنتاج لسرعة أكبر

async function seed() {
  const client = new MongoClient(MONGO_URI);
  await client.connect();
  console.log('✅ Connected to MongoDB');

  const db = client.db();

  // ── 1. إنشاء Indexes ──────────────────────────────────────────────────────
  await db.collection('users').createIndex({ username: 1 }, { unique: true });
  await db.collection('users').createIndex({ email: 1 }, { unique: true, sparse: true });
  await db.collection('classrooms').createIndex({ name: 1 });
  await db.collection('assessments').createIndex({ status: 1 });
  await db.collection('questions').createIndex({ subject: 1, difficulty: 1 });
  console.log('✅ Indexes created');

  // ── 2. إنشاء المستخدمين ───────────────────────────────────────────────────
  const users = [
    {
      username: 'admin',
      password: 'Admin@123',
      email: 'admin@school.edu',
      fullName: 'محمد علي المشرف',
      role: 'admin',
    },
    {
      username: 'teacher',
      password: 'Teacher@123',
      email: 'teacher@school.edu',
      fullName: 'سارة أحمد المعلمة',
      role: 'teacher',
    },
    {
      username: 'student',
      password: 'Student@123',
      email: 'student@school.edu',
      fullName: 'أحمد محمد الطالب',
      role: 'student',
    },
  ];

  const userIds = {};
  for (const user of users) {
    const existing = await db.collection('users').findOne({ username: user.username });
    if (existing) {
      console.log(`⚠️  User '${user.username}' already exists — skipping`);
      userIds[user.role] = existing._id;
      continue;
    }
    const passwordHash = await bcrypt.hash(user.password, COST_FACTOR);
    const result = await db.collection('users').insertOne({
      username: user.username,
      passwordHash,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      isActive: true,
      classroomIds: [],
      failedLoginAttempts: 0,
      activeSessions: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    userIds[user.role] = result.insertedId;
    console.log(`✅ Created ${user.role}: ${user.username} / ${user.password}`);
  }

  // ── 3. إنشاء فصل دراسي ───────────────────────────────────────────────────
  let classroomId;
  const existingClassroom = await db.collection('classrooms').findOne({ name: 'أولى متوسط (أ)' });
  if (existingClassroom) {
    classroomId = existingClassroom._id;
    console.log('⚠️  Classroom already exists — skipping');
  } else {
    const classResult = await db.collection('classrooms').insertOne({
      name: 'أولى متوسط (أ)',
      gradeLevel: 'الصف الأول المتوسط',
      academicYear: '2024-2025',
      teacherId: userIds['teacher'],
      studentIds: [userIds['student']],
      activeAssessments: 0,
      averageScore: 0,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    classroomId = classResult.insertedId;
    console.log('✅ Created classroom: أولى متوسط (أ)');
  }

  // ربط الطالب بالفصل
  await db.collection('users').updateOne(
    { _id: userIds['student'] },
    { $addToSet: { classroomIds: classroomId.toString() } }
  );

  // ── 4. إنشاء أسئلة تجريبية ───────────────────────────────────────────────
  const existingQuestions = await db.collection('questions').countDocuments();
  if (existingQuestions > 0) {
    console.log(`⚠️  ${existingQuestions} questions already exist — skipping`);
  } else {
    const questions = [
      // رياضيات
      {
        subject: 'الرياضيات', gradeLevel: '7', unit: 'الأعداد', mainSkill: 'الجمع',
        questionText: 'ما ناتج 15 + 27؟',
        questionType: 'mcq', difficulty: 2,
        options: [{ key: 'A', value: '40' }, { key: 'B', value: '42' }, { key: 'C', value: '38' }, { key: 'D', value: '45' }],
        correctAnswer: 'B', isActive: true, createdBy: userIds['teacher'],
        createdAt: new Date(), updatedAt: new Date(),
      },
      {
        subject: 'الرياضيات', gradeLevel: '7', unit: 'الأعداد', mainSkill: 'الضرب',
        questionText: 'ما ناتج 8 × 9؟',
        questionType: 'mcq', difficulty: 1,
        options: [{ key: 'A', value: '63' }, { key: 'B', value: '72' }, { key: 'C', value: '81' }, { key: 'D', value: '56' }],
        correctAnswer: 'B', isActive: true, createdBy: userIds['teacher'],
        createdAt: new Date(), updatedAt: new Date(),
      },
      {
        subject: 'الرياضيات', gradeLevel: '8', unit: 'الجبر', mainSkill: 'المعادلات',
        questionText: 'إذا كان 2x + 4 = 10، فما قيمة x؟',
        questionType: 'mcq', difficulty: 2,
        options: [{ key: 'A', value: '2' }, { key: 'B', value: '3' }, { key: 'C', value: '4' }, { key: 'D', value: '5' }],
        correctAnswer: 'B', isActive: true, createdBy: userIds['teacher'],
        createdAt: new Date(), updatedAt: new Date(),
      },
      // لغة عربية
      {
        subject: 'اللغة العربية', gradeLevel: '7', unit: 'النحو', mainSkill: 'الإعراب',
        questionText: 'ما إعراب كلمة "الطالبُ" في جملة "جاء الطالبُ"؟',
        questionType: 'mcq', difficulty: 2,
        options: [{ key: 'A', value: 'مبتدأ مرفوع' }, { key: 'B', value: 'فاعل مرفوع' }, { key: 'C', value: 'مفعول به' }, { key: 'D', value: 'خبر مرفوع' }],
        correctAnswer: 'B', isActive: true, createdBy: userIds['teacher'],
        createdAt: new Date(), updatedAt: new Date(),
      },
      {
        subject: 'اللغة العربية', gradeLevel: '7', unit: 'الإملاء', mainSkill: 'الهمزة',
        questionText: 'أيٌّ من الكلمات التالية تُكتب بهمزة على الواو؟',
        questionType: 'mcq', difficulty: 3,
        options: [{ key: 'A', value: 'سأل' }, { key: 'B', value: 'مؤمن' }, { key: 'C', value: 'سئل' }, { key: 'D', value: 'مئة' }],
        correctAnswer: 'B', isActive: true, createdBy: userIds['teacher'],
        createdAt: new Date(), updatedAt: new Date(),
      },
      // علوم
      {
        subject: 'العلوم', gradeLevel: '7', unit: 'الأحياء', mainSkill: 'الخلية',
        questionText: 'ما الجزء المسؤول عن التحكم في نشاط الخلية؟',
        questionType: 'mcq', difficulty: 1,
        options: [{ key: 'A', value: 'الغشاء الخلوي' }, { key: 'B', value: 'السيتوبلازم' }, { key: 'C', value: 'النواة' }, { key: 'D', value: 'الميتوكوندريا' }],
        correctAnswer: 'C', isActive: true, createdBy: userIds['teacher'],
        createdAt: new Date(), updatedAt: new Date(),
      },
      {
        subject: 'العلوم', gradeLevel: '8', unit: 'الفيزياء', mainSkill: 'الحركة',
        questionText: 'ما وحدة قياس القوة في النظام الدولي؟',
        questionType: 'mcq', difficulty: 2,
        options: [{ key: 'A', value: 'كيلوغرام' }, { key: 'B', value: 'نيوتن' }, { key: 'C', value: 'جول' }, { key: 'D', value: 'واط' }],
        correctAnswer: 'B', isActive: true, createdBy: userIds['teacher'],
        createdAt: new Date(), updatedAt: new Date(),
      },
    ];

    await db.collection('questions').insertMany(questions);
    console.log(`✅ Created ${questions.length} sample questions`);
  }

  // ── 5. إنشاء اختبار تجريبي ───────────────────────────────────────────────
  const existingAssessment = await db.collection('assessments').findOne({ title: 'اختبار الرياضيات التجريبي' });
  if (existingAssessment) {
    console.log('⚠️  Demo assessment already exists — skipping');
  } else {
    const mathQuestions = await db.collection('questions')
      .find({ subject: 'الرياضيات' })
      .limit(3)
      .toArray();

    await db.collection('assessments').insertOne({
      title: 'اختبار الرياضيات التجريبي',
      subject: 'الرياضيات',
      gradeLevel: '7',
      units: ['الأعداد', 'الجبر'],
      assessmentType: 'adaptive',
      questionCount: 3,
      timeLimitMinutes: 30,
      status: 'active',
      classroomIds: [classroomId.toString()],
      questionIds: mathQuestions.map(q => q._id),
      createdBy: userIds['teacher'],
      availableFrom: new Date(),
      availableUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    console.log('✅ Created demo assessment');
  }

  await client.close();

  console.log('\n══════════════════════════════════════════');
  console.log('✅ Seed completed successfully!');
  console.log('══════════════════════════════════════════');
  console.log('\nبيانات الدخول:');
  console.log('  مشرف:  admin / Admin@123');
  console.log('  معلم:  teacher / Teacher@123');
  console.log('  طالب:  student / Student@123');
  console.log('══════════════════════════════════════════\n');
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err.message);
  process.exit(1);
});
