import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { User, IUserDocument, UserRole } from '../models/User';
import { env } from '../config/env';
import { logger } from '../utils/logger';

const BCRYPT_ROUNDS = parseInt(env.BCRYPT_ROUNDS, 10);
const MAX_FAILED_ATTEMPTS = 3;
const LOCK_DURATION_MS = 15 * 60 * 1000; // 15 minutes
const MAX_CONCURRENT_SESSIONS = 2;

export interface TokenPayload {
  userId: string;
  role: UserRole;
  sessionId: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

// ─── Password Utilities ───────────────────────────────────────────────────────

export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, BCRYPT_ROUNDS);
};

export const verifyPassword = async (password: string, hash: string): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};

export const validatePasswordStrength = (password: string): { valid: boolean; message?: string } => {
  if (password.length < 8) {
    return { valid: false, message: 'Password must be at least 8 characters long' };
  }
  if (!/[A-Z]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one uppercase letter' };
  }
  if (!/[a-z]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one lowercase letter' };
  }
  if (!/[0-9]/.test(password)) {
    return { valid: false, message: 'Password must contain at least one digit' };
  }
  return { valid: true };
};

// ─── Token Utilities ──────────────────────────────────────────────────────────

export const generateTokens = (payload: TokenPayload): AuthTokens => {
  const accessToken = jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: env.JWT_EXPIRES_IN as unknown as number,
  });

  const refreshSecret = env.JWT_REFRESH_SECRET || env.JWT_SECRET;
  const refreshToken = jwt.sign(payload, refreshSecret, {
    expiresIn: env.JWT_REFRESH_EXPIRES_IN as unknown as number,
  });

  return { accessToken, refreshToken };
};

export const verifyAccessToken = (token: string): TokenPayload => {
  return jwt.verify(token, env.JWT_SECRET) as TokenPayload;
};

export const verifyRefreshToken = (token: string): TokenPayload => {
  const refreshSecret = env.JWT_REFRESH_SECRET || env.JWT_SECRET;
  return jwt.verify(token, refreshSecret) as TokenPayload;
};

// ─── Login Logic ──────────────────────────────────────────────────────────────

export interface LoginResult {
  success: boolean;
  tokens?: AuthTokens;
  user?: Omit<IUserDocument, 'passwordHash'>;
  error?: string;
  lockedUntil?: Date;
}

export const loginUser = async (
  username: string,
  password: string,
  ipAddress: string,
): Promise<LoginResult> => {
  const user = await User.findOne({ username: username.toLowerCase().trim() })
    .select('+passwordHash +failedLoginAttempts +lockedUntil +activeSessions') as IUserDocument | null;

  if (!user) {
    // Return generic error to prevent username enumeration
    return { success: false, error: 'Invalid credentials' };
  }

  // Check if account is active
  if (!user.isActive) {
    return { success: false, error: 'Account has been deactivated. Please contact your administrator.' };
  }

  // Check if account is locked
  if (user.lockedUntil && user.lockedUntil > new Date()) {
    logger.warn('Login attempt on locked account', { username, ipAddress });
    return {
      success: false,
      error: `Account is locked. Please try again after ${user.lockedUntil.toISOString()}`,
      lockedUntil: user.lockedUntil,
    };
  }

  // Verify password
  const isPasswordValid = await verifyPassword(password, user.passwordHash);

  if (!isPasswordValid) {
    // Increment failed attempts
    user.failedLoginAttempts = (user.failedLoginAttempts || 0) + 1;

    if (user.failedLoginAttempts >= MAX_FAILED_ATTEMPTS) {
      user.lockedUntil = new Date(Date.now() + LOCK_DURATION_MS);
      logger.warn('Account locked after failed attempts', {
        username,
        ipAddress,
        attempts: user.failedLoginAttempts,
      });
    }

    await user.save();

    logger.warn('Failed login attempt', {
      username,
      ipAddress,
      failedAttempts: user.failedLoginAttempts,
    });

    return { success: false, error: 'Invalid credentials' };
  }

  // Reset failed attempts on successful login
  user.failedLoginAttempts = 0;
  user.lockedUntil = undefined;

  // Generate session ID
  const sessionId = `${user._id}-${Date.now()}-${Math.random().toString(36).substring(7)}`;

  // Enforce max concurrent sessions (max 2 devices)
  if (user.activeSessions.length >= MAX_CONCURRENT_SESSIONS) {
    // Remove oldest session
    user.activeSessions.shift();
    logger.info('Oldest session invalidated due to concurrent session limit', { userId: user._id });
  }

  user.activeSessions.push(sessionId);
  user.lastLoginAt = new Date();
  await user.save();

  const tokens = generateTokens({
    userId: user._id.toString(),
    role: user.role,
    sessionId,
  });

  logger.info('User logged in successfully', { userId: user._id, role: user.role, ipAddress });

  return { success: true, tokens, user };
};

// ─── Logout Logic ─────────────────────────────────────────────────────────────

export const logoutUser = async (userId: string, sessionId: string): Promise<void> => {
  await User.findByIdAndUpdate(userId, {
    $pull: { activeSessions: sessionId },
  });
  logger.info('User logged out', { userId, sessionId });
};

// ─── Invalidate All Sessions ──────────────────────────────────────────────────

export const invalidateAllSessions = async (userId: string): Promise<void> => {
  await User.findByIdAndUpdate(userId, { activeSessions: [] });
  logger.info('All sessions invalidated', { userId });
};

// ─── Generate OTP Password ────────────────────────────────────────────────────

export const generateOTP = (): string => {
  return Math.random().toString(36).substring(2, 10).toUpperCase();
};
