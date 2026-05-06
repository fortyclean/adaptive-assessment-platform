import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, TokenPayload } from '../services/authService';
import { User } from '../models/User';
import { UserRole } from '../models/User';
import { logger } from '../utils/logger';

// Extend Express Request to include authenticated user
declare global {
  namespace Express {
    interface Request {
      user?: TokenPayload;
    }
  }
}

// ─── Authentication Middleware ────────────────────────────────────────────────

export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Authentication required. Please provide a valid token.' });
      return;
    }

    const token = authHeader.substring(7);

    let payload: TokenPayload;
    try {
      payload = verifyAccessToken(token);
    } catch {
      res.status(401).json({ error: 'Invalid or expired token. Please log in again.' });
      return;
    }

    // Verify session is still active (not invalidated by deactivation)
    const user = await User.findById(payload.userId).select('isActive activeSessions role');

    if (!user) {
      res.status(401).json({ error: 'User not found.' });
      return;
    }

    if (!user.isActive) {
      res.status(401).json({ error: 'Account has been deactivated.' });
      return;
    }

    if (!user.activeSessions.includes(payload.sessionId)) {
      res.status(401).json({ error: 'Session has been invalidated. Please log in again.' });
      return;
    }

    req.user = payload;
    next();
  } catch (error) {
    logger.error('Authentication middleware error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
};

// ─── RBAC Authorization Middleware ────────────────────────────────────────────

export const authorize = (...allowedRoles: UserRole[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ error: 'Authentication required.' });
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      logger.warn('Unauthorized access attempt', {
        userId: req.user.userId,
        role: req.user.role,
        requiredRoles: allowedRoles,
        path: req.path,
      });
      res.status(403).json({
        error: 'You do not have permission to perform this action.',
      });
      return;
    }

    next();
  };
};
