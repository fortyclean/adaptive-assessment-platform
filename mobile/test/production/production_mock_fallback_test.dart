import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Production mock fallback guards', () {
    bool hasExplicitDemoGuard(String source) =>
        source.contains('AppConstants.useMockData') &&
        source.contains("startsWith('demo-token-')");

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

    test(
        'TeacherDashboardScreen and TeacherHomeScreen do not expose static production placeholders',
        () {
      final dashboardSource = File(
        'lib/features/assessment/screens/teacher_dashboard_screen.dart',
      ).readAsStringSync();
      final homeSource = File(
        'lib/features/assessment/screens/teacher_home_screen.dart',
      ).readAsStringSync();

      expect(dashboardSource, contains('_shouldUseDemoFallback'));
      expect(dashboardSource, contains('_errorMessage'));
      expect(dashboardSource, contains('_demoAssessments'));
      expect(
        dashboardSource,
        isNot(contains(
            "_assessments = [\n            {\n              '_id': '1'")),
      );
      expect(
        dashboardSource,
        isNot(contains("value: '\${_assessments.length * 5}'")),
      );
      expect(homeSource, contains('TeacherDashboardScreen'));
      expect(homeSource, isNot(contains("'8 فصول'")));
      expect(homeSource, isNot(contains("'12'")));
      expect(homeSource, isNot(contains("'5'")));
    });

    test('Marketplace purchase flow updates local redemption state', () {
      final marketplaceSource = File(
        'lib/features/assessment/screens/marketplace_screen.dart',
      ).readAsStringSync();
      final studentMarketplaceSource = File(
        'lib/features/assessment/screens/student_marketplace_screen.dart',
      ).readAsStringSync();

      expect(marketplaceSource, contains('_confirmPurchase'));
      expect(marketplaceSource, contains('StudentPointsStore'));
      expect(marketplaceSource, contains('_pointsBalance -= item.price'));
      expect(marketplaceSource,
          contains('_ownedItemIds = {..._ownedItemIds, item.id}'));
      expect(marketplaceSource, contains('_showCollectionSheet'));
      expect(marketplaceSource, isNot(contains('ScaffoldMessenger.of')));
      expect(studentMarketplaceSource, contains('MarketplaceScreen'));
      expect(
          studentMarketplaceSource, isNot(contains('Mock marketplace items')));
    });

    test('StudentChallengesScreen uses visible challenge states, not SnackBars',
        () {
      final source = File(
        'lib/features/assessment/screens/student_challenges_screen.dart',
      ).readAsStringSync();

      expect(source, contains('enum ChallengeStatus'));
      expect(source, contains('ChallengeStatus.joinable'));
      expect(source, contains('ChallengeStatus.joined'));
      expect(source, contains('ChallengeStatus.completed'));
      expect(source, contains('ChallengeStatus.locked'));
      expect(source, contains('_joinChallenge'));
      expect(source, contains('_showCreateChallengeSheet'));
      expect(source, isNot(contains('ScaffoldMessenger.of')));
      expect(source, isNot(contains('SnackBar(')));
    });

    test('TaskManagementScreen replaces unfinished actions with local state',
        () {
      final taskSource = File(
        'lib/features/assessment/screens/task_management_screen.dart',
      ).readAsStringSync();
      final teacherTaskSource = File(
        'lib/features/assessment/screens/teacher_task_management_screen.dart',
      ).readAsStringSync();

      expect(taskSource, contains('_showTaskEditor'));
      expect(taskSource, contains('_confirmDelete'));
      expect(taskSource, contains('_publishDraft'));
      expect(taskSource, contains('_completeTask'));
      expect(taskSource, contains('_TaskStatus'));
      expect(taskSource, contains('local state model'));
      expect(taskSource, isNot(contains('قيد التطوير')));
      expect(taskSource, isNot(contains('ScaffoldMessenger.of')));
      expect(taskSource, isNot(contains('SnackBar(')));
      expect(teacherTaskSource, contains('extends TaskManagementScreen'));
    });

    test('production fallback screens require explicit mock mode or demo token',
        () {
      final guardedFiles = {
        'manage assessments':
            'lib/features/assessment/screens/manage_assessments_screen.dart',
        'student dashboard':
            'lib/features/assessment/screens/student_dashboard_screen.dart',
        'student assessments':
            'lib/features/assessment/screens/student_assessments_screen.dart',
        'teacher dashboard':
            'lib/features/assessment/screens/teacher_dashboard_screen.dart',
        'assessment start':
            'lib/features/assessment/screens/assessment_start_screen.dart',
        'report schedules':
            'lib/features/reports/screens/report_schedule_screen.dart',
        'certificates': 'lib/features/reports/screens/certificates_screen.dart',
        'excel import':
            'lib/features/question_bank/screens/import_excel_screen.dart',
      };

      for (final entry in guardedFiles.entries) {
        final source = File(entry.value).readAsStringSync();
        expect(
          hasExplicitDemoGuard(source),
          isTrue,
          reason:
              '${entry.key} must gate demo/mock fallback behind useMockData or demo-token sessions.',
        );
      }
    });

    test('ReportScheduleScreen does not load mock schedules in production', () {
      final source = File(
        'lib/features/reports/screens/report_schedule_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_shouldUseDemoFallback'));
      expect(source, contains('_schedules = _shouldUseDemoFallback'));
      expect(source, contains('? _mockSchedules'));
      expect(source, contains('_errorMessage = _shouldUseDemoFallback'));
      expect(source, isNot(contains('Fallback to mock data so the screen')));
      expect(source, isNot(contains('_schedules = _mockSchedules.map')));
      expect(
        source,
        isNot(contains('// Demo mode: simulate success')),
      );
    });

    test('CertificatesScreen does not inject demo students in production', () {
      final source = File(
        'lib/features/reports/screens/certificates_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_shouldUseDemoFallback'));
      expect(source, contains('_students = _shouldUseDemoFallback'));
      expect(source, contains('_classrooms = []'));
    });

    test('AssessmentStartScreen requires explicit demo mode for local attempts',
        () {
      final source = File(
        'lib/features/assessment/screens/assessment_start_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_isDemoAssessmentId'));
      expect(source, contains('_shouldUseDemoFallback'));
      expect(source, contains('token.startsWith'));
      expect(
        source,
        isNot(contains(
            "widget.assessmentId == '2' ||\n          AppConstants.useMockData")),
      );
      expect(source, isNot(contains('// Auto fallback to demo')));
    });

    test('Excel import demo result is never used for production API gaps', () {
      final source = File(
        'lib/features/question_bank/screens/import_excel_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_shouldUseDemoFallback'));
      expect(source, contains('if (_shouldUseDemoFallback &&'));
      expect(source, contains('_demoResult(file.name)'));
      expect(
        source,
        isNot(contains("If backend doesn't support import yet")),
      );
    });
  });
}
