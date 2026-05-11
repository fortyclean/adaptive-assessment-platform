import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../shared/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

// Auth screens
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/extended_onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/auth/screens/settings_screen.dart';
import '../../features/auth/screens/account_settings_screen.dart';
import '../../features/auth/screens/signup_screen.dart';

// Admin screens
import '../../features/auth/screens/admin_dashboard_screen.dart';
import '../../features/auth/screens/admin_dashboard_v2_screen.dart';
import '../../features/auth/screens/user_management_screen.dart';
import '../../features/auth/screens/classroom_management_screen.dart';
import '../../features/reports/screens/school_reports_screen.dart';

// Teacher screens
import '../../features/assessment/screens/teacher_dashboard_screen.dart';
import '../../features/assessment/screens/create_assessment_screen.dart';
import '../../features/assessment/screens/manage_assessments_screen.dart';
import '../../features/question_bank/screens/question_bank_screen.dart';
import '../../features/question_bank/screens/add_question_screen.dart';
import '../../features/question_bank/screens/import_excel_screen.dart';
import '../../features/reports/screens/teacher_report_screen.dart';

// Student screens
import '../../features/assessment/screens/student_analytics_screen.dart';
import '../../features/assessment/screens/student_dashboard_screen.dart';
import '../../features/assessment/screens/edu_assess_student_dashboard_screen.dart';
import '../../features/assessment/screens/micro_learning_screen.dart';
import '../../features/assessment/screens/student_assessments_screen.dart';
import '../../features/assessment/screens/student_progress_screen.dart';
import '../../features/assessment/screens/student_subjects_screen.dart';
import '../../features/assessment/screens/assessment_start_screen.dart';
import '../../features/assessment/screens/exam_screen.dart';
import '../../features/assessment/screens/exam_with_image_screen.dart';
import '../../features/assessment/screens/exam_with_bookmark_screen.dart';
import '../../features/assessment/screens/exam_with_timer_toggle_screen.dart';
import '../../features/assessment/screens/result_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/notifications/screens/advanced_notification_center_screen.dart';
import '../../features/notifications/screens/notification_settings_screen.dart';
import '../../features/reports/screens/performance_alert_screen.dart';
import '../../features/reports/screens/report_schedule_screen.dart';
import '../../features/reports/screens/student_profile_detail_screen.dart';

// Screens 59, 61, 63, 64, 65
import '../../features/assessment/screens/teacher_home_screen.dart';
import '../../features/auth/screens/classroom_list_screen.dart';
import '../../features/reports/screens/student_files_screen.dart';
import '../../features/assessment/screens/student_challenges_screen.dart';
import '../../features/reports/screens/student_academic_profile_screen.dart';

// Screens 70, 74, 75
import '../../features/assessment/screens/class_schedule_screen.dart';
import '../../features/assessment/screens/my_classes_screen.dart';
import '../../features/question_bank/screens/advanced_question_editor_screen.dart';

// Screens 66–69, 71–73
import '../../features/assessment/screens/marketplace_screen.dart';
import '../../features/assessment/screens/task_management_screen.dart';
import '../../features/auth/screens/supervisor_dashboard_screen.dart';
import '../../features/auth/screens/institution_settings_screen.dart';
import '../../features/reports/screens/certificates_screen.dart';
import '../../features/auth/screens/about_screen.dart';
import '../../features/auth/screens/support_screen.dart';
import '../../features/auth/screens/ui_feedback_screen.dart';

