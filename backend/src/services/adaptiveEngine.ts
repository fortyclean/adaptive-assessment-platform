import { DifficultyLevel } from '../models/Question';
import { cache } from '../config/redis';

export const DIFFICULTY_RANK: Record<DifficultyLevel, number> = {
  easy: 1,
  medium: 2,
  hard: 3,
};

export const RANK_TO_DIFFICULTY: Record<number, DifficultyLevel> = {
  1: 'easy',
  2: 'medium',
  3: 'hard',
};

/**
 * Escalates difficulty after a correct answer.
 * easy → medium, medium → hard, hard → hard
 */
export function escalateDifficulty(current: DifficultyLevel): DifficultyLevel {
  const rank = DIFFICULTY_RANK[current];
  const newRank = Math.min(rank + 1, 3);
  return RANK_TO_DIFFICULTY[newRank];
}

/**
 * De-escalates difficulty after an incorrect answer.
 * hard → medium, medium → easy, easy → easy
 */
export function deescalateDifficulty(current: DifficultyLevel): DifficultyLevel {
  const rank = DIFFICULTY_RANK[current];
  const newRank = Math.max(rank - 1, 1);
  return RANK_TO_DIFFICULTY[newRank];
}

/**
 * Determines the next difficulty level based on whether the last answer was correct.
 */
export function getNextDifficulty(
  currentDifficulty: DifficultyLevel,
  wasCorrect: boolean,
): DifficultyLevel {
  return wasCorrect
    ? escalateDifficulty(currentDifficulty)
    : deescalateDifficulty(currentDifficulty);
}

export interface AdaptiveSessionState {
  sessionId: string;
  assessmentId: string;
  studentId: string;
  subject: string;
  units: string[];
  questionCount: number;
  presentedQuestionIds: string[];
  currentDifficulty: DifficultyLevel;
  answeredCount: number;
}

export interface QuestionCandidate {
  _id: string;
  difficulty: DifficultyLevel;
  subject: string;
  unit: string;
}

/**
 * Selects the next question for an adaptive session.
 * Returns null if no more questions are available.
 *
 * Algorithm:
 * 1. Determine target difficulty based on last answer
 * 2. Find candidates at target difficulty, excluding already-presented questions
 * 3. If no candidates at target difficulty, fall back to any available difficulty
 * 4. Return a random pick from candidates
 */
export function selectNextQuestion<T extends QuestionCandidate>(
  session: AdaptiveSessionState,
  questionBank: T[],
): T | null {
  const presentedSet = new Set(session.presentedQuestionIds);

  // Filter out already-presented questions
  const available = questionBank.filter((q) => !presentedSet.has(q._id.toString()));

  if (available.length === 0) {
    return null;
  }

  // Find candidates at the target difficulty
  const targetCandidates = available.filter((q) => q.difficulty === session.currentDifficulty);

  const candidates = targetCandidates.length > 0 ? targetCandidates : available;

  // Random pick from candidates
  const randomIndex = Math.floor(Math.random() * candidates.length);
  return candidates[randomIndex];
}

/**
 * Calculates the score percentage for a completed session.
 */
export function calculateScorePercentage(correctAnswers: number, totalQuestions: number): number {
  if (totalQuestions === 0) return 0;
  return Math.round((correctAnswers / totalQuestions) * 100 * 100) / 100;
}

/**
 * Calculates points earned for a session.
 * Formula: round((scorePercentage / 100) * questionCount * 10)
 * Bonus: +50 points if score >= 90%
 */
export function calculatePointsEarned(
  scorePercentage: number,
  questionCount: number,
): { points: number; bonusAwarded: boolean } {
  const basePoints = Math.round((scorePercentage / 100) * questionCount * 10);
  const bonusAwarded = scorePercentage >= 90;
  const points = bonusAwarded ? basePoints + 50 : basePoints;
  return { points, bonusAwarded };
}

/**
 * Calculates skill breakdown from session answers.
 */
export interface AnswerRecord {
  mainSkill: string;
  isCorrect: boolean;
}

export interface SkillBreakdownResult {
  mainSkill: string;
  totalQuestions: number;
  correctAnswers: number;
  percentage: number;
  classification: 'strength' | 'weakness';
}

export function calculateSkillBreakdown(answers: AnswerRecord[]): SkillBreakdownResult[] {
  const skillMap = new Map<string, { total: number; correct: number }>();

  for (const answer of answers) {
    const existing = skillMap.get(answer.mainSkill) || { total: 0, correct: 0 };
    skillMap.set(answer.mainSkill, {
      total: existing.total + 1,
      correct: existing.correct + (answer.isCorrect ? 1 : 0),
    });
  }

  return Array.from(skillMap.entries()).map(([mainSkill, stats]) => {
    const percentage = stats.total > 0 ? (stats.correct / stats.total) * 100 : 0;
    return {
      mainSkill,
      totalQuestions: stats.total,
      correctAnswers: stats.correct,
      percentage: Math.round(percentage * 100) / 100,
      classification: percentage >= 70 ? 'strength' : 'weakness',
    };
  });
}

