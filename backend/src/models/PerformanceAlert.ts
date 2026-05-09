import mongoose, { Document, Schema } from 'mongoose';

export interface IPerformanceAlert {
  teacherId: mongoose.Types.ObjectId;
  studentId: mongoose.Types.ObjectId;
  classroomId: mongoose.Types.ObjectId;
  subject: string;
  /** Average of the student's last 3 completed assessments in this subject */
  currentAverage: number;
  /** Average of the student's previous 3 completed assessments in this subject */
  previousAverage: number;
  /** Percentage drop: ((previousAverage - currentAverage) / previousAverage) * 100 */
  dropPercentage: number;
  /** Mastery percentages for the last 7 days (oldest → newest) */
  weeklyTrend: number[];
  /** Whether the alert has been acknowledged/dismissed by the teacher */
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface IPerformanceAlertDocument extends IPerformanceAlert, Document {}

const performanceAlertSchema = new Schema<IPerformanceAlertDocument>(
  {
    teacherId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Teacher ID is required'],
    },
    studentId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Student ID is required'],
    },
    classroomId: {
      type: Schema.Types.ObjectId,
      ref: 'Classroom',
      required: [true, 'Classroom ID is required'],
    },
    subject: {
      type: String,
      required: [true, 'Subject is required'],
      trim: true,
    },
    currentAverage: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    previousAverage: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    dropPercentage: {
      type: Number,
      required: true,
      min: 0,
    },
    weeklyTrend: {
      type: [Number],
      default: [],
    },
    isActive: {
      type: Boolean,
      default: true,
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

// Indexes
performanceAlertSchema.index({ teacherId: 1, isActive: 1 });
performanceAlertSchema.index({ studentId: 1, subject: 1 });
// Unique active alert per student+subject combination (upsert-friendly)
performanceAlertSchema.index({ studentId: 1, subject: 1, isActive: 1 });

export const PerformanceAlert = mongoose.model<IPerformanceAlertDocument>(
  'PerformanceAlert',
  performanceAlertSchema,
);