// ─── Route Names ──────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  // Onboarding
  static const String onboarding = '/onboarding';
  static const String extendedOnboarding = '/onboarding-extended';

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminClassrooms = '/admin/classrooms';
  static const String adminReports = '/admin/reports';
  // Admin Dashboard V2
  static const String adminDashboardV2 = '/admin/dashboard-v2';

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

  // Account Settings (Screen 49)
  static const String accountSettings = '/account-settings';

  // Notification Center (Screen 34)
  static const String notificationCenter = '/notifications';

  // Notification Settings (Screen 35)
  static const String notificationSettings = '/notification-settings';

  // Performance Alert (Screen 36)
  static const String performanceAlert = '/performance-alert';

  // Report Schedules (Screen 32/33)
  static const String teacherReportSchedules = '/teacher/report-schedules';

  // Student Profile Detail (Screens 56–58)
  static const String studentProfileDetail = '/teacher/students/:studentId/profile';

  // Screen 59 — Teacher Home (alternative dashboard)
  static const String teacherHome = '/teacher/home';

  // Screen 61 — Classroom List (teacher view)
  static const String classroomList = '/teacher/classrooms';

  // Screen 63 — Student Files (teacher view)
  static const String studentFiles = '/teacher/student-files';

  // Screen 64 — Student Challenges
  static const String studentChallenges = '/student/challenges';

  // Screen 65 — Student Academic Profile (teacher view)
  static const String studentAcademicProfile = '/teacher/students/:studentId/academic-profile';

  // Screen 70 — Class Schedule (الجداول الدراسية)
  static const String classSchedule = '/teacher/class-schedule';

  // Screen 74 — My Classes
  static const String myClasses = '/teacher/my-classes';

  // Screen 75 — Advanced Question Editor
  static const String advancedQuestionEditor = '/teacher/questions/advanced';

  // Screen 66 — Marketplace (متجر النقاط)
  static const String marketplace = '/student/marketplace';

  // Screen 67 — Task Management (إدارة المهام)
  static const String taskManagement = '/teacher/tasks';

  // Screen 68 — Supervisor Dashboard (لوحة تحكم المشرف)
  static const String supervisorDashboard = '/supervisor';

  // Screen 69 — Institution Settings (إعدادات المؤسسة)
  static const String institutionSettings = '/admin/institution-settings';

  // Screen 71 — Certificates (الشهادات والنتائج)
  static const String certificates = '/teacher/certificates';

  // Screen 72 — Support (الدعم الفني)
  static const String support = '/support';
  static const String about = '/about';

  // Screen 73 — UI Feedback Components
  static const String uiFeedback = '/ui-feedback';

  // Student
  static const String studentDashboard = '/student';
  static const String eduAssessStudentDashboard = '/student/edu-assess';
  static const String microLearning = '/student/micro-learning';
  static const String studentAssessments = '/student/assessments';
  static const String studentAssessmentsList = '/student/assessments-list';
  static const String studentResults = '/student/results';
  static const String studentPoints = '/student/points';
  static const String studentNotifications = '/student/notifications';
  static const String studentProgress = '/student/progress';
  static const String studentSubjects = '/student/subjects';
  static const String studentAnalytics = '/student/analytics';
}

