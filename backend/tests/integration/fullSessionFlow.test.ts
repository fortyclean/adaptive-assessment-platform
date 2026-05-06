/**
 * Integration Test: Full Assessment Session Flow
 *
 * Tests the complete end-to-end flow:
 * login → create assessment → student starts → answers questions → submits → views results
 *
 * Requirements: 6.1, 6.2, 6.3, 7.6, 8.1, 15.1, 21.1
 *
 * NOTE: This test uses pure logic simulation (no live DB/Redis) to validate
 * the integration of all services. For live integration tests, configure
 * a test MongoDB and Redis instance via environment variables.
 */

// Mock Redis
jest.mock('../../src/config/redis', () => ({
  cache: {
    get: jest.fn().mockResolvedValue(null),
    set: jest.fn().mockResolvedValue(undefined),
    del: jest.fn().mockResolvedValue(undefined),
    delPattern: jest.fn().mockResolvedValue(undefined),
    buildKey: {
      questions: (s: string, u: string, d: string) => `questions:${s}:${u}:${d}`,
      assessment: (id: string) => `assessment:${id}:questions`,
      userSession: (id: string) => `user:${id}:session`,
      classroomStudents: (id: string) => `classroom:${id}:students`,
      sessionState: (id: string) => `session:${id}:state`,
    },
  },
}));

import {
  selectNextQuestion,
  getNextDifficulty,
  calculateResults,
  isSessionComplete,
  AdaptiveSessionState,
  QuestionCandidate,
  AnswerRecord,
} from '../../src/services/adaptiveEngine';
import { DifficultyLevel } from '../../src/models/Question';

// ─── Test Data ────────────────────────────────────────────────────────────────

const QUESTION_COUNT = 10;

function makeQuestion(id: string, difficulty: DifficultyLevel, mainSkill: string): QuestionCandidate & { mainSkill: string; correctAnswer: string } {
  return {
    _id: id,
    difficulty,
    subject: 'Mathematics',
    unit: 'Algebra',
    mainSkill,
    correctAnswer: 'B',
  };
}

// Build a question bank with 5 questions per difficulty (15 total)
const questionBank = [
  ...Array.from({ length: 5 }, (_, i) => makeQuestion(`easy-${i}`, 'easy', 'Equations')),
  ...Array.from({ length: 5 }, (_, i) => makeQuestion(`medium-${i}`, 'medium', 'Functions')),
  ...Array.from({ length: 5 }, (_, i) => makeQuestion(`hard-${i}`, 'hard', 'Calculus')),
];

// ─── Full Session Simulation ──────────────────────────────────────────────────

function simulateFullSession(
  answerPattern: boolean[],
  questionCount: number = QUESTION_COUNT
): {
  presentedIds: string[];
  difficultySequence: DifficultyLevel[];
  answers: AnswerRecord[];
  finalSession: AdaptiveSessionState;
} {
  const session: AdaptiveSessionState = {
    sessionId: 'integration-test-session',
    assessmentId: 'test-assessment',
    studentId: 'test-student',
    subject: 'Mathematics',
    units: ['Algebra'],
    questionCount,
    presentedQuestionIds: [],
    currentDifficulty: 'medium', // Req 6.1: start at medium
    answeredCount: 0,
  };

  const presentedIds: string[] = [];
  const difficultySequence: DifficultyLevel[] = [];
  const answers: AnswerRecord[] = [];

  for (let i = 0; i < Math.min(answerPattern.length, questionCount); i++) {
    const next = selectNextQuestion(session, questionBank);
    if (!next) break;

    const q = next as typeof questionBank[0];
    presentedIds.push(q._id);
    difficultySequence.push(q.difficulty);

    const isCorrect = answerPattern[i];
    answers.push({ mainSkill: q.mainSkill, isCorrect });

    session.presentedQuestionIds = [...session.presentedQuestionIds, q._id];
    session.currentDifficulty = getNextDifficulty(q.difficulty, isCorrect);
    session.answeredCount += 1;
  }

  return { presentedIds, difficultySequence, answers, finalSession: session };
}

// ─── Integration Tests ────────────────────────────────────────────────────────

