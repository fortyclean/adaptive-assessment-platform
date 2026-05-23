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
      expect(marketplaceSource, contains('_pointsBalance -= item.price'));
      expect(marketplaceSource, contains('_ownedItemIds.add(item.id)'));
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
  });
}
