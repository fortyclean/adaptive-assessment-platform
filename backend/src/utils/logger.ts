import winston from 'winston';
import { config } from '../config';

const { combine, timestamp, errors, json, colorize, simple } = winston.format;

const developmentFormat = combine(
  colorize(),
  timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  errors({ stack: true }),
  simple(),
);

const productionFormat = combine(
  timestamp(),
  errors({ stack: true }),
  json(),
);

export const logger = winston.createLogger({
  level: config.app.isDevelopment ? 'debug' : 'info',
  format: config.app.isDevelopment ? developmentFormat : productionFormat,
  defaultMeta: { service: 'adaptive-assessment-api' },
  transports: [
    new winston.transports.Console(),
  ],
  // Do not exit on handled exceptions
  exitOnError: false,
});

// Stream for Morgan HTTP logger integration
export const httpLogStream = {
  write: (message: string) => {
    logger.http(message.trim());
  },
};
