import Redis from 'ioredis';
import { config } from './index';
import { logger } from '../utils/logger';

let redisClient: Redis | null = null;

export function getRedisClient(): Redis {
  if (!redisClient) {
    throw new Error('Redis client not initialized. Call connectRedis() first.');
  }
  return redisClient;
}

export async function connectRedis(): Promise<Redis> {
  if (redisClient) {
    logger.info('Redis already connected');
    return redisClient;
  }

  return new Promise((resolve, reject) => {
    const client = new Redis(config.redis.url, {
      maxRetriesPerRequest: 3,
      enableReadyCheck: true,
      lazyConnect: false,
      retryStrategy(times) {
        const delay = Math.min(times * 50, 2000);
        return delay;
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
      logger.error('Redis connection error', { error });
      if (!redisClient) {
        reject(error);
      }
    });

    client.on('close', () => {
      logger.warn('Redis connection closed');
    });

    client.on('reconnecting', () => {
      logger.info('Redis reconnecting...');
    });
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

// Cache helper utilities
export const cache = {
  async get<T>(key: string): Promise<T | null> {
    const client = getRedisClient();
    const value = await client.get(key);
    if (!value) return null;
    try {
      return JSON.parse(value) as T;
    } catch {
      return value as unknown as T;
    }
  },

  async set(key: string, value: unknown, ttlSeconds?: number): Promise<void> {
    const client = getRedisClient();
    const serialized = JSON.stringify(value);
    if (ttlSeconds) {
      await client.setex(key, ttlSeconds, serialized);
    } else {
      await client.set(key, serialized);
    }
  },

  async del(key: string): Promise<void> {
    const client = getRedisClient();
    await client.del(key);
  },

  async delPattern(pattern: string): Promise<void> {
    const client = getRedisClient();
    const keys = await client.keys(pattern);
    if (keys.length > 0) {
      await client.del(...keys);
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
