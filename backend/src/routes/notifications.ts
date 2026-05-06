/**
 * Notifications Routes
 *
 * GET    /api/v1/notifications              — List notifications (Req 21.4, 21.7)
 * PATCH  /api/v1/notifications/:id/read     — Mark one as read (Req 21.5)
 * PATCH  /api/v1/notifications/read-all     — Mark all as read (Req 21.6)
 *
 * Points history is served via GET /api/v1/attempts (student session history)
 * and the per-attempt result endpoint. A dedicated points summary endpoint is
 * also provided here for the Points & Achievements screen (Req 15.3, 15.5).
 *
 * GET    /api/v1/notifications/points       — Student points summary (Req 15.3, 15.5)
 */

import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { Notification } from '../models/Notification';
import { StudentAttempt } from '../models/StudentAttempt';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// Maximum notifications retained per user (Req 21.7)
const MAX_NOTIFICATIONS = 50;

// ─── GET /api/v1/notifications — List notifications ──────────────────────────

router.get('/', authorize('student', 'teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user!.userId);

    const notifications = await Notification.find({ userId })
      .sort({ createdAt: -1 })
      .limit(MAX_NOTIFICATIONS)
      .lean();

    const unreadCount = notifications.filter((n) => !n.isRead).length;

    res.status(200).json({ notifications, unreadCount });
  } catch (error) {
    logger.error('Get notifications error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/notifications/points — Student points summary ───────────────

router.get('/points', authorize('student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const studentId = new mongoose.Types.ObjectId(req.user!.userId);

    // Aggregate points history from completed attempts (Req 15.3, 15.5, 15.6)
    const attempts = await StudentAttempt.find({
      studentId,
      status: { $in: ['completed', 'timed_out'] },
    })
      .populate('assessmentId', 'title subject')
      .select('assessmentId scorePercentage pointsEarned submittedAt skillBreakdown')
      .sort({ submittedAt: -1 })
      .lean();

    const totalPoints = attempts.reduce((sum, a) => sum + (a.pointsEarned ?? 0), 0);

    // Points history log (Req 15.6)
    const pointsHistory = attempts.map((a) => ({
      assessmentTitle: (a.assessmentId as { title?: string })?.title ?? 'Unknown',
      subject: (a.assessmentId as { subject?: string })?.subject ?? '',
      pointsEarned: a.pointsEarned ?? 0,
      scorePercentage: a.scorePercentage ?? 0,
      date: a.submittedAt,
    }));

    // Mastered skills — skills with >= 70% across all attempts (Req 15.5)
    const skillMap = new Map<string, { total: number; correct: number }>();
    for (const attempt of attempts) {
      for (const skill of attempt.skillBreakdown ?? []) {
        const existing = skillMap.get(skill.mainSkill) ?? { total: 0, correct: 0 };
        skillMap.set(skill.mainSkill, {
          total: existing.total + skill.totalQuestions,
          correct: existing.correct + skill.correctAnswers,
        });
      }
    }
    const masteredSkills = Array.from(skillMap.entries())
      .map(([mainSkill, stats]) => ({
        mainSkill,
        masteryPercentage: stats.total > 0 ? Math.round((stats.correct / stats.total) * 100 * 100) / 100 : 0,
      }))
      .filter((s) => s.masteryPercentage >= 70)
      .sort((a, b) => b.masteryPercentage - a.masteryPercentage);

    // Achievement badges (Req 15.2, 15.4)
    const bonusAttempts = attempts.filter((a) => (a.scorePercentage ?? 0) >= 90).length;
    const achievements = [
      { id: 'first_attempt', title: 'أول اختبار', earned: attempts.length >= 1 },
      { id: 'perfect_score', title: 'درجة كاملة', earned: attempts.some((a) => a.scorePercentage === 100) },
      { id: 'high_achiever', title: 'متفوق', earned: bonusAttempts >= 3 },
      { id: 'consistent', title: 'مثابر', earned: attempts.length >= 10 },
    ];

    res.status(200).json({
      totalPoints,
      pointsHistory,
      masteredSkills,
      achievements,
      totalAttempts: attempts.length,
    });
  } catch (error) {
    logger.error('Points summary error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/notifications/read-all — Mark all as read ─────────────────
// Must be defined BEFORE /:id/read to avoid route conflict

router.patch('/read-all', authorize('student', 'teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user!.userId);

    const result = await Notification.updateMany({ userId, isRead: false }, { $set: { isRead: true } });

    res.status(200).json({ updatedCount: result.modifiedCount });
  } catch (error) {
    logger.error('Mark all read error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/notifications/:id/read — Mark one as read ─────────────────

router.patch('/:id/read', authorize('student', 'teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = new mongoose.Types.ObjectId(req.user!.userId);

    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, userId },
      { $set: { isRead: true } },
      { new: true },
    );

    if (!notification) {
      res.status(404).json({ error: 'Notification not found' });
      return;
    }

    res.status(200).json({ notification });
  } catch (error) {
    logger.error('Mark read error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
