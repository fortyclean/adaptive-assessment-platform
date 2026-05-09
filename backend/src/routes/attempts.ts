/**
 * Assessment Session (Attempt) Routes
 *
 * POST   /api/v1/attempts                        — Start a new session (Req 7.13)
 * GET    /api/v1/attempts                        — Student session history (Req 8.6)
 * GET    /api/v1/attempts/:id/next-question      — Get next adaptive question (Req 6.5)
 * POST   /api/v1/attempts/:id/answer             — Submit an answer (Req 7.14)
 * POST   /api/v1/attempts/:id/submit             — Finalise session (Req 7.6, 7.12)
 * POST   /api/v1/attempts/:id/anti-cheat         — Log navigation event (Req 7.9)
 * GET    /api/v1/attempts/:id/result             — Retrieve result (Req 8.1–8.5)
 * PATCH  /api/v1/attempts/:id/grade-essay        — Teacher grades essay answer (Req 18.6)
 */

import { Router, Request, Response } from 'express';
import { z } from 'zod';
import mongoose from 'mongoose';
import { Assessment } from '../models/Assessment';
import { Question } from '../models/Question';
import { StudentAttempt } from '../models/StudentAttempt';
import { Notification } from '../models/Notification';
import { Classroom } from '../models/Classroom';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';
import {
  selectNextQuestion,
  getNextDifficulty,
  initializeSession,
  getSessionQuestions,
  clearSessionCache,
  calculateResults,
  calculatePointsEarned,
  calculateSkillBreakdown,
  isSessionComplete,
  checkFillBlankAnswer,
  AdaptiveSessionState,
  QuestionCandidate,
} from '../services/adaptiveEngine';

const router = Router();
router.use(authenticate);

// ─── Validation Schemas ───────────────────────────────────────────────────────

const startAttemptSchema = z.object({
  assessmentId: z.string().min(1),
  classroomId: z.string().min(1),
});

const submitAnswerSchema = z.object({
  questionId: z.string().min(1),
  selectedAnswer: z.string().min(1),
});

const antiCheatSchema = z.object({
  event: z.string().min(1).max(200),
});

// ─── Helper: build AdaptiveSessionState from a StudentAttempt document ────────

function buildSessionState(attempt: InstanceType<typeof StudentAttempt>, questionCount: number): AdaptiveSessionState {
  return {
    sessionId: attempt._id.toString(),
    assessmentId: attempt.assessmentId.toString(),
    studentId: attempt.studentId.toString(),
    subject: '',   // not needed for selectNextQuestion — filtering already done at session start
    units: [],
    questionCount,
    presentedQuestionIds: attempt.presentedQuestionIds.map((id) => id.toString()),
    currentDifficulty: attempt.currentDifficultyLevel,
    answeredCount: attempt.answers.length,
  };
}

// ─── POST /api/v1/attempts — Start session ────────────────────────────────────

