import 'package:flutter/material.dart';

import 'teacher_dashboard_screen.dart';

/// Backward-compatible route for the older teacher home screen.
///
/// The previous implementation was a static design-only page. Keeping this
/// route mapped to the real teacher dashboard prevents production users from
/// seeing hardcoded counts, charts, or unfinished announcement flows.
class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const TeacherDashboardScreen();
}
