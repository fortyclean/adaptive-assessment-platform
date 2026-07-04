import mongoose from 'mongoose';
import { Assessment } from '../models/Assessment';
import { Classroom } from '../models/Classroom';
import { InstitutionSettings } from '../models/InstitutionSettings';
import { Notification } from '../models/Notification';
import { PerformanceAlert } from '../models/PerformanceAlert';
import { Question, Subject } from '../models/Question';
import { ReportSchedule } from '../models/ReportSchedule';
import { StudentAttempt } from '../models/StudentAttempt';
import { User, UserRole } from '../models/User';
import { hashPassword } from './authService';
import { logger } from '../utils/logger';

type DemoUserFixture = {
  username: string;
  password: string;
  email: string;
  fullName: string;
  role: UserRole;
  avatarUrl?: string;
};

type DemoQuestionFixture = {
  subject: Subject;
  gradeLevel: string;
  academicTerm: string;
  unit: string;
  mainSkill: string;
  subSkill: string;
  difficulty: 'easy' | 'medium' | 'hard';
  questionText: string;
  options: Array<{ key: string; value: string }>;
  correctAnswer: string;
};

function getRequiredMapValue<K, V>(map: Map<K, V>, key: K, label: string): V {
  const value = map.get(key);
  if (!value) {
    throw new Error(`Missing demo ${label}: ${String(key)}`);
  }

  return value;
}

export const demoUsers: DemoUserFixture[] = [
  {
    username: 'parent_fatima',
    password: 'Parent@123',
    email: 'fatima.parent@school.edu',
    fullName: 'Fatima Demo Parent',
    role: 'parent',
    avatarUrl: 'https://api.dicebear.com/8.x/initials/png?seed=Fatima%20Parent',
  },
  {
    username: 'teacher_science',
    password: 'Teacher@123',
    email: 'science.teacher@school.edu',
    fullName: 'Science Demo Teacher',
    role: 'teacher',
    avatarUrl: 'https://api.dicebear.com/8.x/initials/png?seed=Science%20Teacher',
  },
  {
    username: 'student_mona',
    password: 'Student@123',
    email: 'mona.student@school.edu',
    fullName: 'Mona Demo Student',
    role: 'student',
    avatarUrl: 'https://api.dicebear.com/8.x/initials/png?seed=Mona',
  },
  {
    username: 'student_omar',
    password: 'Student@123',
    email: 'omar.student@school.edu',
    fullName: 'Omar Demo Student',
    role: 'student',
    avatarUrl: 'https://api.dicebear.com/8.x/initials/png?seed=Omar',
  },
  {
    username: 'student_lina',
    password: 'Student@123',
    email: 'lina.student@school.edu',
    fullName: 'Lina Demo Student',
    role: 'student',
    avatarUrl: 'https://api.dicebear.com/8.x/initials/png?seed=Lina',
  },
  {
    username: 'student_yousef',
    password: 'Student@123',
    email: 'yousef.student@school.edu',
    fullName: 'Yousef Demo Student',
    role: 'student',
    avatarUrl: 'https://api.dicebear.com/8.x/initials/png?seed=Yousef',
  },
];

export const demoClassrooms = [
  {
    key: 'grade-7-a',
    name: 'Grade 7 - Adaptive Math',
    gradeLevel: 'Grade 7',
    academicYear: '2025 / 2026',
    teachers: ['teacher', 'teacher_science'],
    students: ['student', 'student_mona', 'student_omar'],
  },
  {
    key: 'grade-8-b',
    name: 'Grade 8 - Science Lab',
    gradeLevel: 'Grade 8',
    academicYear: '2025 / 2026',
    teachers: ['teacher_science'],
    students: ['student_lina', 'student_yousef'],
  },
];

const baseOptions = [
  { key: 'A', value: 'Option A' },
  { key: 'B', value: 'Option B' },
  { key: 'C', value: 'Option C' },
  { key: 'D', value: 'Option D' },
];

export const demoQuestions: DemoQuestionFixture[] = [
  ...buildSubjectQuestions(
    'Mathematics',
    'Grade 7',
    'Linear Equations',
    'Algebra',
    'Solving equations',
  ),
  ...buildSubjectQuestions('English', 'Grade 7', 'Reading Skills', 'Comprehension', 'Inference'),
  ...buildSubjectQuestions('Arabic', 'Grade 7', 'Reading Texts', 'Language', 'Main idea'),
  ...buildSubjectQuestions('Physics', 'Grade 8', 'Motion', 'Mechanics', 'Speed and distance'),
  ...buildSubjectQuestions('Chemistry', 'Grade 8', 'Matter', 'Lab Skills', 'Properties of matter'),
  ...buildSubjectQuestions('Biology', 'Grade 8', 'Cells', 'Life Science', 'Cell structure'),
];

