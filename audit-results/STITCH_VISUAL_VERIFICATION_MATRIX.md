# Stitch Visual Verification Matrix

Reviewed: 2026-06-24

This matrix covers all 75 numbered Stitch references. “Implemented” means a Flutter counterpart is present in the product flow; “Live smoke” means the physical-device run exercised that area. It does **not** claim pixel-perfect comparison until a reference screenshot diff is recorded.

| Stitch references | Product area | Flutter counterpart | Live smoke | Screenshot-diff status |
|---|---|---|---|---|
| 1–12 | Teacher assessment, bank, reports, and settings | Teacher dashboard, assessment management, question bank, reports, settings | Teacher dashboard and create-assessment form | Pending |
| 13–27 | Student dashboard, start/exam/result, points, notifications, authentication | Student dashboard, assessment flow, result, notifications, auth | Student dashboard and login | Pending |
| 28–35 | Admin reports and notification/scheduling flows | Admin dashboard/reports, notification center/settings, report schedules | Admin dashboard | Pending |
| 36–43 | Performance alerts and student assessment variants | Alert, student dashboard/list, specialized exam routes | Student dashboard | Pending |
| 44–55 | Onboarding, account/profile, and settings variants | Onboarding, account settings, signup, support, profile surfaces | Login only | Pending |
| 56–65 | Student profile, analytics, micro-learning, challenges | Detail profile, analytics, micro-learning, challenges | Not exercised | Pending |
| 66–75 | Marketplace, tasks, admin tools, schedule, certificates, classes, advanced editor | Marketplace, tasks, supervisor/institution settings, schedule, certificates, classes, editor | Teacher/admin primary actions | Pending |

## Device evidence already captured

- Login and demo role selection: Student, teacher, and administrator.
- Student, teacher, and administrator dashboard render.
- Teacher create-assessment form and administrator user-management navigation.
- Offline demo launch and student empty-assessment state.

## Required before pixel-perfect sign-off

1. Capture a baseline screenshot for each numbered reference on a fixed Android viewport.
2. Compare the Flutter capture with the matching Stitch `screen.png` for typography, RTL alignment, spacing, colors, and interaction states.
3. Record pass/fail and a linked artifact for each reference; unresolved differences become tasks, not implicit acceptance.
