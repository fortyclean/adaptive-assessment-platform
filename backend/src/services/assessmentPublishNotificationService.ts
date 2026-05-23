import mongoose from 'mongoose';

type StudentId = mongoose.Types.ObjectId | string;

export type AssessmentPublishNotificationInput = {
  assessmentId: mongoose.Types.ObjectId | string;
  assessmentTitle: string;
  availableUntil?: Date | null;
  studentIds: StudentId[];
};

export type AssessmentPublishNotification = {
  userId: StudentId;
  type: 'new_assessment';
  title: string;
  body: string;
  relatedId: mongoose.Types.ObjectId | string;
  relatedType: 'assessment';
  isRead: false;
};

export function uniqueStudentIds(studentIds: StudentId[]): StudentId[] {
  const unique = new Map<string, StudentId>();

  for (const studentId of studentIds) {
    const key = studentId.toString();
    if (!unique.has(key)) {
      unique.set(key, studentId);
    }
  }

  return [...unique.values()];
}

export function buildAssessmentPublishNotifications(
  input: AssessmentPublishNotificationInput,
): AssessmentPublishNotification[] {
  const uniqueIds = uniqueStudentIds(input.studentIds);

  return uniqueIds.map((studentId) => ({
    userId: studentId,
    type: 'new_assessment',
    title: 'اختبار جديد متاح',
    body: buildAssessmentPublishBody(input.assessmentTitle, input.availableUntil),
    relatedId: input.assessmentId,
    relatedType: 'assessment',
    isRead: false,
  }));
}

function buildAssessmentPublishBody(title: string, availableUntil?: Date | null): string {
  const dueDate = availableUntil
    ? `. الموعد النهائي: ${availableUntil.toLocaleDateString('ar')}`
    : '';

  return `تم تعيين اختبار "${title}" لك${dueDate}`;
}
