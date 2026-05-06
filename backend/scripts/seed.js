/**
 * Seed script — creates default users for local development.
 * Run with: node scripts/seed.js
 *
 * Default accounts:
 *   Admin:   username=admin      password=Admin@1234
 *   Teacher: username=teacher1   password=Teacher@1234
 *   Student: username=student1   password=Student@1234
 */

const { MongoClient } = require('mongodb');
const bcrypt = require('bcrypt');

const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/adaptive_assessment';
const COST_FACTOR = 12;

async function seed() {
  const client = new MongoClient(MONGO_URI);
  await client.connect();
  console.log('Connected to MongoDB:', MONGO_URI);

  const db = client.db();

  // Ensure indexes
  await db.collection('users').createIndex({ username: 1 }, { unique: true });

  const users = [
    {
      username: 'admin',
      password: 'Admin@1234',
      email: 'admin@adaptive-assessment.com',
      fullName: 'مدير النظام',
      role: 'admin',
    },
    {
      username: 'teacher1',
      password: 'Teacher@1234',
      email: 'teacher1@adaptive-assessment.com',
      fullName: 'أحمد المعلم',
      role: 'teacher',
    },
    {
      username: 'student1',
      password: 'Student@1234',
      email: 'student1@adaptive-assessment.com',
      fullName: 'سارة الطالبة',
      role: 'student',
    },
  ];

  for (const user of users) {
    const existing = await db.collection('users').findOne({ username: user.username });
    if (existing) {
      console.log(`⚠️  User '${user.username}' already exists — skipping`);
      continue;
    }

    const passwordHash = await bcrypt.hash(user.password, COST_FACTOR);
    await db.collection('users').insertOne({
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
    console.log(`✅  Created ${user.role}: ${user.username} / ${user.password}`);
  }

  await client.close();
  console.log('\nDone! You can now log in with the accounts above.');
}

seed().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
