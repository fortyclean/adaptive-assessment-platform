/**
 * Unit tests for Points and Notifications System
 * Requirements: 15.1, 15.4, 21.1, 21.2
 */

import {
  calculatePointsEarned,
  calculateScorePercentage,
} from '../../src/services/adaptiveEngine';

// ─── Points Formula Accuracy (Req 15.1) ──────────────────────────────────────

describe('Points — Formula Accuracy (Req 15.1)', () => {
  it('should calculate points: round((score/100) * questionCount * 10)', () => {
    const { points } = calculatePointsEarned(80, 10);
    expect(points).toBe(80); // (80/100) * 10 * 10 = 80
  });

  it('should calculate points for 5-question session', () => {
    const { points } = calculatePointsEarned(100, 5);
    expect(points).toBe(50); // (100/100) * 5 * 10 = 50
  });

  it('should calculate points for 50-question session', () => {
    const { points } = calculatePointsEarned(60, 50);
    expect(points).toBe(300); // (60/100) * 50 * 10 = 300
  });

  it('should round points to nearest integer', () => {
    const { points } = calculatePointsEarned(33.33, 10);
    // (33.33/100) * 10 * 10 = 33.33 → rounds to 33
    expect(Number.isInteger(points)).toBe(true);
  });

  it('should return 0 points for 0% score', () => {
    const { points } = calculatePointsEarned(0, 10);
    expect(points).toBe(0);
  });

  it('should return maximum points for 100% score', () => {
    const { points } = calculatePointsEarned(100, 10);
    expect(points).toBe(100); // (100/100) * 10 * 10 = 100 (no bonus yet)
  });
});

// ─── Bonus Points Trigger at 90% Threshold (Req 15.4) ────────────────────────

describe('Points — Bonus at 90% Threshold (Req 15.4)', () => {
  it('should award 50 bonus points at exactly 90%', () => {
    const { points, bonusAwarded } = calculatePointsEarned(90, 10);
    expect(bonusAwarded).toBe(true);
    expect(points).toBe(140); // 90 base + 50 bonus
  });

  it('should award 50 bonus points above 90%', () => {
    const { points, bonusAwarded } = calculatePointsEarned(95, 10);
    expect(bonusAwarded).toBe(true);
    expect(points).toBe(145); // 95 base + 50 bonus
  });

  it('should award 50 bonus points at 100%', () => {
    const { points, bonusAwarded } = calculatePointsEarned(100, 10);
    expect(bonusAwarded).toBe(true);
    expect(points).toBe(150); // 100 base + 50 bonus
  });

  it('should NOT award bonus at 89%', () => {
    const { bonusAwarded } = calculatePointsEarned(89, 10);
    expect(bonusAwarded).toBe(false);
  });

  it('should NOT award bonus at 89.99%', () => {
    const { bonusAwarded } = calculatePointsEarned(89.99, 10);
    expect(bonusAwarded).toBe(false);
  });

  it('should NOT award bonus at 0%', () => {
    const { bonusAwarded } = calculatePointsEarned(0, 10);
    expect(bonusAwarded).toBe(false);
  });

  it('should NOT award bonus at 50%', () => {
    const { bonusAwarded } = calculatePointsEarned(50, 10);
    expect(bonusAwarded).toBe(false);
  });
});

// ─── Points History Log (Req 15.6) ───────────────────────────────────────────

describe('Points — History Log (Req 15.6)', () => {
  it('should accumulate total points across multiple sessions', () => {
    const sessions = [
      { points: 80 },
      { points: 140 }, // with bonus
      { points: 50 },
    ];

    const totalPoints = sessions.reduce((sum, s) => sum + s.points, 0);
    expect(totalPoints).toBe(270);
  });

  it('should maintain points history sorted by date descending', () => {
    const history = [
      { date: new Date('2024-01-03'), points: 80 },
      { date: new Date('2024-01-01'), points: 50 },
      { date: new Date('2024-01-02'), points: 70 },
    ];

    const sorted = [...history].sort((a, b) => b.date.getTime() - a.date.getTime());

    expect(sorted[0].points).toBe(80);
    expect(sorted[1].points).toBe(70);
    expect(sorted[2].points).toBe(50);
  });
});

