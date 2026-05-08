import mongoose, { Document, Schema } from 'mongoose';

export type NotificationType = 'new_assessment' | 'result_ready' | 'reminder' | 'achievement' | 'session_completed' | 'essay_grading_required';
export type RelatedType = 'assessment' | 'attempt';

export interface INotification {
  userId: mongoose.Types.ObjectId;
  type: NotificationType;
  title: string;
  body: string;
  relatedId?: mongoose.Types.ObjectId;
  relatedType?: RelatedType;
  isRead: boolean;
  createdAt: Date;
}

export interface INotificationDocument extends INotification, Document {}

const notificationSchema = new Schema<INotificationDocument>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User ID is required'],
    },
    type: {
      type: String,
      enum: ['new_assessment', 'result_ready', 'reminder', 'achievement', 'session_completed', 'essay_grading_required'],
      required: [true, 'Notification type is required'],
    },
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      maxlength: [200, 'Title cannot exceed 200 characters'],
    },
    body: {
      type: String,
      required: [true, 'Body is required'],
      trim: true,
      maxlength: [500, 'Body cannot exceed 500 characters'],
    },
    relatedId: {
      type: Schema.Types.ObjectId,
    },
    relatedType: {
      type: String,
      enum: ['assessment', 'attempt'],
    },
    isRead: {
      type: Boolean,
      default: false,
    },
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
notificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, createdAt: -1 });

export const Notification = mongoose.model<INotificationDocument>(
  'Notification',
  notificationSchema,
);
