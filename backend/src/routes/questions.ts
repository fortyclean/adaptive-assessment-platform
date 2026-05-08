import { Router, Request, Response } from 'express';
import { z } from 'zod';
import multer from 'multer';
import { Question, SUBJECTS } from '../models/Question';
import { StudentAttempt } from '../models/StudentAttempt';
import { authenticate, authorize } from '../middleware/authenticate';
import { importQuestionsFromBuffer } from '../services/excelImportService';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// Multer config: memory storage, max 10MB, xlsx/xls only
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (_req, file, cb) => {
    const allowed = [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel',
    ];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only .xlsx and .xls files are allowed'));
    }
  },
});

const router = Router();
router.use(authenticate);

// ─── Validation Schemas ───────────────────────────────────────────────────────

const questionSchema = z.object({
  subject: z.enum(SUBJECTS as unknown as [string, ...string[]]),
  gradeLevel: z.string().min(1).trim(),
  academicTerm: z.string().min(1).trim(),
  unit: z.string().min(1).trim(),
  mainSkill: z.string().min(1).trim(),
  subSkill: z.string().min(1).trim(),
  difficulty: z.enum(['easy', 'medium', 'hard']),
  questionType: z.enum(['mcq', 'true_false', 'fill_blank', 'essay']).default('mcq'),
  questionText: z.string().min(1).trim(),
  options: z
    .array(z.object({ key: z.string().min(1), value: z.string().min(1) }))
    .min(2, 'At least 2 options required'),
  correctAnswer: z.string().min(1),
  imageUrl: z.string().url().optional().nullable(),
});

const filterSchema = z.object({
  subject: z.string().optional(),
  gradeLevel: z.string().optional(),
  unit: z.string().optional(),
  mainSkill: z.string().optional(),
  subSkill: z.string().optional(),
  difficulty: z.enum(['easy', 'medium', 'hard']).optional(),
  questionType: z.enum(['mcq', 'true_false', 'fill_blank', 'essay']).optional(),
  search: z.string().optional(),
  page: z.string().default('1').transform(Number),
  limit: z.string().default('20').transform(Number),
});

// ─── Validation Helper ────────────────────────────────────────────────────────

const validateQuestionData = (
  data: z.infer<typeof questionSchema>,
): { valid: boolean; error?: string } => {
  // Req 22.1: correct answer must match one of the option keys
  const optionKeys = data.options.map((o) => o.key);
  if (!optionKeys.includes(data.correctAnswer)) {
    return { valid: false, error: 'Correct answer must match one of the provided option keys' };
  }

  // Req 22.2: no duplicate option values
  const optionValues = data.options.map((o) => o.value.trim().toLowerCase());
  const uniqueValues = new Set(optionValues);
  if (uniqueValues.size !== optionValues.length) {
    return { valid: false, error: 'Answer options must not contain duplicate text' };
  }

  return { valid: true };
};

// ─── GET /api/v1/questions ────────────────────────────────────────────────────