export const demoAssessments = [
  {
    title: 'Demo Adaptive Mathematics Check',
    subject: 'Mathematics' as Subject,
    gradeLevel: 'Grade 7',
    units: ['Linear Equations'],
    questionCount: 6,
    timeLimitMinutes: 25,
    status: 'active' as const,
    classrooms: ['grade-7-a'],
  },
  {
    title: 'Demo Reading Skills Quiz',
    subject: 'English' as Subject,
    gradeLevel: 'Grade 7',
    units: ['Reading Skills'],
    questionCount: 6,
    timeLimitMinutes: 20,
    status: 'active' as const,
    classrooms: ['grade-7-a'],
  },
  {
    title: 'Demo Science Lab Draft',
    subject: 'Physics' as Subject,
    gradeLevel: 'Grade 8',
    units: ['Motion'],
    questionCount: 6,
    timeLimitMinutes: 30,
    status: 'draft' as const,
    classrooms: ['grade-8-b'],
  },
];

export function getDemoSeedSummary() {
  return {
    users: demoUsers.length + 4,
    classrooms: demoClassrooms.length,
    questions: demoQuestions.length,
    assessments: demoAssessments.length,
    includesAdminAssignmentFlow: true,
    includesTeacherAssessmentFlow: true,
    includesStudentMarketplaceAndProgressFlow: true,
  };
}

export async function ensureDemoSeedData(): Promise<void> {
  if (process.env.DISABLE_DEMO_SEED_DATA === 'true') {
    return;
  }

  await ensureExtraUsers();
  const users = await loadDemoUsers();
  const classrooms = await ensureClassrooms(users);
  const questions = await ensureQuestions(users.teacher._id as mongoose.Types.ObjectId);
  const assessments = await ensureAssessments(
    users.teacher._id as mongoose.Types.ObjectId,
    classrooms,
    questions,
  );
  await ensureAttempts(users, classrooms, assessments, questions);
  await ensureNotifications(users, assessments);
  await ensureReportsAndAlerts(users, classrooms);
  await ensureInstitutionSettings(users.admin._id as mongoose.Types.ObjectId);

  logger.info('Demo seed data ensured', getDemoSeedSummary());
}

function buildSubjectQuestions(
  subject: Subject,
  gradeLevel: string,
  unit: string,
  mainSkill: string,
  subSkill: string,
): DemoQuestionFixture[] {
  const difficulties: Array<'easy' | 'medium' | 'hard'> = [
    'easy',
    'easy',
    'medium',
    'medium',
    'hard',
    'hard',
  ];

  return difficulties.map((difficulty, index) => ({
    subject,
    gradeLevel,
    academicTerm: 'Term 2',
    unit,
    mainSkill,
    subSkill,
    difficulty,
    questionText: `Demo ${subject} question ${index + 1} for ${unit}`,
    options: baseOptions,
    correctAnswer: baseOptions[index % baseOptions.length].key,
  }));
}

async function ensureExtraUsers(): Promise<void> {
  for (const user of demoUsers) {
    await User.updateOne(
      { username: user.username },
      {
        $set: {
          email: user.email,
          fullName: user.fullName,
          passwordHash: await hashPassword(user.password),
          role: user.role,
          avatarUrl: user.avatarUrl,
          isActive: true,
          failedLoginAttempts: 0,
          updatedAt: new Date(),
        },
        $unset: { lockedUntil: '' },
        $setOnInsert: {
          username: user.username,
          classroomIds: [],
          childIds: [],
          activeSessions: [],
          createdAt: new Date(),
        },
      },
      { upsert: true },
    );
  }
}

