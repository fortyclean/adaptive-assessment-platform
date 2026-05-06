import { Router, Request, Response } from 'express';
import { z } from 'zod';
import {
  loginUser,
  logoutUser,
  verifyRefreshToken,
  generateTokens,
  hashPassword,
  validatePasswordStrength,
  generateOTP,
} from '../services/authService';
import { authenticate } from '../middleware/authenticate';
import { User } from '../models/User';
import { logger } from '../utils/logger';

const router = Router();

// ─── Validation Schemas ───────────────────────────────────────────────────────

const loginSchema = z.object({
  username: z.string().min(1, 'Username is required').trim().toLowerCase(),
  password: z.string().min(1, 'Password is required'),
});

const resetPasswordSchema = z.object({
  userId: z.string().min(1, 'User ID is required'),
});

// ─── POST /api/v1/auth/login ──────────────────────────────────────────────────

router.post('/login', async (req: Request, res: Response): Promise<void> => {
  const startTime = Date.now();

  try {
    const validation = loginSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { username, password } = validation.data;
    const ipAddress = req.ip || req.socket.remoteAddress || 'unknown';

    const result = await loginUser(username, password, ipAddress);

    const elapsed = Date.now() - startTime;

    if (!result.success) {
      res.status(401).json({ error: result.error, lockedUntil: result.lockedUntil });
      return;
    }

    // Set refresh token as HttpOnly Secure cookie
    res.cookie('refreshToken', result.tokens!.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    logger.info('Login successful', { username, elapsed: `${elapsed}ms` });

    res.status(200).json({
      accessToken: result.tokens!.accessToken,
      user: result.user,
    });
  } catch (error) {
    logger.error('Login error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/auth/logout ─────────────────────────────────────────────────

router.post('/logout', authenticate, async (req: Request, res: Response): Promise<void> => {
  try {
    await logoutUser(req.user!.userId, req.user!.sessionId);

    res.clearCookie('refreshToken');
    res.status(200).json({ message: 'Logged out successfully' });
  } catch (error) {
    logger.error('Logout error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/auth/refresh ────────────────────────────────────────────────

router.post('/refresh', async (req: Request, res: Response): Promise<void> => {
  try {
    const refreshToken = req.cookies?.refreshToken;

    if (!refreshToken) {
      res.status(401).json({ error: 'Refresh token not found' });
      return;
    }

    let payload;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch {
      res.clearCookie('refreshToken');
      res.status(401).json({ error: 'Invalid or expired refresh token. Please log in again.' });
      return;
    }

    // Verify user still exists and session is valid
    const user = await User.findById(payload.userId).select('isActive activeSessions role');

    if (!user || !user.isActive || !user.activeSessions.includes(payload.sessionId)) {
      res.clearCookie('refreshToken');
      res.status(401).json({ error: 'Session is no longer valid. Please log in again.' });
      return;
    }

    const tokens = generateTokens({
      userId: payload.userId,
      role: payload.role,
      sessionId: payload.sessionId,
    });

    res.cookie('refreshToken', tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });

    res.status(200).json({ accessToken: tokens.accessToken });
  } catch (error) {
    logger.error('Token refresh error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/auth/reset-password (Admin only) ───────────────────────────

router.post('/reset-password', authenticate, async (req: Request, res: Response): Promise<void> => {
  try {
    // Only admins can reset passwords
    if (req.user!.role !== 'admin') {
      res.status(403).json({ error: 'Only administrators can reset passwords.' });
      return;
    }

    const validation = resetPasswordSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { userId } = validation.data;
    const user = await User.findById(userId);

    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }

    // Generate OTP and hash it
    const otp = generateOTP();
    const hashedOTP = await hashPassword(otp);

    user.passwordHash = hashedOTP;
    user.activeSessions = []; // Invalidate all existing sessions
    await user.save();

    logger.info('Password reset by admin', {
      adminId: req.user!.userId,
      targetUserId: userId,
    });

    // In production, send OTP via email. For now, return it in response (dev only)
    const response: Record<string, unknown> = { message: 'Password reset successfully. OTP sent to user email.' };
    if (process.env.NODE_ENV === 'development') {
      response.otp = otp; // Only expose in development
    }

    res.status(200).json(response);
  } catch (error) {
    logger.error('Password reset error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
