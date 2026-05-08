/**
 * Report Schedules Routes
 *
 * POST   /api/v1/report-schedules          — Create schedule (teacher/admin)
 * GET    /api/v1/report-schedules          — List schedules for current user
 * PATCH  /api/v1/report-schedules/:id      — Update schedule
 * DELETE /api/v1/report-schedules/:id      — Delete schedule
 * PATCH  /api/v1/report-schedules/:id/toggle — Toggle isActive
 */

import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { ReportSchedule } from '../models/ReportSchedule';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// ─── POST /api/v1/report-schedules — Create schedule ─────────────────────────

router.post(
  '/',
  authorize('teacher', 'admin'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const {
        title,
        reportType,
        frequency,
        deliveryTime,
        recipients,
        fileFormat,
        classroomIds,
        isActive,
      } = req.body as {
        title?: string;
        reportType?: string;
        frequency?: string;
        deliveryTime?: string;
        recipients?: string[];
        fileFormat?: string;
        classroomIds?: string[];
        isActive?: boolean;
      };

      if (!title || !reportType || !frequency || !deliveryTime || !fileFormat) {
        res.status(400).json({
          error: 'title, reportType, frequency, deliveryTime, and fileFormat are required',
        });
        return;
      }

      if (!recipients || recipients.length === 0) {
        res.status(400).json({ error: 'At least one recipient email is required' });
        return;
      }

      const schedule = await ReportSchedule.create({
        title,
        reportType,
        frequency,
        deliveryTime,
        recipients,
        fileFormat,
        classroomIds: (classroomIds ?? []).map(
          (id) => new mongoose.Types.ObjectId(id),
        ),
        isActive: isActive ?? true,
        createdBy: new mongoose.Types.ObjectId(req.user!.userId),
      });

      res.status(201).json({ schedule });
    } catch (error) {
      logger.error('Create report schedule error', { error });
      if ((error as { name?: string }).name === 'ValidationError') {
        res.status(400).json({ error: (error as Error).message });
        return;
      }
      res.status(500).json({ error: 'An internal server error occurred' });
    }
  },
);

// ─── GET /api/v1/report-schedules — List schedules for current user ───────────

router.get(
  '/',
  authorize('teacher', 'admin'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const schedules = await ReportSchedule.find({
        createdBy: new mongoose.Types.ObjectId(req.user!.userId),
      })
        .sort({ createdAt: -1 })
        .lean();

      res.status(200).json({ schedules });
    } catch (error) {
      logger.error('List report schedules error', { error });
      res.status(500).json({ error: 'An internal server error occurred' });
    }
  },
);

// ─── PATCH /api/v1/report-schedules/:id — Update schedule ────────────────────

router.patch(
  '/:id',
  authorize('teacher', 'admin'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const schedule = await ReportSchedule.findOne({
        _id: new mongoose.Types.ObjectId(req.params.id),
        createdBy: new mongoose.Types.ObjectId(req.user!.userId),
      });

      if (!schedule) {
        res.status(404).json({ error: 'Report schedule not found' });
        return;
      }

      const allowedFields = [
        'title',
        'reportType',
        'frequency',
        'deliveryTime',
        'recipients',
        'fileFormat',
        'classroomIds',
        'isActive',
      ] as const;

      for (const field of allowedFields) {
        if (req.body[field] !== undefined) {
          if (field === 'classroomIds') {
            schedule.classroomIds = (req.body[field] as string[]).map(
              (id) => new mongoose.Types.ObjectId(id),
            );
          } else {
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            (schedule as any)[field] = req.body[field];
          }
        }
      }

      await schedule.save();
      res.status(200).json({ schedule });
    } catch (error) {
      logger.error('Update report schedule error', { error });
      if ((error as { name?: string }).name === 'ValidationError') {
        res.status(400).json({ error: (error as Error).message });
        return;
      }
      res.status(500).json({ error: 'An internal server error occurred' });
    }
  },
);

// ─── DELETE /api/v1/report-schedules/:id — Delete schedule ───────────────────

router.delete(
  '/:id',
  authorize('teacher', 'admin'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const schedule = await ReportSchedule.findOneAndDelete({
        _id: new mongoose.Types.ObjectId(req.params.id),
        createdBy: new mongoose.Types.ObjectId(req.user!.userId),
      });

      if (!schedule) {
        res.status(404).json({ error: 'Report schedule not found' });
        return;
      }

      res.status(200).json({ message: 'Report schedule deleted successfully' });
    } catch (error) {
      logger.error('Delete report schedule error', { error });
      res.status(500).json({ error: 'An internal server error occurred' });
    }
  },
);

// ─── PATCH /api/v1/report-schedules/:id/toggle — Toggle isActive ─────────────

router.patch(
  '/:id/toggle',
  authorize('teacher', 'admin'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const schedule = await ReportSchedule.findOne({
        _id: new mongoose.Types.ObjectId(req.params.id),
        createdBy: new mongoose.Types.ObjectId(req.user!.userId),
      });

      if (!schedule) {
        res.status(404).json({ error: 'Report schedule not found' });
        return;
      }

      schedule.isActive = !schedule.isActive;
      await schedule.save();

      res.status(200).json({ schedule });
    } catch (error) {
      logger.error('Toggle report schedule error', { error });
      res.status(500).json({ error: 'An internal server error occurred' });
    }
  },
);

export default router;
