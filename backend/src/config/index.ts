import dotenv from 'dotenv';
import path from 'path';

// Load environment variables
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

export const config = {
  app: {
    env: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '3000', 10),
    isDevelopment: process.env.NODE_ENV === 'development',
    isProduction: process.env.NODE_ENV === 'production',
    isTest: process.env.NODE_ENV === 'test',
  },
  mongodb: {
    uri: process.env.MONGODB_URI || 'mongodb://localhost:27017/adaptive_assessment',
    options: {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    },
  },
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
    ttl: {
      questions: 3600,        // 1 hour
      assessment: 86400,      // 24 hours
      userSession: 28800,     // 8 hours
      classroomStudents: 1800, // 30 minutes
    },
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'fallback_dev_secret_change_in_production',
    expiresIn: process.env.JWT_EXPIRES_IN || '8h',
    refreshSecret: process.env.REFRESH_TOKEN_SECRET || 'fallback_refresh_secret_change_in_production',
    refreshExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
  },
  bcrypt: {
    saltRounds: 12,
  },
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10),
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },
  aws: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
    s3Bucket: process.env.AWS_S3_BUCKET || '',
    region: process.env.AWS_REGION || 'us-east-1',
  },
  email: {
    host: process.env.SMTP_HOST || '',
    port: parseInt(process.env.SMTP_PORT || '587', 10),
    user: process.env.SMTP_USER || '',
    pass: process.env.SMTP_PASS || '',
    from: process.env.EMAIL_FROM || 'noreply@adaptive-assessment.com',
  },
  encryption: {
    key: process.env.ENCRYPTION_KEY || '',
  },
  auth: {
    maxLoginAttempts: 3,
    lockoutDurationMs: 15 * 60 * 1000, // 15 minutes
    maxConcurrentSessions: 2,
  },
  pagination: {
    defaultLimit: 20,
    maxLimit: 100,
  },
};

export type Config = typeof config;
