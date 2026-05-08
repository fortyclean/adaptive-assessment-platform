/**
 * Performance Alerts Routes
 *
 * POST /api/v1/alerts/performance  — Trigger alert detection for the authenticated teacher
 * GET  /api/v1/alerts              — List active performance alerts for the authenticated teacher
 *
 * Screen: 36
 */

import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { authenticate, authorize } from '../middleware/authenticate';
import { detectPerformanceAlerts, getActiveAlertsForTeacher } from '../services/alertService';
import { sendSuccess, sendCreated, sendError } from '../utils/apiResponse';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// ─── POST /api/v1/alerts/performance — Trigger alert detection ───────────────

router.post(
  '/performance',
  authorize('teacher', 'admin'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const teacherId = new mongoose.Types.ObjectId(req.user!.userId);

      const result = await detectPerformanceAlerts(teacherId);

      sendCreated(res, result, 'Performance alert check completed');
    } catch (error) {
      logger.error('Performance alert detection error', { error });
      sendError(res, 'An internal server error occurred', 500, String(error));
    }
  },
);

// ─── GET /api/v1/alerts — List active alerts for the teacher ─────────────────

router.get(
  '/',
  authorize('teacher', 'admin'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const teacherId = new mongoose.Types.ObjectId(req.user!.userId);

      const alerts = await getActiveAlertsForTeacher(teacherId);

      sendSuccess(res, alerts, `${alerts.length} active performance alert(s)`);
    } catch (error) {
      logger.error('Get performance alerts error', { error });
      sendError(res, 'An internal server error occurred', 500, String(error));
    }
  },
);

export default router;
