import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assessment/screens/assessment_start_screen.dart';
import '../../features/assessment/screens/create_assessment_screen.dart';
import '../../features/assessment/screens/exam_screen.dart';
import '../../features/assessment/screens/manage_assessments_screen.dart';
import '../../features/assessment/screens/result_screen.dart';
// Student screens
import '../../features/assessment/screens/student_dashboard_screen.dart';
// Teacher screens
import '../../features/assessment/screens/teacher_dashboard_screen.dart';
// Admin screens
import '../../features/auth/screens/admin_dashboard_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/auth/screens/classroom_management_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
// Auth screens
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/settings_screen.dart';
import '../../features/auth/screens/user_management_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/question_bank/screens/add_question_screen.dart';
import '../../features/question_bank/screens/import_excel_screen.dart';
import '../../features/question_bank/screens/question_bank_screen.dart';
import '../../features/reports/screens/essay_grading_screen.dart';
import '../../features/reports/screens/pending_essays_screen.dart';
import '../../features/reports/screens/school_reports_screen.dart';
import '../../features/reports/screens/teacher_report_screen.dart';
import '../../shared/providers/auth_provider.dart';

// ─── Route Names ──────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminClassrooms = '/admin/classrooms';
  static const String adminReports = '/admin/reports';

  // Teacher
  static const String teacherDashboard = '/teacher';
  static const String teacherAssessments = '/teacher/assessments';
  static const String teacherCreateAssessment = '/teacher/assessments/create';
  static const String teacherQuestionBank = '/teacher/questions';
  static const String teacherAddQuestion = '/teacher/questions/add';
  static const String teacherImportExcel = '/teacher/questions/import';
  static const String teacherReports = '/teacher/reports';
  static const String teacherSettings = '/teacher/settings';
  static const String teacherNotifications = '/teacher/notifications';
  static const String teacherPendingEssays = '/teacher/pending-essays';

  // Student
  static const String studentDashboard = '/student';
  static const String studentAssessments = '/student/assessments';
  static const String studentPoints = '/student/points';
  static const String studentNotifications = '/student/notifications';
}

/// GoRouter configuration with role-based route guards.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isAuthenticated && !isLoginRoute) return AppRoutes.login;
      if (isAuthenticated && isLoginRoute) {
        return _getDashboardRoute(authState.user?.role);
      }
      return null;
    },
    routes: [
      // ─── Auth Stack ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (_, __) => const ChangePasswordScreen(),
      ),

      // ─── Admin Stack ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (_, __) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'users',
            name: 'adminUsers',
            builder: (_, __) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'classrooms',
            name: 'adminClassrooms',
            builder: (_, __) => const ClassroomManagementScreen(),
          ),
          GoRoute(
            path: 'reports',
            name: 'adminReports',
            builder: (_, __) => const SchoolReportsScreen(),
          ),
        ],
      ),

      // ─── Teacher Stack ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.teacherDashboard,
        name: 'teacherDashboard',
        builder: (_, __) => const TeacherDashboardScreen(),
        routes: [
          GoRoute(
            path: 'assessments',
            name: 'teacherAssessments',
            builder: (_, __) => const ManageAssessmentsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'teacherCreateAssessment',
                builder: (_, __) => const CreateAssessmentScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'questions',
            name: 'teacherQuestionBank',
            builder: (_, __) => const QuestionBankScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'teacherAddQuestion',
                builder: (_, __) => const AddQuestionScreen(),
              ),
              GoRoute(
                path: 'import',
                name: 'teacherImportExcel',
                builder: (_, __) => const ImportExcelScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'reports/:assessmentId',
            name: 'teacherReportDetail',
            builder: (_, state) => TeacherReportScreen(
              assessmentId: state.pathParameters['assessmentId'] ?? '',
            ),
          ),
          GoRoute(
            path: 'pending-essays',
            name: 'teacherPendingEssays',
            builder: (_, __) => const PendingEssaysScreen(),
            routes: [
              GoRoute(
                path: ':attemptId',
                name: 'teacherEssayGrading',
                builder: (_, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return EssayGradingScreen(
                    attemptId: state.pathParameters['attemptId'] ?? '',
                    studentName: extra?['studentName'] as String? ?? 'طالب',
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: 'teacherSettings',
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'teacherNotifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),

      // ─── Student Stack ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.studentDashboard,
        name: 'studentDashboard',
        builder: (_, __) => const StudentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'assessments/:id/start',
            name: 'studentAssessmentStart',
            builder: (_, state) => AssessmentStartScreen(
              assessmentId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'assessments/:id/exam',
            name: 'studentExam',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ExamScreen(
                assessmentId: state.pathParameters['id'] ?? '',
                attemptId: extra?['attemptId'] as String? ?? '',
                questionCount: extra?['questionCount'] as int? ?? 10,
                timeLimitMinutes: extra?['timeLimitMinutes'] as int? ?? 30,
              );
            },
          ),
          GoRoute(
            path: 'results/:id',
            name: 'studentResultDetail',
            builder: (_, state) => ResultScreen(
              attemptId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'notifications',
            name: 'studentNotifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('الصفحة غير موجودة: ${state.error}'),
      ),
    ),
  );
});

String _getDashboardRoute(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.teacher:
      return AppRoutes.teacherDashboard;
    case UserRole.student:
      return AppRoutes.studentDashboard;
    case null:
      return AppRoutes.login;
  }
}