router.post('/', authorize('student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = startAttemptSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { assessmentId, classroomId } = validation.data;
    const studentId = req.user!.userId;

    // Load assessment
    const assessment = await Assessment.findById(assessmentId);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    // Validate availability window (Req 5.7, 5.8)
    const now = new Date();
    if (assessment.availableFrom && now < assessment.availableFrom) {
      res.status(403).json({ error: 'Assessment is not yet available', availableFrom: assessment.availableFrom });
      return;
    }
    if (assessment.availableUntil && now > assessment.availableUntil) {
      res.status(403).json({ error: 'Assessment availability window has closed', availableUntil: assessment.availableUntil });
      return;
    }
    if (assessment.status !== 'active') {
      res.status(403).json({ error: 'Assessment is not active' });
      return;
    }

    // Validate student belongs to the classroom
    const classroom = await Classroom.findById(classroomId);
    if (!classroom) {
      res.status(404).json({ error: 'Classroom not found' });
      return;
    }
    const studentObjId = new mongoose.Types.ObjectId(studentId);
    if (!classroom.studentIds.some((id) => id.equals(studentObjId))) {
      res.status(403).json({ error: 'Student is not enrolled in this classroom' });
      return;
    }

    // Prevent duplicate in-progress attempts
    const existing = await StudentAttempt.findOne({
      studentId: studentObjId,
      assessmentId: new mongoose.Types.ObjectId(assessmentId),
      status: 'in_progress',
    });
    if (existing) {
      res.status(409).json({ error: 'An in-progress attempt already exists', attemptId: existing._id });
      return;
    }

    // Create attempt
    const attempt = new StudentAttempt({
      studentId: studentObjId,
      assessmentId: new mongoose.Types.ObjectId(assessmentId),
      classroomId: new mongoose.Types.ObjectId(classroomId),
      status: 'in_progress',
      startedAt: now,
      currentDifficultyLevel: 'medium', // always start at medium (Req 6.1)
      answers: [],
      presentedQuestionIds: [],
      skillBreakdown: [],
      antiCheatLog: [],
    });
    await attempt.save();

    // Prefetch question bank into Redis for 100ms SLA (Req 6.5, 12.1)
    if (assessment.assessmentType === 'adaptive') {
      const questions = await Question.find({
        subject: assessment.subject,
        gradeLevel: assessment.gradeLevel,
        unit: { $in: assessment.units },
        isArchived: false,
      }).select('_id difficulty subject unit mainSkill subSkill questionText options correctAnswer').lean();

      const ttlSeconds = assessment.timeLimitMinutes * 60 + 300; // session duration + 5 min buffer
      await initializeSession(attempt._id.toString(), questions as unknown as QuestionCandidate[], ttlSeconds);
    }

    logger.info('Attempt started', { studentId, assessmentId, attemptId: attempt._id });
    res.status(201).json({
      attemptId: attempt._id,
      assessmentType: assessment.assessmentType,
      questionCount: assessment.questionCount,
      timeLimitMinutes: assessment.timeLimitMinutes,
      startedAt: attempt.startedAt,
    });
  } catch (error) {
    logger.error('Start attempt error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/attempts — Student session history ──────────────────────────

router.get('/', authorize('student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const studentId = new mongoose.Types.ObjectId(req.user!.userId);

    const attempts = await StudentAttempt.find({ studentId })
      .populate('assessmentId', 'title subject gradeLevel assessmentType')
      .select('-answers -antiCheatLog -presentedQuestionIds')
      .sort({ createdAt: -1 });

    res.status(200).json({ attempts });
  } catch (error) {
    logger.error('Get attempts error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/attempts/:id/next-question ───────────────────────────────────

router.get('/:id/next-question', authorize('student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const attempt = await StudentAttempt.findById(req.params.id);
    if (!attempt) {
      res.status(404).json({ error: 'Attempt not found' });
      return;
    }
    if (attempt.studentId.toString() !== req.user!.userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }
    if (attempt.status !== 'in_progress') {
      res.status(400).json({ error: 'Attempt is not in progress' });
      return;
    }

    const assessment = await Assessment.findById(attempt.assessmentId);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    // Check session completion
    if (attempt.answers.length >= assessment.questionCount) {
      res.status(200).json({ complete: true, message: 'All questions have been answered' });
      return;
    }

    let nextQuestion: QuestionCandidate | null = null;

    if (assessment.assessmentType === 'adaptive') {
      // Retrieve from Redis cache (100ms SLA)
      let questionBank = await getSessionQuestions<QuestionCandidate & Record<string, unknown>>(attempt._id.toString());

      if (!questionBank) {
        // Cache miss — reload from DB and re-cache
        const questions = await Question.find({
          subject: assessment.subject,
          gradeLevel: assessment.gradeLevel,
          unit: { $in: assessment.units },
          isArchived: false,
        }).select('_id difficulty subject unit mainSkill subSkill questionText options').lean();
        questionBank = questions as unknown as (QuestionCandidate & Record<string, unknown>)[];
        const ttlSeconds = assessment.timeLimitMinutes * 60 + 300;
        await initializeSession(attempt._id.toString(), questionBank, ttlSeconds);
      }

      const sessionState = buildSessionState(attempt, assessment.questionCount);
      nextQuestion = selectNextQuestion(sessionState, questionBank);
    } else {
      // Random assessment: serve questions from pre-selected list in order
      const presentedSet = new Set(attempt.presentedQuestionIds.map((id) => id.toString()));
      const remaining = assessment.questionIds.filter((id) => !presentedSet.has(id.toString()));
      if (remaining.length === 0) {
        res.status(200).json({ complete: true });
        return;
      }
      const questionDoc = await Question.findById(remaining[0]).select('_id difficulty subject unit mainSkill subSkill questionText options').lean();
      nextQuestion = questionDoc as unknown as QuestionCandidate;
    }

    if (!nextQuestion) {
      res.status(200).json({ complete: true, message: 'No more questions available' });
      return;
    }

    // Never send correctAnswer to client before session ends (Req 7.14)
    const { correctAnswer: _hidden, ...safeQuestion } = nextQuestion as QuestionCandidate & { correctAnswer?: string };

    res.status(200).json({
      complete: false,
      question: safeQuestion,
      questionNumber: attempt.answers.length + 1,
      totalQuestions: assessment.questionCount,
    });
  } catch (error) {
    logger.error('Next question error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/attempts/:id/answer — Submit answer ────────────────────────

router.post('/:id/answer', authorize('student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = submitAnswerSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { questionId, selectedAnswer } = validation.data;

    const attempt = await StudentAttempt.findById(req.params.id);
    if (!attempt) {
      res.status(404).json({ error: 'Attempt not found' });
      return;
    }
    if (attempt.studentId.toString() !== req.user!.userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }
    if (attempt.status !== 'in_progress') {
      res.status(400).json({ error: 'Attempt is not in progress' });
      return;
    }

    const assessment = await Assessment.findById(attempt.assessmentId);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    // Validate question belongs to this session (Req 7.14)
    const questionObjId = new mongoose.Types.ObjectId(questionId);
    const alreadyPresented = attempt.presentedQuestionIds.some((id) => id.equals(questionObjId));
    if (!alreadyPresented) {
      res.status(403).json({ error: 'Question does not belong to this session' });
      return;
    }

    // Prevent re-answering the same question
    const alreadyAnswered = attempt.answers.some((a) => a.questionId.equals(questionObjId));
    if (alreadyAnswered) {
      res.status(409).json({ error: 'Question has already been answered' });
      return;
    }

    // Load question to validate answer server-side (Req 7.14)
    const question = await Question.findById(questionId);
    if (!question) {
      res.status(404).json({ error: 'Question not found' });
      return;
    }

    const isEssay = question.questionType === 'essay';
    let isCorrect = false;

    if (!isEssay) {
      // For MCQ, True/False, Fill-in-the-Blank: validate server-side
      if (question.questionType === 'fill_blank') {
        const accepted = Array.isArray(question.correctAnswer)
          ? question.correctAnswer
          : [question.correctAnswer as string];
        isCorrect = checkFillBlankAnswer(selectedAnswer, accepted);
      } else {
        isCorrect = question.correctAnswer === selectedAnswer;
      }
    }
    // Essay answers are always marked isCorrect=false until teacher grades them (Req 18.5, 18.6)

    // Record answer
    attempt.answers.push({
      questionId: questionObjId,
      questionText: question.questionText,
      selectedAnswer,
      correctAnswer: isEssay ? '' : (Array.isArray(question.correctAnswer) ? question.correctAnswer.join(', ') : question.correctAnswer),
      isCorrect,
      difficultyLevel: question.difficulty,
      mainSkill: question.mainSkill,
      subSkill: question.subSkill,
      answeredAt: new Date(),
      isEssay,
      maxMarks: isEssay ? 10 : undefined, // default max marks for essay; teacher can adjust when grading
    });

    // Update adaptive difficulty for next question
    attempt.currentDifficultyLevel = getNextDifficulty(question.difficulty, isCorrect);

    // Check if session is now complete
    if (attempt.answers.length >= assessment.questionCount) {
      await finaliseAttempt(attempt, assessment);
    } else {
      await attempt.save();
    }

    res.status(200).json({
      isCorrect: undefined, // never reveal correctness during session
      answeredCount: attempt.answers.length,
      totalQuestions: assessment.questionCount,
      sessionComplete: attempt.status !== 'in_progress',
    });
  } catch (error) {
    logger.error('Submit answer error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/attempts/:id/submit — Finalise session ─────────────────────

router.post('/:id/submit', authorize('student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const attempt = await StudentAttempt.findById(req.params.id);
    if (!attempt) {
      res.status(404).json({ error: 'Attempt not found' });
      return;
    }
    if (attempt.studentId.toString() !== req.user!.userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }
    if (attempt.status !== 'in_progress') {
      res.status(400).json({ error: 'Attempt is already finalised' });
      return;
    }

    const assessment = await Assessment.findById(attempt.assessmentId);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    await finaliseAttempt(attempt, assessment);

    logger.info('Attempt submitted', { attemptId: attempt._id, studentId: req.user!.userId });
    res.status(200).json({
      message: 'Session submitted successfully',
      attemptId: attempt._id,
      status: attempt.status,
    });
  } catch (error) {
    logger.error('Submit attempt error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/attempts/:id/anti-cheat — Log navigation event ─────────────

router.post('/:id/anti-cheat', authorize('student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = antiCheatSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const attempt = await StudentAttempt.findById(req.params.id);
    if (!attempt) {
      res.status(404).json({ error: 'Attempt not found' });
      return;
    }
    if (attempt.studentId.toString() !== req.user!.userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    // Append anti-cheat event with timestamp (Req 7.9)
    attempt.antiCheatLog.push({ event: validation.data.event, timestamp: new Date() });
    await attempt.save();

    res.status(200).json({ logged: true });
  } catch (error) {
    logger.error('Anti-cheat log error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/attempts/:id/result — Retrieve result ───────────────────────

router.get('/:id/result', authorize('student', 'teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const attempt = await StudentAttempt.findById(req.params.id)
      .populate('assessmentId', 'title subject gradeLevel assessmentType questionCount timeLimitMinutes')
      .populate('studentId', 'fullName username');

    if (!attempt) {
      res.status(404).json({ error: 'Attempt not found' });
      return;
    }

    // Students can only view their own results
    if (req.user!.role === 'student' && attempt.studentId.toString() !== req.user!.userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    if (attempt.status === 'in_progress') {
      res.status(400).json({ error: 'Session is still in progress' });
      return;
    }

    // Build result response — include correct answers for wrong responses (Req 8.4)
    const wrongAnswers = attempt.answers
      .filter((a) => !a.isCorrect && !a.isEssay)
      .map((a) => ({
        questionId: a.questionId,
        questionText: a.questionText,
        selectedAnswer: a.selectedAnswer,
        correctAnswer: a.correctAnswer,
        mainSkill: a.mainSkill,
        subSkill: a.subSkill,
        difficultyLevel: a.difficultyLevel,
      }));

    // Essay answers for teacher review
    const essayAnswers = attempt.answers
      .filter((a) => a.isEssay)
      .map((a) => ({
        questionId: a.questionId,
        questionText: a.questionText,
        studentAnswer: a.selectedAnswer,
        teacherScore: a.teacherScore,
        maxMarks: a.maxMarks,
        isGraded: a.teacherScore !== undefined,
      }));

    res.status(200).json({
      attemptId: attempt._id,
      status: attempt.status,
      scorePercentage: attempt.scorePercentage,
      pointsEarned: attempt.pointsEarned,
      skillBreakdown: attempt.skillBreakdown,
      timeTakenSeconds: attempt.timeTakenSeconds,
      submittedAt: attempt.submittedAt,
      wrongAnswers,
      essayAnswers,
      totalQuestions: attempt.answers.length,
      correctAnswers: attempt.answers.filter((a) => a.isCorrect).length,
      pendingEssayGrading: attempt.answers.filter((a) => a.isEssay && a.teacherScore === undefined).length,
    });
  } catch (error) {
    logger.error('Get result error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/attempts/:id/grade-essay — Teacher grades essay answer ─────
//
// Requirements: 18.6
// Body: { questionId: string, score: number, maxScore: number }
// After all essay questions are graded, the session is finalised automatically.

const gradeEssaySchema = z.object({
  questionId: z.string().min(1),
  score: z.number().min(0),
  maxScore: z.number().min(1),
});

router.patch('/:id/grade-essay', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = gradeEssaySchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const { questionId, score, maxScore } = validation.data;

    if (score > maxScore) {
      res.status(400).json({ error: 'Score cannot exceed maxScore' });
      return;
    }

    const attempt = await StudentAttempt.findById(req.params.id);
    if (!attempt) {
      res.status(404).json({ error: 'Attempt not found' });
      return;
    }
    if (attempt.status !== 'pending_review') {
      res.status(400).json({ error: 'Attempt is not pending review' });
      return;
    }

    const assessment = await Assessment.findById(attempt.assessmentId);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    // Verify the teacher owns this assessment
    if (req.user!.role === 'teacher' && assessment.createdBy.toString() !== req.user!.userId) {
      res.status(403).json({ error: 'Access denied: you did not create this assessment' });
      return;
    }

    // Find the essay answer record
    const questionObjId = new mongoose.Types.ObjectId(questionId);
    const answerRecord = attempt.answers.find(
      (a) => a.questionId.equals(questionObjId) && a.isEssay,
    );
    if (!answerRecord) {
      res.status(404).json({ error: 'Essay answer not found for this question' });
      return;
    }

    // Apply teacher score (Req 18.6)
    answerRecord.teacherScore = score;
    answerRecord.maxMarks = maxScore;
    // Mark as correct if score > 0 (partial credit counts as correct for skill analysis)
    answerRecord.isCorrect = score > 0;

    // Check if all essay questions have been graded
    const ungradedEssays = attempt.answers.filter(
      (a) => a.isEssay && a.teacherScore === undefined,
    );

    if (ungradedEssays.length === 0) {
      // All essays graded — finalise the session (Req 18.6)
      const now = new Date();

      // Calculate final score including essay marks
      const totalMarks = attempt.answers.reduce((sum, a) => {
        if (a.isEssay) {
          return sum + (a.maxMarks ?? 0);
        }
        return sum + 1; // non-essay questions worth 1 mark each
      }, 0);

      const earnedMarks = attempt.answers.reduce((sum, a) => {
        if (a.isEssay) {
          return sum + (a.teacherScore ?? 0);
        }
        return sum + (a.isCorrect ? 1 : 0);
      }, 0);

      const scorePercentage = totalMarks > 0
        ? Math.round((earnedMarks / totalMarks) * 100 * 100) / 100
        : 0;

      const { points: pointsEarned, bonusAwarded } = calculatePointsEarned(scorePercentage, assessment.questionCount);
      const skillBreakdown = calculateSkillBreakdown(
        attempt.answers.map((a) => ({ mainSkill: a.mainSkill, isCorrect: a.isCorrect })),
      );

      attempt.status = 'completed';
      attempt.scorePercentage = scorePercentage;
      attempt.pointsEarned = pointsEarned;
      attempt.skillBreakdown = skillBreakdown;

      await attempt.save();

      // Notify student that results are ready
      try {
        await Notification.create({
          userId: attempt.studentId,
          type: 'result_ready',
          title: 'نتيجة اختبارك جاهزة',
          body: `تم تصحيح اختبار "${assessment.title}" ونتيجتك ${scorePercentage.toFixed(1)}%`,
          relatedId: attempt._id,
          relatedType: 'attempt',
          isRead: false,
        });
      } catch (notifError) {
        logger.warn('Failed to send result_ready notification', { error: notifError });
      }

      logger.info('Essay attempt finalised after grading', {
        attemptId: attempt._id,
        score: scorePercentage,
        points: pointsEarned,
        bonus: bonusAwarded,
      });

      res.status(200).json({
        message: 'Essay graded and session finalised',
        attemptId: attempt._id,
        status: attempt.status,
        scorePercentage,
        pointsEarned,
        bonusAwarded,
      });
    } else {
      await attempt.save();
      logger.info('Essay answer graded', {
        attemptId: attempt._id,
        questionId,
        score,
        remainingUngradedEssays: ungradedEssays.length,
      });

      res.status(200).json({
        message: 'Essay answer graded',
        attemptId: attempt._id,
        status: attempt.status,
        remainingUngradedEssays: ungradedEssays.length,
      });
    }
  } catch (error) {
    logger.error('Grade essay error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── Helper: finalise an attempt (calculate results, notify teacher) ──────────

async function finaliseAttempt(
  attempt: InstanceType<typeof StudentAttempt>,
  assessment: InstanceType<typeof Assessment>,
): Promise<void> {
  const now = new Date();
  const timeTakenSeconds = Math.round((now.getTime() - attempt.startedAt.getTime()) / 1000);

  // Check if any essay questions are present (Req 18.5)
  const hasEssayQuestions = attempt.answers.some((a) => a.isEssay);

  attempt.submittedAt = now;
  attempt.timeTakenSeconds = timeTakenSeconds;

  if (hasEssayQuestions) {
    // Session requires manual grading — set to pending_review (Req 18.5)
    attempt.status = 'pending_review';
    // Calculate partial score from non-essay questions only
    const nonEssayAnswers = attempt.answers.filter((a) => !a.isEssay);
    if (nonEssayAnswers.length > 0) {
      const sessionState = buildSessionState(attempt, assessment.questionCount);
      const answerRecords = nonEssayAnswers.map((a) => ({
        mainSkill: a.mainSkill,
        isCorrect: a.isCorrect,
      }));
      const result = calculateResults(sessionState, answerRecords);
      attempt.skillBreakdown = result.skillBreakdown;
      // Score and points will be finalized after essay grading
    }
    await attempt.save();

    // Clean up Redis cache
    await clearSessionCache(attempt._id.toString());

    // Notify teacher that manual grading is required (Req 18.5)
    try {
      const teacherId = assessment.createdBy;
      await Notification.create({
        userId: teacherId,
        type: 'essay_grading_required',
        title: 'يتطلب تصحيحاً يدوياً',
        body: `طالب أكمل اختبار "${assessment.title}" ويحتوي على أسئلة مقالية تحتاج إلى تصحيح يدوي`,
        relatedId: attempt._id,
        relatedType: 'attempt',
        isRead: false,
      });
    } catch (notifError) {
      logger.warn('Failed to send essay grading notification', { error: notifError });
    }

    logger.info('Attempt pending review (essay questions)', { attemptId: attempt._id });
    return;
  }

  // No essay questions — finalise normally
  const sessionState = buildSessionState(attempt, assessment.questionCount);
  const answerRecords = attempt.answers.map((a) => ({
    mainSkill: a.mainSkill,
    isCorrect: a.isCorrect,
  }));

  const result = calculateResults(sessionState, answerRecords);

  attempt.status = 'completed';
  attempt.scorePercentage = result.scorePercentage;
  attempt.pointsEarned = result.pointsEarned;
  attempt.skillBreakdown = result.skillBreakdown;

  await attempt.save();

  // Clean up Redis cache
  await clearSessionCache(attempt._id.toString());

  // Notify teacher (Req 21.2)
  try {
    const teacherId = assessment.createdBy;
    await Notification.create({
      userId: teacherId,
      type: 'session_completed',
      title: 'طالب أكمل الاختبار',
      body: `أكمل طالب اختبار "${assessment.title}" بنتيجة ${result.scorePercentage.toFixed(1)}%`,
      relatedId: attempt._id,
      relatedType: 'attempt',
      isRead: false,
    });
  } catch (notifError) {
    // Non-critical — log but don't fail the submission
    logger.warn('Failed to send teacher notification', { error: notifError });
  }

  logger.info('Attempt finalised', {
    attemptId: attempt._id,
    score: result.scorePercentage,
    points: result.pointsEarned,
    bonus: result.bonusAwarded,
  });
}

export default router;
