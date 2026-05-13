import { Router, Request, Response } from 'express';
import { z } from 'zod';
import {
  InstitutionSettings,
  IInstitutionSettingsDocument,
} from '../models/InstitutionSettings';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

const institutionSettingsSchema = z.object({
  schoolName: z.string().trim().min(1).max(120).optional(),
  schoolPhone: z.string().trim().max(40).optional(),
  schoolEmail: z.string().trim().email().max(120).optional(),
  academicYear: z.string().trim().min(1).max(40).optional(),
  term: z.string().trim().min(1).max(80).optional(),
  gradeScale: z.string().trim().min(1).max(120).optional(),
  language: z.string().trim().min(1).max(40).optional(),
  timezone: z.string().trim().min(1).max(80).optional(),
  emailNotifications: z.boolean().optional(),
  pushNotifications: z.boolean().optional(),
  weeklyDigest: z.boolean().optional(),
  sisIntegration: z.boolean().optional(),
  lmsIntegration: z.boolean().optional(),
});

async function getOrCreateSettings(): Promise<IInstitutionSettingsDocument> {
  const existing = await InstitutionSettings.findOne({ key: 'default' });
  if (existing) {
    return existing;
  }

  return InstitutionSettings.create({ key: 'default' });
}

router.get('/', authorize('admin'), async (_req: Request, res: Response) => {
  try {
    const settings = await getOrCreateSettings();
    res.status(200).json({ settings });
  } catch (error) {
    logger.error('Institution settings load error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

router.patch('/', authorize('admin'), async (req: Request, res: Response) => {
  try {
    const parsed = institutionSettingsSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({
        error: 'Invalid institution settings data',
        details: parsed.error.flatten(),
      });
      return;
    }

    const settings = await InstitutionSettings.findOneAndUpdate(
      { key: 'default' },
      {
        $set: {
          ...parsed.data,
          key: 'default',
          updatedBy: req.user?.userId,
        },
      },
      { new: true, upsert: true, setDefaultsOnInsert: true },
    );

    res.status(200).json({ settings });
  } catch (error) {
    logger.error('Institution settings update error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
