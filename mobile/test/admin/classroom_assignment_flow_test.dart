import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/features/auth/repositories/admin_repository.dart';
import 'package:adaptive_assessment/features/auth/screens/classroom_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class ClassroomAssignmentFakeRepository extends AdminRepository {
  ClassroomAssignmentFakeRepository() : super(ApiService.instance);

  final classrooms = <Map<String, dynamic>>[
    {
      '_id': 'class-a',
      'name': 'الأول المتوسط (أ)',
      'gradeLevel': 'الأول المتوسط',
      'academicYear': '2026',
      'teacherId': null,
      'teacherName': 'غير محدد',
      'studentIds': [
        {'_id': 'student-1', 'fullName': 'سارة خالد'},
      ],
      'activeAssessments': 1,
      'averageScore': 82,
    },
    {
      '_id': 'class-b',
      'name': 'الثاني المتوسط (ب)',
      'gradeLevel': 'الثاني المتوسط',
      'academicYear': '2026',
      'teacherId': 'teacher-old',
      'teacherName': 'أ. قديم',
      'studentIds': <String>[],
      'activeAssessments': 0,
      'averageScore': 74,
    },
  ];

  final teachers = <Map<String, dynamic>>[
    {
      '_id': 'teacher-1',
      'fullName': 'أ. علي حسن',
      'subject': 'الرياضيات',
      'role': 'teacher',
      'isActive': true,
    },
    {
      '_id': 'teacher-2',
      'fullName': 'أ. منى سالم',
      'subject': 'العلوم',
      'role': 'teacher',
      'isActive': true,
    },
  ];

  final students = <Map<String, dynamic>>[
    {
      '_id': 'student-1',
      'fullName': 'سارة خالد',
      'username': 'STU-001',
      'grade': 'الأول المتوسط',
      'role': 'student',
      'isActive': true,
    },
    {
      '_id': 'student-2',
      'fullName': 'ليان أحمد',
      'username': 'STU-002',
      'grade': 'الأول المتوسط',
      'role': 'student',
      'isActive': true,
    },
  ];

  int createClassroomCalls = 0;
  int assignTeachersCalls = 0;
  int assignStudentsCalls = 0;
  int deleteClassroomCalls = 0;
  String? lastRoleFilter;
  bool? lastIsActiveFilter;
  String? lastClassroomId;
  List<String>? lastTeacherIds;
  List<String>? lastStudentIds;
  Map<String, dynamic>? lastCreatePayload;

  @override
  Future<List<Map<String, dynamic>>> getClassrooms() async =>
      classrooms.map(Map<String, dynamic>.from).toList();

  @override
  Future<Map<String, dynamic>> createClassroom(
    Map<String, dynamic> data,
  ) async {
    createClassroomCalls++;
    lastCreatePayload = Map<String, dynamic>.from(data);
    final created = {
      '_id': 'created-$createClassroomCalls',
      ...data,
      'teacherName': 'غير محدد',
      'studentIds': <String>[],
      'activeAssessments': 0,
      'averageScore': null,
    };
    classrooms.insert(0, created);
    return created;
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers({
    String? search,
    String? role,
    bool? isActive,
  }) async {
    lastRoleFilter = role;
    lastIsActiveFilter = isActive;
    final source = role == 'teacher' ? teachers : students;
    return source.map(Map<String, dynamic>.from).toList();
  }

  @override
  Future<void> assignTeachers(
    String classroomId,
    List<String> teacherIds,
  ) async {
    assignTeachersCalls++;
    lastClassroomId = classroomId;
    lastTeacherIds = List<String>.from(teacherIds);
    final teacher = teachers.firstWhere((t) => t['_id'] == teacherIds.first);
    final index = classrooms.indexWhere((c) => c['_id'] == classroomId);
    classrooms[index] = {
      ...classrooms[index],
      'teacherId': teacher['_id'],
      'teacherName': teacher['fullName'],
    };
  }

  @override
  Future<void> assignStudents(
    String classroomId,
    List<String> studentIds,
  ) async {
    assignStudentsCalls++;
    lastClassroomId = classroomId;
    lastStudentIds = List<String>.from(studentIds)..sort();
    final selectedStudents =
        students.where((student) => studentIds.contains(student['_id']));
    final index = classrooms.indexWhere((c) => c['_id'] == classroomId);
    classrooms[index] = {
      ...classrooms[index],
      'studentIds': selectedStudents.map(Map<String, dynamic>.from).toList(),
    };
  }

  @override
  Future<void> deleteClassroom(String id) async {
    deleteClassroomCalls++;
    classrooms.removeWhere((classroom) => classroom['_id'] == id);
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  ClassroomAssignmentFakeRepository repository,
) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const ClassroomManagementScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisibleText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text).first,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  group('ClassroomManagementScreen admin assignment flow', () {
    testWidgets('creates a classroom and refreshes the list', (tester) async {
      final repository = ClassroomAssignmentFakeRepository();
      await _pumpScreen(tester, repository);

      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'ثالث متوسط (ج)');
      await tester.enterText(fields.at(1), 'الثالث المتوسط');
      await tester.enterText(fields.at(2), '2026');
      await tester.tap(find.text('إنشاء'));
      await tester.pumpAndSettle();

      expect(repository.createClassroomCalls, 1);
      expect(repository.lastCreatePayload?['name'], 'ثالث متوسط (ج)');
      expect(repository.lastCreatePayload?['gradeLevel'], 'الثالث المتوسط');
      expect(repository.lastCreatePayload?['academicYear'], '2026');
      expect(find.text('ثالث متوسط (ج)'), findsOneWidget);
    });

    testWidgets('assigns an active teacher to a classroom', (tester) async {
      final repository = ClassroomAssignmentFakeRepository();
      await _pumpScreen(tester, repository);

      await _tapVisibleText(tester, 'ربط معلم');
      expect(repository.lastRoleFilter, 'teacher');
      expect(repository.lastIsActiveFilter, isTrue);

      await tester.tap(find.text('أ. علي حسن'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تأكيد الربط'));
      await tester.pumpAndSettle();

      expect(repository.assignTeachersCalls, 1);
      expect(repository.lastClassroomId, 'class-a');
      expect(repository.lastTeacherIds, ['teacher-1']);
      expect(find.text('أ. علي حسن'), findsWidgets);
    });

    testWidgets('updates the assigned student set for a classroom',
        (tester) async {
      final repository = ClassroomAssignmentFakeRepository();
      await _pumpScreen(tester, repository);

      await _tapVisibleText(tester, 'ربط طلاب');
      expect(repository.lastRoleFilter, 'student');
      expect(repository.lastIsActiveFilter, isTrue);

      await tester.tap(find.text('ليان أحمد'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ الطلاب'));
      await tester.pumpAndSettle();

      expect(repository.assignStudentsCalls, 1);
      expect(repository.lastClassroomId, 'class-a');
      expect(repository.lastStudentIds, ['student-1', 'student-2']);
      expect(find.textContaining('ليان أحمد'), findsWidgets);
    });

    testWidgets('deletes a classroom only after confirmation', (tester) async {
      final repository = ClassroomAssignmentFakeRepository();
      await _pumpScreen(tester, repository);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();
      expect(repository.deleteClassroomCalls, 0);

      await tester.tap(find.text('حذف').last);
      await tester.pumpAndSettle();

      expect(repository.deleteClassroomCalls, 1);
      expect(find.text('الأول المتوسط (أ)'), findsNothing);
      expect(find.text('الثاني المتوسط (ب)'), findsOneWidget);
    });
  });
}
