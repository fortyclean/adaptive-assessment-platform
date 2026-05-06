import { Router, Request, Response } from 'express';
import { z } from 'zod';
import bcrypt from 'bcrypt';
import { User } from '../models/User';
import { authenticate, authorize } from '../middleware/authenticate';
import { invalidateAllSessions, hashPassword, validatePasswordStrength } from '../services/authService';
import { logger } from '../utils/logger';
import { env } from '../config/env';

const router = Router();

// All user routes require authentication
router.use(authenticate);

// ─── Validation Schemas ───────────────────────────────────────────────────────

const createUserSchema = z.object({
  username: z.string().min(3).max(50).trim().toLowerCase(),
  email: z.string().email().trim().toLowerCase(),
  fullName: z.string().min(2).max(100).trim(),
  role: z.enum(['teacher', 'student']),
  password: z.string().min(8).optional(),
  classroomIds: z.array(z.string()).optional(),
});

const updateUserSchema = z.object({
  email: z.string().email().trim().toLowerCase().optional(),
  fullName: z.string().min(2).max(100).trim().optional(),
  classroomIds: z.array(z.string()).optional(),
});

const paginationSchema = z.object({
  page: z.string().default('1').transform(Number),
  limit: z.string().default('20').transform(Number),
  role: z.enum(['admin', 'teacher', 'student']).optional(),
  search: z.string().optional(),
  isActive: z.string().optional().transform((v) => (v === 'true' ? true : v === 'false' ? false : undefined)),
});

// ─── GET /api/v1/users ────────────────────────────────────────────────────────

router.get('/', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const query = paginationSchema.safeParse(req.query);
    if (!query.success) {
      res.status(400).json({ error: 'Invalid query parameters' });
      return;
    }

    const { page, limit, role, search, isActive } = query.data;
    const skip = (page - 1) * limit;

    const filter: Record<string, unknown> = {};
    if (role) filter.role = role;
    if (isActive !== undefined) filter.isActive = isActive;
    if (search) {
      filter.$or = [
        { username: { $regex: search, $options: 'i' } },
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const [users, total] = await Promise.all([
      User.find(filter).skip(skip).limit(limit).sort({ createdAt: -1 }),
      User.countDocuments(filter),
    ]);

    res.status(200).json({
      users,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    logger.error('Get users error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/users ───────────────────────────────────────────────────────

router.post('/', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = createUserSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { username, email, fullName, role, password, classroomIds } = validation.data;

    // Check for existing username
    const existing = await User.findOne({ $or: [{ username }, { email }] });
    if (existing) {
      res.status(409).json({ error: 'Username or email already exists' });
      return;
    }

    // Generate or validate password
    let finalPassword = password;
    if (!finalPassword) {
      // Auto-generate OTP for new accounts
      finalPassword = Math.random().toString(36).substring(2, 10).toUpperCase();
    }

    const strengthCheck = validatePasswordStrength(finalPassword);
    if (!strengthCheck.valid) {
      res.status(400).json({ error: strengthCheck.message });
      return;
    }

    const passwordHash = await hashPassword(finalPassword);

    const user = new User({
      username,
      email,
      fullName,
      role,
      passwordHash,
      classroomIds: classroomIds || [],
      isActive: true,
    });

    await user.save();

    logger.info('User created by admin', {
      adminId: req.user!.userId,
      newUserId: user._id,
      role,
    });

    // In production, send OTP via email
    const response: Record<string, unknown> = {
      message: `${role === 'teacher' ? 'Teacher' : 'Student'} account created successfully`,
      user,
    };

    if (process.env.NODE_ENV === 'development') {
      response.temporaryPassword = finalPassword;
    }

    res.status(201).json(response);
  } catch (error) {
    logger.error('Create user error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/users/:id ────────────────────────────────────────────────────

router.get('/:id', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }
    res.status(200).json({ user });
  } catch (error) {
    logger.error('Get user error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/users/:id ──────────────────────────────────────────────────

router.patch('/:id', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = updateUserSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const user = await User.findByIdAndUpdate(req.params.id, validation.data, { new: true, runValidators: true });
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }

    logger.info('User updated by admin', { adminId: req.user!.userId, targetUserId: req.params.id });
    res.status(200).json({ user });
  } catch (error) {
    logger.error('Update user error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/users/:id/deactivate ──────────────────────────────────────

router.patch('/:id/deactivate', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }

    if (user._id.toString() === req.user!.userId) {
      res.status(400).json({ error: 'You cannot deactivate your own account' });
      return;
    }

    // Immediately invalidate all active sessions (within 30 seconds per requirement 1.10)
    await invalidateAllSessions(req.params.id);

    user.isActive = false;
    await user.save();

    logger.info('User deactivated by admin', {
      adminId: req.user!.userId,
      targetUserId: req.params.id,
      role: user.role,
    });

    res.status(200).json({ message: 'Account deactivated successfully. All active sessions have been invalidated.' });
  } catch (error) {
    logger.error('Deactivate user error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/users/:id/reactivate ──────────────────────────────────────

router.patch('/:id/reactivate', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isActive: true, failedLoginAttempts: 0, lockedUntil: null },
      { new: true },
    );

    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }

    logger.info('User reactivated by admin', { adminId: req.user!.userId, targetUserId: req.params.id });
    res.status(200).json({ message: 'Account reactivated successfully', user });
  } catch (error) {
    logger.error('Reactivate user error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
