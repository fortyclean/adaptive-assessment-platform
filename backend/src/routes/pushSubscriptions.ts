import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/authenticate';
import { PushSubscription } from '../models/PushSubscription';
import { logger } from '../utils/logger';

const router = Router();

const registerSchema = z.object({
  provider: z.enum(['onesignal', 'firebase']).default('onesignal'),
  deviceToken: z.string().min(10).max(512).trim(),
  platform: z.enum(['android', 'ios', 'web']),
});

router.post('/', authenticate, async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = registerSchema.safeParse(req.body);
    if (!validation.success) {
      res
        .status(400)
        .json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { provider, deviceToken, platform } = validation.data;
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ error: 'Authentication required.' });
      return;
    }

    const subscription = await PushSubscription.findOneAndUpdate(
      { provider, deviceToken },
      {
        $set: {
          userId,
          provider,
          deviceToken,
          platform,
          isActive: true,
        },
      },
      { new: true, upsert: true, setDefaultsOnInsert: true },
    );

    res.status(200).json({ subscription });
  } catch (error) {
    logger.error('Register push subscription error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

router.delete('/:deviceToken', authenticate, async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json({ error: 'Authentication required.' });
      return;
    }

    await PushSubscription.updateMany(
      { userId, deviceToken: req.params.deviceToken },
      { $set: { isActive: false } },
    );
    res.status(204).send();
  } catch (error) {
    logger.error('Deactivate push subscription error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
