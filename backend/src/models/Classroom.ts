import mongoose, { Document, Schema } from 'mongoose';

export interface IClassroom {
  name: string;
  gradeLevel: string;
  academicYear: string;
  teacherIds: mongoose.Types.ObjectId[];
  studentIds: mongoose.Types.ObjectId[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface IClassroomDocument extends IClassroom, Document {}

const classroomSchema = new Schema<IClassroomDocument>(
  {
    name: {
      type: String,
      required: [true, 'Classroom name is required'],
      trim: true,
      maxlength: [100, 'Classroom name cannot exceed 100 characters'],
    },
    gradeLevel: {
      type: String,
      required: [true, 'Grade level is required'],
      trim: true,
    },
    academicYear: {
      type: String,
      required: [true, 'Academic year is required'],
      trim: true,
    },
    teacherIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
    studentIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
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
classroomSchema.index({ gradeLevel: 1, academicYear: 1 });
classroomSchema.index({ teacherIds: 1 });
classroomSchema.index({ studentIds: 1 });

export const Classroom = mongoose.model<IClassroomDocument>('Classroom', classroomSchema);
