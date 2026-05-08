import { Router } from 'express';
import healthRouter from './health';
import authRouter from './auth';
import usersRouter from './users';
import classroomsRouter from './classrooms';
import questionsRouter from './questions';
import assessmentsRouter from './assessments';
import attemptsRouter from './attempts';
import reportsRouter from './reports';
import notificationsRouter from './notifications';
import mediaRouter from './media';
import reportSchedulesRouter from './reportSchedules';
import alertsRouter from './alerts';
import studentsRouter from './students';

const router = Router();

// Health check — no auth required
router.use('/health', healthRouter);

// Auth routes
router.use('/auth', authRouter);

// User management routes
router.use('/users', usersRouter);

// Classroom routes
router.use('/classrooms', classroomsRouter);

// Question bank routes
router.use('/questions', questionsRouter);

// Assessment routes
router.use('/assessments', assessmentsRouter);

// Attempt/session routes
router.use('/attempts', attemptsRouter);

// Reports routes
router.use('/reports', reportsRouter);

// Notifications routes
router.use('/notifications', notificationsRouter);

// Media upload routes (Post-MVP)
router.use('/media', mediaRouter);

// Report schedule routes
router.use('/report-schedules', reportSchedulesRouter);

// Performance alerts routes
router.use('/alerts', alertsRouter);

// Student profile routes (skill radar, behavior log, weekly trend)
router.use('/students', studentsRouter);

export default router;
