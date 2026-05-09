import mongoose, { Document, Schema, Model } from 'mongoose';

export type UserRole = 'admin' | 'teacher' | 'student';

export interface IUser {
  username: string;
  passwordHash: string;
  email: string;
  fullName: string;
  role: UserRole;
  isActive: boolean;
  classroomIds: mongoose.Types.ObjectId[];
  failedLoginAttempts: number;
  lockedUntil?: Date;
  activeSessions: string[];
  createdAt: Date;
  updatedAt: Date;
  lastLoginAt?: Date;
}

export interface IUserDocument extends IUser, Document {}

export interface IUserModel extends Model<IUserDocument> {
  findByUsername(username: string): Promise<IUserDocument | null>;
}

const userSchema = new Schema<IUserDocument>(
  {
    username: {
      type: String,
      required: [true, 'Username is required'],
      unique: true,
      trim: true,
      lowercase: true,
      minlength: [3, 'Username must be at least 3 characters'],
      maxlength: [50, 'Username cannot exceed 50 characters'],
    },
    passwordHash: {
      type: String,
      required: [true, 'Password hash is required'],
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email address'],
    },
    fullName: {
      type: String,
      required: [true, 'Full name is required'],
      trim: true,
      maxlength: [100, 'Full name cannot exceed 100 characters'],
    },
    role: {
      type: String,
      enum: {
        values: ['admin', 'teacher', 'student'],
        message: 'Role must be admin, teacher, or student',
      },
      required: [true, 'Role is required'],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    classroomIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Classroom',
      },
    ],
    failedLoginAttempts: {
      type: Number,
      default: 0,
    },
    lockedUntil: {
      type: Date,
    },
    activeSessions: [
      {
        type: String,
      },
    ],
    lastLoginAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret: Record<string, unknown>) => {
        ret['passwordHash'] = undefined;
        ret['failedLoginAttempts'] = undefined;
        ret['lockedUntil'] = undefined;
        ret['activeSessions'] = undefined;
        ret['__v'] = undefined;
        return ret;
      },
    },
  },
);

// Indexes
userSchema.index({ username: 1 }, { unique: true });
userSchema.index({ email: 1 });
userSchema.index({ role: 1, isActive: 1 });

// Static methods
userSchema.statics.findByUsername = function (username: string) {
  return this.findOne({ username: username.toLowerCase().trim() });
};

export const User = mongoose.model<IUserDocument, IUserModel>('User', userSchema);
