# Retention Metrics and Product Events

Version: 1.0.72

The app now has enough student, teacher, admin, notification, points, and micro-learning flows to define measurable retention events before adding analytics tooling.

## North Star Metric

Weekly active learners who complete at least one assessment or one micro-learning lesson and view a recommendation.

## Core Events

| Event | Role | Trigger | Why It Matters |
|---|---|---|---|
| `login_success` | all | User signs in successfully | Activation and reliability. |
| `demo_login_success` | all | User enters demo mode | Sales/demo funnel. |
| `assessment_started` | student | Student starts an assessment | Learning intent. |
| `assessment_submitted` | student | Student completes or submits an assessment | Core product value. |
| `result_viewed` | student | Student opens result details | Feedback consumption. |
| `recommendation_opened` | student | Student taps a recommendation | Personalization quality. |
| `micro_lesson_started` | student | Student starts a lesson | Retention loop. |
| `micro_lesson_completed` | student | Student completes a lesson | Learning progress. |
| `points_store_purchase` | student | Student redeems points | Gamification engagement. |
| `challenge_completed` | student | Student completes daily/weekly challenge | Habit formation. |
| `assessment_created` | teacher | Teacher creates a draft | Teacher activation. |
| `assessment_published` | teacher | Teacher publishes to classrooms | Classroom adoption. |
| `report_exported` | teacher/admin | Report is exported | Institutional value. |
| `classroom_assigned` | admin | Admin assigns students/teachers | Setup completeness. |
| `notification_opened` | all | User opens a notification | Message relevance. |

## Retention Reports

- D1/D7/D30 retention by role.
- Assessment completion rate by classroom.
- Recommendation-to-micro-lesson conversion.
- Teacher publish rate after account creation.
- Admin setup completion: users created, classrooms created, teachers/students assigned.
- Notification open rate by notification type.

## Privacy Rules

- Do not send raw student answers to analytics providers.
- Do not send tokens, passwords, refresh tokens, or client secrets.
- Use IDs that can be rotated or deleted.
- Provide a school-level opt-out before public production launch.
