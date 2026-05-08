/**
 * Property-Based Tests for the Adaptive Engine.
 *
 * Properties tested:
 *   Property 1 — No Duplicates Invariant      (Task 7.4, Req 6.4)
 *   Property 2 — Ascending Difficulty         (Task 7.5, Req 6.2)
 *   Property 3 — Descending Difficulty        (Task 7.6, Req 6.3)
 *   Property 4 — Termination Invariant        (Task 7.7, Req 6.7)
 *
 * Uses fast-check for property-based test generation.
 */

// Mock Redis so the engine can be imported without a live connection
jest.mock('../../src/config/redis', () => ({
  cache: { get: jest.fn(), set: jest.fn(), del: jest.fn() },
}));

import * as fc from 'fast-check';
import {
  selectNextQuestion,
  getNextDifficulty,
  AdaptiveSessionState,
  QuestionCandidate,
  DIFFICULTY_RANK,
} from '../../src/services/adaptiveEngine';
import { DifficultyLevel } from '../../src/models/Question';

// ─── Arbitraries ──────────────────────────────────────────────────────────────

const difficulties: DifficultyLevel[] = ['easy', 'medium', 'hard'];

/** Generates a random DifficultyLevel */
const arbDifficulty = fc.constantFrom<DifficultyLevel>(...difficulties);

/** Generates a QuestionCandidate with a unique id */
const arbQuestion = (id: string, difficulty: DifficultyLevel): QuestionCandidate => ({
  _id: id,
  difficulty,
  subject: 'Mathematics',
  unit: 'Unit 1',
});

/** Generates a bank of N questions with unique IDs and random difficulties */
const arbQuestionBank = (size: number) =>
  fc
    .array(arbDifficulty, { minLength: size, maxLength: size })
    .map((diffs) => diffs.map((d, i) => arbQuestion(`q${i}`, d)));

/** Generates a boolean sequence representing correct/incorrect answers */
const arbAnswerSequence = (length: number) =>
  fc.array(fc.boolean(), { minLength: length, maxLength: length });

// ─── Helper: simulate a full adaptive session ─────────────────────────────────

interface SimulatedSession {
  presentedIds: string[];
  difficultySequence: DifficultyLevel[];
}

/**
 * Runs a simulated adaptive session by repeatedly calling selectNextQuestion
 * and updating the session state based on the provided answer sequence.
 *
 * @param questionBank  - The full pool of questions
 * @param answers       - Sequence of booleans (true = correct, false = incorrect)
 * @param questionCount - How many questions to present (Q)
 * @returns The list of presented question IDs and the difficulty sequence
 */
function simulateSession(
  questionBank: QuestionCandidate[],
  answers: boolean[],
  questionCount: number,
): SimulatedSession {
  const session: AdaptiveSessionState = {
    sessionId: 'test-session',
    assessmentId: 'test-assessment',
    studentId: 'test-student',
    subject: 'Mathematics',
    units: ['Unit 1'],
    questionCount,
    presentedQuestionIds: [],
    currentDifficulty: 'medium', // always starts at medium (Req 6.1)
    answeredCount: 0,
  };

  const presentedIds: string[] = [];
  const difficultySequence: DifficultyLevel[] = [];

  for (let i = 0; i < Math.min(answers.length, questionCount); i++) {
    const next = selectNextQuestion(session, questionBank);
    if (next === null) break; // bank exhausted

    presentedIds.push(next._id);
    difficultySequence.push(next.difficulty);

    // Update session state
    session.presentedQuestionIds = [...session.presentedQuestionIds, next._id];
    session.currentDifficulty = getNextDifficulty(next.difficulty, answers[i]);
    session.answeredCount += 1;
  }

  return { presentedIds, difficultySequence };
}

// ─── Property 1: No Duplicates Invariant (Task 7.4, Req 6.4) ─────────────────

describe('PBT — Property 1: No Duplicates Invariant (Req 6.4)', () => {
  /**
   * For ALL sessions with ANY question bank and ANY answer sequence,
   * the list of presented question IDs must never contain duplicates.
   */
  it('presentedQuestionIds contains no duplicates across all sessions', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 5, max: 30 }).chain((bankSize) =>
          fc.tuple(
            arbQuestionBank(bankSize),
            arbAnswerSequence(bankSize),
            fc.integer({ min: 1, max: bankSize }),
          ),
        ),
        ([questionBank, answers, questionCount]) => {
          const { presentedIds } = simulateSession(questionBank, answers, questionCount);

          // Property: no duplicates
          const uniqueIds = new Set(presentedIds);
          return uniqueIds.size === presentedIds.length;
        },
      ),
      { numRuns: 500, verbose: false },
    );
  });

  it('no duplicates even when bank has many questions of the same difficulty', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 10, max: 50 }).chain((n) =>
          fc.tuple(
            // All questions at the same difficulty — stress test for dedup
            fc.constant(Array.from({ length: n }, (_, i) => arbQuestion(`q${i}`, 'medium'))),
            arbAnswerSequence(n),
            fc.integer({ min: 1, max: n }),
          ),
        ),
        ([questionBank, answers, questionCount]) => {
          const { presentedIds } = simulateSession(questionBank, answers, questionCount);
          const uniqueIds = new Set(presentedIds);
          return uniqueIds.size === presentedIds.length;
        },
      ),
      { numRuns: 300, verbose: false },
    );
  });
});

// ─── Property 2: Ascending Difficulty (Task 7.5, Req 6.2) ────────────────────

