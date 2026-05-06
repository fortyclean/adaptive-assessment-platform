/**
 * Audit Logger Service
 *
 * Logs Admin-level actions, login events, and server errors.
 * Requirements: 12.7, 12.11, 13.5
 *
 * Login events are stored in-memory (last 100) and also written to the
 * application logger. In production, these would be persisted to a
 * dedicated audit collection in MongoDB.
 */

import { logger } from '../utils/logger';

// ─── Types ────────────────────────────────────────────────────────────────────

export type AdminAction =
  | 'user_created'
  | 'user_deactivated'
  | 'user_password_reset'
  | 'classroom_created'
  | 'classroom_updated'
  | 'classroom_deleted'
  | 'student_assigned'
  | 'teacher_assigned';

export interface LoginEvent {
  userId: string;
  username: string;
  role: string;
  ip: string;
  timestamp: Date;
  success: boolean;
  reason?: string;
}

export interface AdminAuditEvent {
  adminId: string;
  adminUsername: string;
  action: AdminAction;
  targetId?: string;
  targetType?: string;
  details?: Record<string, unknown>;
  timestamp: Date;
  ip: string;
}

// ─── In-memory login event ring buffer (last 100) ─────────────────────────────

const MAX_LOGIN_EVENTS = 100;
const loginEvents: LoginEvent[] = [];

// ─── Login Event Logging (Req 13.5) ──────────────────────────────────────────

export function logLoginEvent(event: Omit<LoginEvent, 'timestamp'>): void {
  const entry: LoginEvent = { ...event, timestamp: new Date() };

  // Maintain ring buffer of last 100 events
  if (loginEvents.length >= MAX_LOGIN_EVENTS) {
    loginEvents.shift();
  }
  loginEvents.push(entry);

  logger.info('Login event', {
    userId: entry.userId,
    username: entry.username,
    role: entry.role,
    ip: entry.ip,
    success: entry.success,
    reason: entry.reason,
  });
}

export function getLoginEvents(): LoginEvent[] {
  return [...loginEvents].reverse(); // most recent first
}

// ─── Admin Action Logging (Req 12.7) ─────────────────────────────────────────

export function logAdminAction(event: Omit<AdminAuditEvent, 'timestamp'>): void {
  const entry: AdminAuditEvent = { ...event, timestamp: new Date() };

  logger.info('Admin action', {
    adminId: entry.adminId,
    adminUsername: entry.adminUsername,
    action: entry.action,
    targetId: entry.targetId,
    targetType: entry.targetType,
    details: entry.details,
    ip: entry.ip,
  });
}

// ─── Server Error Logging (Req 12.11) ────────────────────────────────────────

export function logServerError(
  requestId: string,
  error: Error,
  context?: Record<string, unknown>,
): void {
  logger.error('Server error', {
    requestId,
    message: error.message,
    stack: error.stack,
    timestamp: new Date().toISOString(),
    ...context,
  });
}
