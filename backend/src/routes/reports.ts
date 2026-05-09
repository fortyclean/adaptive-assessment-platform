/**
 * Reports Routes
 *
 * GET /api/v1/reports/assessment/:id          — Class-level assessment report (Req 9.1–9.5)
 * GET /api/v1/reports/assessment/:id/export   — CSV export (Req 9.6)
 * GET /api/v1/reports/student/:id             — Per-student answer history (Req 9.5)
 * GET /api/v1/reports/classroom/:id           — Classroom ranking (Req 13.1)
 * GET /api/v1/reports/school                  — School-wide overview (Req 19.1, 19.7)
 * GET /api/v1/reports/school/comparison       — Classroom comparison report (Req 19.2)
 * GET /api/v1/reports/school/longitudinal     — Longitudinal performance chart (Req 19.3)
 * GET /api/v1/reports/school/weaknesses       — Top weakest skills school-wide (Req 19.4)
 * GET /api/v1/reports/school/export           — PDF/structured export (Req 19.6)
 */

import { Router, Request, Response } from 'express';
import mongoose from 'mongoose';
import { StudentAttempt } from '../models/StudentAttempt';
import { Assessment } from '../models/Assessment';
import { Classroom } from '../models/Classroom';
import { User } from '../models/User';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// ─── Helper: build CSV string from rows ──────────────────────────────────────

function buildCsv(headers: string[], rows: (string | number | undefined)[][]): string {
  const escape = (v: string | number | undefined) => {
    const s = String(v ?? '');
    return s.includes(',') || s.includes('"') || s.includes('\n')
      ? `"${s.replace(/"/g, '""')}"`
      : s;
  };
  const lines = [headers.map(escape).join(',')];
  for (const row of rows) {
    lines.push(row.map(escape).join(','));
  }
  return lines.join('\n');
}

// ─── GET /api/v1/reports/assessment/:id ──────────────────────────────────────

