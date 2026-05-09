import mongoose, { Document, Schema } from 'mongoose';

export type DifficultyLevel = 'easy' | 'medium' | 'hard';
export type QuestionType = 'mcq' | 'true_false' | 'fill_blank' | 'essay';

export const SUBJECTS = [
  'Mathematics',
  'English',
  'Arabic',
  'Physics',
  'Chemistry',
  'Biology',
] as const;

export type Subject = (typeof SUBJECTS)[number];

export interface IQuestionOption {
  key: string;
  value: string;
}

export interface IQuestion {
  subject: Subject;
  gradeLevel: string;
  academicTerm: string;
  unit: string;
  mainSkill: string;
  subSkill: string;
  difficulty: DifficultyLevel;
  questionType: QuestionType;
  questionText: string;
  options: IQuestionOption[];
  /**
   * For MCQ and True/False: a single string (the correct answer key or 'true'/'false').
   * For Fill-in-the-Blank: an array of accepted correct answers (case-insensitive matching).
   * Stored as a JSON string in MongoDB; use the virtual `correctAnswers` for typed access.
   */
  correctAnswer: string | string[];
  imageUrl?: string;
  createdBy: mongoose.Types.ObjectId;
  isArchived: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface IQuestionDocument extends IQuestion, Document {}

const questionSchema = new Schema<IQuestionDocument>(
  {
    subject: {
      type: String,
      enum: {
        values: SUBJECTS,
        message: 'Invalid subject',
      },
      required: [true, 'Subject is required'],
    },
    gradeLevel: {
      type: String,
      required: [true, 'Grade level is required'],
      trim: true,
    },
    academicTerm: {
      type: String,
      required: [true, 'Academic term is required'],
      trim: true,
    },
    unit: {
      type: String,
      required: [true, 'Unit is required'],
      trim: true,
    },
    mainSkill: {
      type: String,
      required: [true, 'Main skill is required'],
      trim: true,
    },
    subSkill: {
      type: String,
      required: [true, 'Sub-skill is required'],
      trim: true,
    },
    difficulty: {
      type: String,
      enum: {
        values: ['easy', 'medium', 'hard'],
        message: 'Difficulty must be easy, medium, or hard',
      },
      required: [true, 'Difficulty level is required'],
    },
    questionType: {
      type: String,
      enum: {
        values: ['mcq', 'true_false', 'fill_blank', 'essay'],
        message: 'Invalid question type',
      },
      required: [true, 'Question type is required'],
      default: 'mcq',
    },
    questionText: {
      type: String,
      required: [true, 'Question text is required'],
      trim: true,
    },
    options: [
      {
        key: { type: String, required: true },
        value: { type: String, required: true },
      },
    ],
    correctAnswer: {
      // For MCQ / True-False: a single string (answer key or 'true'/'false').
      // For Fill-in-the-Blank: an array of accepted strings (case-insensitive).
      type: Schema.Types.Mixed,
      required: [true, 'Correct answer is required'],
      validate: {
        validator(value: unknown) {
          if (typeof value === 'string') return value.trim().length > 0;
          if (Array.isArray(value)) {
            return (
              value.length > 0 &&
              value.every((v) => typeof v === 'string' && v.trim().length > 0)
            );
          }
          return false;
        },
        message:
          'correctAnswer must be a non-empty string or a non-empty array of strings',
      },
    },
    imageUrl: {
      type: String,
      default: null,
    },
    createdBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Creator is required'],
    },
    isArchived: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret: Record<string, unknown>) => {
        ret['__v'] = undefined;
        return ret;
      },
    },
  },
);

// Compound indexes for adaptive engine fast lookup
questionSchema.index({ subject: 1, gradeLevel: 1, unit: 1, difficulty: 1 });
questionSchema.index({ mainSkill: 1, subSkill: 1 });
questionSchema.index({ questionText: 'text' });

// Uniqueness constraint: no duplicate question text within same subject/grade/unit
questionSchema.index(
  { subject: 1, gradeLevel: 1, unit: 1, questionText: 1 },
  { unique: true },
);

export const Question = mongoose.model<IQuestionDocument>('Question', questionSchema);
