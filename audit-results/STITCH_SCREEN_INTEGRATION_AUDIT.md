# Stitch Screen Coverage & Integration Audit

Reviewed: 2026-06-23

## Verdict

The Flutter application contains an implementation counterpart for the Stitch reference set and its principal student, teacher, administrator, authentication, reporting, notification, onboarding, and advanced-tool flows are represented in code. The implementation is substantially connected through `GoRouter`, not merely a set of static mockup widgets.

It is **not accurate** to claim that every reference is independently routed and pixel-perfectly verified. Several Stitch files are alternative states of the same journey and are deliberately consolidated in Flutter; visual equivalence across all references has not been established by automated screenshot comparison.

## Coverage assessment

| Area | Reference coverage | Route/flow status | Evidence |
|---|---|---|---|
| Authentication and onboarding | Implemented | Direct routes for onboarding, login, signup, password reset/change, and account settings | `app_router.dart`, widget tests, Android login smoke test |
| Student assessment journey | Implemented | Dashboard, assessment list, start, exam, results, progress, analytics, subjects, challenges, and settings are routed | `app_router.dart`; Android student smoke test |
| Teacher workflow | Implemented | Dashboard, assessment creation/management, question-bank/import, reports, schedules, classes, tasks, certificates, and settings are routed | `app_router.dart`; Android teacher smoke test |
| Administrator workflow | Implemented | Dashboard, users, classrooms, reports, institution/account settings are routed | `app_router.dart`; Android administrator smoke test |
| Screens 32–75 | Implemented as planned | Most are routed as primary screens or consolidated variants | Phase 3 task plan and widget tests |

## Confirmed integration findings

1. **Fixed:** `studentExamWithImage`, `studentExamWithBookmark`, and `studentExamWithTimerToggle` previously opened the generic `ExamScreen`. They now open `ExamWithImageScreen`, `ExamWithBookmarkScreen`, and `ExamWithTimerToggleScreen` respectively. A regression test protects these mappings.
2. **Consolidated variants:** several Stitch reference images are alternatives/states of one Flutter screen rather than separate routes. This is acceptable only when the matching interaction remains available; it is not proof of pixel-perfect parity.
3. **Unreachable or legacy screen classes:** `EssayGradingScreen`, `PendingEssaysScreen`, `QualityIndicatorScreen`, and the legacy `NotificationsScreen` have no direct `GoRouter` mapping in the current router. They should either be linked from their owner journeys or explicitly retired/merged to avoid dead product surface.
4. **Visual verification gap:** the Android smoke test covers the login flow and the three role dashboards plus one primary action each. It does not provide screen-by-screen screenshot comparison against all Stitch references.

## Recommended next batch

1. Add accessible routes and entry points for pending essays and essay grading.
2. Add a quality-indicator entry point from question-bank workflows with explicit subject/grade/unit parameters.
3. Retire or route the legacy notifications implementation after deciding which notification UI is canonical.
4. Add screenshot-golden checks for the high-traffic Stitch screens before claiming pixel-perfect completion.
