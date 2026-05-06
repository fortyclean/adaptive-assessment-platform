// Mock the Redis cache module so tests don't need a live Redis connection
// This must be declared before any imports that use the redis module
jest.mock('../../src/config/redis', () => ({
  cache: {
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
  },
}));

import {
  escalateDifficulty,
  deescalateDifficulty,
  getNextDifficulty,
  selectNextQuestion,
  calculateScorePercentage,
  calculatePointsEarned,
  calculateSkillBreakdown,
  calculateResults,
  isSessionComplete,
  initializeSession,
  getSessionQuestions,
  clearSessionCache,
  checkFillBlankAnswer,
  AdaptiveSessionState,
  QuestionCandidate,
  AnswerRecord,
} from '../../src/services/adaptiveEngine';
import { DifficultyLevel } from '../../src/models/Question';
import { cache } from '../../src/config/redis';

describe('Adaptive Engine — Unit Tests', () => {
  // ─── Difficulty Escalation ─────────────────────────────────────────────────
  describe('escalateDifficulty', () => {
    it('escalates easy to medium', () => {
      expect(escalateDifficulty('easy')).toBe('medium');
    });

    it('escalates medium to hard', () => {
      expect(escalateDifficulty('medium')).toBe('hard');
    });

    it('keeps hard at hard (ceiling)', () => {
      expect(escalateDifficulty('hard')).toBe('hard');
    });
  });

  // ─── Difficulty De-escalation ──────────────────────────────────────────────
  describe('deescalateDifficulty', () => {
    it('de-escalates hard to medium', () => {
      expect(deescalateDifficulty('hard')).toBe('medium');
    });

    it('de-escalates medium to easy', () => {
      expect(deescalateDifficulty('medium')).toBe('easy');
    });

    it('keeps easy at easy (floor)', () => {
      expect(deescalateDifficulty('easy')).toBe('easy');
    });
  });

  // ─── Next Difficulty ───────────────────────────────────────────────────────
  describe('getNextDifficulty', () => {
    it('escalates on correct answer', () => {
      expect(getNextDifficulty('easy', true)).toBe('medium');
      expect(getNextDifficulty('medium', true)).toBe('hard');
      expect(getNextDifficulty('hard', true)).toBe('hard');
    });

    it('de-escalates on incorrect answer', () => {
      expect(getNextDifficulty('hard', false)).toBe('medium');
      expect(getNextDifficulty('medium', false)).toBe('easy');
      expect(getNextDifficulty('easy', false)).toBe('easy');
    });
  });

  // ─── Question Selection ────────────────────────────────────────────────────
  describe('selectNextQuestion', () => {
    const makeSession = (
      overrides: Partial<AdaptiveSessionState> = {},
    ): AdaptiveSessionState => ({
      sessionId: 'session-1',
      assessmentId: 'assessment-1',
      studentId: 'student-1',
      subject: 'Mathematics',
      units: ['Unit 1'],
      questionCount: 10,
      presentedQuestionIds: [],
      currentDifficulty: 'medium',
      answeredCount: 0,
      ...overrides,
    });

    const makeQuestion = (
      id: string,
      difficulty: DifficultyLevel,
    ): QuestionCandidate => ({
      _id: id,
      difficulty,
      subject: 'Mathematics',
      unit: 'Unit 1',
    });

    it('returns null when question bank is empty', () => {
      const session = makeSession();
      expect(selectNextQuestion(session, [])).toBeNull();
    });

    it('returns null when all questions have been presented', () => {
      const questions = [makeQuestion('q1', 'medium'), makeQuestion('q2', 'easy')];
      const session = makeSession({ presentedQuestionIds: ['q1', 'q2'] });
      expect(selectNextQuestion(session, questions)).toBeNull();
    });

    it('selects a question at the target difficulty when available', () => {
      const questions = [
        makeQuestion('q1', 'easy'),
        makeQuestion('q2', 'medium'),
        makeQuestion('q3', 'hard'),
      ];
      const session = makeSession({ currentDifficulty: 'medium' });
      const selected = selectNextQuestion(session, questions);
      expect(selected).not.toBeNull();
      expect(selected!.difficulty).toBe('medium');
    });

    it('falls back to any available difficulty when target is exhausted', () => {
      const questions = [makeQuestion('q1', 'easy'), makeQuestion('q2', 'easy')];
      const session = makeSession({ currentDifficulty: 'hard' });
      const selected = selectNextQuestion(session, questions);
      expect(selected).not.toBeNull();
      // Falls back to easy since no hard questions available
      expect(selected!.difficulty).toBe('easy');
    });

    it('never selects an already-presented question', () => {
      const questions = [
        makeQuestion('q1', 'medium'),
        makeQuestion('q2', 'medium'),
        makeQuestion('q3', 'medium'),
      ];
      const session = makeSession({ presentedQuestionIds: ['q1', 'q2'] });
      const selected = selectNextQuestion(session, questions);
      expect(selected).not.toBeNull();
      expect(selected!._id).toBe('q3');
    });
  });

  // ─── Score Calculation ─────────────────────────────────────────────────────
  describe('calculateScorePercentage', () => {
    it('calculates 100% for all correct', () => {
      expect(calculateScorePercentage(10, 10)).toBe(100);
    });

    it('calculates 0% for all incorrect', () => {
      expect(calculateScorePercentage(0, 10)).toBe(0);
    });

    it('calculates 50% for half correct', () => {
      expect(calculateScorePercentage(5, 10)).toBe(50);
    });

    it('returns 0 for zero total questions', () => {
      expect(calculateScorePercentage(0, 0)).toBe(0);
    });

    it('rounds to 2 decimal places', () => {
      expect(calculateScorePercentage(1, 3)).toBe(33.33);
    });
  });

  // ─── Points Calculation ────────────────────────────────────────────────────
  describe('calculatePointsEarned', () => {
    it('calculates base points correctly', () => {
      const { points, bonusAwarded } = calculatePointsEarned(80, 10);
      expect(points).toBe(80); // (80/100) * 10 * 10 = 80
      expect(bonusAwarded).toBe(false);
    });

    it('awards 50 bonus points for score >= 90%', () => {
      const { points, bonusAwarded } = calculatePointsEarned(90, 10);
      expect(points).toBe(140); // 90 base + 50 bonus
      expect(bonusAwarded).toBe(true);
    });

    it('awards bonus at exactly 90%', () => {
      const { bonusAwarded } = calculatePointsEarned(90, 10);
      expect(bonusAwarded).toBe(true);
    });

    it('does not award bonus at 89%', () => {
      const { bonusAwarded } = calculatePointsEarned(89, 10);
      expect(bonusAwarded).toBe(false);
    });

    it('calculates 0 points for 0% score', () => {
      const { points } = calculatePointsEarned(0, 10);
      expect(points).toBe(0);
    });
  });

  // ─── Skill Breakdown ───────────────────────────────────────────────────────
  describe('calculateSkillBreakdown', () => {
    it('classifies skill as strength when >= 70% correct', () => {
      const answers = [
        { mainSkill: 'Algebra', isCorrect: true },
        { mainSkill: 'Algebra', isCorrect: true },
        { mainSkill: 'Algebra', isCorrect: true },
        { mainSkill: 'Algebra', isCorrect: false },
      ];
      const breakdown = calculateSkillBreakdown(answers);
      const algebra = breakdown.find((s) => s.mainSkill === 'Algebra');
      expect(algebra?.classification).toBe('strength');
      expect(algebra?.percentage).toBe(75);
    });

    it('classifies skill as weakness when < 70% correct', () => {
      const answers = [
        { mainSkill: 'Geometry', isCorrect: true },
        { mainSkill: 'Geometry', isCorrect: false },
        { mainSkill: 'Geometry', isCorrect: false },
      ];
      const breakdown = calculateSkillBreakdown(answers);
      const geometry = breakdown.find((s) => s.mainSkill === 'Geometry');
      expect(geometry?.classification).toBe('weakness');
    });

    it('handles multiple skills', () => {
      const answers = [
        { mainSkill: 'Algebra', isCorrect: true },
        { mainSkill: 'Geometry', isCorrect: false },
      ];
      const breakdown = calculateSkillBreakdown(answers);
      expect(breakdown).toHaveLength(2);
    });

    it('returns empty array for no answers', () => {
      expect(calculateSkillBreakdown([])).toEqual([]);
    });
  });

  // ─── Fill-in-the-Blank Answer Checking (Req 18.2, 18.3) ──────────────────
  describe('checkFillBlankAnswer', () => {
    it('returns true when student answer exactly matches an accepted answer', () => {
      expect(checkFillBlankAnswer('Paris', ['Paris'])).toBe(true);
    });

    it('is case-insensitive (Req 18.3)', () => {
      expect(checkFillBlankAnswer('paris', ['Paris'])).toBe(true);
      expect(checkFillBlankAnswer('PARIS', ['Paris'])).toBe(true);
      expect(checkFillBlankAnswer('Paris', ['paris'])).toBe(true);
    });

    it('trims surrounding whitespace before comparing', () => {
      expect(checkFillBlankAnswer('  Paris  ', ['Paris'])).toBe(true);
      expect(checkFillBlankAnswer('Paris', ['  Paris  '])).toBe(true);
    });

    it('returns true when student answer matches any of multiple accepted answers', () => {
      expect(checkFillBlankAnswer('H2O', ['water', 'H2O', 'dihydrogen monoxide'])).toBe(true);
      expect(checkFillBlankAnswer('water', ['water', 'H2O', 'dihydrogen monoxide'])).toBe(true);
    });

    it('returns false when student answer does not match any accepted answer', () => {
      expect(checkFillBlankAnswer('London', ['Paris', 'Paris, France'])).toBe(false);
    });

    it('returns false for an empty student answer', () => {
      expect(checkFillBlankAnswer('', ['Paris'])).toBe(false);
      expect(checkFillBlankAnswer('   ', ['Paris'])).toBe(false);
    });

    it('returns false when accepted answers list is empty', () => {
      expect(checkFillBlankAnswer('Paris', [])).toBe(false);
    });

    it('handles Arabic text correctly', () => {
      expect(checkFillBlankAnswer('باريس', ['باريس'])).toBe(true);
      expect(checkFillBlankAnswer('لندن', ['باريس'])).toBe(false);
    });
  });
});

