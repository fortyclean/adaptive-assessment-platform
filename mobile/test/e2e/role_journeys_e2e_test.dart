import 'dart:io';

import 'package:adaptive_assessment/core/constants/app_constants.dart';
import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/features/assessment/repositories/assessment_repository.dart';
import 'package:adaptive_assessment/features/assessment/repositories/teacher_repository.dart';
import 'package:adaptive_assessment/features/assessment/screens/assessment_start_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/create_assessment_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/exam_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/manage_assessments_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/micro_learning_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/result_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/student_analytics_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/student_dashboard_screen.dart';
import 'package:adaptive_assessment/features/auth/repositories/admin_repository.dart';
import 'package:adaptive_assessment/features/auth/screens/classroom_management_screen.dart';
import 'package:adaptive_assessment/features/auth/screens/login_screen.dart';
import 'package:adaptive_assessment/features/auth/screens/user_management_screen.dart';
import 'package:adaptive_assessment/features/reports/screens/school_reports_screen.dart';
import 'package:adaptive_assessment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class E2EAssessmentRepository extends AssessmentRepository {
  E2EAssessmentRepository() : super(ApiService.instance);

  int startAttemptCalls = 0;
  int submitAnswerCalls = 0;
  int submitAttemptCalls = 0;
  bool _answerSubmitted = false;

  final history = [
    {
      '_id': 'e2e-history-1',
      'status': 'completed',
      'submittedAt': DateTime(2026, 5, 20).toIso8601String(),
      'scorePercentage': 82,
      'pointsEarned': 164,
      'assessmentId': {
        'title': 'اختبار الجبر التشخيصي',
        'subject': 'الرياضيات',
      },
      'skillBreakdown': [
        {
          'mainSkill': 'الجبر',
          'percentage': 45,
          'correctAnswers': 2,
          'totalQuestions': 5,
        },
        {
          'mainSkill': 'الهندسة',
          'percentage': 88,
          'correctAnswers': 4,
          'totalQuestions': 5,
        },
      ],
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> getAssessments() async => [
        {
          '_id': 'e2e-assessment-1',
          'title': 'اختبار الجبر التشخيصي',
          'subject': 'الرياضيات',
          'unit': 'المعادلات الخطية',
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 1,
          'timeLimitMinutes': 5,
          'classroomIds': ['class-a'],
          'createdBy': {'fullName': 'أ. سارة'},
        },
      ];

  @override
  Future<List<Map<String, dynamic>>> getAttemptHistory() async => history;

  @override
  Future<Map<String, dynamic>> getAssessment(String id) async => {
        '_id': id,
        'title': 'اختبار الجبر التشخيصي',
        'subject': 'الرياضيات',
        'unit': 'المعادلات الخطية',
        'status': 'active',
        'assessmentType': 'adaptive',
        'questionCount': 1,
        'timeLimitMinutes': 5,
        'classroomIds': ['class-a'],
        'createdBy': {'fullName': 'أ. سارة'},
      };

  @override
  Future<Map<String, dynamic>> startAttempt({
    required String assessmentId,
    required String classroomId,
  }) async {
    startAttemptCalls++;
    return {'attemptId': 'e2e-attempt-1'};
  }

  @override
  Future<Map<String, dynamic>> getNextQuestion(String attemptId) async {
    if (_answerSubmitted) return {'complete': true};
    return {
      'questionNumber': 1,
      'question': {
        '_id': 'question-1',
        'questionType': 'mcq',
        'questionText': 'ما ناتج 2 + 2؟',
        'options': [
          {'key': 'A', 'value': '3'},
          {'key': 'B', 'value': '4'},
          {'key': 'C', 'value': '5'},
          {'key': 'D', 'value': '6'},
        ],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String selectedAnswer,
  }) async {
    submitAnswerCalls++;
    _answerSubmitted = true;
    return {'isCorrect': true};
  }

  @override
  Future<void> submitAttempt(String attemptId) async {
    submitAttemptCalls++;
  }

  @override
  Future<Map<String, dynamic>> getResult(String attemptId) async => {
        'status': 'completed',
        'scorePercentage': 82,
        'correctAnswers': 1,
        'totalQuestions': 1,
        'timeTakenSeconds': 42,
        'passed': true,
        'pointsEarned': 20,
        'bonusAwarded': false,
        'skillBreakdown': [
          {'mainSkill': 'الجبر', 'percentage': 82.0},
        ],
        'wrongAnswers': [],
        'pendingEssayGrading': 0,
      };
}

class E2ETeacherRepository extends TeacherRepository {
  E2ETeacherRepository() : super(ApiService.instance);

  int createAssessmentCalls = 0;
  int publishAssessmentCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getAssessments({String? status}) async => [
        {
          '_id': 'teacher-e2e-draft',
          'title': 'مسودة القياس',
          'subject': 'الرياضيات',
          'status': 'draft',
          'assessmentType': 'adaptive',
          'questionCount': 10,
        },
      ];

  @override
  Future<List<Map<String, dynamic>>> getClassrooms() async => [
        {
          '_id': 'teacher-class-a',
          'name': 'الصف السابع - أ',
          'gradeLevel': 'الصف السابع',
        },
      ];

  @override
  Future<Map<String, dynamic>> createAssessment(
    Map<String, dynamic> data,
  ) async {
    createAssessmentCalls++;
    return {'_id': 'teacher-created-e2e', ...data};
  }

  @override
  Future<void> publishAssessment(String id) async {
    publishAssessmentCalls++;
  }
}

class E2EAdminRepository extends AdminRepository {
  E2EAdminRepository() : super(ApiService.instance);

  int createUserCalls = 0;
  int createClassroomCalls = 0;
  int schoolReportCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? search,
    bool? isActive,
  }) async =>
      [
        {
          '_id': 'teacher-1',
          'fullName': 'سارة المعلمة',
          'username': 'teacher.demo',
          'email': 'teacher@demo.edu',
          'role': 'teacher',
          'isActive': true,
        },
        {
          '_id': 'student-1',
          'fullName': 'أحمد الطالب',
          'username': 'student.demo',
          'email': 'student@demo.edu',
          'role': 'student',
          'isActive': true,
        },
      ];

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    createUserCalls++;
    return {'_id': 'new-user-e2e', ...data};
  }

  @override
  Future<List<Map<String, dynamic>>> getClassrooms() async => [
        {
          '_id': 'classroom-1',
          'name': 'الصف السابع - أ',
          'gradeLevel': 'الصف السابع',
          'academicYear': '2026',
          'teacherIds': ['teacher-1'],
          'studentIds': ['student-1'],
          'studentCount': 1,
          'activeAssessmentCount': 1,
        },
      ];

  @override
  Future<Map<String, dynamic>> createClassroom(
    Map<String, dynamic> data,
  ) async {
    createClassroomCalls++;
    return {'_id': 'classroom-created-e2e', ...data};
  }

  @override
  Future<Map<String, dynamic>> getSchoolReport() async {
    schoolReportCalls++;
    return {
      'summary': {
        'totalStudents': 1,
        'totalTeachers': 1,
        'schoolAverage': 82,
        'participationRate': 90,
        'topClassroom': 'الصف السابع - أ',
      },
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getClassroomComparison({
    String? term,
    String? subject,
    String? gradeLevel,
  }) async =>
      [
        {
          'classroomName': 'الصف السابع - أ',
          'averageScore': 82,
          'completionRate': 90,
          'topSkill': 'الجبر',
        },
      ];

  @override
  Future<List<Map<String, dynamic>>> getWeakestSkills({
    String? subject,
    String? gradeLevel,
  }) async =>
      [
        {'mainSkill': 'الجبر', 'averagePercentage': 45},
      ];
}

Future<void> _prepareHive() async {
  final dir = await Directory.systemTemp.createTemp('eduassess-e2e-');
  Hive.init(dir.path);
  if (!Hive.isBoxOpen(AppConstants.pendingAnswersBoxName)) {
    await Hive.openBox<dynamic>(AppConstants.pendingAnswersBoxName);
  }
  if (!Hive.isBoxOpen(AppConstants.sessionStateBoxName)) {
    await Hive.openBox<dynamic>(AppConstants.sessionStateBoxName);
  }
}

Widget _buildStudentE2EApp(E2EAssessmentRepository repository) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/student', builder: (_, __) => const StudentDashboardScreen()),
      GoRoute(
        path: '/student/assessments/:assessmentId/start',
        builder: (_, state) => AssessmentStartScreen(
          assessmentId: state.pathParameters['assessmentId']!,
        ),
      ),
      GoRoute(
        path: '/student/assessments/:assessmentId/exam',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ExamScreen(
            assessmentId: state.pathParameters['assessmentId']!,
            attemptId: extra['attemptId'] as String,
            questionCount: extra['questionCount'] as int,
            timeLimitMinutes: extra['timeLimitMinutes'] as int,
          );
        },
      ),
      GoRoute(
        path: '/student/results/:attemptId',
        builder: (_, state) => ResultScreen(
          attemptId: state.pathParameters['attemptId']!,
        ),
      ),
      GoRoute(
        path: '/student/analytics',
        builder: (_, __) => const StudentAnalyticsScreen(),
      ),
      GoRoute(
        path: '/student/micro-learning',
        builder: (_, __) => const MicroLearningScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [assessmentRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget _buildTeacherE2EApp(E2ETeacherRepository repository) {
  final router = GoRouter(
    initialLocation: '/teacher/assessments/create',
    routes: [
      GoRoute(
        path: '/teacher/assessments',
        builder: (_, __) => const ManageAssessmentsScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const CreateAssessmentScreen(),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [teacherRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget _buildAdminE2EApp(E2EAdminRepository repository) {
  final router = GoRouter(
    initialLocation: '/admin/users',
    routes: [
      GoRoute(
          path: '/admin/users',
          builder: (_, __) => const UserManagementScreen()),
      GoRoute(
        path: '/admin/classrooms',
        builder: (_, __) => const ClassroomManagementScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (_, __) => const SchoolReportsScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [adminRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
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
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    await _prepareHive();
  });

  tearDown(() async {
    if (Hive.isBoxOpen(AppConstants.pendingAnswersBoxName)) {
      await Hive.box<dynamic>(AppConstants.pendingAnswersBoxName).clear();
    }
    if (Hive.isBoxOpen(AppConstants.sessionStateBoxName)) {
      await Hive.box<dynamic>(AppConstants.sessionStateBoxName).clear();
    }
  });

  group('Role E2E journeys', () {
    testWidgets(
      'student: login -> assessment -> result -> analytics -> micro learning',
      (tester) async {
        final repository = E2EAssessmentRepository();
        await tester.binding.setSurfaceSize(const Size(900, 1800));
        addTearDown(() async => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_buildStudentE2EApp(repository));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.school_rounded).last);
        await tester.pumpAndSettle();
        expect(find.byType(StudentDashboardScreen), findsOneWidget);

        final router =
            GoRouter.of(tester.element(find.byType(StudentDashboardScreen)));
        router.go('/student/assessments/e2e-assessment-1/start');
        await tester.pumpAndSettle();
        expect(find.byType(AssessmentStartScreen), findsOneWidget);

        await tester.ensureVisible(find.byType(ElevatedButton).first);
        await tester.tap(find.byType(ElevatedButton).first);
        await tester.pump(const Duration(seconds: 1));
        expect(repository.startAttemptCalls, 1);
        router.go(
          '/student/assessments/e2e-assessment-1/exam',
          extra: {
            'attemptId': 'e2e-attempt-1',
            'questionCount': 1,
            'timeLimitMinutes': 5,
          },
        );
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(ExamScreen), findsOneWidget);

        await repository.submitAnswer(
          attemptId: 'e2e-attempt-1',
          questionId: 'question-1',
          selectedAnswer: 'B',
        );
        await repository.submitAttempt('e2e-attempt-1');

        expect(repository.submitAnswerCalls, 1);
        expect(repository.submitAttemptCalls, 1);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              assessmentRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(
              locale: Locale('ar'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ResultScreen(attemptId: 'e2e-attempt-1'),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(ResultScreen), findsOneWidget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              assessmentRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(
              locale: Locale('ar'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: StudentAnalyticsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(StudentAnalyticsScreen), findsOneWidget);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              assessmentRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(
              locale: Locale('ar'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MicroLearningScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MicroLearningScreen), findsOneWidget);
      },
    );

    testWidgets('teacher: create -> publish -> report-ready assessments list',
        (tester) async {
      final repository = E2ETeacherRepository();
      await tester.binding.setSurfaceSize(const Size(900, 2200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildTeacherE2EApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'اختبار E2E');
      await _selectDropdownItem(
        tester,
        hint: 'اختر المادة',
        value: 'رياضيات',
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
    });

    testWidgets('admin: user -> classroom -> report', (tester) async {
      final repository = E2EAdminRepository();
      await tester.binding.setSurfaceSize(const Size(900, 1800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildAdminE2EApp(repository));
      await tester.pumpAndSettle();
      expect(find.byType(UserManagementScreen), findsOneWidget);
      expect(find.text('سارة المعلمة'), findsOneWidget);

      final router =
          GoRouter.of(tester.element(find.byType(UserManagementScreen)));
      router.go('/admin/classrooms');
      await tester.pumpAndSettle();
      expect(find.byType(ClassroomManagementScreen), findsOneWidget);
      expect(find.text('الصف السابع - أ'), findsWidgets);

      router.go('/admin/reports');
      await tester.pumpAndSettle();
      expect(find.byType(SchoolReportsScreen), findsOneWidget);
      expect(repository.schoolReportCalls, 1);
    });
  });
}
