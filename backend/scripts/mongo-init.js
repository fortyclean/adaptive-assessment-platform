// MongoDB initialization script for local development
// This runs when the MongoDB container starts for the first time

db = db.getSiblingDB('adaptive_assessment');

// Create collections with validation
db.createCollection('users');
db.createCollection('classrooms');
db.createCollection('questions');
db.createCollection('assessments');
db.createCollection('student_attempts');
db.createCollection('notifications');

// Create indexes
db.users.createIndex({ username: 1 }, { unique: true });
db.users.createIndex({ email: 1 });
db.users.createIndex({ role: 1, isActive: 1 });

db.questions.createIndex({ subject: 1, gradeLevel: 1, unit: 1, difficulty: 1 });
db.questions.createIndex({ mainSkill: 1, subSkill: 1 });
db.questions.createIndex({ questionText: 'text' });
db.questions.createIndex(
  { subject: 1, gradeLevel: 1, unit: 1, questionText: 1 },
  { unique: true }
);

db.assessments.createIndex({ createdBy: 1, status: 1 });
db.assessments.createIndex({ classroomIds: 1, status: 1 });

db.student_attempts.createIndex({ studentId: 1, assessmentId: 1 });
db.student_attempts.createIndex({ assessmentId: 1, status: 1 });
db.student_attempts.createIndex({ studentId: 1, createdAt: -1 });

db.notifications.createIndex({ userId: 1, isRead: 1, createdAt: -1 });

// Seed a default admin user for development
// Password: Admin@1234 (bcrypt hash with cost factor 12)
db.users.insertOne({
  username: 'admin',
  passwordHash: '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK2.',
  email: 'admin@adaptive-assessment.com',
  fullName: 'System Administrator',
  role: 'admin',
  isActive: true,
  classroomIds: [],
  failedLoginAttempts: 0,
  activeSessions: [],
  createdAt: new Date(),
  updatedAt: new Date(),
});

print('MongoDB initialization complete');