// ─── Redis Session Cache ───────────────────────────────────────────────────────

/**
 * Cache key for the prefetched question list for a given session.
 */
export function sessionQuestionsKey(attemptId: string): string {
  return `session:${attemptId}:questions`;
}

/**
 * Initializes a session in Redis by caching the full question bank for that
 * session. This prefetch allows the adaptive engine to select the next question
 * within the 100ms SLA without hitting MongoDB on every request.
 *
 * @param attemptId   - The StudentAttempt _id (used as the Redis key namespace)
 * @param questions   - The full list of candidate questions for this session
 * @param ttlSeconds  - TTL matching the session duration (e.g. timeLimitMinutes * 60)
 */
export async function initializeSession<T extends QuestionCandidate>(
  attemptId: string,
  questions: T[],
  ttlSeconds: number,
): Promise<void> {
  const key = sessionQuestionsKey(attemptId);
  await cache.set(key, questions, ttlSeconds);
}

/**
 * Retrieves the cached question bank for a session from Redis.
 * Returns null if the cache has expired or was never set.
 */
export async function getSessionQuestions<T extends QuestionCandidate>(
  attemptId: string,
): Promise<T[] | null> {
  const key = sessionQuestionsKey(attemptId);
  return cache.get<T[]>(key);
}

/**
 * Removes the cached question bank for a session from Redis.
 * Should be called when the session terminates to free memory.
 */
export async function clearSessionCache(attemptId: string): Promise<void> {
  const key = sessionQuestionsKey(attemptId);
  await cache.del(key);
}

// ─── Fill-in-the-Blank Answer Checking ────────────────────────────────────────

/**
 * Checks whether a student's text answer matches any of the accepted correct
 * answers for a Fill-in-the-Blank question.
 *
 * Matching is case-insensitive and trims surrounding whitespace from both the
 * student's answer and each accepted answer (Requirement 18.3).
 *
 * @param studentAnswer   - The raw text typed by the student.
 * @param acceptedAnswers - One or more accepted correct answers defined by the teacher.
 * @returns true if the student's answer matches at least one accepted answer.
 */
export function checkFillBlankAnswer(
  studentAnswer: string,
  acceptedAnswers: string[],
): boolean {
  if (!studentAnswer || acceptedAnswers.length === 0) return false;
  const normalised = studentAnswer.trim().toLowerCase();
  return acceptedAnswers.some((a) => a.trim().toLowerCase() === normalised);
}

// ─── Session Result Calculation ────────────────────────────────────────────────

export interface SessionResult {
  scorePercentage: number;
  pointsEarned: number;
  bonusAwarded: boolean;
  skillBreakdown: SkillBreakdownResult[];
  isComplete: boolean;
}

/**
 * Determines whether a session has reached its configured question count.
 * Per requirement 6.7, the session terminates after exactly Q questions.
 */
export function isSessionComplete(session: AdaptiveSessionState): boolean {
  return session.answeredCount >= session.questionCount;
}

/**
 * Calculates the full result for a completed adaptive session.
 *
 * Formula (Requirements 6.7, 6.8, 8.1, 8.2, 8.3, 15.1, 15.4):
 *   scorePercentage = (correctAnswers / totalQuestions) × 100
 *   pointsEarned    = round((scorePercentage / 100) × questionCount × 10)
 *   bonus           = +50 if scorePercentage >= 90
 *   skillBreakdown  = per mainSkill: strength (>=70%) or weakness (<70%)
 *
 * @param session - The completed AdaptiveSessionState
 * @param answers - The answer records for the session (mainSkill + isCorrect per question)
 */
export function calculateResults(
  session: AdaptiveSessionState,
  answers: AnswerRecord[],
): SessionResult {
  const totalQuestions = answers.length;
  const correctAnswers = answers.filter((a) => a.isCorrect).length;

  const scorePercentage = calculateScorePercentage(correctAnswers, totalQuestions);
  const { points: pointsEarned, bonusAwarded } = calculatePointsEarned(
    scorePercentage,
    session.questionCount,
  );
  const skillBreakdown = calculateSkillBreakdown(answers);
  const isComplete = isSessionComplete(session);

  return {
    scorePercentage,
    pointsEarned,
    bonusAwarded,
    skillBreakdown,
    isComplete,
  };
}
