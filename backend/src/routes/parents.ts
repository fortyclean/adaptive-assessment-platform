import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { authenticate, authorize } from '../middleware/authenticate';
import { Classroom } from '../models/Classroom';
import { Notification } from '../models/Notification';
import { StudentAttempt } from '../models/StudentAttempt';
import { User } from '../models/User';
import { logger } from '../utils/logger';

const router = Router();

router.use(authenticate);
router.use(authorize('parent'));

router.get('/me/children', async (req: Request, res: Response): Promise<void> => {
  try {
    const parentUserId = req.user?.userId;
    if (!parentUserId) {
      res.status(401).json({ error: 'Authentication required.' });
      return;
    }

    const parent = await User.findById(parentUserId).select('childIds');
    const childIds = parent?.childIds ?? [];

    if (childIds.length === 0) {
      res.status(200).json({ children: [] });
      return;
    }

    const children = await User.find({
      _id: { $in: childIds },
      role: 'student',
      isActive: true,
    }).select('fullName username email classroomIds avatarUrl');

    const summaries = await Promise.all(
      children.map(async (child) => buildChildSummary(child._id as mongoose.Types.ObjectId, child)),
    );

    res.status(200).json({ children: summaries });
  } catch (error) {
    logger.error('Parent children list error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

router.get('/me/children/:childId', async (req: Request, res: Response): Promise<void> => {
  try {
    const parentUserId = req.user?.userId;
    if (!parentUserId) {
      res.status(401).json({ error: 'Authentication required.' });
      return;
    }

    const childId = req.params.childId;
    if (!mongoose.Types.ObjectId.isValid(childId)) {
      res.status(400).json({ error: 'Invalid child ID' });
      return;
    }

    const parent = await User.findById(parentUserId).select('childIds');
    const isLinked = (parent?.childIds ?? []).some((id) => id.toString() === childId);
    if (!isLinked) {
      res.status(403).json({ error: 'You do not have permission to view this child.' });
      return;
    }

    const child = await User.findOne({
      _id: childId,
      role: 'student',
      isActive: true,
    }).select('fullName username email classroomIds avatarUrl');

    if (!child) {
      res.status(404).json({ error: 'Child not found' });
      return;
    }

    const summary = await buildChildSummary(child._id as mongoose.Types.ObjectId, child);
    res.status(200).json({ child: summary });
  } catch (error) {
    logger.error('Parent child detail error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

router.get('/me/messages', async (req: Request, res: Response): Promise<void> => {
  try {
    const parentUserId = req.user?.userId;
    if (!parentUserId) {
      res.status(401).json({ error: 'Authentication required.' });
      return;
    }

    const notifications = await Notification.find({ userId: parentUserId })
      .sort({ createdAt: -1 })
      .limit(25)
      .select('title body isRead createdAt type');

    res.status(200).json({
      messages: notifications.map((notification) => ({
        id: notification._id,
        subject: notification.title,
        body: notification.body,
        isRead: notification.isRead,
        type: notification.type,
        createdAt: notification.createdAt,
      })),
    });
  } catch (error) {
    logger.error('Parent messages error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

async function buildChildSummary(
  childId: mongoose.Types.ObjectId,
  child: {
    fullName: string;
    username: string;
    email?: string;
    classroomIds: mongoose.Types.ObjectId[];
    avatarUrl?: string;
  },
) {
  const [classroom, attempts] = await Promise.all([
    Classroom.findOne({ studentIds: childId, isActive: true })
      .sort({ updatedAt: -1 })
      .select('name gradeLevel'),
    StudentAttempt.find({ studentId: childId, status: { $in: ['completed', 'timed_out'] } })
      .sort({ submittedAt: -1, updatedAt: -1 })
      .limit(8)
      .select('scorePercentage submittedAt updatedAt skillBreakdown'),
  ]);

  const scoredAttempts = attempts.filter((attempt) => typeof attempt.scorePercentage === 'number');
  const average =
    scoredAttempts.length === 0
      ? null
      : Math.round(
          scoredAttempts.reduce((sum, attempt) => sum + (attempt.scorePercentage ?? 0), 0) /
            scoredAttempts.length,
        );
  const weakSkill = scoredAttempts
    .flatMap((attempt) => attempt.skillBreakdown)
    .filter((skill) => skill.classification === 'weakness')
    .sort((a, b) => a.percentage - b.percentage)[0];

  return {
    id: childId.toString(),
    name: child.fullName,
    username: child.username,
    email: child.email,
    avatarUrl: child.avatarUrl,
    classroom: classroom
      ? {
          id: classroom._id.toString(),
          name: classroom.name,
          gradeLevel: classroom.gradeLevel,
        }
      : null,
    average,
    attendance: null,
    pendingAssessments: 0,
    latestNote: weakSkill
      ? `Needs follow-up in ${weakSkill.mainSkill}`
      : 'No urgent academic follow-up items.',
    latestAttemptAt: scoredAttempts[0]?.submittedAt ?? scoredAttempts[0]?.updatedAt ?? null,
  };
}

export default router;
