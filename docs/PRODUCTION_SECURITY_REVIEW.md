# Production Security Review

Version: 1.0.72

## CORS Review

Current implementation:

- Source: `backend/src/app.ts`
- Environment variables: `CORS_ORIGIN` or `ALLOWED_ORIGINS`
- Multiple origins are supported as a comma-separated list.
- Wildcard CORS (`*`) disables credentials for safety.
- Production wildcard usage logs a warning.

Release requirement:

- Production must use explicit HTTPS origins.
- Do not use wildcard CORS for a public production API.
- Example:

```env
ALLOWED_ORIGINS=https://app.adaptivemastery.app,https://admin.adaptivemastery.app
```

Verification:

1. Deploy with explicit `ALLOWED_ORIGINS`.
2. Send a request from an allowed origin and confirm success.
3. Send a request from an untrusted origin and confirm it is blocked.
4. Confirm no cookies or credentials are allowed when wildcard CORS is configured.

## Rate Limit Review

Current implementation:

- Source: `backend/src/middleware/rateLimiter.ts`
- General API limiter uses `config.rateLimit.windowMs` and `config.rateLimit.max`.
- Auth limiter uses 10 requests per 15 minutes.
- Health checks are skipped by the general limiter.
- Rate-limit headers use modern standard headers and disable legacy headers.

Release requirement:

- Keep auth limiter stricter than general API traffic.
- Tune general limits per deployment capacity.
- Add monitoring for repeated limit hits by IP/user/session.
- Do not expose internal stack traces when limits are hit.

Suggested production values:

```env
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=100
```

High-risk endpoints that should remain guarded:

- `/api/v1/auth/login`
- `/api/v1/auth/refresh`
- `/api/v1/auth/reset-password`
- `/api/v1/users`
- `/api/v1/classrooms`
- `/api/v1/questions/import`
- `/api/v1/attempts`
- `/api/v1/reports`
