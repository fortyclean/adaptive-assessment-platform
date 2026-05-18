import mongoose, { Document, Schema } from 'mongoose';

export type PushProvider = 'onesignal' | 'firebase';

export interface IPushSubscription {
  userId: mongoose.Types.ObjectId;
  provider: PushProvider;
  deviceToken: string;
  platform: 'android' | 'ios' | 'web';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface IPushSubscriptionDocument extends IPushSubscription, Document {}

const pushSubscriptionSchema = new Schema<IPushSubscriptionDocument>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    provider: {
      type: String,
      enum: ['onesignal', 'firebase'],
      required: true,
    },
    deviceToken: {
      type: String,
      required: true,
      trim: true,
    },
    platform: {
      type: String,
      enum: ['android', 'ios', 'web'],
      required: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true },
);

pushSubscriptionSchema.index({ provider: 1, deviceToken: 1 }, { unique: true });
pushSubscriptionSchema.index({ userId: 1, isActive: 1 });

export const PushSubscription = mongoose.model<IPushSubscriptionDocument>(
  'PushSubscription',
  pushSubscriptionSchema,
);
