/**
 * Students Routes
 *
 * GET /api/v1/students/:id/profile — Full skill radar data for a student (Screens 56, 57, 58)
 *   Returns: skillRadar (array of {skill, percentage}), behaviorLog, weeklyTrend
 */

import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { StudentAttempt } from '../models/StudentAttempt';
import { User } from '../models/User';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// ─── GET /api/v1/students/:id/profile ────────────────────────────────────────
//
// Returns a full skill radar profile for a student, including:
//   - skillRadar:   aggregated skill mastery percentages across all completed attempts
//   - behaviorLog:  recent activity events (last 10 completed/timed-out attempts)
//   - weeklyTrend:  daily average mastery percentage for the last 7 days

router.get(
  '/:id/profile',
  authorize('teacher', 'admin', 'student'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const { id } = req.params;

      // Students may only view their own profile
      if (req.user!.role === 'student' && id !== req.user!.userId) {
        res.status(403).json({ error: 'Access denied' });
        return;
      }

      // Validate ObjectId format
      if (!mongoose.Types.ObjectId.isValid(id)) {
        res.status(400).json({ error: 'Invalid student ID' });
        return;
      }

      const studentObjectId = new mongoose.Types.ObjectId(id);

      // Verify the student exists and is actually a student
      const student = await User.findById(studentObjectId).select('fullName username role isActive').lean();
      if (!student) {
        res.status(404).json({ error: 'Student not found' });
        return;
      }
      if (student.role !== 'student') {
        res.status(400).json({ error: 'The specified user is not a student' });
        return;
      }

      // ── 1. skillRadar — aggregate skill mastery across all completed attempts ──
      //
      // For each mainSkill, sum totalQuestions and correctAnswers across all
      // completed/timed-out attempts, then compute the overall percentage.

      const skillAgg = await StudentAttempt.aggregate([
        {
          $match: {
            studentId: studentObjectId,
            status: { $in: ['completed', 'timed_out'] },
          },
        },
        { $unwind: '$skillBreakdown' },
        {
          $group: {
            _id: '$skillBreakdown.mainSkill',
            totalQuestions: { $sum: '$skillBreakdown.totalQuestions' },
            correctAnswers: { $sum: '$skillBreakdown.correctAnswers' },
          },
        },
        {
          $project: {
            _id: 0,
            skill: '$_id',
            percentage: {
              $round: [
                {
                  $multiply: [
                    { $divide: ['$correctAnswers', '$totalQuestions'] },
                    100,
                  ],
                },
                1,
              ],
            },
            totalQuestions: 1,
            correctAnswers: 1,
          },
        },
        { $sort: { skill: 1 } },
      ]);

      const skillRadar: { skill: string; percentage: number }[] = skillAgg.map((s) => ({
        skill: s.skill as string,
        percentage: s.percentage as number,
      }));

      // ── 2. behaviorLog — last 10 completed/timed-out attempts ─────────────────
      //
      // Each entry represents a recent assessment activity event.

      const recentAttempts = await StudentAttempt.find({
        studentId: studentObjectId,
        status: { $in: ['completed', 'timed_out'] },
      })
        .sort({ submittedAt: -1 })
        .limit(10)
        .populate('assessmentId', 'title subject')
        .select('assessmentId status scorePercentage pointsEarned submittedAt timeTakenSeconds antiCheatLog')
        .lean();

      const behaviorLog = recentAttempts.map((attempt) => {
        const assessment = attempt.assessmentId as {
          _id: mongoose.Types.ObjectId;
          title?: string;
          subject?: string;
        } | null;

        // Count anti-cheat events as a behaviour signal
        const antiCheatCount = attempt.antiCheatLog?.length ?? 0;

        return {
          attemptId: attempt._id,
          assessmentTitle: assessment?.title ?? 'Unknown',
          subject: assessment?.subject ?? 'Unknown',
          status: attempt.status,
          scorePercentage: attempt.scorePercentage ?? null,
          pointsEarned: attempt.pointsEarned ?? null,
          timeTakenSeconds: attempt.timeTakenSeconds ?? null,
          submittedAt: attempt.submittedAt ?? null,
          antiCheatEvents: antiCheatCount,
        };
      });

      // ── 3. weeklyTrend — daily average mastery for the last 7 days ────────────
      //
      // Groups completed attempts by calendar day (YYYY-MM-DD) and computes the
      // average scorePercentage per day. Days with no attempts are filled with null.

      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6); // inclusive of today → 7 days
      sevenDaysAgo.setHours(0, 0, 0, 0);

      const dailyAgg = await StudentAttempt.aggregate([
        {
          $match: {
            studentId: studentObjectId,
            status: { $in: ['completed', 'timed_out'] },
            submittedAt: { $gte: sevenDaysAgo },
          },
        },
        {
          $group: {
            _id: {
              $dateToString: { format: '%Y-%m-%d', date: '$submittedAt' },
            },
            averageScore: { $avg: '$scorePercentage' },
            attemptCount: { $sum: 1 },
          },
        },
        {
          $project: {
            _id: 0,
            date: '$_id',
            averageScore: { $round: ['$averageScore', 1] },
            attemptCount: 1,
          },
        },
        { $sort: { date: 1 } },
      ]);

      // Build a full 7-day array, filling missing days with null
      const dailyMap = new Map<string, { averageScore: number; attemptCount: number }>(
        dailyAgg.map((d) => [d.date as string, { averageScore: d.averageScore as number, attemptCount: d.attemptCount as number }]),
      );

      const weeklyTrend: { date: string; averageScore: number | null; attemptCount: number }[] = [];
      for (let i = 0; i < 7; i++) {
        const day = new Date(sevenDaysAgo);
        day.setDate(sevenDaysAgo.getDate() + i);
        const dateStr = day.toISOString().slice(0, 10); // YYYY-MM-DD
        const entry = dailyMap.get(dateStr);
        weeklyTrend.push({
          date: dateStr,
          averageScore: entry?.averageScore ?? null,
          attemptCount: entry?.attemptCount ?? 0,
        });
      }

      // ── Response ──────────────────────────────────────────────────────────────

      res.status(200).json({
        student: {
          id: student._id,
          fullName: student.fullName,
          username: student.username,
        },
        skillRadar,
        behaviorLog,
        weeklyTrend,
      });
    } catch (error) {
      logger.error('Student profile error', { error });
      res.status(500).json({ error: 'An internal server error occurred' });
    }
  },
);

export default router;
