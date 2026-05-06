/**
 * Cache Service
 *
 * Implements the Redis caching strategy for all domain entities.
 * Requirements: 12.1, 12.2, 20.6
 *
 * TTL Strategy:
 *   questions:{subject}:{unit}:{difficulty}  → 1 hour   (3600s)
 *   assessment:{id}:questions                → 24 hours (86400s)
 *   user:{id}:session                        → 8 hours  (28800s)
 *   classroom:{id}:students                  → 30 min   (1800s)
 */

import { cache } from '../config/redis';
import { logger } from '../utils/logger';

const TTL = {
  QUESTIONS: 3600,        // 1 hour
  ASSESSMENT: 86400,      // 24 hours
  USER_SESSION: 28800,    // 8 hours
  CLASSROOM_STUDENTS: 1800, // 30 minutes
} as const;

// ─── Questions Cache ──────────────────────────────────────────────────────────

export async function getCachedQuestions<T>(
  subject: string,
  unit: string,
  difficulty: string,
): Promise<T[] | null> {
  try {
    const key = cache.buildKey.questions(subject, unit, difficulty);
    return await cache.get<T[]>(key);
  } catch (error) {
    logger.warn('Cache get questions failed', { error });
    return null;
  }
}

export async function setCachedQuestions<T>(
  subject: string,
  unit: string,
  difficulty: string,
  questions: T[],
): Promise<void> {
  try {
    const key = cache.buildKey.questions(subject, unit, difficulty);
    await cache.set(key, questions, TTL.QUESTIONS);
  } catch (error) {
    logger.warn('Cache set questions failed', { error });
  }
}

export async function invalidateQuestionsCache(subject: string, unit: string): Promise<void> {
  try {
    await cache.delPattern(`questions:${subject}:${unit}:*`);
  } catch (error) {
    logger.warn('Cache invalidate questions failed', { error });
  }
}

// ─── Assessment Questions Cache ───────────────────────────────────────────────

export async function getCachedAssessmentQuestions<T>(assessmentId: string): Promise<T[] | null> {
  try {
    const key = cache.buildKey.assessment(assessmentId);
    return await cache.get<T[]>(key);
  } catch (error) {
    logger.warn('Cache get assessment questions failed', { error });
    return null;
  }
}

export async function setCachedAssessmentQuestions<T>(
  assessmentId: string,
  questions: T[],
): Promise<void> {
  try {
    const key = cache.buildKey.assessment(assessmentId);
    await cache.set(key, questions, TTL.ASSESSMENT);
  } catch (error) {
    logger.warn('Cache set assessment questions failed', { error });
  }
}

export async function invalidateAssessmentCache(assessmentId: string): Promise<void> {
  try {
    await cache.del(cache.buildKey.assessment(assessmentId));
  } catch (error) {
    logger.warn('Cache invalidate assessment failed', { error });
  }
}

// ─── User Session Cache ───────────────────────────────────────────────────────

export async function getCachedUserSession<T>(userId: string): Promise<T | null> {
  try {
    const key = cache.buildKey.userSession(userId);
    return await cache.get<T>(key);
  } catch (error) {
    logger.warn('Cache get user session failed', { error });
    return null;
  }
}

export async function setCachedUserSession<T>(userId: string, session: T): Promise<void> {
  try {
    const key = cache.buildKey.userSession(userId);
    await cache.set(key, session, TTL.USER_SESSION);
  } catch (error) {
    logger.warn('Cache set user session failed', { error });
  }
}

export async function invalidateUserSession(userId: string): Promise<void> {
  try {
    await cache.del(cache.buildKey.userSession(userId));
  } catch (error) {
    logger.warn('Cache invalidate user session failed', { error });
  }
}

// ─── Classroom Students Cache ─────────────────────────────────────────────────

export async function getCachedClassroomStudents<T>(classroomId: string): Promise<T[] | null> {
  try {
    const key = cache.buildKey.classroomStudents(classroomId);
    return await cache.get<T[]>(key);
  } catch (error) {
    logger.warn('Cache get classroom students failed', { error });
    return null;
  }
}

export async function setCachedClassroomStudents<T>(
  classroomId: string,
  students: T[],
): Promise<void> {
  try {
    const key = cache.buildKey.classroomStudents(classroomId);
    await cache.set(key, students, TTL.CLASSROOM_STUDENTS);
  } catch (error) {
    logger.warn('Cache set classroom students failed', { error });
  }
}

export async function invalidateClassroomStudentsCache(classroomId: string): Promise<void> {
  try {
    await cache.del(cache.buildKey.classroomStudents(classroomId));
  } catch (error) {
    logger.warn('Cache invalidate classroom students failed', { error });
  }
}