/// GoRouter configuration with role-based route guards.
/// Uses a single stable GoRouter instance with refreshListenable
/// so switching apps never triggers a re-login.
final routerProvider = Provider<GoRouter>((ref) {
  // Check if onboarding has been seen (stored in Hive)
  bool onboardingSeen = false;
  try {
    final box = Hive.box<dynamic>(AppConstants.sessionStateBoxName);
    onboardingSeen = box.get(AppConstants.onboardingSeenKey, defaultValue: false) as bool;
  } catch (_) {
    onboardingSeen = false;
  }

  // Use a notifier so GoRouter refreshes only when auth actually changes
  final authNotifier = _AuthChangeNotifier(ref);

  final router = GoRouter(
    initialLocation: onboardingSeen ? AppRoutes.login : AppRoutes.onboarding,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isOnboardingRoute = state.matchedLocation == AppRoutes.onboarding;
      final isLoginRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.signup;

      // Always allow onboarding and auth routes
      if (isOnboardingRoute) return null;
      if (!isAuthenticated && isLoginRoute) return null;

      if (!isAuthenticated) return AppRoutes.login;
      if (isAuthenticated && isLoginRoute) {
        return _getDashboardRoute(authState.user?.role);
      }
      final roleRedirect = _guardRouteForRole(
        state.matchedLocation,
        authState.user?.role,
      );
      if (roleRedirect != null) return roleRedirect;
      return null;
    },
    routes: [
      // ─── Onboarding ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.extendedOnboarding,
        name: 'extendedOnboarding',
        builder: (_, __) => const ExtendedOnboardingScreen(),
      ),

      // ─── Auth Stack ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (_, __) => const SignupScreen(),
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

      // Notification Settings (Screen 35) — accessible from any role
      GoRoute(
        path: AppRoutes.notificationSettings,
        name: 'notificationSettings',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),

      // Account Settings (Screen 49) — accessible from any role
      GoRoute(
        path: AppRoutes.accountSettings,
        name: 'accountSettings',
        builder: (_, __) => const AccountSettingsScreen(),
      ),

      // Screen 66 — Marketplace
      GoRoute(
        path: AppRoutes.marketplace,
        name: 'marketplace',
        builder: (_, __) => const MarketplaceScreen(),
      ),

      // Screen 68 — Supervisor Dashboard
      GoRoute(
        path: AppRoutes.supervisorDashboard,
        name: 'supervisorDashboard',
        builder: (_, __) => const SupervisorDashboardScreen(),
      ),

      // Screen 69 — Institution Settings
      GoRoute(
        path: AppRoutes.institutionSettings,
        name: 'institutionSettings',
        builder: (_, __) => const InstitutionSettingsScreen(),
      ),

      // Screen 72 — Support
      GoRoute(
        path: AppRoutes.support,
        name: 'support',
        builder: (_, __) => const SupportScreen(),
      ),

      // About screen
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (_, __) => const AboutScreen(),
      ),

      // Screen 73 — UI Feedback
      GoRoute(
        path: AppRoutes.uiFeedback,
        name: 'uiFeedback',
        builder: (_, __) => const UiFeedbackScreen(),
      ),

      // Performance Alert (Screen 36) — accessible from Teacher role
      GoRoute(
        path: AppRoutes.performanceAlert,
        name: 'performanceAlert',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PerformanceAlertScreen(
            studentId: extra?['studentId'] as String?,
            studentName: extra?['studentName'] as String?,
            className: extra?['className'] as String?,
            subject: extra?['subject'] as String?,
            currentAverage: (extra?['currentAverage'] as num?)?.toDouble(),
            attendanceRate: (extra?['attendanceRate'] as num?)?.toDouble(),
            dropPercentage: extra?['dropPercentage'] as int?,
            weeklyData: (extra?['weeklyData'] as List?)
                ?.map((e) => (e as num).toDouble())
                .toList(),
          );
        },
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
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return UserManagementScreen(
                initialFilter: extra?['initialFilter'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'classrooms',
            name: 'adminClassrooms',
            builder: (_, __) => const ClassroomManagementScreen(),
          ),
          GoRoute(
            path: 'reports',
            name: 'adminReports',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SchoolReportsScreen(
                initialGradeLevel: extra?['gradeLevel'] as String?,
                initialSubject: extra?['subject'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'dashboard-v2',
            name: 'adminDashboardV2',
            builder: (_, __) => const AdminDashboardV2Screen(),
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
            path: 'settings',
            name: 'teacherSettings',
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'notification-settings',
            name: 'teacherNotificationSettings',
            builder: (_, __) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'teacherNotifications',
            builder: (_, __) => const AdvancedNotificationCenterScreen(),
          ),
          GoRoute(
            path: 'report-schedules',
            name: 'teacherReportSchedules',
            builder: (_, __) => const ReportScheduleScreen(),
          ),
          GoRoute(
            path: 'students/:studentId/profile',
            name: 'studentProfileDetail',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return StudentProfileDetailScreen(
                studentId: state.pathParameters['studentId'] ?? '',
                studentName: extra?['studentName'] as String?,
                assessmentId: extra?['assessmentId'] as String?,
              );
            },
          ),
          // Screen 59 — Teacher Home
          GoRoute(
            path: 'home',
            name: 'teacherHome',
            builder: (_, __) => const TeacherHomeScreen(),
          ),
          // Screen 61 — Classroom List
          GoRoute(
            path: 'classrooms-list',
            name: 'classroomList',
            builder: (_, __) => const ClassroomListScreen(),
          ),
          // Screen 63 — Student Files
          GoRoute(
            path: 'student-files',
            name: 'studentFiles',
            builder: (_, __) => const StudentFilesScreen(),
          ),
          // Screen 65 — Student Academic Profile
          GoRoute(
            path: 'students/:studentId/academic-profile',
            name: 'studentAcademicProfile',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return StudentAcademicProfileScreen(
                studentId: state.pathParameters['studentId'],
                studentName: extra?['studentName'] as String?,
              );
            },
          ),
          // Screen 70 — Class Schedule (الجداول الدراسية)
          GoRoute(
            path: 'class-schedule',
            name: 'classSchedule',
            builder: (_, __) => const ClassScheduleScreen(),
          ),
          // Screen 74 — My Classes
          GoRoute(
            path: 'my-classes',
            name: 'myClasses',
            builder: (_, __) => const MyClassesScreen(),
          ),
          // Screen 75 — Advanced Question Editor
          GoRoute(
            path: 'questions/advanced',
            name: 'advancedQuestionEditor',
            builder: (_, __) => const AdvancedQuestionEditorScreen(),
          ),
          // Screen 67 — Task Management
          GoRoute(
            path: 'tasks',
            name: 'taskManagement',
            builder: (_, __) => const TaskManagementScreen(),
          ),
          // Screen 71 — Certificates
          GoRoute(
            path: 'certificates',
            name: 'certificates',
            builder: (_, __) => const CertificatesScreen(),
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
            path: 'edu-assess',
            name: 'eduAssessStudentDashboard',
            builder: (_, __) => const EduAssessStudentDashboardScreen(),
          ),
          GoRoute(
            path: 'micro-learning',
            name: 'microLearning',
            builder: (_, __) => const MicroLearningScreen(),
          ),
          GoRoute(
            path: 'assessments-list',
            name: 'studentAssessmentsList',
            builder: (_, __) => const StudentAssessmentsScreen(),
          ),
          GoRoute(
            path: 'results',
            name: 'studentResults',
            builder: (_, __) => const StudentAssessmentsScreen(),
          ),
          GoRoute(
            path: 'progress',
            name: 'studentProgress',
            builder: (_, __) => const StudentProgressScreen(),
          ),
          GoRoute(
            path: 'subjects',
            name: 'studentSubjects',
            builder: (_, __) => const StudentSubjectsScreen(),
          ),
          GoRoute(
            path: 'analytics',
            name: 'studentAnalytics',
            builder: (_, __) => const StudentAnalyticsScreen(),
          ),
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
            path: 'assessments/:id/exam-image',
            name: 'studentExamWithImage',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ExamWithImageScreen(
                assessmentId: state.pathParameters['id'] ?? '',
                attemptId: extra?['attemptId'] as String? ?? '',
                questionCount: extra?['questionCount'] as int? ?? 10,
                timeLimitMinutes: extra?['timeLimitMinutes'] as int? ?? 30,
                subjectTitle: extra?['subjectTitle'] as String? ??
                    'الرياضيات المتقدمة',
              );
            },
          ),
          GoRoute(
            path: 'assessments/:id/exam-bookmark',
            name: 'studentExamWithBookmark',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ExamWithBookmarkScreen(
                assessmentId: state.pathParameters['id'] ?? '',
                attemptId: extra?['attemptId'] as String? ?? '',
                questionCount: extra?['questionCount'] as int? ?? 10,
                timeLimitMinutes: extra?['timeLimitMinutes'] as int? ?? 30,
                subjectTitle: extra?['subjectTitle'] as String? ??
                    'الرياضيات المتقدمة',
              );
            },
          ),
          GoRoute(
            path: 'assessments/:id/exam-timer-toggle',
            name: 'studentExamWithTimerToggle',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ExamWithTimerToggleScreen(
                assessmentId: state.pathParameters['id'] ?? '',
                attemptId: extra?['attemptId'] as String? ?? '',
                questionCount: extra?['questionCount'] as int? ?? 10,
                timeLimitMinutes: extra?['timeLimitMinutes'] as int? ?? 30,
                subjectTitle: extra?['subjectTitle'] as String? ??
                    'الرياضيات المتقدمة',
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
            builder: (_, __) => const AdvancedNotificationCenterScreen(),
          ),
          // Student Settings
          GoRoute(
            path: 'settings',
            name: 'studentSettings',
            builder: (_, __) => const SettingsScreen(),
          ),
          // Screen 64 — Student Challenges
          GoRoute(
            path: 'challenges',
            name: 'studentChallenges',
            builder: (_, __) => const StudentChallengesScreen(),
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

  // Dispose notifier when provider is disposed
  ref.onDispose(() => authNotifier.dispose());

  return router;
});

/// ChangeNotifier that listens to auth state changes and notifies GoRouter.
/// This ensures the router only refreshes on actual login/logout events,
/// NOT when switching between apps.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(authProvider, (previous, next) {
      // Only notify if authentication status actually changed
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

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

String? _guardRouteForRole(String location, UserRole? role) {
  if (role == null) return AppRoutes.login;

  final isAdminRoute =
      location.startsWith('/admin') || location == AppRoutes.supervisorDashboard;
  final isTeacherRoute = location.startsWith('/teacher');
  final isStudentRoute = location.startsWith('/student');

  if (isAdminRoute && role != UserRole.admin) return _getDashboardRoute(role);
  if (isTeacherRoute && role != UserRole.teacher) return _getDashboardRoute(role);
  if (isStudentRoute && role != UserRole.student) return _getDashboardRoute(role);

  return null;
}
