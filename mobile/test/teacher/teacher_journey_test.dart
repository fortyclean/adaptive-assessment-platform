import 'package:adaptive_assessment/features/assessment/repositories/teacher_repository.dart';
import 'package:adaptive_assessment/features/assessment/screens/class_schedule_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/create_assessment_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/manage_assessments_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/task_management_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/teacher_dashboard_screen.dart';
import 'package:adaptive_assessment/features/question_bank/screens/advanced_question_editor_screen.dart';
import 'package:adaptive_assessment/features/question_bank/screens/question_bank_screen.dart';
import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class TeacherJourneyFakeRepository extends TeacherRepository {
  TeacherJourneyFakeRepository() : super(ApiService.instance);

  int createAssessmentCalls = 0;
  int publishAssessmentCalls = 0;
  Map<String, dynamic>? lastCreatePayload;
  String? lastPublishedAssessmentId;

  @override
  Future<List<Map<String, dynamic>>> getAssessments({String? status}) async {
    final assessments = [
      {
        '_id': 'journey-draft-1',
        'title': 'اختبار الجبر التشخيصي',
        'subject': 'الرياضيات',
        'status': 'draft',
        'assessmentType': 'adaptive',
        'questionCount': 10,
        'studentCount': 24,
        'averageScore': 78,
      },
      {
        '_id': 'journey-active-1',
        'title': 'اختبار القراءة السريعة',
        'subject': 'اللغة العربية',
        'status': 'active',
        'assessmentType': 'random',
        'questionCount': 12,
        'studentCount': 18,
        'averageScore': 84,
      },
    ];
    if (status == null) return assessments;
    return assessments.where((item) => item['status'] == status).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getClassrooms() async => [
        {
          '_id': 'class-a',
          'name': 'الصف السابع - أ',
          'gradeLevel': 'الصف السابع',
        },
      ];

  @override
  Future<Map<String, dynamic>> createAssessment(
    Map<String, dynamic> data,
  ) async {
    createAssessmentCalls++;
    lastCreatePayload = Map<String, dynamic>.from(data);
    return {'_id': 'created-assessment-1', ...data};
  }

  @override
  Future<void> publishAssessment(String id) async {
    publishAssessmentCalls++;
    lastPublishedAssessmentId = id;
  }

  @override
  Future<Map<String, dynamic>> getQuestions({
    Map<String, dynamic>? filters,
    int page = 1,
  }) async =>
      {
        'total': 1,
        'questions': [
          {
            '_id': 'q-1',
            'questionText': 'ما ناتج 2 + 3؟',
            'subject': 'رياضيات',
            'difficulty': 'easy',
            'mainSkill': 'الجمع',
            'questionType': 'mcq',
          },
        ],
      };
}

Widget _wrapWithRouter({
  required TeacherJourneyFakeRepository repository,
  String initialLocation = '/teacher',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/teacher',
        builder: (_, __) => const TeacherDashboardScreen(),
        routes: [
          GoRoute(
            path: 'assessments',
            builder: (_, __) => const ManageAssessmentsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateAssessmentScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'questions',
            builder: (_, __) => const QuestionBankScreen(),
          ),
          GoRoute(
            path: 'questions/advanced',
            builder: (_, __) => const AdvancedQuestionEditorScreen(),
          ),
          GoRoute(
            path: 'tasks',
            builder: (_, __) => const TaskManagementScreen(),
          ),
          GoRoute(
            path: 'class-schedule',
            builder: (_, __) => const ClassScheduleScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      teacherRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _selectDropdownItem(
  WidgetTester tester, {
  required String hint,
  required String value,
}) async {
  await tester.ensureVisible(find.text(hint));
  await tester.tap(find.text(hint), warnIfMissed: false);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

void main() {
  group('Teacher journey', () {
    testWidgets('navigates through core teacher workflow screens',
        (tester) async {
      final repository = TeacherJourneyFakeRepository();
      await tester.binding.setSurfaceSize(const Size(800, 2200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrapWithRouter(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('إنشاء اختبار جديد'), findsOneWidget);
      expect(find.text('اختبار الجبر التشخيصي'), findsOneWidget);

      await tester.tap(find.text('إنشاء اختبار جديد'));
      await tester.pumpAndSettle();
      expect(find.text('حفظ الاختبار كمسودة'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('إدارة المهام'));
      await tester.tap(find.text('إدارة المهام'));
      await tester.pumpAndSettle();
      expect(find.text('إدارة المهام'), findsOneWidget);
      expect(find.textContaining('حالة محلية'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('الجدول الدراسي'));
      await tester.tap(find.text('الجدول الدراسي'));
      await tester.pumpAndSettle();
      expect(find.text('الجداول الدراسية'), findsOneWidget);
      expect(find.textContaining('لا يوجد API للجدول الدراسي بعد'),
          findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('بنك الأسئلة').last);
      await tester.pumpAndSettle();
      expect(find.text('بنك الأسئلة'), findsOneWidget);
      expect(find.text('ما ناتج 2 + 3؟'), findsOneWidget);
    });

    testWidgets('creates and publishes an assessment with classroom assignment',
        (tester) async {
      final repository = TeacherJourneyFakeRepository();
      await tester.binding.setSurfaceSize(const Size(800, 2600));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrapWithRouter(
        repository: repository,
        initialLocation: '/teacher/assessments/create',
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'اختبار رحلة المعلم',
      );
      await _selectDropdownItem(
        tester,
        hint: 'اختر المادة...',
        value: 'الرياضيات',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'الوحدة الأولى');
      await _selectDropdownItem(
        tester,
        hint: 'اختر المرحلة...',
        value: 'الصف السابع',
      );
      await tester.ensureVisible(find.text('الصف السابع - أ'));
      await tester.tap(find.text('الصف السابع - أ'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('نشر الاختبار مباشرة بعد الإنشاء'));
      await tester.tap(find.text('نشر الاختبار مباشرة بعد الإنشاء'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('تأكيد وإنشاء ونشر الاختبار'));
      await tester.tap(find.text('تأكيد وإنشاء ونشر الاختبار'));
      await tester.pumpAndSettle();

      expect(repository.createAssessmentCalls, 1);
      expect(repository.publishAssessmentCalls, 1);
      expect(repository.lastPublishedAssessmentId, 'created-assessment-1');
      expect(repository.lastCreatePayload?['title'], 'اختبار رحلة المعلم');
      expect(repository.lastCreatePayload?['subject'], 'الرياضيات');
      expect(repository.lastCreatePayload?['classroomIds'], ['class-a']);
      expect(find.text('تم إنشاء الاختبار ونشره بنجاح'), findsOneWidget);
    });

    testWidgets(
        'keeps AI question generation visibly disabled until backend is ready',
        (tester) async {
      final repository = TeacherJourneyFakeRepository();
      await tester.pumpWidget(_wrapWithRouter(
        repository: repository,
        initialLocation: '/teacher/questions/advanced',
      ));
      await tester.pumpAndSettle();

      expect(find.text('قيد التخطيط'), findsOneWidget);
      await tester.tap(find.text('قيد التخطيط'));
      await tester.pumpAndSettle();

      expect(find.text('مساعد توليد الأسئلة'), findsOneWidget);
      expect(find.text('التوليد التلقائي قيد التخطيط'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(
                OutlinedButton,
                'التوليد التلقائي قيد التخطيط',
              ),
            )
            .onPressed,
        isNull,
      );
    });
  });
}
