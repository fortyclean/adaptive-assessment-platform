import { User, UserRole } from '../models/User';
import { hashPassword } from './authService';
import { logger } from '../utils/logger';

const demoAccounts: Array<{
  username: string;
  password: string;
  email: string;
  fullName: string;
  role: UserRole;
}> = [
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

export async function ensureDemoAccounts(): Promise<void> {
  if (process.env.DISABLE_DEMO_ACCOUNTS === 'true') {
    return;
  }

  for (const account of demoAccounts) {
    const passwordHash = await hashPassword(account.password);
    await User.updateOne(
      { username: account.username },
      {
        $set: {
          email: account.email,
          fullName: account.fullName,
          passwordHash,
          role: account.role,
          isActive: true,
          failedLoginAttempts: 0,
          updatedAt: new Date(),
        },
        $unset: {
          lockedUntil: '',
        },
        $setOnInsert: {
          username: account.username,
          classroomIds: [],
          activeSessions: [],
          createdAt: new Date(),
        },
      },
      { upsert: true },
    );
  }

  logger.info('Demo accounts ensured', {
    usernames: demoAccounts.map((account) => account.username),
  });
}
