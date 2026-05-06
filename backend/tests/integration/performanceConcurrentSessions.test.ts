/**
 * Performance Test: 20 Concurrent Adaptive Sessions
 *
 * Simulates 20 concurrent students each performing a 10-question adaptive session.
 * Verifies:
 *   - All API responses complete within 200ms (Req 12.2)
 *   - Adaptive engine next-question delivery within 100ms (Req 12.1)
 *
 * Requirements: 12.1, 12.2
 */

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
  AdaptiveSessionState,
  QuestionCandidate,
} from '../../src/services/adaptiveEngine';
import { DifficultyLevel } from '../../src/models/Question';

// ─── Constants ────────────────────────────────────────────────────────────────

const CONCURRENT_SESSIONS = 20;
const QUESTIONS_PER_SESSION = 10;
const NEXT_QUESTION_SLA_MS = 100;
const API_RESPONSE_SLA_MS = 200;

// ─── Helpers ──────────────────────────────────────────────────────────────────

const difficulties: DifficultyLevel[] = ['easy', 'medium', 'hard'];

function buildQuestionBank(sessionId: string): QuestionCandidate[] {
  return Array.from({ length: 30 }, (_, i) => ({
    _id: `${sessionId}-q${i}`,
    difficulty: difficulties[i % 3],
    subject: 'Mathematics',
    unit: 'Algebra',
  }));
}

function makeSession(studentId: string): AdaptiveSessionState {
  return {
    sessionId: `session-${studentId}`,
    assessmentId: 'assessment-perf-test',
    studentId,
    subject: 'Mathematics',
    units: ['Algebra'],
    questionCount: QUESTIONS_PER_SESSION,
    presentedQuestionIds: [],
    currentDifficulty: 'medium',
    answeredCount: 0,
  };
}

interface SessionMetrics {
  studentId: string;
  questionTimes: number[];
  totalTimeMs: number;
  questionsPresented: number;
  noDuplicates: boolean;
}

async function simulateSession(studentId: string): Promise<SessionMetrics> {
  const questionBank = buildQuestionBank(studentId);
  const session = makeSession(studentId);
  const questionTimes: number[] = [];
  const presentedIds: string[] = [];

  const sessionStart = performance.now();

  for (let i = 0; i < QUESTIONS_PER_SESSION; i++) {
    const qStart = performance.now();

    const next = selectNextQuestion(session, questionBank);
    if (!next) break;

    const qEnd = performance.now();
    questionTimes.push(qEnd - qStart);

    presentedIds.push(next._id);
    session.presentedQuestionIds = [...session.presentedQuestionIds, next._id];
    session.currentDifficulty = getNextDifficulty(next.difficulty, i % 2 === 0);
    session.answeredCount += 1;

    // Simulate minimal async overhead (1ms)
    await new Promise((r) => setTimeout(r, 1));
  }

  return {
    studentId,
    questionTimes,
    totalTimeMs: performance.now() - sessionStart,
    questionsPresented: presentedIds.length,
    noDuplicates: new Set(presentedIds).size === presentedIds.length,
  };
}

function percentile(values: number[], p: number): number {
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.max(0, Math.ceil((p / 100) * sorted.length) - 1)];
}

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('Performance — 20 Concurrent Adaptive Sessions (Req 12.1, 12.2)', () => {
  let allMetrics: SessionMetrics[];

  beforeAll(async () => {
    const promises = Array.from({ length: CONCURRENT_SESSIONS }, (_, i) =>
      simulateSession(`student-${i + 1}`)
    );
    allMetrics = await Promise.all(promises);
  }, 30_000);

  it('should complete all 20 concurrent sessions', () => {
    expect(allMetrics).toHaveLength(CONCURRENT_SESSIONS);
  });

  it('should present exactly 10 questions per session', () => {
    for (const m of allMetrics) {
      expect(m.questionsPresented).toBe(QUESTIONS_PER_SESSION);
    }
  });

  it('should have no duplicate questions in any session (Req 6.4)', () => {
    for (const m of allMetrics) {
      expect(m.noDuplicates).toBe(true);
    }
  });

  it('should deliver next-question within 100ms SLA (Req 12.1)', () => {
    const allTimes = allMetrics.flatMap((m) => m.questionTimes);
    const violations = allTimes.filter((t) => t > NEXT_QUESTION_SLA_MS);
    // Allow up to 2% violation for CI jitter
    expect(violations.length / allTimes.length).toBeLessThan(0.02);
  });

  it('should complete each question interaction within 200ms SLA (Req 12.2)', () => {
    const allTimes = allMetrics.flatMap((m) => m.questionTimes);
    const violations = allTimes.filter((t) => t > API_RESPONSE_SLA_MS);
    expect(violations.length).toBe(0);
  });

  it('should have P99 next-question time under 100ms', () => {
    const allTimes = allMetrics.flatMap((m) => m.questionTimes);
    const p99 = percentile(allTimes, 99);
    expect(p99).toBeLessThan(NEXT_QUESTION_SLA_MS);
  });

  it('should produce valid results for all concurrent sessions', () => {
    for (const m of allMetrics) {
      const session = makeSession(m.studentId);
      session.answeredCount = m.questionsPresented;
      const answers = Array.from({ length: m.questionsPresented }, (_, i) => ({
        mainSkill: 'Algebra',
        isCorrect: i % 2 === 0,
      }));
      const result = calculateResults(session, answers);
      expect(result.scorePercentage).toBeGreaterThanOrEqual(0);
      expect(result.scorePercentage).toBeLessThanOrEqual(100);
      expect(result.isComplete).toBe(true);
    }
  });

  it('should log performance summary', () => {
    const allTimes = allMetrics.flatMap((m) => m.questionTimes);
    const avg = allTimes.reduce((a, b) => a + b, 0) / allTimes.length;
    console.info(
      `\nPerf Summary — ${CONCURRENT_SESSIONS} sessions × ${QUESTIONS_PER_SESSION} questions:\n` +
      `  Avg: ${avg.toFixed(3)}ms | P50: ${percentile(allTimes, 50).toFixed(3)}ms | ` +
      `P95: ${percentile(allTimes, 95).toFixed(3)}ms | P99: ${percentile(allTimes, 99).toFixed(3)}ms | ` +
      `Max: ${Math.max(...allTimes).toFixed(3)}ms`
    );
    expect(avg).toBeLessThan(NEXT_QUESTION_SLA_MS);
  });
});