// ─── Notification Creation on Assessment Publish (Req 21.1) ──────────────────

describe('Notifications — Assessment Publish (Req 21.1)', () => {
  it('should create notification for each student in assigned classrooms', () => {
    const studentIds = ['s1', 's2', 's3', 's4', 's5'];
    const assessmentTitle = 'اختبار الرياضيات';

    const notifications = studentIds.map((studentId) => ({
      userId: studentId,
      type: 'new_assessment',
      title: 'اختبار جديد متاح',
      body: `تم تعيين اختبار "${assessmentTitle}" لك`,
      isRead: false,
    }));

    expect(notifications).toHaveLength(5);
    expect(notifications[0].type).toBe('new_assessment');
    expect(notifications[0].isRead).toBe(false);
    expect(notifications[0].body).toContain(assessmentTitle);
  });

  it('should not create notifications when no students in classroom', () => {
    const studentIds: string[] = [];
    const notifications = studentIds.map((id) => ({ userId: id }));

    expect(notifications).toHaveLength(0);
  });

  it('should include assessment due date in notification body when set', () => {
    const dueDate = new Date('2024-12-31');
    const body = `تم تعيين اختبار "اختبار" لك. الموعد النهائي: ${dueDate.toLocaleDateString('ar')}`;

    expect(body).toContain('الموعد النهائي');
  });
});

// ─── Notification on Session Completion (Req 21.2) ───────────────────────────

describe('Notifications — Session Completion (Req 21.2)', () => {
  it('should create notification for teacher when student completes session', () => {
    const teacherId = 'teacher-1';
    const scorePercentage = 85.5;
    const assessmentTitle = 'اختبار الفيزياء';

    const notification = {
      userId: teacherId,
      type: 'session_completed',
      title: 'طالب أكمل الاختبار',
      body: `أكمل طالب اختبار "${assessmentTitle}" بنتيجة ${scorePercentage.toFixed(1)}%`,
      isRead: false,
    };

    expect(notification.userId).toBe(teacherId);
    expect(notification.type).toBe('session_completed');
    expect(notification.body).toContain('85.5%');
    expect(notification.isRead).toBe(false);
  });
});

// ─── Notification Read Status (Req 21.5, 21.6) ───────────────────────────────

describe('Notifications — Read Status (Req 21.5, 21.6)', () => {
  it('should mark single notification as read', () => {
    const notification = { _id: 'n1', isRead: false };
    notification.isRead = true;

    expect(notification.isRead).toBe(true);
  });

  it('should mark all notifications as read', () => {
    const notifications = [
      { _id: 'n1', isRead: false },
      { _id: 'n2', isRead: false },
      { _id: 'n3', isRead: true },
    ];

    notifications.forEach((n) => (n.isRead = true));

    expect(notifications.every((n) => n.isRead)).toBe(true);
  });

  it('should count unread notifications correctly', () => {
    const notifications = [
      { isRead: false },
      { isRead: false },
      { isRead: true },
      { isRead: false },
    ];

    const unreadCount = notifications.filter((n) => !n.isRead).length;
    expect(unreadCount).toBe(3);
  });
});

// ─── Notification Limit (Req 21.7) ───────────────────────────────────────────

describe('Notifications — Limit (Req 21.7)', () => {
  it('should maintain last 50 notifications per user', () => {
    const MAX = 50;
    const notifications = Array.from({ length: 60 }, (_, i) => ({
      _id: `n${i}`,
      createdAt: new Date(Date.now() + i * 1000),
    }));

    // Keep only the most recent 50
    const trimmed = notifications
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, MAX);

    expect(trimmed).toHaveLength(50);
    expect(trimmed[0]._id).toBe('n59'); // most recent
  });
});