// ─── Task 7.2: Redis Session Cache ────────────────────────────────────────────
describe('Adaptive Engine — Redis Session Cache', () => {
  const mockedCache = cache as jest.Mocked<typeof cache>;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  const sampleQuestions: QuestionCandidate[] = [
    { _id: 'q1', difficulty: 'easy', subject: 'Mathematics', unit: 'Unit 1' },
    { _id: 'q2', difficulty: 'medium', subject: 'Mathematics', unit: 'Unit 1' },
    { _id: 'q3', difficulty: 'hard', subject: 'Mathematics', unit: 'Unit 1' },
  ];

  describe('initializeSession', () => {
    it('stores the question list in Redis with the correct key and TTL', async () => {
      mockedCache.set.mockResolvedValue(undefined);

      await initializeSession('attempt-123', sampleQuestions, 3600);

      expect(mockedCache.set).toHaveBeenCalledWith(
        'session:attempt-123:questions',
        sampleQuestions,
        3600,
      );
    });

    it('uses the session duration as the TTL', async () => {
      mockedCache.set.mockResolvedValue(undefined);

      await initializeSession('attempt-456', sampleQuestions, 1800);

      expect(mockedCache.set).toHaveBeenCalledWith(
        'session:attempt-456:questions',
        sampleQuestions,
        1800,
      );
    });
  });

  describe('getSessionQuestions', () => {
    it('returns the cached question list when present', async () => {
      mockedCache.get.mockResolvedValue(sampleQuestions);

      const result = await getSessionQuestions('attempt-123');

      expect(result).toEqual(sampleQuestions);
      expect(mockedCache.get).toHaveBeenCalledWith('session:attempt-123:questions');
    });

    it('returns null when the cache has expired or was never set', async () => {
      mockedCache.get.mockResolvedValue(null);

      const result = await getSessionQuestions('attempt-999');

      expect(result).toBeNull();
    });
  });

  describe('clearSessionCache', () => {
    it('deletes the session questions key from Redis', async () => {
      mockedCache.del.mockResolvedValue(undefined);

      await clearSessionCache('attempt-123');

      expect(mockedCache.del).toHaveBeenCalledWith('session:attempt-123:questions');
    });
  });
});