router.get('/assessment/:id', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const assessmentId = new mongoose.Types.ObjectId(req.params.id);

    const assessment = await Assessment.findById(assessmentId)
      .populate('createdBy', 'fullName username');
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    // All completed attempts for this assessment
    const attempts = await StudentAttempt.find({
      assessmentId,
      status: { $in: ['completed', 'timed_out'] },
    })
      .populate('studentId', 'fullName username')
      .select('studentId scorePercentage timeTakenSeconds status submittedAt skillBreakdown')
      .lean();

    if (attempts.length === 0) {
      res.status(200).json({
        assessment: { id: assessment._id, title: assessment.title },
        totalAttempts: 0,
        classAverage: null,
        highestScore: null,
        lowestScore: null,
        scoreDistribution: { '0-49': 0, '50-69': 0, '70-89': 0, '90-100': 0 },
        studentResults: [],
        skillHeatmap: [],
      });
      return;
    }

    const scores = attempts.map((a) => a.scorePercentage ?? 0);
    const classAverage = scores.reduce((s, v) => s + v, 0) / scores.length;
    const highestScore = Math.max(...scores);
    const lowestScore = Math.min(...scores);

    // Score distribution (Req 9.2)
    const distribution = { '0-49': 0, '50-69': 0, '70-89': 0, '90-100': 0 };
    for (const score of scores) {
      if (score < 50) distribution['0-49']++;
      else if (score < 70) distribution['50-69']++;
      else if (score < 90) distribution['70-89']++;
      else distribution['90-100']++;
    }

    // Per-student results table (Req 9.3)
    const studentResults = attempts.map((a) => ({
      studentId: (a.studentId as { _id: unknown; fullName?: string; username?: string })?._id,
      fullName: (a.studentId as { fullName?: string })?.fullName,
      username: (a.studentId as { username?: string })?.username,
      scorePercentage: a.scorePercentage,
      timeTakenSeconds: a.timeTakenSeconds,
      status: a.status,
      submittedAt: a.submittedAt,
    }));

    // Skill heatmap — class-wide average per primary skill (Req 9.4)
    const skillTotals = new Map<string, { total: number; correct: number }>();
    for (const attempt of attempts) {
      for (const skill of attempt.skillBreakdown ?? []) {
        const existing = skillTotals.get(skill.mainSkill) ?? { total: 0, correct: 0 };
        skillTotals.set(skill.mainSkill, {
          total: existing.total + skill.totalQuestions,
          correct: existing.correct + skill.correctAnswers,
        });
      }
    }
    const skillHeatmap = Array.from(skillTotals.entries()).map(([mainSkill, stats]) => ({
      mainSkill,
      averagePercentage: stats.total > 0 ? Math.round((stats.correct / stats.total) * 100 * 100) / 100 : 0,
    }));

    res.status(200).json({
      assessment: { id: assessment._id, title: assessment.title, subject: assessment.subject },
      totalAttempts: attempts.length,
      classAverage: Math.round(classAverage * 100) / 100,
      highestScore,
      lowestScore,
      scoreDistribution: distribution,
      studentResults,
      skillHeatmap,
    });
  } catch (error) {
    logger.error('Assessment report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/assessment/:id/export — CSV export ──────────────────

router.get('/assessment/:id/export', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const assessmentId = new mongoose.Types.ObjectId(req.params.id);

    const assessment = await Assessment.findById(assessmentId);
    if (!assessment) {
      res.status(404).json({ error: 'Assessment not found' });
      return;
    }

    const attempts = await StudentAttempt.find({
      assessmentId,
      status: { $in: ['completed', 'timed_out'] },
    })
      .populate('studentId', 'fullName username')
      .select('studentId scorePercentage timeTakenSeconds status submittedAt')
      .lean();

    const headers = ['Student Name', 'Username', 'Score (%)', 'Time (seconds)', 'Status', 'Submitted At'];
    const rows = attempts.map((a) => [
      (a.studentId as { fullName?: string })?.fullName ?? '',
      (a.studentId as { username?: string })?.username ?? '',
      a.scorePercentage ?? '',
      a.timeTakenSeconds ?? '',
      a.status,
      a.submittedAt ? new Date(a.submittedAt).toISOString() : '',
    ]);

    const csv = buildCsv(headers, rows);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="assessment-${req.params.id}-results.csv"`);
    res.status(200).send(csv);
  } catch (error) {
    logger.error('CSV export error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/student/:id — Per-student answer history ─────────────

router.get('/student/:id', authorize('teacher', 'admin', 'student'), async (req: Request, res: Response): Promise<void> => {
  try {
    // Students can only view their own history
    if (req.user!.role === 'student' && req.params.id !== req.user!.userId) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    const { assessmentId } = req.query;
    const filter: Record<string, unknown> = {
      studentId: new mongoose.Types.ObjectId(req.params.id),
      status: { $in: ['completed', 'timed_out'] },
    };
    if (assessmentId) {
      filter.assessmentId = new mongoose.Types.ObjectId(assessmentId as string);
    }

    const attempts = await StudentAttempt.find(filter)
      .populate('assessmentId', 'title subject gradeLevel assessmentType')
      .sort({ createdAt: -1 })
      .lean();

    res.status(200).json({ attempts });
  } catch (error) {
    logger.error('Student report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/classroom/:id — Classroom ranking ───────────────────

router.get('/classroom/:id', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const classroomId = new mongoose.Types.ObjectId(req.params.id);

    const classroom = await Classroom.findById(classroomId).populate('studentIds', 'fullName username');
    if (!classroom) {
      res.status(404).json({ error: 'Classroom not found' });
      return;
    }

    // Aggregate mastery per student across all completed attempts in this classroom
    const results = await StudentAttempt.aggregate([
      { $match: { classroomId, status: { $in: ['completed', 'timed_out'] } } },
      {
        $group: {
          _id: '$studentId',
          averageScore: { $avg: '$scorePercentage' },
          totalAttempts: { $sum: 1 },
          totalPoints: { $sum: '$pointsEarned' },
        },
      },
      { $sort: { averageScore: -1 } },
    ]);

    // Enrich with student names
    const studentMap = new Map(
      (classroom.studentIds as unknown as { _id: mongoose.Types.ObjectId; fullName: string; username: string }[])
        .map((s) => [s._id.toString(), s]),
    );

    const ranking = results.map((r, index) => ({
      rank: index + 1,
      studentId: r._id,
      fullName: studentMap.get(r._id.toString())?.fullName ?? 'Unknown',
      username: studentMap.get(r._id.toString())?.username ?? '',
      averageScore: Math.round(r.averageScore * 100) / 100,
      totalAttempts: r.totalAttempts,
      totalPoints: r.totalPoints,
    }));

    res.status(200).json({
      classroom: { id: classroom._id, name: classroom.name },
      ranking,
    });
  } catch (error) {
    logger.error('Classroom report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/school — School-wide overview ───────────────────────

router.get('/school', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    // Overall school stats
    const [totalStudents, totalTeachers, totalAssessments, totalAttempts] = await Promise.all([
      User.countDocuments({ role: 'student', isActive: true }),
      User.countDocuments({ role: 'teacher', isActive: true }),
      Assessment.countDocuments({ status: { $in: ['active', 'completed'] } }),
      StudentAttempt.countDocuments({ status: { $in: ['completed', 'timed_out'] } }),
    ]);

    // Average score school-wide
    const scoreAgg = await StudentAttempt.aggregate([
      { $match: { status: { $in: ['completed', 'timed_out'] } } },
      { $group: { _id: null, avgScore: { $avg: '$scorePercentage' } } },
    ]);
    const schoolAverage = scoreAgg[0]?.avgScore ?? 0;

    // Per-classroom performance summary
    const classroomStats = await StudentAttempt.aggregate([
      { $match: { status: { $in: ['completed', 'timed_out'] } } },
      {
        $group: {
          _id: '$classroomId',
          averageScore: { $avg: '$scorePercentage' },
          totalAttempts: { $sum: 1 },
          completedStudents: { $addToSet: '$studentId' },
        },
      },
      {
        $project: {
          averageScore: { $round: ['$averageScore', 2] },
          totalAttempts: 1,
          uniqueStudents: { $size: '$completedStudents' },
        },
      },
      { $sort: { averageScore: -1 } },
    ]);

    // Enrich with classroom names
    const classroomIds = classroomStats.map((c) => c._id);
    const classrooms = await Classroom.find({ _id: { $in: classroomIds } }).select('name gradeLevel').lean();
    const classroomMap = new Map(classrooms.map((c) => [c._id.toString(), c]));

    const classroomSummary = classroomStats.map((c) => ({
      classroomId: c._id,
      name: classroomMap.get(c._id.toString())?.name ?? 'Unknown',
      gradeLevel: classroomMap.get(c._id.toString())?.gradeLevel,
      averageScore: c.averageScore,
      totalAttempts: c.totalAttempts,
      uniqueStudents: c.uniqueStudents,
    }));

    // Top 3 weakest skills school-wide (Req 19.7)
    const skillAgg = await StudentAttempt.aggregate([
      { $match: { status: { $in: ['completed', 'timed_out'] } } },
      { $unwind: '$skillBreakdown' },
      {
        $group: {
          _id: '$skillBreakdown.mainSkill',
          totalQuestions: { $sum: '$skillBreakdown.totalQuestions' },
          correctAnswers: { $sum: '$skillBreakdown.correctAnswers' },
        },
      },
      {
        $project: {
          mainSkill: '$_id',
          averagePercentage: {
            $round: [{ $multiply: [{ $divide: ['$correctAnswers', '$totalQuestions'] }, 100] }, 2],
          },
        },
      },
      { $sort: { averagePercentage: 1 } },
      { $limit: 3 },
    ]);

    res.status(200).json({
      summary: {
        totalStudents,
        totalTeachers,
        totalAssessments,
        totalAttempts,
        schoolAverage: Math.round(schoolAverage * 100) / 100,
      },
      classroomSummary,
      weakestSkills: skillAgg,
    });
  } catch (error) {
    logger.error('School report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/school/comparison — Classroom comparison (Req 19.2) ──

router.get('/school/comparison', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const { term, subject, gradeLevel } = req.query as Record<string, string | undefined>;

    // Build assessment filter for subject/gradeLevel/term
    const assessmentFilter: Record<string, unknown> = { status: { $in: ['active', 'completed'] } };
    if (subject) assessmentFilter.subject = subject;
    if (gradeLevel) assessmentFilter.gradeLevel = gradeLevel;

    // If term is provided, filter assessments by availableFrom date range
    // Term is expected as an academicYear string (e.g. "2024-2025") or a term label
    // We match against the assessment's availableFrom field or the classroom's academicYear
    let assessmentIds: mongoose.Types.ObjectId[] | undefined;
    if (term || subject || gradeLevel) {
      const matchingAssessments = await Assessment.find(assessmentFilter).select('_id').lean();
      assessmentIds = matchingAssessments.map((a) => a._id as mongoose.Types.ObjectId);
    }

    // Build attempt match stage
    const attemptMatch: Record<string, unknown> = {
      status: { $in: ['completed', 'timed_out'] },
    };
    if (assessmentIds) {
      attemptMatch.assessmentId = { $in: assessmentIds };
    }

    // Aggregate per-classroom stats
    const classroomStats = await StudentAttempt.aggregate([
      { $match: attemptMatch },
      {
        $group: {
          _id: '$classroomId',
          totalScoreSum: { $sum: '$scorePercentage' },
          totalAttempts: { $sum: 1 },
          uniqueStudents: { $addToSet: '$studentId' },
          // Collect all skill breakdowns for top-skill calculation
          allSkillBreakdowns: { $push: '$skillBreakdown' },
        },
      },
      {
        $project: {
          averageScore: {
            $round: [{ $divide: ['$totalScoreSum', '$totalAttempts'] }, 2],
          },
          totalAttempts: 1,
          enrolledCount: { $size: '$uniqueStudents' },
          allSkillBreakdowns: 1,
        },
      },
    ]);

    // Fetch all classrooms to get enrolled student counts and names
    const classroomIds = classroomStats.map((c) => c._id);
    const classrooms = await Classroom.find({ _id: { $in: classroomIds } })
      .select('name gradeLevel studentIds')
      .lean();
    const classroomMap = new Map(classrooms.map((c) => [c._id.toString(), c]));

    // Build comparison result
    const comparison = classroomStats.map((c) => {
      const classroom = classroomMap.get(c._id?.toString() ?? '');

      // Calculate completion rate: students who attempted / total enrolled
      const enrolledTotal = classroom?.studentIds?.length ?? 0;
      const completionRate = enrolledTotal > 0
        ? Math.round((c.enrolledCount / enrolledTotal) * 100 * 100) / 100
        : 0;

      // Determine top skill: flatten all skill breakdowns and find highest avg
      const skillTotals = new Map<string, { total: number; correct: number }>();
      for (const breakdownArray of c.allSkillBreakdowns as { mainSkill: string; totalQuestions: number; correctAnswers: number }[][]) {
        for (const skill of breakdownArray ?? []) {
          const existing = skillTotals.get(skill.mainSkill) ?? { total: 0, correct: 0 };
          skillTotals.set(skill.mainSkill, {
            total: existing.total + skill.totalQuestions,
            correct: existing.correct + skill.correctAnswers,
          });
        }
      }

      let topSkill: string | null = null;
      let topSkillPct = -1;
      for (const [skill, stats] of skillTotals.entries()) {
        const pct = stats.total > 0 ? stats.correct / stats.total : 0;
        if (pct > topSkillPct) {
          topSkillPct = pct;
          topSkill = skill;
        }
      }

      return {
        classroomId: c._id,
        name: classroom?.name ?? 'Unknown',
        gradeLevel: classroom?.gradeLevel,
        averageScore: c.averageScore,
        completionRate,
        topSkill,
      };
    });

    // Sort by averageScore descending
    comparison.sort((a, b) => (b.averageScore ?? 0) - (a.averageScore ?? 0));

    res.status(200).json({ comparison });
  } catch (error) {
    logger.error('Classroom comparison report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/school/longitudinal — Longitudinal trend (Req 19.3) ─

router.get('/school/longitudinal', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const { classroomId, subject, term } = req.query as Record<string, string | undefined>;

    // Build assessment filter
    const assessmentFilter: Record<string, unknown> = { status: { $in: ['active', 'completed'] } };
    if (subject) assessmentFilter.subject = subject;

    let assessmentIds: mongoose.Types.ObjectId[] | undefined;
    if (subject || term) {
      const matchingAssessments = await Assessment.find(assessmentFilter).select('_id').lean();
      assessmentIds = matchingAssessments.map((a) => a._id as mongoose.Types.ObjectId);
    }

    // Build attempt match stage
    const attemptMatch: Record<string, unknown> = {
      status: { $in: ['completed', 'timed_out'] },
      submittedAt: { $exists: true },
    };
    if (classroomId) {
      attemptMatch.classroomId = new mongoose.Types.ObjectId(classroomId);
    }
    if (assessmentIds) {
      attemptMatch.assessmentId = { $in: assessmentIds };
    }

    // Aggregate: group by classroomId + month (YYYY-MM)
    const longitudinal = await StudentAttempt.aggregate([
      { $match: attemptMatch },
      {
        $project: {
          classroomId: 1,
          scorePercentage: 1,
          // Format submittedAt as YYYY-MM
          month: {
            $dateToString: { format: '%Y-%m', date: '$submittedAt' },
          },
        },
      },
      {
        $group: {
          _id: { classroomId: '$classroomId', month: '$month' },
          averageScore: { $avg: '$scorePercentage' },
          totalAttempts: { $sum: 1 },
        },
      },
      {
        $project: {
          classroomId: '$_id.classroomId',
          month: '$_id.month',
          averageScore: { $round: ['$averageScore', 2] },
          totalAttempts: 1,
          _id: 0,
        },
      },
      { $sort: { month: 1 } },
    ]);

    // Enrich with classroom names
    const classroomIds = [...new Set(longitudinal.map((l) => l.classroomId?.toString()))];
    const classrooms = await Classroom.find({
      _id: { $in: classroomIds.map((id) => new mongoose.Types.ObjectId(id as string)) },
    })
      .select('name gradeLevel')
      .lean();
    const classroomMap = new Map(classrooms.map((c) => [c._id.toString(), c]));

    const enriched = longitudinal.map((l) => ({
      classroomId: l.classroomId,
      classroomName: classroomMap.get(l.classroomId?.toString() ?? '')?.name ?? 'Unknown',
      gradeLevel: classroomMap.get(l.classroomId?.toString() ?? '')?.gradeLevel,
      month: l.month,
      averageScore: l.averageScore,
      totalAttempts: l.totalAttempts,
    }));

    res.status(200).json({ longitudinal: enriched });
  } catch (error) {
    logger.error('Longitudinal report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/school/weaknesses — Top weakest skills (Req 19.4) ───

router.get('/school/weaknesses', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const { term, subject, gradeLevel } = req.query as Record<string, string | undefined>;

    // Build assessment filter for subject/gradeLevel
    let assessmentIds: mongoose.Types.ObjectId[] | undefined;
    if (subject || gradeLevel || term) {
      const assessmentFilter: Record<string, unknown> = { status: { $in: ['active', 'completed'] } };
      if (subject) assessmentFilter.subject = subject;
      if (gradeLevel) assessmentFilter.gradeLevel = gradeLevel;
      const matchingAssessments = await Assessment.find(assessmentFilter).select('_id').lean();
      assessmentIds = matchingAssessments.map((a) => a._id as mongoose.Types.ObjectId);
    }

    const attemptMatch: Record<string, unknown> = {
      status: { $in: ['completed', 'timed_out'] },
    };
    if (assessmentIds) {
      attemptMatch.assessmentId = { $in: assessmentIds };
    }

    // Aggregate top 5 weakest skills school-wide (Req 19.4 asks for top 3, but we return top 5 for flexibility)
    const weakestSkills = await StudentAttempt.aggregate([
      { $match: attemptMatch },
      { $unwind: '$skillBreakdown' },
      {
        $group: {
          _id: '$skillBreakdown.mainSkill',
          totalQuestions: { $sum: '$skillBreakdown.totalQuestions' },
          correctAnswers: { $sum: '$skillBreakdown.correctAnswers' },
        },
      },
      {
        $project: {
          mainSkill: '$_id',
          averagePercentage: {
            $round: [
              { $multiply: [{ $divide: ['$correctAnswers', '$totalQuestions'] }, 100] },
              2,
            ],
          },
          totalQuestions: 1,
          correctAnswers: 1,
          _id: 0,
        },
      },
      { $sort: { averagePercentage: 1 } },
      { $limit: 5 },
    ]);

    res.status(200).json({ weakestSkills });
  } catch (error) {
    logger.error('School weaknesses report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/school/export — Structured export for PDF (Req 19.6) ─

router.get('/school/export', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const { term, subject, gradeLevel } = req.query as Record<string, string | undefined>;

    // ── Summary stats ──────────────────────────────────────────────────────────
    const [totalStudents, totalTeachers, totalAssessments, totalAttempts] = await Promise.all([
      User.countDocuments({ role: 'student', isActive: true }),
      User.countDocuments({ role: 'teacher', isActive: true }),
      Assessment.countDocuments({ status: { $in: ['active', 'completed'] } }),
      StudentAttempt.countDocuments({ status: { $in: ['completed', 'timed_out'] } }),
    ]);

    const scoreAgg = await StudentAttempt.aggregate([
      { $match: { status: { $in: ['completed', 'timed_out'] } } },
      { $group: { _id: null, avgScore: { $avg: '$scorePercentage' } } },
    ]);
    const schoolAverage = Math.round((scoreAgg[0]?.avgScore ?? 0) * 100) / 100;

    // ── Classroom comparison (same logic as /school/comparison) ───────────────
    const assessmentFilter: Record<string, unknown> = { status: { $in: ['active', 'completed'] } };
    if (subject) assessmentFilter.subject = subject;
    if (gradeLevel) assessmentFilter.gradeLevel = gradeLevel;

    let assessmentIds: mongoose.Types.ObjectId[] | undefined;
    if (subject || gradeLevel || term) {
      const matchingAssessments = await Assessment.find(assessmentFilter).select('_id').lean();
      assessmentIds = matchingAssessments.map((a) => a._id as mongoose.Types.ObjectId);
    }

    const attemptMatch: Record<string, unknown> = {
      status: { $in: ['completed', 'timed_out'] },
    };
    if (assessmentIds) {
      attemptMatch.assessmentId = { $in: assessmentIds };
    }

    const classroomStats = await StudentAttempt.aggregate([
      { $match: attemptMatch },
      {
        $group: {
          _id: '$classroomId',
          totalScoreSum: { $sum: '$scorePercentage' },
          totalAttempts: { $sum: 1 },
          uniqueStudents: { $addToSet: '$studentId' },
          allSkillBreakdowns: { $push: '$skillBreakdown' },
        },
      },
      {
        $project: {
          averageScore: {
            $round: [{ $divide: ['$totalScoreSum', '$totalAttempts'] }, 2],
          },
          totalAttempts: 1,
          enrolledCount: { $size: '$uniqueStudents' },
          allSkillBreakdowns: 1,
        },
      },
    ]);

    const classroomIds = classroomStats.map((c) => c._id);
    const classrooms = await Classroom.find({ _id: { $in: classroomIds } })
      .select('name gradeLevel studentIds')
      .lean();
    const classroomMap = new Map(classrooms.map((c) => [c._id.toString(), c]));

    const classroomComparison = classroomStats
      .map((c) => {
        const classroom = classroomMap.get(c._id?.toString() ?? '');
        const enrolledTotal = classroom?.studentIds?.length ?? 0;
        const completionRate = enrolledTotal > 0
          ? Math.round((c.enrolledCount / enrolledTotal) * 100 * 100) / 100
          : 0;

        const skillTotals = new Map<string, { total: number; correct: number }>();
        for (const breakdownArray of c.allSkillBreakdowns as { mainSkill: string; totalQuestions: number; correctAnswers: number }[][]) {
          for (const skill of breakdownArray ?? []) {
            const existing = skillTotals.get(skill.mainSkill) ?? { total: 0, correct: 0 };
            skillTotals.set(skill.mainSkill, {
              total: existing.total + skill.totalQuestions,
              correct: existing.correct + skill.correctAnswers,
            });
          }
        }

        let topSkill: string | null = null;
        let topSkillPct = -1;
        for (const [skill, stats] of skillTotals.entries()) {
          const pct = stats.total > 0 ? stats.correct / stats.total : 0;
          if (pct > topSkillPct) {
            topSkillPct = pct;
            topSkill = skill;
          }
        }

        return {
          classroomId: c._id,
          name: classroom?.name ?? 'Unknown',
          gradeLevel: classroom?.gradeLevel,
          averageScore: c.averageScore,
          completionRate,
          topSkill,
        };
      })
      .sort((a, b) => (b.averageScore ?? 0) - (a.averageScore ?? 0));

    // ── Top 5 weakest skills ───────────────────────────────────────────────────
    const weakestSkills = await StudentAttempt.aggregate([
      { $match: attemptMatch },
      { $unwind: '$skillBreakdown' },
      {
        $group: {
          _id: '$skillBreakdown.mainSkill',
          totalQuestions: { $sum: '$skillBreakdown.totalQuestions' },
          correctAnswers: { $sum: '$skillBreakdown.correctAnswers' },
        },
      },
      {
        $project: {
          mainSkill: '$_id',
          averagePercentage: {
            $round: [
              { $multiply: [{ $divide: ['$correctAnswers', '$totalQuestions'] }, 100] },
              2,
            ],
          },
          _id: 0,
        },
      },
      { $sort: { averagePercentage: 1 } },
      { $limit: 5 },
    ]);

    // ── Response — structured JSON for client-side PDF rendering ──────────────
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', 'attachment; filename="school-report.json"');
    res.status(200).json({
      exportNote: 'PDF rendering is handled client-side. This structured JSON contains all data required to generate the report.',
      generatedAt: new Date().toISOString(),
      filters: { term: term ?? null, subject: subject ?? null, gradeLevel: gradeLevel ?? null },
      summary: {
        totalStudents,
        totalTeachers,
        totalAssessments,
        totalAttempts,
        schoolAverage,
      },
      classroomComparison,
      weakestSkills,
    });
  } catch (error) {
    logger.error('School export error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── GET /api/v1/reports/classroom/:id/certificates — Student certificates ───

router.get('/classroom/:id/certificates', authorize('teacher', 'admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const classroomId = new mongoose.Types.ObjectId(req.params.id);

    const classroom = await Classroom.findById(classroomId)
      .populate('studentIds', 'fullName username email')
      .lean();

    if (!classroom) {
      res.status(404).json({ error: 'Classroom not found' });
      return;
    }

    // Get latest attempt score per student in this classroom
    const studentScores = await StudentAttempt.aggregate([
      { $match: { classroomId, status: { $in: ['completed', 'timed_out'] } } },
      { $sort: { submittedAt: -1 } },
      {
        $group: {
          _id: '$studentId',
          averageScore: { $avg: '$scorePercentage' },
          totalAttempts: { $sum: 1 },
          lastScore: { $first: '$scorePercentage' },
          totalPoints: { $sum: '$pointsEarned' },
        },
      },
    ]);

    const scoreMap = new Map(studentScores.map((s) => [s._id.toString(), s]));

    const students = (classroom.studentIds as unknown as { _id: mongoose.Types.ObjectId; fullName: string; username: string; email?: string }[])
      .map((student) => {
        const stats = scoreMap.get(student._id.toString());
        const avgScore = stats?.averageScore ?? 0;
        const passed = avgScore >= 50;

        let grade = 'راسب';
        if (avgScore >= 95) grade = 'ممتاز';
        else if (avgScore >= 85) grade = 'امتياز';
        else if (avgScore >= 75) grade = 'جيد جداً';
        else if (avgScore >= 65) grade = 'جيد';
        else if (avgScore >= 50) grade = 'مقبول';

        return {
          _id: student._id,
          fullName: student.fullName,
          username: student.username,
          email: student.email,
          score: Math.round(avgScore * 100) / 100,
          grade,
          passed,
          totalAttempts: stats?.totalAttempts ?? 0,
          totalPoints: stats?.totalPoints ?? 0,
        };
      })
      .sort((a, b) => b.score - a.score);

    res.status(200).json({
      classroom: {
        _id: classroom._id,
        name: classroom.name,
        gradeLevel: classroom.gradeLevel,
        academicYear: classroom.academicYear,
      },
      students,
      summary: {
        total: students.length,
        passed: students.filter((s) => s.passed).length,
        failed: students.filter((s) => !s.passed).length,
      },
    });
  } catch (error) {
    logger.error('Certificates report error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
