import { Router, Request, Response } from 'express';
import { z } from 'zod';
import mongoose from 'mongoose';
import { Classroom } from '../models/Classroom';
import { User } from '../models/User';
import { Assessment } from '../models/Assessment';
import { authenticate, authorize } from '../middleware/authenticate';
import { logger } from '../utils/logger';

const router = Router();

// All classroom routes require authentication
router.use(authenticate);

// ─── Validation Schemas ───────────────────────────────────────────────────────

const createClassroomSchema = z.object({
  name: z.string().min(1).max(100).trim(),
  gradeLevel: z.string().min(1).trim(),
  academicYear: z.string().min(1).trim(),
});

const updateClassroomSchema = z.object({
  name: z.string().min(1).max(100).trim().optional(),
  gradeLevel: z.string().min(1).trim().optional(),
  academicYear: z.string().min(1).trim().optional(),
});

const assignUsersSchema = z.object({
  userIds: z.array(z.string().min(1)).min(1, 'At least one user ID is required'),
});

// ─── GET /api/v1/classrooms ───────────────────────────────────────────────────

router.get('/', authorize('admin', 'teacher'), async (req: Request, res: Response): Promise<void> => {
  try {
    let filter: Record<string, unknown> = {};

    // Teachers only see their own classrooms
    if (req.user!.role === 'teacher') {
      filter = { teacherIds: new mongoose.Types.ObjectId(req.user!.userId) };
    }

    const classrooms = await Classroom.find(filter)
      .populate('teacherIds', 'fullName username email')
      .populate('studentIds', 'fullName username')
      .sort({ createdAt: -1 });

    // Add student and active assessment counts per classroom (req 2.6)
    const classroomsWithCounts = await Promise.all(
      classrooms.map(async (classroom) => {
        const activeAssessmentCount = await Assessment.countDocuments({
          classroomIds: classroom._id,
          status: 'active',
        });
        return {
          ...classroom.toJSON(),
          studentCount: classroom.studentIds.length,
          activeAssessmentCount,
        };
      }),
    );

    res.status(200).json({ classrooms: classroomsWithCounts });
  } catch (error) {
    logger.error('Get classrooms error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/classrooms ──────────────────────────────────────────────────

router.post('/', authorize('admin', 'teacher'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = createClassroomSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const classroomData: Record<string, unknown> = { ...validation.data };

    // Teachers automatically become the teacher of the classroom they create
    if (req.user!.role === 'teacher') {
      classroomData.teacherIds = [new mongoose.Types.ObjectId(req.user!.userId)];
    }

    const classroom = new Classroom(classroomData);
    await classroom.save();

    // Associate classroom with teacher's classroomIds
    if (req.user!.role === 'teacher') {
      await User.findByIdAndUpdate(req.user!.userId, {
        $addToSet: { classroomIds: classroom._id },
      });
    }

    logger.info('Classroom created', { userId: req.user!.userId, role: req.user!.role, classroomId: classroom._id });
    res.status(201).json({ classroom });
  } catch (error) {
    logger.error('Create classroom error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── PATCH /api/v1/classrooms/:id ────────────────────────────────────────────

router.patch('/:id', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = updateClassroomSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const classroom = await Classroom.findByIdAndUpdate(req.params.id, validation.data, {
      new: true,
      runValidators: true,
    });

    if (!classroom) {
      res.status(404).json({ error: 'Classroom not found' });
      return;
    }

    logger.info('Classroom updated', { adminId: req.user!.userId, classroomId: req.params.id });
    res.status(200).json({ classroom });
  } catch (error) {
    logger.error('Update classroom error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── DELETE /api/v1/classrooms/:id ───────────────────────────────────────────

router.delete('/:id', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const classroom = await Classroom.findById(req.params.id);
    if (!classroom) {
      res.status(404).json({ error: 'Classroom not found' });
      return;
    }

    // Check for active assessments (req 2.5)
    const activeAssessmentCount = await Assessment.countDocuments({
      classroomIds: classroom._id,
      status: 'active',
    });

    if (activeAssessmentCount > 0) {
      // Return warning and require explicit confirmation
      const confirmed = req.query.confirm === 'true';
      if (!confirmed) {
        res.status(409).json({
          error: `This classroom has ${activeAssessmentCount} active assessment(s). Add ?confirm=true to proceed with deletion.`,
          activeAssessmentCount,
          requiresConfirmation: true,
        });
        return;
      }
    }

    await Classroom.findByIdAndDelete(req.params.id);

    logger.info('Classroom deleted', { adminId: req.user!.userId, classroomId: req.params.id });
    res.status(200).json({ message: 'Classroom deleted successfully' });
  } catch (error) {
    logger.error('Delete classroom error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/classrooms/:id/students ────────────────────────────────────

router.post('/:id/students', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = assignUsersSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const classroom = await Classroom.findById(req.params.id);
    if (!classroom) {
      res.status(404).json({ error: 'Classroom not found' });
      return;
    }

    const { userIds } = validation.data;

    // Verify all users exist and are students
    const students = await User.find({
      _id: { $in: userIds },
      role: 'student',
      isActive: true,
    });

    if (students.length !== userIds.length) {
      res.status(400).json({ error: 'One or more user IDs are invalid or not active students' });
      return;
    }

    // Add students to classroom (avoid duplicates)
    const studentObjectIds = userIds.map((id) => new mongoose.Types.ObjectId(id));
    await Classroom.findByIdAndUpdate(req.params.id, {
      $addToSet: { studentIds: { $each: studentObjectIds } },
    });

    // Associate classroom with each student's classroomIds (req 2.2)
    await User.updateMany(
      { _id: { $in: studentObjectIds } },
      { $addToSet: { classroomIds: classroom._id } },
    );

    logger.info('Students assigned to classroom', {
      adminId: req.user!.userId,
      classroomId: req.params.id,
      studentCount: userIds.length,
    });

    res.status(200).json({ message: `${userIds.length} student(s) assigned to classroom successfully` });
  } catch (error) {
    logger.error('Assign students error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

// ─── POST /api/v1/classrooms/:id/teachers ────────────────────────────────────

router.post('/:id/teachers', authorize('admin'), async (req: Request, res: Response): Promise<void> => {
  try {
    const validation = assignUsersSchema.safeParse(req.body);
    if (!validation.success) {
      res.status(400).json({ error: 'Invalid request', details: validation.error.flatten().fieldErrors });
      return;
    }

    const classroom = await Classroom.findById(req.params.id);
    if (!classroom) {
      res.status(404).json({ error: 'Classroom not found' });
      return;
    }

    const { userIds } = validation.data;

    // Verify all users exist and are teachers
    const teachers = await User.find({
      _id: { $in: userIds },
      role: 'teacher',
      isActive: true,
    });

    if (teachers.length !== userIds.length) {
      res.status(400).json({ error: 'One or more user IDs are invalid or not active teachers' });
      return;
    }

    const teacherObjectIds = userIds.map((id) => new mongoose.Types.ObjectId(id));
    await Classroom.findByIdAndUpdate(req.params.id, {
      $addToSet: { teacherIds: { $each: teacherObjectIds } },
    });

    // Associate classroom with each teacher's classroomIds (req 2.3)
    await User.updateMany(
      { _id: { $in: teacherObjectIds } },
      { $addToSet: { classroomIds: classroom._id } },
    );

    logger.info('Teachers assigned to classroom', {
      adminId: req.user!.userId,
      classroomId: req.params.id,
      teacherCount: userIds.length,
    });

    res.status(200).json({ message: `${userIds.length} teacher(s) assigned to classroom successfully` });
  } catch (error) {
    logger.error('Assign teachers error', { error });
    res.status(500).json({ error: 'An internal server error occurred' });
  }
});

export default router;
