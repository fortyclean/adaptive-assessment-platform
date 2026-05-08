import mongoose, { Document, Schema } from 'mongoose';

export type AssessmentType = 'random' | 'adaptive';
export type AssessmentStatus = 'draft' | 'active' | 'completed';

export interface IAssessment {
  title: string;
  createdBy: mongoose.Types.ObjectId;
  assessmentType: AssessmentType;
  subject: string;
  gradeLevel: string;
  units: string[];
  questionCount: number;
  timeLimitMinutes: number;
  classroomIds: mongoose.Types.ObjectId[];
  status: AssessmentStatus;
  availableFrom?: Date;
  availableUntil?: Date;
  questionIds: mongoose.Types.ObjectId[];
  createdAt: Date;
  updatedAt: Date;
}

export interface IAssessmentDocument extends IAssessment, Document {}

const assessmentSchema = new Schema<IAssessmentDocument>(
  {
    title: {
      type: String,
      required: [true, 'Assessment title is required'],
      trim: true,
      maxlength: [200, 'Title cannot exceed 200 characters'],
    },
    createdBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Creator is required'],
    },
    assessmentType: {
      type: String,
      enum: {
        values: ['random', 'adaptive'],
        message: 'Assessment type must be random or adaptive',
      },
      required: [true, 'Assessment type is required'],
    },
    subject: {
      type: String,
      required: [true, 'Subject is required'],
    },
    gradeLevel: {
      type: String,
      required: [true, 'Grade level is required'],
    },
    units: [
      {
        type: String,
        required: true,
      },
    ],
    questionCount: {
      type: Number,
      required: [true, 'Question count is required'],
      min: [5, 'Minimum 5 questions required'],
      max: [50, 'Maximum 50 questions allowed'],
    },
    timeLimitMinutes: {
      type: Number,
      required: [true, 'Time limit is required'],
      min: [5, 'Minimum 5 minutes required'],
      max: [120, 'Maximum 120 minutes allowed'],
    },
    classroomIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Classroom',
      },
    ],
    status: {
      type: String,
      enum: {
        values: ['draft', 'active', 'completed'],
        message: 'Status must be draft, active, or completed',
      },
      default: 'draft',
    },
    availableFrom: {
      type: Date,
    },
    availableUntil: {
      type: Date,
    },
    questionIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Question',
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
assessmentSchema.index({ createdBy: 1, status: 1 });
assessmentSchema.index({ classroomIds: 1, status: 1 });
assessmentSchema.index({ availableFrom: 1, availableUntil: 1 });

export const Assessment = mongoose.model<IAssessmentDocument>('Assessment', assessmentSchema);