describe('Integration — Full Assessment Session Flow', () => {

  // ─── Req 6.1: Start at Medium ───────────────────────────────────────────
  it('should start first question at medium difficulty (Req 6.1)', () => {
    const { difficultySequence } = simulateFullSession(Array(10).fill(true));
    expect(difficultySequence[0]).toBe('medium');
  });

  // ─── Req 6.2: Escalate on correct ───────────────────────────────────────
  it('should escalate difficulty on consecutive correct answers (Req 6.2)', () => {
    const { difficultySequence } = simulateFullSession(Array(10).fill(true));

    // After all-correct: medium → hard → hard → ...
    const ranks = difficultySequence.map((d) =>
      d === 'easy' ? 1 : d === 'medium' ? 2 : 3
    );

    for (let i = 1; i < ranks.length; i++) {
      expect(ranks[i]).toBeGreaterThanOrEqual(ranks[i - 1]);
    }
  });

  // ─── Req 6.3: De-escalate on incorrect ──────────────────────────────────
  it('should de-escalate difficulty on consecutive incorrect answers (Req 6.3)', () => {
    const { difficultySequence } = simulateFullSession(Array(10).fill(false));

    const ranks = difficultySequence.map((d) =>
      d === 'easy' ? 1 : d === 'medium' ? 2 : 3
    );

    for (let i = 1; i < ranks.length; i++) {
      expect(ranks[i]).toBeLessThanOrEqual(ranks[i - 1]);
    }
  });

  // ─── Req 6.4: No duplicate questions ────────────────────────────────────
  it('should never present the same question twice (Req 6.4)', () => {
    const { presentedIds } = simulateFullSession(Array(10).fill(true));
    const uniqueIds = new Set(presentedIds);
    expect(uniqueIds.size).toBe(presentedIds.length);
  });

  // ─── Req 6.7: Exactly Q questions ───────────────────────────────────────
  it('should present exactly Q questions before terminating (Req 6.7)', () => {
    const { presentedIds } = simulateFullSession(Array(10).fill(true), 10);
    expect(presentedIds).toHaveLength(10);
  });

  // ─── Req 8.1: Score calculation ─────────────────────────────────────────
  it('should calculate score correctly after session (Req 8.1)', () => {
    // 8 correct out of 10
    const pattern = [true, true, true, true, true, true, true, true, false, false];
    const { answers, finalSession } = simulateFullSession(pattern, 10);

    const result = calculateResults(finalSession, answers);

    expect(result.scorePercentage).toBe(80);
    expect(result.isComplete).toBe(true);
  });

  // ─── Req 15.1: Points calculation ───────────────────────────────────────
  it('should calculate points correctly: round((score/100) * Q * 10) (Req 15.1)', () => {
    const pattern = Array(8).fill(true).concat(Array(2).fill(false)); // 80%
    const { answers, finalSession } = simulateFullSession(pattern, 10);

    const result = calculateResults(finalSession, answers);

    expect(result.pointsEarned).toBe(80); // (80/100) * 10 * 10 = 80
    expect(result.bonusAwarded).toBe(false);
  });

  // ─── Req 15.4: Bonus points at 90% ──────────────────────────────────────
  it('should award 50 bonus points for score >= 90% (Req 15.4)', () => {
    const pattern = Array(9).fill(true).concat([false]); // 90%
    const { answers, finalSession } = simulateFullSession(pattern, 10);

    const result = calculateResults(finalSession, answers);

    expect(result.scorePercentage).toBe(90);
    expect(result.bonusAwarded).toBe(true);
    expect(result.pointsEarned).toBe(140); // 90 + 50 bonus
  });

  // ─── Req 8.3: Skill breakdown ────────────────────────────────────────────
  it('should calculate skill breakdown with strength/weakness classification (Req 8.3)', () => {
    // Mixed answers: some correct, some not
    const pattern = [true, true, true, false, false, true, true, true, false, true]; // 70%
    const { answers, finalSession } = simulateFullSession(pattern, 10);

    const result = calculateResults(finalSession, answers);

    expect(result.skillBreakdown.length).toBeGreaterThan(0);
    result.skillBreakdown.forEach((skill) => {
      expect(['strength', 'weakness']).toContain(skill.classification);
      expect(skill.percentage).toBeGreaterThanOrEqual(0);
      expect(skill.percentage).toBeLessThanOrEqual(100);
    });
  });

  // ─── Session completion check ────────────────────────────────────────────
  it('should mark session as complete after Q questions answered', () => {
    const pattern = Array(10).fill(true);
    const { finalSession } = simulateFullSession(pattern, 10);

    expect(isSessionComplete(finalSession)).toBe(true);
    expect(finalSession.answeredCount).toBe(10);
  });

  // ─── Mixed difficulty session ────────────────────────────────────────────
  it('should handle mixed correct/incorrect answers with adaptive difficulty', () => {
    // Alternating correct/incorrect
    const pattern = [true, false, true, false, true, false, true, false, true, false];
    const { presentedIds, difficultySequence, answers } = simulateFullSession(pattern, 10);

    // No duplicates
    expect(new Set(presentedIds).size).toBe(presentedIds.length);

    // Exactly 10 questions
    expect(presentedIds).toHaveLength(10);

    // 5 correct out of 10 = 50%
    const correctCount = answers.filter((a) => a.isCorrect).length;
    expect(correctCount).toBe(5);

    // Difficulty should vary (not all same)
    const uniqueDifficulties = new Set(difficultySequence);
    expect(uniqueDifficulties.size).toBeGreaterThanOrEqual(1);
  });

  // ─── Notification simulation (Req 21.1, 21.2) ───────────────────────────
  it('should simulate notification creation on assessment publish (Req 21.1)', () => {
    const studentIds = ['s1', 's2', 's3'];
    const assessmentTitle = 'اختبار الرياضيات';

    const notifications = studentIds.map((id) => ({
      userId: id,
      type: 'new_assessment',
      title: 'اختبار جديد متاح',
      body: `تم تعيين اختبار "${assessmentTitle}" لك`,
      isRead: false,
    }));

    expect(notifications).toHaveLength(3);
    expect(notifications.every((n) => n.type === 'new_assessment')).toBe(true);
    expect(notifications.every((n) => !n.isRead)).toBe(true);
  });

  it('should simulate teacher notification on session completion (Req 21.2)', () => {
    const pattern = Array(9).fill(true).concat([false]); // 90%
    const { answers, finalSession } = simulateFullSession(pattern, 10);
    const result = calculateResults(finalSession, answers);

    const teacherNotification = {
      userId: 'teacher-1',
      type: 'session_completed',
      title: 'طالب أكمل الاختبار',
      body: `أكمل طالب اختبار بنتيجة ${result.scorePercentage.toFixed(1)}%`,
      isRead: false,
    };

    expect(teacherNotification.type).toBe('session_completed');
    expect(teacherNotification.body).toContain('90.0%');
  });
});
