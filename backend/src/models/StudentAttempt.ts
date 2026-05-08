import mongoose, { Document, Schema } from 'mongoose';
import { DifficultyLevel } from './Question';

export type AttemptStatus = 'in_progress' | 'completed' | 'timed_out' | 'pending_review';
export type SkillClassification = 'strength' | 'weakness';

export interface IAnswerRecord {
  questionId: mongoose.Types.ObjectId;
  questionText: string;
  selectedAnswer: string;
  correctAnswer: string;
  isCorrect: boolean;
  difficultyLevel: DifficultyLevel;
  mainSkill: string;
  subSkill: string;
  answeredAt: Date;
  // Essay-specific fields (Req 18.4, 18.5, 18.6)
  isEssay?: boolean;
  maxMarks?: number;
  teacherScore?: number;
}

export interface ISkillBreakdown {
  mainSkill: string;
  totalQuestions: number;
  correctAnswers: number;
  percentage: number;
  classification: SkillClassification;
}

export interface IAntiCheatEvent {
  event: string;
  timestamp: Date;
}

export interface IStudentAttempt {
  studentId: mongoose.Types.ObjectId;
  assessmentId: mongoose.Types.ObjectId;
  classroomId: mongoose.Types.ObjectId;
  status: AttemptStatus;
  startedAt: Date;
  submittedAt?: Date;
  timeTakenSeconds?: number;
  currentDifficultyLevel: DifficultyLevel;
  answers: IAnswerRecord[];
  presentedQuestionIds: mongoose.Types.ObjectId[];
  scorePercentage?: number;
  pointsEarned?: number;
  skillBreakdown: ISkillBreakdown[];
  antiCheatLog: IAntiCheatEvent[];
  createdAt: Date;
  updatedAt: Date;
}

export interface IStudentAttemptDocument extends IStudentAttempt, Document {}

const studentAttemptSchema = new Schema<IStudentAttemptDocument>(
  {
    studentId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Student ID is required'],
    },
    assessmentId: {
      type: Schema.Types.ObjectId,
      ref: 'Assessment',
      required: [true, 'Assessment ID is required'],
    },
    classroomId: {
      type: Schema.Types.ObjectId,
      ref: 'Classroom',
      required: [true, 'Classroom ID is required'],
    },
    status: {
      type: String,
      enum: ['in_progress', 'completed', 'timed_out', 'pending_review'],
      default: 'in_progress',
    },
    startedAt: {
      type: Date,
      required: true,
      default: Date.now,
    },
    submittedAt: {
      type: Date,
    },
    timeTakenSeconds: {
      type: Number,
    },
    currentDifficultyLevel: {
      type: String,
      enum: ['easy', 'medium', 'hard'],
      default: 'medium',
    },
    answers: [
      {
        questionId: { type: Schema.Types.ObjectId, ref: 'Question', required: true },
        questionText: { type: String, required: true },
        selectedAnswer: { type: String, required: true },
        correctAnswer: { type: String, required: true },
        isCorrect: { type: Boolean, required: true },
        difficultyLevel: { type: String, enum: ['easy', 'medium', 'hard'], required: true },
        mainSkill: { type: String, required: true },
        subSkill: { type: String, required: true },
        answeredAt: { type: Date, default: Date.now },
        // Essay-specific fields (Req 18.4, 18.5, 18.6)
        isEssay: { type: Boolean, default: false },
        maxMarks: { type: Number, min: 0 },
        teacherScore: { type: Number, min: 0 },
      },
    ],
    presentedQuestionIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Question',
      },
    ],
    scorePercentage: {
      type: Number,
      min: 0,
      max: 100,
    },
    pointsEarned: {
      type: Number,
      min: 0,
    },
    skillBreakdown: [
      {
        mainSkill: { type: String, required: true },
        totalQuestions: { type: Number, required: true },
        correctAnswers: { type: Number, required: true },
        percentage: { type: Number, required: true },
        classification: { type: String, enum: ['strength', 'weakness'], required: true },
      },
    ],
    antiCheatLog: [
      {
        event: { type: String, required: true },
        timestamp: { type: Date, default: Date.now },
      },
    ],
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret) => {
        delete ret.__v;
        return ret;
      },
    },
  },
);

// Indexes
studentAttemptSchema.index({ studentId: 1, assessmentId: 1 });
studentAttemptSchema.index({ assessmentId: 1, status: 1 });
studentAttemptSchema.index({ classroomId: 1 });
studentAttemptSchema.index({ studentId: 1, createdAt: -1 });

export const StudentAttempt = mongoose.model<IStudentAttemptDocument>(
  'StudentAttempt',
  studentAttemptSchema,
);