describe('PBT — Property 2: Ascending Difficulty — Metamorphic (Req 6.2)', () => {
  /**
   * For any sequence of N >= 2 consecutive CORRECT answers,
   * the difficulty levels presented must be non-decreasing.
   *
   * difficultyRank: easy=1, medium=2, hard=3
   */
  it('difficulty is non-decreasing after consecutive correct answers', () => {
    fc.assert(
      fc.property(
        // Generate a bank large enough to always have questions at every difficulty
        fc.constant(
          Array.from({ length: 60 }, (_, i) => {
            const diff = difficulties[i % 3];
            return arbQuestion(`q${i}`, diff);
          }),
        ),
        // All-correct answer sequence of length 10
        fc.constant(Array(10).fill(true)),
        ([questionBank, answers]) => {
          const { difficultySequence } = simulateSession(questionBank, answers, 10);

          // Property: for each consecutive pair, rank must be non-decreasing
          for (let i = 1; i < difficultySequence.length; i++) {
            const prevRank = DIFFICULTY_RANK[difficultySequence[i - 1]];
            const currRank = DIFFICULTY_RANK[difficultySequence[i]];
            if (currRank < prevRank) return false;
          }
          return true;
        },
      ),
      { numRuns: 200, verbose: false },
    );
  });

  it('difficulty escalates from easy toward hard on repeated correct answers', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 2, max: 8 }).chain((n) =>
          fc.tuple(
            // Bank with all three difficulties
            fc.constant(
              Array.from({ length: n * 3 }, (_, i) => arbQuestion(`q${i}`, difficulties[i % 3])),
            ),
            fc.constant(Array(n).fill(true)), // all correct
          ),
        ),
        ([questionBank, answers]) => {
          const { difficultySequence } = simulateSession(questionBank, answers, answers.length);

          for (let i = 1; i < difficultySequence.length; i++) {
            const prevRank = DIFFICULTY_RANK[difficultySequence[i - 1]];
            const currRank = DIFFICULTY_RANK[difficultySequence[i]];
            if (currRank < prevRank) return false;
          }
          return true;
        },
      ),
      { numRuns: 300, verbose: false },
    );
  });
});

// ─── Property 3: Descending Difficulty (Task 7.6, Req 6.3) ───────────────────

describe('PBT — Property 3: Descending Difficulty — Metamorphic (Req 6.3)', () => {
  /**
   * For any sequence of N >= 2 consecutive INCORRECT answers,
   * the difficulty levels presented must be non-increasing.
   */
  it('difficulty is non-increasing after consecutive incorrect answers', () => {
    fc.assert(
      fc.property(
        fc.constant(
          Array.from({ length: 60 }, (_, i) => {
            const diff = difficulties[i % 3];
            return arbQuestion(`q${i}`, diff);
          }),
        ),
        fc.constant(Array(10).fill(false)), // all incorrect
        ([questionBank, answers]) => {
          const { difficultySequence } = simulateSession(questionBank, answers, 10);

          for (let i = 1; i < difficultySequence.length; i++) {
            const prevRank = DIFFICULTY_RANK[difficultySequence[i - 1]];
            const currRank = DIFFICULTY_RANK[difficultySequence[i]];
            if (currRank > prevRank) return false;
          }
          return true;
        },
      ),
      { numRuns: 200, verbose: false },
    );
  });

  it('difficulty de-escalates from hard toward easy on repeated incorrect answers', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 2, max: 8 }).chain((n) =>
          fc.tuple(
            fc.constant(
              Array.from({ length: n * 3 }, (_, i) => arbQuestion(`q${i}`, difficulties[i % 3])),
            ),
            fc.constant(Array(n).fill(false)), // all incorrect
          ),
        ),
        ([questionBank, answers]) => {
          const { difficultySequence } = simulateSession(questionBank, answers, answers.length);

          for (let i = 1; i < difficultySequence.length; i++) {
            const prevRank = DIFFICULTY_RANK[difficultySequence[i - 1]];
            const currRank = DIFFICULTY_RANK[difficultySequence[i]];
            if (currRank > prevRank) return false;
          }
          return true;
        },
      ),
      { numRuns: 300, verbose: false },
    );
  });
});

// ─── Property 4: Termination Invariant (Task 7.7, Req 6.7) ───────────────────

describe('PBT — Property 4: Termination Invariant (Req 6.7)', () => {
  /**
   * If questionBank.count >= Q, the session must present EXACTLY Q questions
   * before terminating — no more, no less.
   */
  it('session presents exactly Q questions when bank has enough questions', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 5, max: 20 }).chain((q) =>
          fc.tuple(
            // Bank always has at least Q questions
            fc.integer({ min: q, max: q + 20 }).chain((bankSize) => arbQuestionBank(bankSize)),
            arbAnswerSequence(q),
            fc.constant(q),
          ),
        ),
        ([questionBank, answers, questionCount]) => {
          const { presentedIds } = simulateSession(questionBank, answers, questionCount);
          // Property: exactly Q questions presented
          return presentedIds.length === questionCount;
        },
      ),
      { numRuns: 500, verbose: false },
    );
  });

  it('session presents fewer than Q questions only when bank is exhausted', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 3, max: 10 }).chain((bankSize) =>
          fc.tuple(
            arbQuestionBank(bankSize),
            arbAnswerSequence(bankSize + 5), // ask for more than available
            fc.integer({ min: bankSize + 1, max: bankSize + 5 }),
          ),
        ),
        ([questionBank, answers, questionCount]) => {
          const { presentedIds } = simulateSession(questionBank, answers, questionCount);
          // Property: can't present more than what's in the bank
          return presentedIds.length <= questionBank.length;
        },
      ),
      { numRuns: 300, verbose: false },
    );
  });
});
