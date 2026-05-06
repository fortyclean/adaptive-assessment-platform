import { Router, Request, Response } from 'express';
import { z } from 'zod';
import mongoose from 'mongoose';
import { Assessment } from '../models/Assessment';
import { Question, SUBJECTS } from '../models/Question';
import { Notification } from '../models/Notification';
import { Classroom } from '../models/Classroom';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// ─── Validation Schemas ───────────────────────────────────────────────────────

const createAssessmentSchema = z.object({
  title: z.string().min(1).max(200).trim(),
  assessmentType: z.enum(['random', 'adaptive']),
  subject: z.enum(SUBJECTS as unknown as [string, ...string[]]),
  gradeLevel: z.string().min(1).trim(),
  units: z.array(z.string().min(1)).min(1, 'At least one unit is required'),
  questionCount: z.number().int().min(5).max(50),
  timeLimitMinutes: z.number().int().min(5).max(120),
  classroomIds: z.array(z.string()).optional(),
  availableFrom: z.string().datetime().optional(),
  availableUntil: z.string().datetime().optional(),
});

// ─── GET /api/v1/assessments ──────────────────────────────────────────────────

router.get('/', authorize('teacher', 'admin', 'student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const filter: Record<string, unknown> = {};

    if (req.user!.role === 'teacher') {
      filter.createdBy = new mongoose.Types.ObjectId(req.user!.userId);
    } else if (req.user!.role === 'student') {
      // Students see assessments assigned to their classrooms that are active and within window
      const now = new Date();
      filter.status = 'active';
      filter.$or = [
        { availableFrom: { $lte: now }, availableUntil: { $gte: now } },
        { availableFrom: null, availableUntil: null },
      ];
    }

    const assessments = await Assessment.find(filter)
      .populate('createdBy', 'fullName username')
      .sort({ createdAt: -1 });

    res.status(200).json({ assessments });
  } catch (error) {
    logger.error('Get assessments error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/assessments ─────────────────────────────────────────────────

router.post('/', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = createAssessmentSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { title, assessmentType, subject, gradeLevel, units, questionCount, timeLimitMinutes,
      classroomIds, availableFrom, availableUntil } = validation.data;

    // Check available question count (req 5.4)
    const availableCount = await Question.countDocuments({
      subject, gradeLevel, unit: { $in: units }, isArchived: false,
    });

    if (availableCount < questionCount) {
      res.status(422).json({
        error: `Insufficient questions available. Requested: ${questionCount}, Available: ${availableCount}`,
        availableCount,
        requestedCount: questionCount,
        requiresConfirmation: true,
      });
      return;
    }

    // For random assessments: pre-select questions (req 5.2)
    let selectedQuestionIds: mongoose.Types.ObjectId[] = [];
    if (assessmentType === 'random') {
      const questions = await Question.aggregate([
        { $match: { subject, gradeLevel, unit: { $in: units }, isArchived: false } },
        { $sample: { size: questionCount } },
        { $project: { _id: 1 } },
      ]);
      selectedQuestionIds = questions.map((q) => q._id);
    }

    const assessment = new Assessment({
      title,
      createdBy: new mongoose.Types.ObjectId(req.user!.userId),
      assessmentType,
      subject,
      gradeLevel,
      units,
      questionCount,
      timeLimitMinutes,
      classroomIds: classroomIds?.map((id) => new mongoose.Types.ObjectId(id)) || [],
      status: 'draft',
      availableFrom: availableFrom ? new Date(availableFrom) : undefined,
      availableUntil: availableUntil ? new Date(availableUntil) : undefined,
      questionIds: selectedQuestionIds,
    });

    await assessment.save();

    logger.info('Assessment created', { teacherId: req.user!.userId, assessmentId: assessment._id, type: assessmentType });
    res.status(201).json({ assessment });
  } catch (error) {
    logger.error('Create assessment error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/assessments/:id ─────────────────────────────────────────────

router.get('/:id', authorize('teacher', 'admin', 'student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const assessment = await Assessment.findById(req.params.id)
      .populate('createdBy', 'fullName username');

    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    res.status(200).json({ assessment });
  } catch (error) {
    logger.error('Get assessment error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/assessments/:id ───────────────────────────────────────────

router.patch('/:id', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const assessment = await Assessment.findById(req.params.id);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    if (assessment.status === 'active') {
      res.status(400).json({ error: 'Cannot edit an active assessment' });
      return;
    }

    const updateSchema = createAssessmentSchema.partial();
    const validation = updateSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    Object.assign(assessment, validation.data);
    await assessment.save();

    res.status(200).json({ assessment });
  } catch (error) {
    logger.error('Update assessment error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/assessments/:id/publish ────────────────────────────────────

router.post('/:id/publish', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const assessment = await Assessment.findById(req.params.id);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    if (assessment.classroomIds.length === 0) {
      res.status(400).json({ error: 'Assessment must be assigned to at least one classroom before publishing' });
      return;
    }

    assessment.status = 'active';
    await assessment.save();

    // Send notifications to all students in assigned classrooms (req 21.1)
    const classrooms = await Classroom.find({ _id: { $in: assessment.classroomIds } }).select('studentIds');
    const allStudentIds = classrooms.flatMap((c) => c.studentIds);

    if (allStudentIds.length > 0) {
      const notifications = allStudentIds.map((studentId) => ({
        userId: studentId,
        type: 'new_assessment' as const,
        title: 'اختبار جديد متاح',
        body: `تم تعيين اختبار "${assessment.title}" لك${assessment.availableUntil ? `. الموعد النهائي: ${assessment.availableUntil.toLocaleDateString('ar')}` : ''}`,
        relatedId: assessment._id,
        relatedType: 'assessment' as const,
        isRead: false,
      }));

      await Notification.insertMany(notifications);
      logger.info('Notifications sent to students', { assessmentId: assessment._id, studentCount: allStudentIds.length });
    }

    logger.info('Assessment published', { teacherId: req.user!.userId, assessmentId: assessment._id });
    res.status(200).json({ message: 'Assessment published successfully', assessment });
  } catch (error) {
    logger.error('Publish assessment error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
