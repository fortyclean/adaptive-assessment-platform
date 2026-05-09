import mongoose, { Document, Schema } from 'mongoose';

export type ReportType =
  | 'student_performance'
  | 'question_quality'
  | 'classroom_comparison'
  | 'skill_analysis';

export type ReportFrequency = 'daily' | 'weekly' | 'monthly';
export type ReportFileFormat = 'pdf' | 'excel';

export interface IReportSchedule {
  title: string;
  reportType: ReportType;
  frequency: ReportFrequency;
  /** Delivery time in HH:MM 24-hour format, e.g. "08:00" */
  deliveryTime: string;
  recipients: string[];
  fileFormat: ReportFileFormat;
  classroomIds: mongoose.Types.ObjectId[];
  isActive: boolean;
  createdBy: mongoose.Types.ObjectId;
  lastSentAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface IReportScheduleDocument extends IReportSchedule, Document {}

const reportScheduleSchema = new Schema<IReportScheduleDocument>(
  {
    title: {
      type: String,
      required: [true, 'Schedule title is required'],
      trim: true,
      maxlength: [200, 'Title cannot exceed 200 characters'],
    },
    reportType: {
      type: String,
      enum: {
        values: [
          'student_performance',
          'question_quality',
          'classroom_comparison',
          'skill_analysis',
        ],
        message: 'Invalid report type',
      },
      required: [true, 'Report type is required'],
    },
    frequency: {
      type: String,
      enum: {
        values: ['daily', 'weekly', 'monthly'],
        message: 'Frequency must be daily, weekly, or monthly',
      },
      required: [true, 'Frequency is required'],
    },
    deliveryTime: {
      type: String,
      required: [true, 'Delivery time is required'],
      match: [/^\d{2}:\d{2}$/, 'Delivery time must be in HH:MM format'],
    },
    recipients: {
      type: [String],
      required: [true, 'At least one recipient is required'],
      validate: {
        validator: (arr: string[]) => arr.length > 0,
        message: 'At least one recipient email is required',
      },
    },
    fileFormat: {
      type: String,
      enum: {
        values: ['pdf', 'excel'],
        message: 'File format must be pdf or excel',
      },
      required: [true, 'File format is required'],
    },
    classroomIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Classroom',
      },
    ],
    isActive: {
      type: Boolean,
      default: true,
    },
    createdBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Creator is required'],
    },
    lastSentAt: {
      type: Date,
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
reportScheduleSchema.index({ createdBy: 1, isActive: 1 });
reportScheduleSchema.index({ createdBy: 1, createdAt: -1 });

export const ReportSchedule = mongoose.model<IReportScheduleDocument>(
  'ReportSchedule',
  reportScheduleSchema,
);
