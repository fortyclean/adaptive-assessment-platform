import express from 'express';
import jwt from 'jsonwebtoken';
import request from 'supertest';
import { app } from '../../src/app';
import { apiRateLimiter } from '../../src/middleware/rateLimiter';
import { errorHandler, notFoundHandler } from '../../src/middleware/errorHandler';
import { generateTokens } from '../../src/services/authService';

const activeSessions = new Set<string>();

jest.mock('../../src/utils/logger', () => ({
  logger: {
    debug: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

jest.mock('../../src/models/User', () => ({
  User: {
    findById: jest.fn((id: string) => ({
      select: jest.fn(async () => ({
        _id: id,
        role: id.includes('teacher')
          ? 'teacher'
          : id.includes('admin')
            ? 'admin'
            : id.includes('parent')
              ? 'parent'
              : 'student',
        isActive: true,
        activeSessions: [...activeSessions],
        childIds: [],
      })),
    })),
  },
}));

describe('API contract smoke tests', () => {
  beforeEach(() => {
    activeSessions.clear();
  });

  function authHeader(role: 'student' | 'teacher' | 'admin' | 'parent' = 'student') {
    const sessionId = `${role}-session`;
    activeSessions.add(sessionId);
    const { accessToken, refreshToken } = generateTokens({
      userId: `${role}-user`,
      role,
      sessionId,
    });

    return {
      accessToken,
      refreshToken,
      authorization: `Bearer ${accessToken}`,
    };
  }

  it('exposes health without authentication and keeps core domain routes mounted', async () => {
    const health = await request(app).get('/api/v1/health');
    expect([200, 503]).toContain(health.status);
    expect(health.body).toHaveProperty('status');

    for (const path of [
      '/api/v1/assessments',
      '/api/v1/attempts',
      '/api/v1/reports/school',
      '/api/v1/parents/me/children',
    ]) {
      const response = await request(app).get(path);
      expect(response.status).toBe(401);
      expect(response.body.error).toContain('Authentication required');
    }

    const notifications = await request(app).get('/api/v1/notifications');
    expect(notifications.status).toBe(401);
  });

  it('returns 401 for invalid and expired-token style access attempts', async () => {
    const response = await request(app)
      .get('/api/v1/assessments')
      .set('Authorization', 'Bearer invalid.token.value');

    expect(response.status).toBe(401);
    expect(response.body.error).toContain('Invalid or expired token');

    const expiredToken = jwt.sign(
      { userId: 'student-user', role: 'student', sessionId: 'student-session' },
      process.env.JWT_SECRET ?? 'test_jwt_secret_for_testing_only',
      { expiresIn: '-1s' },
    );

    const expiredResponse = await request(app)
      .get('/api/v1/assessments')
      .set('Authorization', `Bearer ${expiredToken}`);

    expect(expiredResponse.status).toBe(401);
    expect(expiredResponse.body.error).toContain('Invalid or expired token');
  });

  it('returns 403 when an authenticated role reaches a forbidden contract', async () => {
    const { authorization } = authHeader('student');

    const response = await request(app)
      .post('/api/v1/assessments')
      .set('Authorization', authorization)
      .send({});

    expect(response.status).toBe(403);
    expect(response.body.error).toContain('permission');
  });

  it('protects parent portal contracts behind the parent role', async () => {
    const student = authHeader('student');
    await request(app)
      .get('/api/v1/parents/me/children')
      .set('Authorization', student.authorization)
      .expect(403);

    const parent = authHeader('parent');
    await request(app)
      .get('/api/v1/parents/me/children')
      .set('Authorization', parent.authorization)
      .expect(200)
      .expect((response) => {
        expect(response.body.children).toEqual([]);
      });
  });

  it('refreshes mobile sessions from a body refresh token', async () => {
    const { refreshToken } = authHeader('student');

    const response = await request(app)
      .post('/api/v1/auth/refresh')
      .set('X-Client-Platform', 'mobile')
      .send({ refreshToken });

    expect(response.status).toBe(200);
    expect(response.body.accessToken).toEqual(expect.any(String));
    expect(response.body.refreshToken).toEqual(expect.any(String));
  });

  it('rejects missing and malformed refresh token contracts', async () => {
    await request(app)
      .post('/api/v1/auth/refresh')
      .send({})
      .expect(401)
      .expect((response) => {
        expect(response.body.error).toContain('Refresh token not found');
      });

    await request(app)
      .post('/api/v1/auth/refresh')
      .set('X-Client-Platform', 'mobile')
      .send({ refreshToken: 'invalid.refresh.token' })
      .expect(401)
      .expect((response) => {
        expect(response.body.error).toContain('Invalid or expired refresh token');
      });
  });

  it('applies CORS contracts for an allowed origin without enabling credentials for wildcard config', async () => {
    const response = await request(app)
      .options('/api/v1/health')
      .set('Origin', 'https://school.example')
      .set('Access-Control-Request-Method', 'GET');

    expect(response.status).toBe(204);
    expect(response.headers['access-control-allow-origin']).toBe('https://school.example');
    expect(response.headers['access-control-allow-credentials']).toBeUndefined();
  });

  it('returns consistent 404 for unknown routes', async () => {
    const response = await request(app).get('/api/v1/does-not-exist');

    expect(response.status).toBe(404);
    expect(response.body).toMatchObject({
      success: false,
      message: expect.stringContaining('Route GET /api/v1/does-not-exist not found'),
    });
  });

  it('returns 429 through the shared rate-limit error contract', async () => {
    const limitedApp = express();
    limitedApp.use(apiRateLimiter);
    limitedApp.get('/limited', (_req, res) => res.status(200).json({ ok: true }));
    limitedApp.use(notFoundHandler);
    limitedApp.use(errorHandler);

    const requests = Array.from({ length: 105 }, () => request(limitedApp).get('/limited'));
    const responses = await Promise.all(requests);

    expect(responses.some((response) => response.status === 429)).toBe(true);
    const limitedResponse = responses.find((response) => response.status === 429);
    expect(limitedResponse?.body).toMatchObject({
      success: false,
      message: expect.stringContaining('Rate limit exceeded'),
    });
  });

  it('returns a sanitized 500 through the shared error contract', async () => {
    const failingApp = express();
    failingApp.get('/boom', () => {
      throw new Error('Sensitive implementation detail');
    });
    failingApp.use(notFoundHandler);
    failingApp.use(errorHandler);

    const response = await request(failingApp).get('/boom');

    expect(response.status).toBe(500);
    expect(response.body).toMatchObject({
      success: false,
      message: 'An internal server error occurred',
      requestId: expect.any(String),
    });
    expect(JSON.stringify(response.body)).not.toContain('Sensitive implementation detail');
  });
});
