import mongoose, { Document, Schema } from 'mongoose';

export interface IInstitutionSettings {
  key: string;
  schoolName: string;
  schoolPhone: string;
  schoolEmail: string;
  academicYear: string;
  term: string;
  gradeScale: string;
  language: string;
  timezone: string;
  emailNotifications: boolean;
  pushNotifications: boolean;
  weeklyDigest: boolean;
  sisIntegration: boolean;
  lmsIntegration: boolean;
  updatedBy?: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

export interface IInstitutionSettingsDocument
  extends IInstitutionSettings,
    Document {}

const institutionSettingsSchema =
  new Schema<IInstitutionSettingsDocument>(
    {
      key: {
        type: String,
        required: true,
        unique: true,
        default: 'default',
      },
      schoolName: {
        type: String,
        required: true,
        trim: true,
        maxlength: 120,
        default: 'أكاديمية المستقبل الدولية',
      },
      schoolPhone: {
        type: String,
        trim: true,
        maxlength: 40,
        default: '+966 500 000 000',
      },
      schoolEmail: {
        type: String,
        trim: true,
        lowercase: true,
        maxlength: 120,
        default: 'contact@future-academy.edu',
      },
      academicYear: {
        type: String,
        trim: true,
        maxlength: 40,
        default: '2025 / 2026',
      },
      term: {
        type: String,
        trim: true,
        maxlength: 80,
        default: 'الفصل الدراسي الثاني',
      },
      gradeScale: {
        type: String,
        trim: true,
        maxlength: 120,
        default: 'A-F',
      },
      language: {
        type: String,
        trim: true,
        maxlength: 40,
        default: 'العربية',
      },
      timezone: {
        type: String,
        trim: true,
        maxlength: 80,
        default: 'Asia/Kuwait',
      },
      emailNotifications: {
        type: Boolean,
        default: true,
      },
      pushNotifications: {
        type: Boolean,
        default: true,
      },
      weeklyDigest: {
        type: Boolean,
        default: true,
      },
      sisIntegration: {
        type: Boolean,
        default: false,
      },
      lmsIntegration: {
        type: Boolean,
        default: false,
      },
      updatedBy: {
        type: Schema.Types.ObjectId,
        ref: 'User',
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

export const InstitutionSettings =
  mongoose.model<IInstitutionSettingsDocument>(
    'InstitutionSettings',
    institutionSettingsSchema,
  );
