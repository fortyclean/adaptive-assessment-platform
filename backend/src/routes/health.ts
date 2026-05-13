import { Router, Request, Response } from 'express';
import { getMongoDBStatus } from '../config/database';
import { getRedisStatus } from '../config/redis';

const router = Router();

router.get('/', async (_req: Request, res: Response) => {
  const mongoStatus = getMongoDBStatus();
  const redisStatus = getRedisStatus();

  // Healthy = MongoDB connected (Redis is optional/cache only)
  const isHealthy = mongoStatus.connected;

  const healthData = {
    status: isHealthy ? 'healthy' : 'degraded',
    timestamp: new Date().toISOString(),
    services: {
      api: { status: 'up' },
      mongodb: {
        status: mongoStatus.connected ? 'up' : 'down',
        readyState: mongoStatus.readyState,
      },
      redis: {
        status: redisStatus.connected ? 'up' : 'down',
      },
    },
    version: process.env.npm_package_version || '1.0.0',
    build: 'admin-polish-1.0.24',
    environment: process.env.NODE_ENV || 'development',
  };

  res.status(isHealthy ? 200 : 503).json(healthData);
});

export default router;