async function loadDemoUsers() {
  const usernames = [
    'admin',
    'parent',
    'parent_fatima',
    'teacher',
    'teacher_science',
    'student',
    'student_mona',
    'student_omar',
    'student_lina',
    'student_yousef',
  ];
  const users = await User.find({ username: { $in: usernames } });
  const byUsername = new Map(users.map((user) => [user.username, user]));

  const required = usernames.map((username) => byUsername.get(username));
  if (required.some((user) => !user)) {
    throw new Error('Demo users were not prepared correctly');
  }

  return {
    admin: getRequiredMapValue(byUsername, 'admin', 'user'),
    parent: getRequiredMapValue(byUsername, 'parent', 'user'),
    parentFatima: getRequiredMapValue(byUsername, 'parent_fatima', 'user'),
    teacher: getRequiredMapValue(byUsername, 'teacher', 'user'),
    teacherScience: getRequiredMapValue(byUsername, 'teacher_science', 'user'),
    students: [
      getRequiredMapValue(byUsername, 'student', 'user'),
      getRequiredMapValue(byUsername, 'student_mona', 'user'),
      getRequiredMapValue(byUsername, 'student_omar', 'user'),
      getRequiredMapValue(byUsername, 'student_lina', 'user'),
      getRequiredMapValue(byUsername, 'student_yousef', 'user'),
    ],
    byUsername,
  };
}

async function ensureClassrooms(
  users: Awaited<ReturnType<typeof loadDemoUsers>>,
): Promise<Map<string, mongoose.Types.ObjectId>> {
  const classroomIds = new Map<string, mongoose.Types.ObjectId>();

  for (const fixture of demoClassrooms) {
    const teacherIds = fixture.teachers.map((username) => {
      const teacher = getRequiredMapValue(users.byUsername, username, 'classroom teacher');
      return teacher._id as mongoose.Types.ObjectId;
    });
    const studentIds = fixture.students.map((username) => {
      const student = getRequiredMapValue(users.byUsername, username, 'classroom student');
      return student._id as mongoose.Types.ObjectId;
    });

    const classroom = await Classroom.findOneAndUpdate(
      { name: fixture.name, academicYear: fixture.academicYear },
      {
        $set: {
          name: fixture.name,
          gradeLevel: fixture.gradeLevel,
          academicYear: fixture.academicYear,
          teacherIds,
          studentIds,
          isActive: true,
        },
      },
      { upsert: true, new: true },
    );

    if (!classroom) {
      throw new Error(`Unable to prepare demo classroom: ${fixture.name}`);
    }

    classroomIds.set(fixture.key, classroom._id as mongoose.Types.ObjectId);
    await User.updateMany(
      { _id: { $in: [...teacherIds, ...studentIds] } },
      { $addToSet: { classroomIds: classroom._id } },
    );
  }

  await User.updateMany(
    { username: { $in: ['parent', 'parent_fatima'] } },
    {
      $set: {
        childIds: users.students
          .slice(0, 2)
          .map((student) => student._id as mongoose.Types.ObjectId),
      },
    },
  );

  return classroomIds;
}

async function ensureQuestions(
  teacherId: mongoose.Types.ObjectId,
): Promise<Map<string, mongoose.Types.ObjectId[]>> {
  const questionIdsBySubject = new Map<string, mongoose.Types.ObjectId[]>();

  for (const fixture of demoQuestions) {
    const question = await Question.findOneAndUpdate(
      {
        subject: fixture.subject,
        gradeLevel: fixture.gradeLevel,
        unit: fixture.unit,
        questionText: fixture.questionText,
      },
      {
        $set: {
          ...fixture,
          createdBy: teacherId,
          isArchived: false,
        },
      },
      { upsert: true, new: true, runValidators: true },
    );

    if (!question) {
      throw new Error(`Unable to prepare demo question: ${fixture.questionText}`);
    }

    const key = `${fixture.subject}:${fixture.gradeLevel}:${fixture.unit}`;
    const list = questionIdsBySubject.get(key) ?? [];
    list.push(question._id as mongoose.Types.ObjectId);
    questionIdsBySubject.set(key, list);
  }

  return questionIdsBySubject;
}

