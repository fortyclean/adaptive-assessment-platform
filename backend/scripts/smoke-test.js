#!/usr/bin/env node

const DEFAULT_BASE_URL = 'https://eduassess-backend-8cf4.onrender.com/api/v1';

const baseUrl = (process.env.BASE_URL || DEFAULT_BASE_URL).replace(/\/$/, '');

const accounts = [
  {
    label: 'admin',
    username: process.env.ADMIN_USER || 'admin',
    password: process.env.ADMIN_PASSWORD || 'Admin@123',
  },
  {
    label: 'teacher',
    username: process.env.TEACHER_USER || 'teacher',
    password: process.env.TEACHER_PASSWORD || 'Teacher@123',
  },
  {
    label: 'student',
    username: process.env.STUDENT_USER || 'student',
    password: process.env.STUDENT_PASSWORD || 'Student@123',
  },
];

async function request(path, options = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: {
      'content-type': 'application/json',
      ...(options.headers || {}),
    },
  });

  const text = await response.text();
  let body = {};
  if (text) {
    try {
      body = JSON.parse(text);
    } catch {
      body = { raw: text };
    }
  }

  if (!response.ok) {
    const message = body.error || body.message || response.statusText;
    throw new Error(`${path} failed with ${response.status}: ${message}`);
  }

  return body;
}

async function login(account) {
  const body = await request('/auth/login', {
    method: 'POST',
    body: JSON.stringify({
      username: account.username,
      password: account.password,
    }),
  });

  if (!body.accessToken || !body.refreshToken) {
    throw new Error(`${account.label} login did not return tokens`);
  }

  return body;
}

async function main() {
  console.log(`Smoke test target: ${baseUrl}`);

  await request('/health');
  console.log('OK health');

  const sessions = {};
  for (const account of accounts) {
    sessions[account.label] = await login(account);
    console.log(`OK login ${account.label}`);
  }

  const refreshed = await request('/auth/refresh', {
    method: 'POST',
    headers: { 'x-client-platform': 'mobile' },
    body: JSON.stringify({ refreshToken: sessions.admin.refreshToken }),
  });
  if (!refreshed.accessToken) {
    throw new Error('refresh did not return a new access token');
  }
  console.log('OK refresh');

  const authHeaders = {
    authorization: `Bearer ${sessions.admin.accessToken}`,
  };

  await request('/users?limit=1', { headers: authHeaders });
  console.log('OK users');

  await request('/classrooms', { headers: authHeaders });
  console.log('OK classrooms');

  await request('/reports/school', { headers: authHeaders });
  console.log('OK school reports');

  console.log('Smoke test passed');
}

main().catch((error) => {
  console.error(`Smoke test failed: ${error.message}`);
  process.exitCode = 1;
});
