/**
 * Alert Detection Service
 *
 * Detects students whose recent performance has dropped significantly compared
 * to their previous performance in the same subject.
 *
 * Detection logic:
 *   - "Current average"  = average scorePercentage of the student's last 3
 *     completed attempts in a given subject.
 *   - "Previous average" = average scorePercentage of the 3 attempts before
 *     those (i.e. attempts 4–6 in reverse-chronological order).
 *   - If (previousAverage - currentAverage) / previousAverage >= 0.15 (15%),
 *     an alert is created or updated for that student+subject pair.
 *   - weeklyTrend = array of daily average mastery percentages for the last 7
 *     calendar days (index 0 = oldest day, index 6 = today).
 */

import mongoose from 'mongoose';
import { StudentAttempt } from '../models/StudentAttempt';
import { Assessment } from '../models/Assessment';
import { Classroom } from '../models/Classroom';
import { PerformanceAlert } from '../models/PerformanceAlert';
import { logger } from '../utils/logger';

// ─── Types ────────────────────────────────────────────────────────────────────

export interface AlertCheckResult {
  checked: number;
  created: number;
  updated: number;
  dismissed: number;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Calculates the average of an array of numbers.
 * Returns 0 for an empty array.
 */
function average(values: number[]): number {
  if (values.length === 0) return 0;
  return values.reduce((sum, v) => sum + v, 0) / values.length;
}

/**
 * Builds a 7-element array of daily average mastery percentages.
 * Index 0 = 6 days ago, index 6 = today.
 * Days with no attempts get a value of 0.
 */
function buildWeeklyTrend(
  attempts: { submittedAt?: Date; scorePercentage?: number }[],
): number[] {
  const trend: number[] = new Array(7).fill(0);
  const now = new Date();

  // Bucket attempts by day offset (0 = today, 6 = 6 days ago)
  const buckets: number[][] = Array.from({ length: 7 }, () => []);

  for (const attempt of attempts) {
    if (!attempt.submittedAt || attempt.scorePercentage == null) continue;
    const diffMs = now.getTime() - new Date(attempt.submittedAt).getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    if (diffDays >= 0 && diffDays < 7) {
      // diffDays 0 = today → index 6; diffDays 6 = 6 days ago → index 0
      buckets[6 - diffDays].push(attempt.scorePercentage);
    }
  }

  for (let i = 0; i < 7; i++) {
    trend[i] = buckets[i].length > 0 ? Math.round(average(buckets[i]) * 100) / 100 : 0;
  }

  return trend;
}

// ─── Core detection logic ─────────────────────────────────────────────────────

/**
 * Runs the performance alert detection for all students in classrooms
 * belonging to the given teacher.
 *
 * For each student × subject combination:
 *   1. Fetch the last 6 completed attempts (sorted newest first).
 *   2. If fewer than 4 attempts exist, skip (not enough data).
 *   3. Compute currentAverage (attempts 1–3) and previousAverage (attempts 4–6).
 *   4. If drop >= 15%, upsert an active alert.
 *   5. If drop < 15% and an active alert exists, mark it inactive (auto-dismiss).
 *
 * @param teacherId  - The ObjectId of the teacher triggering the check.
 * @returns          - Summary counts of what was created/updated/dismissed.
 */
export async function detectPerformanceAlerts(
  teacherId: mongoose.Types.ObjectId,
): Promise<AlertCheckResult> {
  const result: AlertCheckResult = { checked: 0, created: 0, updated: 0, dismissed: 0 };

  // 1. Find all classrooms where this teacher is assigned
  const classrooms = await Classroom.find({
    teacherIds: teacherId,
    isActive: true,
  })
    .select('_id studentIds')
    .lean();

  if (classrooms.length === 0) {
    return result;
  }

  // 2. Collect all unique student IDs across those classrooms
  const studentClassroomMap = new Map<string, mongoose.Types.ObjectId>();
  for (const classroom of classrooms) {
    for (const studentId of classroom.studentIds) {
      // Map student → first classroom found (for alert association)
      if (!studentClassroomMap.has(studentId.toString())) {
        studentClassroomMap.set(studentId.toString(), classroom._id as mongoose.Types.ObjectId);
      }
    }
  }

  const studentIds = Array.from(studentClassroomMap.keys()).map(
    (id) => new mongoose.Types.ObjectId(id),
  );

  if (studentIds.length === 0) {
    return result;
  }

  // 3. For each student, aggregate their last 6 completed attempts per subject
  //    We use a MongoDB aggregation to group by studentId + subject efficiently.
  const attemptsByStudentSubject = await StudentAttempt.aggregate([
    {
      $match: {
        studentId: { $in: studentIds },
        status: { $in: ['completed', 'timed_out'] },
      },
    },
    // Join with assessments to get the subject
    {
      $lookup: {
        from: 'assessments',
        localField: 'assessmentId',
        foreignField: '_id',
        as: 'assessment',
      },
    },
    { $unwind: '$assessment' },
    // Project only what we need
    {
      $project: {
        studentId: 1,
        subject: '$assessment.subject',
        scorePercentage: 1,
        submittedAt: 1,
        createdAt: 1,
      },
    },
    // Sort newest first within each student+subject group
    { $sort: { studentId: 1, subject: 1, createdAt: -1 } },
    // Group and collect the last 6 attempts per student+subject
    {
      $group: {
        _id: { studentId: '$studentId', subject: '$subject' },
        attempts: {
          $push: {
            scorePercentage: '$scorePercentage',
            submittedAt: '$submittedAt',
            createdAt: '$createdAt',
          },
        },
      },
    },
    // Keep only the first 6 (already sorted newest-first)
    {
      $project: {
        attempts: { $slice: ['$attempts', 6] },
      },
    },
  ]);

  // 4. Also fetch all attempts from the last 7 days for weekly trend calculation
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const recentAttempts = await StudentAttempt.aggregate([
    {
      $match: {
        studentId: { $in: studentIds },
        status: { $in: ['completed', 'timed_out'] },
        submittedAt: { $gte: sevenDaysAgo },
      },
    },
    {
      $lookup: {
        from: 'assessments',
        localField: 'assessmentId',
        foreignField: '_id',
        as: 'assessment',
      },
    },
    { $unwind: '$assessment' },
    {
      $project: {
        studentId: 1,
        subject: '$assessment.subject',
        scorePercentage: 1,
        submittedAt: 1,
      },
    },
  ]);

  // Build a lookup map: studentId+subject → recent attempts for trend
  const trendMap = new Map<string, { submittedAt?: Date; scorePercentage?: number }[]>();
  for (const a of recentAttempts) {
    const key = `${a.studentId.toString()}::${a.subject}`;
    if (!trendMap.has(key)) trendMap.set(key, []);
    trendMap.get(key)!.push({ submittedAt: a.submittedAt, scorePercentage: a.scorePercentage });
  }

  // 5. Process each student+subject combination
  for (const group of attemptsByStudentSubject) {
    const studentId: mongoose.Types.ObjectId = group._id.studentId;
    const subject: string = group._id.subject;
    const attempts: { scorePercentage?: number; submittedAt?: Date }[] = group.attempts;

    result.checked++;

    // Need at least 4 attempts to compare two windows of 3
    if (attempts.length < 4) {
      continue;
    }

    // Newest 3 = current window; next 3 = previous window
    const currentScores = attempts.slice(0, 3).map((a) => a.scorePercentage ?? 0);
    const previousScores = attempts.slice(3, 6).map((a) => a.scorePercentage ?? 0);

    const currentAverage = Math.round(average(currentScores) * 100) / 100;
    const previousAverage = Math.round(average(previousScores) * 100) / 100;

    // Avoid division by zero
    const dropPercentage =
      previousAverage > 0
        ? Math.round(((previousAverage - currentAverage) / previousAverage) * 100 * 100) / 100
        : 0;

    const classroomId = studentClassroomMap.get(studentId.toString())!;
    const trendKey = `${studentId.toString()}::${subject}`;
    const weeklyTrend = buildWeeklyTrend(trendMap.get(trendKey) ?? []);

    if (dropPercentage >= 15) {
      // Upsert an active alert for this student+subject
      const existing = await PerformanceAlert.findOne({
        studentId,
        subject,
        isActive: true,
      });

      if (existing) {
        // Update the existing alert with fresh data
        existing.currentAverage = currentAverage;
        existing.previousAverage = previousAverage;
        existing.dropPercentage = dropPercentage;
        existing.weeklyTrend = weeklyTrend;
        existing.teacherId = teacherId;
        existing.classroomId = classroomId;
        await existing.save();
        result.updated++;
      } else {
        await PerformanceAlert.create({
          teacherId,
          studentId,
          classroomId,
          subject,
          currentAverage,
          previousAverage,
          dropPercentage,
          weeklyTrend,
          isActive: true,
        });
        result.created++;
      }
    } else {
      // Drop is below threshold — auto-dismiss any existing active alert
      const dismissed = await PerformanceAlert.updateMany(
        { studentId, subject, isActive: true },
        { $set: { isActive: false } },
      );
      if (dismissed.modifiedCount > 0) {
        result.dismissed += dismissed.modifiedCount;
      }
    }
  }

  logger.info('Performance alert detection complete', {
    teacherId: teacherId.toString(),
    ...result,
  });

  return result;
}

// ─── List active alerts for a teacher ────────────────────────────────────────

export interface PerformanceAlertWithStudent {
  _id: unknown;
  studentId: unknown;
  studentName: string;
  studentUsername: string;
  classroomId: unknown;
  subject: string;
  currentAverage: number;
  previousAverage: number;
  dropPercentage: number;
  weeklyTrend: number[];
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Returns all active performance alerts for the given teacher,
 * enriched with student name and username.
 */
export async function getActiveAlertsForTeacher(
  teacherId: mongoose.Types.ObjectId,
): Promise<PerformanceAlertWithStudent[]> {
  const alerts = await PerformanceAlert.find({ teacherId, isActive: true })
    .populate('studentId', 'fullName username')
    .sort({ dropPercentage: -1, createdAt: -1 })
    .lean();

  return alerts.map((alert) => {
    const student = alert.studentId as {
      _id: unknown;
      fullName?: string;
      username?: string;
    };
    return {
      _id: alert._id,
      studentId: student._id,
      studentName: student.fullName ?? 'Unknown',
      studentUsername: student.username ?? '',
      classroomId: alert.classroomId,
      subject: alert.subject,
      currentAverage: alert.currentAverage,
      previousAverage: alert.previousAverage,
      dropPercentage: alert.dropPercentage,
      weeklyTrend: alert.weeklyTrend,
      createdAt: alert.createdAt,
      updatedAt: alert.updatedAt,
    };
  });
}
