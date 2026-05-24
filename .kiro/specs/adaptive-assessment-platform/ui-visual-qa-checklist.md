# UI, Dark Mode, and Responsive QA Checklist

Version scope: 1.0.63 and later

## Purpose

This checklist keeps every release honest about visual quality before an APK is shared. It is focused on the remaining UI debt that affects dark mode, small screens, and tablet landscape.

## Current Color Debt Scan

Scan command:

```powershell
rg "Colors\.white|Colors\.black|Color\(0xFF" mobile/lib -n --glob "*.dart"
```

Highest-impact files from the latest scan:

| Priority | File | White | Black | Hex | Classification | Recommendation |
|---:|---|---:|---:|---:|---|---|
| 1 | `mobile/lib/features/reports/screens/student_academic_profile_screen.dart` | 3 | 0 | 59 | Medium risk | Main shells now use `AppSectionCard`; continue converting chart/badge semantic colors carefully. |
| 2 | `mobile/lib/features/reports/screens/report_schedule_screen.dart` | 14 | 1 | 46 | High risk | Replace non-branded cards and form fields with theme-aware surfaces. |
| 3 | `mobile/lib/features/auth/screens/ui_feedback_screen.dart` | 14 | 6 | 27 | High risk | Treat as visual QA/demo surface; align overlays, cards, and modal colors with theme. |
| 4 | `mobile/lib/features/auth/screens/admin_dashboard_v2_screen.dart` | 8 | 5 | 25 | Medium risk | Preserve bento design, but move card/surface colors to colorScheme. |
| 5 | `mobile/lib/features/reports/screens/school_reports_screen.dart` | 10 | 1 | 22 | Medium risk | Continue replacing white report cards after export validation work. |
| 6 | `mobile/lib/features/auth/screens/support_screen.dart` | 10 | 4 | 19 | Medium risk | Replace form/card backgrounds and keep CTA contrast. |
| 7 | `mobile/lib/features/assessment/screens/student_challenges_screen.dart` | 17 | 2 | 14 | Medium risk | Distinguish intentional badge colors from hardcoded surfaces. |
| 8 | `mobile/lib/features/auth/screens/classroom_management_screen.dart` | 17 | 1 | 12 | Medium risk | Use shared admin cards once 37.3 starts. |
| 9 | `mobile/lib/features/reports/screens/certificates_screen.dart` | 16 | 1 | 13 | Medium risk | Keep certificate template colors intentional; convert only shell surfaces. |
| 10 | `mobile/lib/features/auth/screens/admin_dashboard_screen.dart` | 12 | 4 | 11 | Medium risk | Legacy admin dashboard needs gradual theme migration. |

## Classification Rules

| Category | Keep | Replace |
|---|---|---|
| Brand/logo colors | Google icon colors, certificate accent colors, badge identity colors | None unless contrast fails |
| Foreground on primary | `Colors.white` inside primary buttons, icons on colored circles, loading spinner on primary button | Replace only if contrast fails |
| Surface/card backgrounds | Plain cards, scaffold sections, bottom sheets, form fills | Replace with `colorScheme.surface`, `surfaceContainerHighest`, or `cardTheme.color` |
| Text and icons | Decorative white text over gradient/primary areas | Replace fixed dark text with `onSurface`/`onSurfaceVariant` |
| Shadows/overlays | Subtle black alpha shadows, modal scrims | Keep if theme contrast is acceptable; avoid opaque black/white |

## Release Visual QA Checklist

Before building a release APK:

- Run `flutter analyze`.
- Run `flutter test`.
- Run at least one small-phone widget test for a critical admin/supervisor flow.
- Run at least one tablet-landscape widget test for a critical admin/supervisor flow.
- Toggle dark mode from Settings and confirm the selected mode persists in `themeModeProvider`.
- Verify login, notifications, admin reports, classroom management, student dashboard, and teacher dashboard do not show blank white panels in dark mode.
- Verify Arabic RTL alignment on the same screens.
- Verify text does not overflow on a 390px-wide viewport.
- Verify primary CTA labels remain readable in light and dark themes.
- Verify empty/error/loading states use clear Arabic copy and visible retry/action controls where appropriate.
- Re-run the color debt scan and update this file when a high-risk screen is completed.

## Next Recommended Batch

Continue with `report_schedule_screen.dart` and `ui_feedback_screen.dart`; `student_academic_profile_screen.dart` now has a shared card baseline and a small-phone dark-mode regression test.
