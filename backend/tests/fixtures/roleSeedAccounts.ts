export const roleSeedAccounts = {
  admin: {
    username: 'admin',
    password: 'Admin@123',
    email: 'admin@school.edu',
    role: 'admin',
  },
  teacher: {
    username: 'teacher',
    password: 'Teacher@123',
    email: 'teacher@school.edu',
    role: 'teacher',
  },
  student: {
    username: 'student',
    password: 'Student@123',
    email: 'student@school.edu',
    role: 'student',
  },
} as const;

export type SeedRole = keyof typeof roleSeedAccounts;
