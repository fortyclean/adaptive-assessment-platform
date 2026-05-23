import mongoose from 'mongoose';
import {
  buildAssessmentPublishNotifications,
  uniqueStudentIds,
} from '../../src/services/assessmentPublishNotificationService';

describe('Assessment publish notifications', () => {
  it('deduplicates students assigned through multiple classrooms', () => {
    const sharedStudentId = new mongoose.Types.ObjectId();
    const uniqueStudentId = new mongoose.Types.ObjectId();

    const result = uniqueStudentIds([sharedStudentId, uniqueStudentId, sharedStudentId.toString()]);

    expect(result.map((id) => id.toString())).toEqual([
      sharedStudentId.toString(),
      uniqueStudentId.toString(),
    ]);
  });

  it('builds one unread assessment notification per assigned student', () => {
    const assessmentId = new mongoose.Types.ObjectId();
    const studentIds = [new mongoose.Types.ObjectId(), new mongoose.Types.ObjectId()];

    const notifications = buildAssessmentPublishNotifications({
      assessmentId,
      assessmentTitle: 'اختبار الرياضيات',
      studentIds,
    });

    expect(notifications).toHaveLength(2);
    expect(notifications[0]).toMatchObject({
      userId: studentIds[0],
      type: 'new_assessment',
      title: 'اختبار جديد متاح',
      relatedId: assessmentId,
      relatedType: 'assessment',
      isRead: false,
    });
    expect(notifications[0].body).toContain('اختبار الرياضيات');
  });

  it('includes due date when assessment has availability end', () => {
    const assessmentId = new mongoose.Types.ObjectId();

    const [notification] = buildAssessmentPublishNotifications({
      assessmentId,
      assessmentTitle: 'اختبار العلوم',
      availableUntil: new Date('2026-05-30T10:00:00.000Z'),
      studentIds: [new mongoose.Types.ObjectId()],
    });

    expect(notification.body).toContain('الموعد النهائي');
  });

  it('does not create notifications for empty classrooms', () => {
    const notifications = buildAssessmentPublishNotifications({
      assessmentId: new mongoose.Types.ObjectId(),
      assessmentTitle: 'اختبار',
      studentIds: [],
    });

    expect(notifications).toEqual([]);
  });
});
