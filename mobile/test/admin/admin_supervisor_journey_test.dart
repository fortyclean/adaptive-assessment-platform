import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/core/router/app_router.dart';
import 'package:adaptive_assessment/features/auth/repositories/admin_repository.dart';
import 'package:adaptive_assessment/features/auth/screens/classroom_management_screen.dart';
import 'package:adaptive_assessment/features/auth/screens/supervisor_dashboard_screen.dart';
import 'package:adaptive_assessment/features/reports/screens/school_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class AdminSupervisorJourneyFakeRepository extends AdminRepository {
  AdminSupervisorJourneyFakeRepository() : super(ApiService.instance);

  String? lastComparisonSubject;
  String? lastComparisonGradeLevel;
  String? lastWeaknessSubject;
  String? lastWeaknessGradeLevel;
  int getClassroomsCalls = 0;

  @override
  Future<Map<String, dynamic>> getSchoolReport() async => {
        'summary': {
          'totalStudents': 120,
          'totalTeachers': 8,
          'schoolAverage': 86,
          'participationRate': 94,
          'topClassroom': 'العاشر (أ)',
        },
      };

  @override
  Future<List<Map<String, dynamic>>> getClassroomComparison({
    String? term,
    String? subject,
    String? gradeLevel,
  }) async {
    lastComparisonSubject = subject;
    lastComparisonGradeLevel = gradeLevel;
    return [
      {
        'classroomName': 'العاشر (أ)',
        'averageScore': 91,
        'completionRate': 98,
        'topSkill': 'الجبر',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getWeakestSkills({
    String? subject,
    String? gradeLevel,
  }) async {
    lastWeaknessSubject = subject;
    lastWeaknessGradeLevel = gradeLevel;
    return [
      {'mainSkill': 'الدوال', 'averagePercentage': 62},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getClassrooms() async {
    getClassroomsCalls++;
    return const [];
  }
}

Future<GoRouter> _pumpJourney(
  WidgetTester tester,
  AdminSupervisorJourneyFakeRepository repository, {
  String initialLocation = AppRoutes.adminReports,
  Size viewportSize = const Size(900, 1800),
}) async {
  tester.view.physicalSize = viewportSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.adminReports,
        builder: (_, __) => const SchoolReportsScreen(
          initialGradeLevel: '10',
          initialSubject: 'الرياضيات',
        ),
      ),
      GoRoute(
        path: AppRoutes.adminClassrooms,
        builder: (_, __) => const ClassroomManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.supervisorDashboard,
        builder: (_, __) => const SupervisorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationCenter,
        builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _dragDownUntilTextIsBuilt(WidgetTester tester, String text) async {
  final scrollable = find.byType(CustomScrollView).first;
  for (var attempt = 0;
      attempt < 8 && find.text(text).evaluate().isEmpty;
      attempt++) {
    await tester.drag(scrollable, const Offset(0, -550));
    await tester.pumpAndSettle();
  }
}

void main() {
  group('Admin and supervisor journey tests', () {
    testWidgets(
        'opens school reports with initial filters and navigates onward',
        (tester) async {
      final repository = AdminSupervisorJourneyFakeRepository();
      await _pumpJourney(tester, repository);

      expect(find.text('تقارير المدرسة الكلية'), findsOneWidget);
      expect(find.textContaining('الرياضيات'), findsWidgets);
      expect(find.textContaining('المرحلة 10'), findsWidgets);
      expect(repository.lastComparisonSubject, 'الرياضيات');
      expect(repository.lastComparisonGradeLevel, '10');
      expect(repository.lastWeaknessSubject, 'الرياضيات');
      expect(repository.lastWeaknessGradeLevel, '10');

      final allClassroomsButton =
          find.widgetWithText(TextButton, 'عرض جميع الفصول');
      await tester.scrollUntilVisible(allClassroomsButton, 500);
      await tester.pumpAndSettle();
      await tester.tap(allClassroomsButton);
      await tester.pumpAndSettle();

      expect(find.byType(ClassroomManagementScreen), findsOneWidget);
      expect(repository.getClassroomsCalls, 1);
      expect(find.text('لا توجد فصول دراسية'), findsOneWidget);
    });

    testWidgets('opens supervisor dashboard as part of admin workflow',
        (tester) async {
      final repository = AdminSupervisorJourneyFakeRepository();
      await _pumpJourney(
        tester,
        repository,
        initialLocation: AppRoutes.supervisorDashboard,
      );

      expect(find.text('لوحة تحكم المشرف'), findsOneWidget);
      await _dragDownUntilTextIsBuilt(tester, 'تنبيهات الإدارة');
      expect(find.text('تنبيهات الإدارة'), findsWidgets);
      await _dragDownUntilTextIsBuilt(tester, 'وصول سريع');
      expect(find.text('وصول سريع'), findsWidgets);
    });

    testWidgets('renders school reports on a small phone viewport',
        (tester) async {
      final repository = AdminSupervisorJourneyFakeRepository();
      await _pumpJourney(
        tester,
        repository,
        viewportSize: const Size(390, 844),
      );

      expect(find.text('تقارير المدرسة الكلية'), findsOneWidget);
      expect(find.textContaining('الرياضيات'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders supervisor dashboard on tablet landscape',
        (tester) async {
      final repository = AdminSupervisorJourneyFakeRepository();
      await _pumpJourney(
        tester,
        repository,
        initialLocation: AppRoutes.supervisorDashboard,
        viewportSize: const Size(1280, 800),
      );

      expect(find.text('لوحة تحكم المشرف'), findsOneWidget);
      await _dragDownUntilTextIsBuilt(tester, 'وصول سريع');
      expect(find.text('وصول سريع'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