async function ensureAssessments(
  teacherId: mongoose.Types.ObjectId,
  classrooms: Map<string, mongoose.Types.ObjectId>,
  questions: Map<string, mongoose.Types.ObjectId[]>,
): Promise<Map<string, mongoose.Types.ObjectId>> {
  const assessmentIds = new Map<string, mongoose.Types.ObjectId>();
  const now = new Date();
  const availableUntil = new Date(now);
  availableUntil.setDate(availableUntil.getDate() + 30);

  for (const fixture of demoAssessments) {
    const questionKey = `${fixture.subject}:${fixture.gradeLevel}:${fixture.units[0]}`;
    const questionIds = questions.get(questionKey) ?? [];
    const classroomIds = fixture.classrooms
      .map((key) => classrooms.get(key))
      .filter((id): id is mongoose.Types.ObjectId => Boolean(id));

    const assessment = await Assessment.findOneAndUpdate(
      { title: fixture.title, createdBy: teacherId },
      {
        $set: {
          title: fixture.title,
          createdBy: teacherId,
          assessmentType: 'adaptive',
          subject: fixture.subject,
          gradeLevel: fixture.gradeLevel,
          units: fixture.units,
          questionCount: fixture.questionCount,
          timeLimitMinutes: fixture.timeLimitMinutes,
          classroomIds,
          status: fixture.status,
          availableFrom: now,
          availableUntil,
          questionIds: questionIds.slice(0, fixture.questionCount),
        },
      },
      { upsert: true, new: true, runValidators: true },
    );

    if (!assessment) {
      throw new Error(`Unable to prepare demo assessment: ${fixture.title}`);
    }

    assessmentIds.set(fixture.title, assessment._id as mongoose.Types.ObjectId);
  }

  return assessmentIds;
}

async function ensureAttempts(
  users: Awaited<ReturnType<typeof loadDemoUsers>>,
  classrooms: Map<string, mongoose.Types.ObjectId>,
  assessments: Map<string, mongoose.Types.ObjectId>,
  questions: Map<string, mongoose.Types.ObjectId[]>,
): Promise<void> {
  const studentIds = users.students.map((student) => student._id as mongoose.Types.ObjectId);
  const assessmentIds = [...assessments.values()];
  await StudentAttempt.deleteMany({
    studentId: { $in: studentIds },
    assessmentId: { $in: assessmentIds },
  });

  const mathAssessment = getRequiredMapValue(
    assessments,
    'Demo Adaptive Mathematics Check',
    'assessment',
  );
  const englishAssessment = getRequiredMapValue(
    assessments,
    'Demo Reading Skills Quiz',
    'assessment',
  );
  const mathQuestions = questions.get('Mathematics:Grade 7:Linear Equations') ?? [];
  const englishQuestions = questions.get('English:Grade 7:Reading Skills') ?? [];
  const classroomId = getRequiredMapValue(classrooms, 'grade-7-a', 'classroom');
  const scores = [92, 84, 76, 68, 58];

  const attempts = users.students.flatMap((student, studentIndex) => {
    const submittedAt = new Date();
    submittedAt.setDate(submittedAt.getDate() - studentIndex);
    return [
      buildAttempt(
        student._id as mongoose.Types.ObjectId,
        mathAssessment,
        classroomId,
        mathQuestions,
        scores[studentIndex],
        submittedAt,
      ),
      buildAttempt(
        student._id as mongoose.Types.ObjectId,
        englishAssessment,
        classroomId,
        englishQuestions,
        Math.max(scores[studentIndex] - 7, 45),
        new Date(submittedAt.getTime() - 86400000),
      ),
    ];
  });

  await StudentAttempt.insertMany(attempts);
}

function buildAttempt(
  studentId: mongoose.Types.ObjectId,
  assessmentId: mongoose.Types.ObjectId,
  classroomId: mongoose.Types.ObjectId,
  questionIds: mongoose.Types.ObjectId[],
  score: number,
  submittedAt: Date,
) {
  const correctCount = Math.round((score / 100) * questionIds.length);
  return {
    studentId,
    assessmentId,
    classroomId,
    status: 'completed' as const,
    startedAt: new Date(submittedAt.getTime() - 18 * 60 * 1000),
    submittedAt,
    timeTakenSeconds: 18 * 60,
    currentDifficultyLevel:
      score >= 85 ? ('hard' as const) : score >= 70 ? ('medium' as const) : ('easy' as const),
    presentedQuestionIds: questionIds,
    scorePercentage: score,
    pointsEarned: Math.round(score * 1.4),
    answers: questionIds.map((questionId, index) => ({
      questionId,
      questionText: `Demo answered question ${index + 1}`,
      selectedAnswer: index < correctCount ? 'A' : 'B',
      correctAnswer: 'A',
      isCorrect: index < correctCount,
      difficultyLevel:
        index < 2 ? ('easy' as const) : index < 4 ? ('medium' as const) : ('hard' as const),
      mainSkill: index % 2 === 0 ? 'Core understanding' : 'Application',
      subSkill: index % 2 === 0 ? 'Concept recognition' : 'Problem solving',
      answeredAt: new Date(submittedAt.getTime() - (questionIds.length - index) * 60000),
    })),
    skillBreakdown: [
      {
        mainSkill: 'Core understanding',
        totalQuestions: 3,
        correctAnswers: Math.min(3, Math.max(1, Math.round(score / 35))),
        percentage: Math.min(100, score + 4),
        classification: score >= 70 ? ('strength' as const) : ('weakness' as const),
      },
      {
        mainSkill: 'Application',
        totalQuestions: 3,
        correctAnswers: Math.min(3, Math.max(0, Math.round(score / 40))),
        percentage: Math.max(0, score - 8),
        classification: score >= 75 ? ('strength' as const) : ('weakness' as const),
      },
    ],
    antiCheatLog: score < 65 ? [{ event: 'app_backgrounded', timestamp: submittedAt }] : [],
  };
}

