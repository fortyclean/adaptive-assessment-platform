import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Production mock fallback guards', () {
    test(
        'ManageAssessmentsScreen does not silently show mock data in production',
        () {
      final source = File(
        'lib/features/assessment/screens/manage_assessments_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_shouldUseDemoFallback'));
      expect(
        source,
        isNot(contains(
            '_assessments = data.isNotEmpty ? data : _mockAssessments')),
      );
      expect(
        source,
        isNot(contains(
            '_assessments = _mockAssessments;\n        _isLoading = false;')),
      );
      expect(source, contains('_errorMessage'));
    });

    test(
        'StudentDashboardScreen does not inject fake dashboard stats in production',
        () {
      final source = File(
        'lib/features/assessment/screens/student_dashboard_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_shouldUseDemoFallback'));
      expect(source, contains('_errorMessage'));
      expect(
        source,
        isNot(contains(
            '_totalAssessments = 5;\n          _averageScore = 78.5;')),
      );
      expect(
        source,
        isNot(contains(
            "_upcomingAssessments = [\n            {\n              '_id': '1'")),
      );
    });
  });
}
