import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/user_avatar.dart';

/// EduAssess Student Dashboard Screen — Design _60
/// "EduAssess - لوحة تحكم الطالب"
/// Updated student dashboard with GPA, courses progress rings,
/// upcoming exams, and quick access actions.
class EduAssessStudentDashboardScreen extends ConsumerStatefulWidget {
  const EduAssessStudentDashboardScreen({super.key});

  @override
  ConsumerState<EduAssessStudentDashboardScreen> createState() =>
      _EduAssessStudentDashboardScreenState();
}

class _EduAssessStudentDashboardScreenState
    extends ConsumerState<EduAssessStudentDashboardScreen> {
  // Mock data matching the design
  final double _gpa = 3.85;
  final int _completedTasks = 24;
  final int _totalTasks = 30;
  final int _badgesCount = 12;

  final List<_CourseProgress> _courses = const [
    _CourseProgress(name: 'الرياضيات', progress: 0.75),
    _CourseProgress(name: 'الفيزياء', progress: 0.90),
    _CourseProgress(name: 'اللغة العربية', progress: 0.40),
  ];

  final List<_UpcomingExam> _upcomingExams = const [
    _UpcomingExam(
      day: '12',
      month: 'أكتوبر',
      title: 'اختبار منتصف الفصل - كيمياء',
      time: 'الساعة 09:00 صباحاً',
      colorIndex: 0,
    ),
    _UpcomingExam(
      day: '15',
      month: 'أكتوبر',
      title: 'مشروع التخرج - المرحلة الأولى',
      time: 'الساعة 11:59 مساءً',
      colorIndex: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // ─── Top App Bar ───────────────────────────────────────────────
            _buildTopAppBar(context),

            // ─── Scrollable Content ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting & Motivation
                    _buildGreetingSection(),
                    const SizedBox(height: 24),

                    // Summary Metrics Bento
                    _buildMetricsBento(),
                    const SizedBox(height: 24),

                    // My Courses
                    _buildCoursesSection(),
                    const SizedBox(height: 24),

                    // Upcoming Exams
                    _buildUpcomingExams(),
                    const SizedBox(height: 24),

                    // Quick Access
                    _buildQuickAccess(context),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 0, role: 'student'),
      );

  // ─── Top App Bar ─────────────────────────────────────────────────────────

  Widget _buildTopAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;

    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notification button (RTL: left)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => context.push('/student/notifications'),
          ),
          // Avatar + App name (RTL: right)
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EduAssess',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              UserAvatar(
                user: user,
                size: 40,
                borderColor: colorScheme.outlineVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Greeting & Motivation ────────────────────────────────────────────────

  Widget _buildGreetingSection() {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName.split(' ').first ?? 'طالب';
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'أهلاً بك، $firstName!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '"النجاح ليس عدم فعل الأخطاء، بل هو عدم تكرار نفس الخطأ مرتين."',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurface,
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                'جورج برنارد شو',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Summary Metrics Bento ────────────────────────────────────────────────

  Widget _buildMetricsBento() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // GPA — full width
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon (RTL: left)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.grade_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              // Text (RTL: right)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'المعدل التراكمي (GPA)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_gpa.toStringAsFixed(2)} / 4.0',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Tasks + Badges — two columns
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.task_alt_rounded,
                label: 'المهام المكتملة',
                value: '$_completedTasks/$_totalTasks',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.military_tech_rounded,
                label: 'الأوسمة المستحقة',
                value: '$_badgesCount وساماً',
                iconColor: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  // ─── My Courses ───────────────────────────────────────────────────────────

  Widget _buildCoursesSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'مساقاتي الدراسية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true, // RTL scroll
            itemCount: _courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildCourseCard(_courses[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(_CourseProgress course) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = (course.progress * 100).round();
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress ring
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(72, 72),
                  painter: _CircularProgressPainter(
                    progress: course.progress,
                    color: AppColors.primary,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            course.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Upcoming Exams ───────────────────────────────────────────────────────

  Widget _buildUpcomingExams() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الاختبارات القادمة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),
        ..._upcomingExams.map(_buildExamCard),
      ],
    );
  }

  Widget _buildExamCard(_UpcomingExam exam) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      const Color(0xFFFFDBCE), // tertiary-fixed
      const Color(0xFFD3E4FE), // secondary-fixed
    ];
    final textColors = [
      const Color(0xFF380D00),
      const Color(0xFF0B1C30),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Chevron (RTL: left)
          Icon(
            Icons.chevron_left_rounded,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            size: 24,
          ),
          const SizedBox(width: 12),
          // Info (RTL: right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exam.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  exam.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Date badge (RTL: right-most)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors[exam.colorIndex],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exam.day,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColors[exam.colorIndex],
                  ),
                ),
                Text(
                  exam.month,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColors[exam.colorIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Access ─────────────────────────────────────────────────────────

  Widget _buildQuickAccess(BuildContext context) => Row(
        children: [
          // Resources button (RTL: left)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_stories_rounded, size: 24),
              label: const Text('مصادري'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Start training button (RTL: right)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/student/micro-learning'),
              icon: const Icon(Icons.play_circle_rounded, size: 24),
              label: const Text('ابدأ التدريب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _CourseProgress {
  const _CourseProgress({required this.name, required this.progress});
  final String name;
  final double progress;
}

class _UpcomingExam {
  const _UpcomingExam({
    required this.day,
    required this.month,
    required this.title,
    required this.time,
    required this.colorIndex,
  });
  final String day;
  final String month;
  final String title;
  final String time;
  final int colorIndex;
}

// ─── Circular Progress Painter ────────────────────────────────────────────────

class _CircularProgressPainter extends CustomPainter {
  const _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14159 / 2; // -90 degrees (top)
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