async function ensureNotifications(
  users: Awaited<ReturnType<typeof loadDemoUsers>>,
  assessments: Map<string, mongoose.Types.ObjectId>,
): Promise<void> {
  const userIds = [
    users.admin._id,
    users.teacher._id,
    ...users.students.map((student) => student._id),
  ];
  await Notification.deleteMany({ userId: { $in: userIds } });

  const mathAssessment = assessments.get('Demo Adaptive Mathematics Check');
  await Notification.insertMany([
    {
      userId: users.students[0]._id,
      type: 'new_assessment',
      title: 'Demo assessment available',
      body: 'A mathematics adaptive assessment is ready for the demo student.',
      relatedId: mathAssessment,
      relatedType: 'assessment',
      isRead: false,
    },
    {
      userId: users.students[0]._id,
      type: 'achievement',
      title: 'Demo achievement unlocked',
      body: 'You earned points for completing the reading skills quiz.',
      isRead: false,
    },
    {
      userId: users.teacher._id,
      type: 'essay_grading_required',
      title: 'Demo teacher task',
      body: 'Review pending demo student work and classroom performance alerts.',
      isRead: false,
    },
    {
      userId: users.admin._id,
      type: 'reminder',
      title: 'Demo admin checklist',
      body: 'Classrooms now include assigned teachers, students, reports, and active assessments.',
      isRead: false,
    },
  ]);
}

async function ensureReportsAndAlerts(
  users: Awaited<ReturnType<typeof loadDemoUsers>>,
  classrooms: Map<string, mongoose.Types.ObjectId>,
): Promise<void> {
  const classroomId = getRequiredMapValue(classrooms, 'grade-7-a', 'classroom');
  await PerformanceAlert.deleteMany({ teacherId: users.teacher._id });
  await PerformanceAlert.create({
    teacherId: users.teacher._id,
    studentId: users.students[4]._id,
    classroomId,
    subject: 'Mathematics',
    currentAverage: 58,
    previousAverage: 82,
    dropPercentage: 29.3,
    weeklyTrend: [78, 76, 72, 68, 64, 61, 58],
    isActive: true,
  });

  await ReportSchedule.deleteMany({ createdBy: { $in: [users.admin._id, users.teacher._id] } });
  await ReportSchedule.insertMany([
    {
      title: 'Demo weekly classroom comparison',
      reportType: 'classroom_comparison',
      frequency: 'weekly',
      deliveryTime: '08:00',
      recipients: ['admin@school.edu', 'teacher@school.edu'],
      fileFormat: 'pdf',
      classroomIds: [classroomId],
      isActive: true,
      createdBy: users.admin._id,
      lastSentAt: new Date(Date.now() - 7 * 86400000),
    },
    {
      title: 'Demo student performance digest',
      reportType: 'student_performance',
      frequency: 'daily',
      deliveryTime: '14:30',
      recipients: ['teacher@school.edu'],
      fileFormat: 'excel',
      classroomIds: [classroomId],
      isActive: true,
      createdBy: users.teacher._id,
    },
  ]);
}

async function ensureInstitutionSettings(adminId: mongoose.Types.ObjectId): Promise<void> {
  await InstitutionSettings.findOneAndUpdate(
    { key: 'default' },
    {
      $set: {
        schoolName: 'EduAssess Demo Academy',
        schoolPhone: '+966 500 000 000',
        schoolEmail: 'demo@eduassess.school',
        academicYear: '2025 / 2026',
        term: 'Term 2',
        gradeScale: 'A-F',
        language: 'Arabic / English',
        timezone: 'Asia/Kuwait',
        emailNotifications: true,
        pushNotifications: true,
        weeklyDigest: true,
        sisIntegration: false,
        lmsIntegration: true,
        updatedBy: adminId,
      },
    },
    { upsert: true, new: true, runValidators: true },
  );
}