// ─── Task 7.3: Session Termination and Result Calculation ─────────────────────
describe('Adaptive Engine — Session Termination and Result Calculation', () => {
  const makeSession = (overrides: Partial<AdaptiveSessionState> = {}): AdaptiveSessionState => ({
    sessionId: 'session-1',
    assessmentId: 'assessment-1',
    studentId: 'student-1',
    subject: 'Mathematics',
    units: ['Unit 1'],
    questionCount: 10,
    presentedQuestionIds: [],
    currentDifficulty: 'medium',
    answeredCount: 0,
    ...overrides,
  });

  // ─── isSessionComplete ───────────────────────────────────────────────────
  describe('isSessionComplete', () => {
    it('returns false when answeredCount < questionCount', () => {
      const session = makeSession({ answeredCount: 5, questionCount: 10 });
      expect(isSessionComplete(session)).toBe(false);
    });

    it('returns true when answeredCount equals questionCount', () => {
      const session = makeSession({ answeredCount: 10, questionCount: 10 });
      expect(isSessionComplete(session)).toBe(true);
    });

    it('returns true when answeredCount exceeds questionCount', () => {
      const session = makeSession({ answeredCount: 11, questionCount: 10 });
      expect(isSessionComplete(session)).toBe(true);
    });
  });

  // ─── calculateResults ────────────────────────────────────────────────────
  describe('calculateResults', () => {
    it('calculates scorePercentage correctly', () => {
      const session = makeSession({ answeredCount: 10, questionCount: 10 });
      const answers: AnswerRecord[] = Array.from({ length: 10 }, (_, i) => ({
        mainSkill: 'Algebra',
        isCorrect: i < 8, // 8 correct out of 10
      }));
      const result = calculateResults(session, answers);
      expect(result.scorePercentage).toBe(80);
    });

    it('calculates pointsEarned correctly: round((score/100) * questionCount * 10)', () => {
      const session = makeSession({ answeredCount: 10, questionCount: 10 });
      const answers: AnswerRecord[] = Array.from({ length: 10 }, (_, i) => ({
        mainSkill: 'Algebra',
        isCorrect: i < 8, // 80%
      }));
      const result = calculateResults(session, answers);
      // (80/100) * 10 * 10 = 80
      expect(result.pointsEarned).toBe(80);
      expect(result.bonusAwarded).toBe(false);
    });

    it('awards 50 bonus points when score >= 90%', () => {
      const session = makeSession({ answeredCount: 10, questionCount: 10 });
      const answers: AnswerRecord[] = Array.from({ length: 10 }, (_, i) => ({
        mainSkill: 'Algebra',
        isCorrect: i < 9, // 90%
      }));
      const result = calculateResults(session, answers);
      // base: (90/100) * 10 * 10 = 90, bonus: +50 = 140
      expect(result.pointsEarned).toBe(140);
      expect(result.bonusAwarded).toBe(true);
    });

    it('does not award bonus when score is exactly 89%', () => {
      const session = makeSession({ answeredCount: 10, questionCount: 10 });
      // 89% — use 100 questions to get exact 89%
      const session100 = makeSession({ answeredCount: 100, questionCount: 100 });
      const answers: AnswerRecord[] = Array.from({ length: 100 }, (_, i) => ({
        mainSkill: 'Algebra',
        isCorrect: i < 89,
      }));
      const result = calculateResults(session100, answers);
      expect(result.bonusAwarded).toBe(false);
    });

    it('calculates skillBreakdown per mainSkill', () => {
      const session = makeSession({ answeredCount: 6, questionCount: 6 });
      const answers: AnswerRecord[] = [
        { mainSkill: 'Algebra', isCorrect: true },
        { mainSkill: 'Algebra', isCorrect: true },
        { mainSkill: 'Algebra', isCorrect: true }, // 100% → strength
        { mainSkill: 'Geometry', isCorrect: true },
        { mainSkill: 'Geometry', isCorrect: false },
        { mainSkill: 'Geometry', isCorrect: false }, // 33% → weakness
      ];
      const result = calculateResults(session, answers);
      const algebra = result.skillBreakdown.find((s) => s.mainSkill === 'Algebra');
      const geometry = result.skillBreakdown.find((s) => s.mainSkill === 'Geometry');
      expect(algebra?.classification).toBe('strength');
      expect(geometry?.classification).toBe('weakness');
    });

    it('marks session as complete when answeredCount equals questionCount', () => {
      const session = makeSession({ answeredCount: 10, questionCount: 10 });
      const answers: AnswerRecord[] = Array.from({ length: 10 }, () => ({
        mainSkill: 'Algebra',
        isCorrect: true,
      }));
      const result = calculateResults(session, answers);
      expect(result.isComplete).toBe(true);
    });

    it('marks session as incomplete when answeredCount < questionCount', () => {
      const session = makeSession({ answeredCount: 5, questionCount: 10 });
      const answers: AnswerRecord[] = Array.from({ length: 5 }, () => ({
        mainSkill: 'Algebra',
        isCorrect: true,
      }));
      const result = calculateResults(session, answers);
      expect(result.isComplete).toBe(false);
    });

    it('handles zero answers gracefully', () => {
      const session = makeSession({ answeredCount: 0, questionCount: 10 });
      const result = calculateResults(session, []);
      expect(result.scorePercentage).toBe(0);
      expect(result.pointsEarned).toBe(0);
      expect(result.bonusAwarded).toBe(false);
      expect(result.skillBreakdown).toEqual([]);
      expect(result.isComplete).toBe(false);
    });
  });
});
