import Redis from 'ioredis';
import { config } from './index';
import { logger } from '../utils/logger';

let redisClient: Redis | null = null;

export function getRedisClient(): Redis | null {
  return redisClient;
}

export async function connectRedis(): Promise<Redis> {
  if (redisClient) {
    logger.info('Redis already connected');
    return redisClient;
  }

  return new Promise((resolve) => {
    const client = new Redis(config.redis.url, {
      maxRetriesPerRequest: 3,
      enableReadyCheck: true,
      lazyConnect: false,
      retryStrategy(times) {
        // Stop retrying after 5 attempts in production to avoid blocking startup
        if (times > 5) {
          logger.warn('Redis max retries reached — running without cache');
          return null; // stop retrying
        }
        return Math.min(times * 200, 2000);
      },
    });

    client.on('connect', () => {
      logger.info('Redis connecting...');
    });

    client.on('ready', () => {
      redisClient = client;
      logger.info('Redis connected and ready');
      resolve(client);
    });

    client.on('error', (error) => {
      logger.warn('Redis connection error — app will run without cache', { message: (error as Error).message });
      // Resolve anyway so the app starts — Redis is optional for basic functionality
      if (!redisClient) {
        resolve(client);
      }
    });

    client.on('close', () => {
      logger.warn('Redis connection closed');
    });

    client.on('reconnecting', () => {
      logger.info('Redis reconnecting...');
    });

    // Timeout: if Redis doesn't connect in 5s, continue without it
    setTimeout(() => {
      if (!redisClient) {
        logger.warn('Redis connection timeout — starting without cache');
        resolve(client);
      }
    }, 5000);
  });
}

export async function disconnectRedis(): Promise<void> {
  if (!redisClient) return;

  try {
    await redisClient.quit();
    redisClient = null;
    logger.info('Redis disconnected gracefully');
  } catch (error) {
    logger.error('Error disconnecting from Redis', { error });
    throw error;
  }
}

export function getRedisStatus(): { connected: boolean } {
  return {
    connected: redisClient?.status === 'ready',
  };
}

// Cache helper utilities — gracefully degrade when Redis is unavailable
export const cache = {
  async get<T>(key: string): Promise<T | null> {
    const client = getRedisClient();
    if (!client || client.status !== 'ready') return null;
    try {
      const value = await client.get(key);
      if (!value) return null;
      return JSON.parse(value) as T;
    } catch {
      return null;
    }
  },

  async set(key: string, value: unknown, ttlSeconds?: number): Promise<void> {
    const client = getRedisClient();
    if (!client || client.status !== 'ready') return;
    try {
      const serialized = JSON.stringify(value);
      if (ttlSeconds) {
        await client.setex(key, ttlSeconds, serialized);
      } else {
        await client.set(key, serialized);
      }
    } catch {
      // ignore cache write errors
    }
  },

  async del(key: string): Promise<void> {
    const client = getRedisClient();
    if (!client || client.status !== 'ready') return;
    try {
      await client.del(key);
    } catch {
      // ignore
    }
  },

  async delPattern(pattern: string): Promise<void> {
    const client = getRedisClient();
    if (!client || client.status !== 'ready') return;
    try {
      const keys = await client.keys(pattern);
      if (keys.length > 0) {
        await client.del(...keys);
      }
    } catch {
      // ignore
    }
  },

  buildKey: {
    questions: (subject: string, unit: string, difficulty: string) =>
      `questions:${subject}:${unit}:${difficulty}`,
    assessment: (id: string) => `assessment:${id}:questions`,
    userSession: (userId: string) => `user:${userId}:session`,
    classroomStudents: (classroomId: string) => `classroom:${classroomId}:students`,
    sessionState: (attemptId: string) => `session:${attemptId}:state`,
  },
};
