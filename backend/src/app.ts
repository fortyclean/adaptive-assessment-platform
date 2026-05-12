import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { config } from './config';
import { connectMongoDB } from './config/database';
import { connectRedis } from './config/redis';
import { logger } from './utils/logger';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { apiRateLimiter } from './middleware/rateLimiter';
import { sanitizeInputs } from './middleware/sanitize';
import apiRouter from './routes/index';

const app: Application = express();

// ─── Security Middleware ───────────────────────────────────────────────────────
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
  }),
);

// ─── CORS ─────────────────────────────────────────────────────────────────────
const corsOrigin = process.env.CORS_ORIGIN || process.env.ALLOWED_ORIGINS || '*';
const isWildcardCors = corsOrigin.trim() === '*';
const allowedOrigins = isWildcardCors
  ? true
  : corsOrigin.split(',').map(o => o.trim()).filter(Boolean);

if (config.app.env === 'production' && isWildcardCors) {
  logger.warn(
    'CORS is configured as wildcard in production. Cookies/credentials will be disabled for safety.',
  );
}

app.use(
  cors({
    origin: allowedOrigins,
    credentials: !isWildcardCors,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
  }),
);

// ─── Body Parsing ─────────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── Input Sanitization ───────────────────────────────────────────────────────
app.use(sanitizeInputs);

// ─── Rate Limiting ────────────────────────────────────────────────────────────
app.use(apiRateLimiter);

// ─── API Routes ───────────────────────────────────────────────────────────────
app.use('/api/v1', apiRouter);

// ─── 404 Handler ──────────────────────────────────────────────────────────────
app.use(notFoundHandler);

// ─── Global Error Handler ─────────────────────────────────────────────────────
app.use(errorHandler);

// ─── Server Startup ───────────────────────────────────────────────────────────
async function startServer(): Promise<void> {
  try {
    // Connect to MongoDB
    await connectMongoDB();

    // Connect to Redis
    await connectRedis();

    // Start HTTP server — Railway injects PORT dynamically
    const port = parseInt(process.env.PORT || '3000', 10);
    const server = app.listen(port, '0.0.0.0', () => {
      logger.info(`Server running on port ${port}`, {
        environment: config.app.env,
        port,
      });
    });

    // Graceful shutdown
    const shutdown = async (signal: string) => {
      logger.info(`Received ${signal}. Starting graceful shutdown...`);

      server.close(async () => {
        logger.info('HTTP server closed');

        try {
          const { disconnectMongoDB } = await import('./config/database');
          const { disconnectRedis } = await import('./config/redis');

          await disconnectMongoDB();
          await disconnectRedis();

          logger.info('Graceful shutdown complete');
          process.exit(0);
        } catch (error) {
          logger.error('Error during shutdown', { error });
          process.exit(1);
        }
      });

      // Force shutdown after 30 seconds
      setTimeout(() => {
        logger.error('Forced shutdown after timeout');
        process.exit(1);
      }, 30000);
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));
  } catch (error) {
    logger.error('Failed to start server', { error });
    process.exit(1);
  }
}

// Only start server if this file is run directly (not imported in tests)
if (require.main === module) {
  startServer();
}

export { app };
export default app;