router.get('/', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const query = filterSchema.safeParse(req.query);
    if (!query.success) {
      res.status(400).json({ error: 'Invalid query parameters' });
      return;
    }

    const { subject, gradeLevel, unit, mainSkill, subSkill, difficulty, questionType, search, page, limit } =
      query.data;

    const filter: Record<string, unknown> = { isArchived: false };
    if (subject) filter.subject = subject;
    if (gradeLevel) filter.gradeLevel = gradeLevel;
    if (unit) filter.unit = unit;
    if (mainSkill) filter.mainSkill = mainSkill;
    if (subSkill) filter.subSkill = subSkill;
    if (difficulty) filter.difficulty = difficulty;
    if (questionType) filter.questionType = questionType;
    if (search) filter.$text = { $search: search };

    const skip = (page - 1) * limit;

    const [questions, total] = await Promise.all([
      Question.find(filter).skip(skip).limit(limit).sort({ createdAt: -1 }),
      Question.countDocuments(filter),
    ]);

    res.status(200).json({
      questions,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    logger.error('Get questions error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/questions ───────────────────────────────────────────────────

router.post('/', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = questionSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const dataValidation = validateQuestionData(validation.data);
    if (!dataValidation.valid) {
      res.status(400).json({ error: dataValidation.error });
      return;
    }

    const question = new Question({
      ...validation.data,
      createdBy: req.user!.userId,
    });

    await question.save();

    logger.info('Question created', { teacherId: req.user!.userId, questionId: question._id });
    res.status(201).json({ question });
  } catch (error: unknown) {
    if ((error as { code?: number }).code === 11000) {
      res.status(409).json({ error: 'A question with this text already exists in the same subject, grade, and unit' });
      return;
    }
    logger.error('Create question error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/questions/:id ────────────────────────────────────────────────

router.get('/:id', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const question = await Question.findById(req.params.id);
    if (!question) {
      res.status(404).json({ error: 'Question not found' });
      return;
    }
    res.status(200).json({ question });
  } catch (error) {
    logger.error('Get question error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/questions/:id ──────────────────────────────────────────────

router.patch('/:id', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const question = await Question.findById(req.params.id);
    if (!question) {
      res.status(404).json({ error: 'Question not found' });
      return;
    }

    const updateSchema = questionSchema.partial();
    const validation = updateSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    // Req 3.5: preserve original in historical sessions — update only applies to future assessments
    // The snapshot in student_attempts.answers.questionText preserves the original
    Object.assign(question, validation.data);
    await question.save();

    logger.info('Question updated', { teacherId: req.user!.userId, questionId: req.params.id });
    res.status(200).json({ question });
  } catch (error) {
    logger.error('Update question error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── DELETE /api/v1/questions/:id — Post-MVP (Req 16.5, 16.6) ────────────────
// Deletes a question only if it is NOT used in any published assessment.
// If used in a published assessment, returns 409 with an archive suggestion.

router.delete('/:id', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const question = await Question.findById(req.params.id);
    if (!question) {
      res.status(404).json({ error: 'Question not found' });
      return;
    }

    // Req 16.6: prevent deletion if question is used in a published assessment
    const { Assessment } = await import('../models/Assessment');
    const usedInAssessment = await Assessment.findOne({
      questionIds: question._id,
      status: { $in: ['active', 'completed'] },
    });

    if (usedInAssessment) {
      res.status(409).json({
        error: 'Cannot delete a question used in a published assessment',
        suggestion: 'Archive the question instead to preserve historical data',
        assessmentId: usedInAssessment._id,
        assessmentTitle: usedInAssessment.title,
      });
      return;
    }

    await question.deleteOne();

    logger.info('Question deleted', { teacherId: req.user!.userId, questionId: req.params.id });
    res.status(200).json({ message: 'Question deleted successfully' });
  } catch (error) {
    logger.error('Delete question error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/questions/:id/archive ─────────────────────────────────────

router.patch('/:id/archive', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const question = await Question.findByIdAndUpdate(
      req.params.id,
      { isArchived: true },
      { new: true },
    );

    if (!question) {
      res.status(404).json({ error: 'Question not found' });
      return;
    }

    logger.info('Question archived', { teacherId: req.user!.userId, questionId: req.params.id });
    res.status(200).json({ message: 'Question archived successfully', question });
  } catch (error) {
    logger.error('Archive question error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/questions/template ──────────────────────────────────────────

router.get('/template/download', authorize('teacher', 'admin'), async (_req: Request, res: Response): Promise<void> => {
  try {
    // Return template column headers as JSON (actual Excel generation in Excel import service)
    const template = {
      columns: [
        'subject', 'gradeLevel', 'academicTerm', 'unit',
        'mainSkill', 'subSkill', 'difficulty', 'questionType',
        'questionText', 'optionA', 'optionB', 'optionC', 'optionD',
        'correctAnswer', 'imageUrl',
      ],
      example: {
        subject: 'Mathematics',
        gradeLevel: 'Grade 7',
        academicTerm: 'Term 1',
        unit: 'Algebra',
        mainSkill: 'Equations',
        subSkill: 'Linear Equations',
        difficulty: 'medium',
        questionType: 'mcq',
        questionText: 'What is the value of x in 2x + 4 = 10?',
        optionA: '2',
        optionB: '3',
        optionC: '4',
        optionD: '5',
        correctAnswer: 'B',
        imageUrl: '',
      },
      validSubjects: SUBJECTS,
      validDifficulties: ['easy', 'medium', 'hard'],
      validQuestionTypes: ['mcq', 'true_false', 'fill_blank', 'essay'],
    };

    res.status(200).json({ template });
  } catch (error) {
    logger.error('Template download error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/questions/quality-check ─────────────────────────────────────

router.get('/quality/check', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const { subject, gradeLevel, unit } = req.query as Record<string, string>;

    if (!subject || !gradeLevel || !unit) {
      res.status(400).json({ error: 'subject, gradeLevel, and unit are required query parameters' });
      return;
    }

    const MIN_PER_DIFFICULTY = 3;

    const [easyCnt, mediumCnt, hardCnt] = await Promise.all([
      Question.countDocuments({ subject, gradeLevel, unit, difficulty: 'easy', isArchived: false }),
      Question.countDocuments({ subject, gradeLevel, unit, difficulty: 'medium', isArchived: false }),
      Question.countDocuments({ subject, gradeLevel, unit, difficulty: 'hard', isArchived: false }),
    ]);

    const qualityReport = {
      subject, gradeLevel, unit,
      counts: { easy: easyCnt, medium: mediumCnt, hard: hardCnt },
      minimumRequired: MIN_PER_DIFFICULTY,
      isAdaptiveReady: easyCnt >= MIN_PER_DIFFICULTY && mediumCnt >= MIN_PER_DIFFICULTY && hardCnt >= MIN_PER_DIFFICULTY,
      warnings: [] as string[],
    };

    if (easyCnt < MIN_PER_DIFFICULTY) qualityReport.warnings.push(`Insufficient easy questions: ${easyCnt}/${MIN_PER_DIFFICULTY}`);
    if (mediumCnt < MIN_PER_DIFFICULTY) qualityReport.warnings.push(`Insufficient medium questions: ${mediumCnt}/${MIN_PER_DIFFICULTY}`);
    if (hardCnt < MIN_PER_DIFFICULTY) qualityReport.warnings.push(`Insufficient hard questions: ${hardCnt}/${MIN_PER_DIFFICULTY}`);

    res.status(200).json({ qualityReport });
  } catch (error) {
    logger.error('Quality check error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/questions/import ───────────────────────────────────────────

router.post(
  '/import',
  authorize('teacher', 'admin'),
  upload.single('file'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      if (!req.file) {
        res.status(400).json({ error: 'No file uploaded. Please attach an Excel file.' });
        return;
      }

      const result = await importQuestionsFromBuffer(req.file.buffer, req.user!.userId);

      logger.info('Excel import completed by teacher', {
        teacherId: req.user!.userId,
        imported: result.imported,
        skipped: result.skippedDuplicates,
        failed: result.failed,
      });

      res.status(200).json({
        message: 'Import completed',
        summary: {
          totalRows: result.totalRows,
          imported: result.imported,
          skippedDuplicates: result.skippedDuplicates,
          failed: result.failed,
        },
        errors: result.errors,
      });
    } catch (error) {
      logger.error('Excel import error', { error });
      res.status(500).json({ error: (error as Error).message || 'An internal server error occurred' });
    }
  },
);

export default router;
