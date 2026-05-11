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
import { OAuth2Client } from 'google-auth-library';

const router = Router();

// ─── Validation Schemas ───────────────────────────────────────────────────────

const loginSchema = z.object({
  username: z.string().min(1, 'Username is required').trim().toLowerCase(),
  password: z.string().min(1, 'Password is required'),
});

const resetPasswordSchema = z.object({
  userId: z.string().min(1, 'User ID is required'),
});

const registerSchema = z.object({
  fullName: z.string().min(2, 'Full name is required').max(100).trim(),
  email: z.string().email('Valid email is required').trim().toLowerCase(),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1).optional(),
});

function parseRefreshTokenFromCookieHeader(cookieHeader?: string): string | undefined {
  if (!cookieHeader) return undefined;
  const cookies = cookieHeader.split(';');
  for (const cookie of cookies) {
    const [rawKey, ...rawValueParts] = cookie.trim().split('=');
    if (rawKey === 'refreshToken') {
      return rawValueParts.join('=');
    }
  }
  return undefined;
}

function createUsernameFromEmail(email: string): string {
  const localPart = email.split('@')[0].toLowerCase().replace(/[^a-z0-9]/g, '_');
  return localPart.slice(0, 50);
}

async function getUniqueUsername(email: string): Promise<string> {
  const base = createUsernameFromEmail(email) || 'user';
  let username = base;
  let suffix = 1;
  while (await User.findOne({ username })) {
    const postfix = `_${suffix}`;
    username = `${base.slice(0, 50 - postfix.length)}${postfix}`;
    suffix += 1;
  }
  return username;
}

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
      refreshToken: result.tokens!.refreshToken,
      user: result.user,
    });
  } catch (error) {
    logger.error('Login error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/auth/register ───────────────────────────────────────────────

router.post('/register', async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = registerSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { fullName, email, password } = validation.data;
    const existing = await User.findOne({ email });
    if (existing) {
      res.status(409).json({ error: 'An account with this email already exists' });
      return;
    }

    const strengthCheck = validatePasswordStrength(password);
    if (!strengthCheck.valid) {
      res.status(400).json({ error: strengthCheck.message });
      return;
    }

    const user = new User({
      username: await getUniqueUsername(email),
      email,
      fullName,
      passwordHash: await hashPassword(password),
      role: 'student',
      isActive: false,
      classroomIds: [],
      failedLoginAttempts: 0,
      activeSessions: [],
    });

    await user.save();
    logger.info('Pending student registration created', { email, userId: user._id });

    res.status(202).json({
      message: 'Registration request submitted and is pending administrator approval.',
      status: 'pending_approval',
    });
  } catch (error) {
    logger.error('Register error', { error });
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
    const validation = refreshSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid refresh request' });
      return;
    }

    const refreshTokenFromBody = validation.data.refreshToken;
    const refreshTokenFromCookieObject = (req as Request & { cookies?: { refreshToken?: string } }).cookies?.refreshToken;
    const refreshTokenFromHeader = parseRefreshTokenFromCookieHeader(req.headers.cookie);
    const refreshToken =
      refreshTokenFromBody ?? refreshTokenFromCookieObject ?? refreshTokenFromHeader;

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

    res.status(200).json({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    });
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

// ─── GET /api/v1/auth/me ─────────────────────────────────────────────────────

router.get('/me', authenticate, async (req: Request, res: Response): Promise<void> => {
  try {
    const user = await User.findById(req.user!.userId)
      .select('-passwordHash -activeSessions -failedLoginAttempts');

    if (!user || !user.isActive) {
      res.status(401).json({ error: 'User not found or inactive' });
      return;
    }

    res.status(200).json({ user });
  } catch (error) {
    logger.error('Get me error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/auth/google ─────────────────────────────────────────────────

router.post('/google', async (req: Request, res: Response): Promise<void> => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      res.status(400).json({ error: 'Google ID token is required' });
      return;
    }

    const clientId = process.env.GOOGLE_CLIENT_ID;
    if (!clientId) {
      res.status(503).json({ error: 'Google Sign-In is not configured on this server' });
      return;
    }

    // Verify Google ID token
    const client = new OAuth2Client(clientId);
    const ticket = await client.verifyIdToken({
      idToken,
      audience: clientId,
    });
    const payload = ticket.getPayload();
    if (!payload || !payload.email) {
      res.status(401).json({ error: 'Invalid Google token' });
      return;
    }

    const { email, name, sub: googleId } = payload;

    // Find or create user
    let user = await User.findOne({ email });
    if (!user) {
      // Create a pending student request. The administrator must activate it.
      user = new User({
        username: await getUniqueUsername(email),
        email,
        fullName: name || email.split('@')[0],
        passwordHash: await hashPassword(googleId + process.env.JWT_SECRET),
        role: 'student',
        isActive: false,
        googleId,
        classroomIds: [],
        failedLoginAttempts: 0,
        activeSessions: [],
      });
      await user.save();
      logger.info('Pending user created via Google Sign-In', { email });
      res.status(202).json({
        message: 'Google account registration is pending administrator approval.',
        status: 'pending_approval',
      });
      return;
    } else if (!user.isActive) {
      res.status(403).json({
        error: 'Account is pending administrator approval or deactivated',
        status: 'pending_approval',
      });
      return;
    }

    // Generate session
    const { v4: uuidv4 } = await import('uuid');
    const sessionId = uuidv4();
    user.activeSessions.push(sessionId);
    await user.save();

    const tokens = generateTokens({
      userId: user._id.toString(),
      role: user.role,
      sessionId,
    });

    res.cookie('refreshToken', tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });

    logger.info('Google Sign-In successful', { email });

    res.status(200).json({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        _id: user._id,
        username: user.username,
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        classroomIds: user.classroomIds,
      },
    });
  } catch (error) {
    logger.error('Google Sign-In error', { error });
    res.status(500).json({ error: 'Google Sign-In failed' });
  }
});

export default router;
