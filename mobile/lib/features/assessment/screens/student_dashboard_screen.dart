import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../repositories/assessment_repository.dart';

/// Student Dashboard Screen — Design _37
/// Requirements: 11.1–11.6
class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingAssessments = [];
  int _totalAssessments = 0;
  double _averageScore = 0;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final assessments =
          await ref.read(assessmentRepositoryProvider).getAssessments();
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();

      final upcoming = assessments
          .where((a) => a['status'] == 'active')
          .take(3)
          .toList();

      final scores = history
          .map((h) => (h['scorePercentage'] as num?)?.toDouble() ?? 0.0)
          .toList();
      final avg = scores.isEmpty
          ? 0.0
          : scores.reduce((a, b) => a + b) / scores.length;
      final points = history.fold<int>(
          0, (sum, h) => sum + ((h['pointsEarned'] as num?)?.toInt() ?? 0));

      if (mounted) {
        setState(() {
          _upcomingAssessments = upcoming;
          _totalAssessments = history.length;
          _averageScore = avg;
          _totalPoints = points;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _upcomingAssessments = [
            {'_id': '1', 'title': 'اختبار الرياضيات', 'subject': 'رياضيات', 'questionCount': 20, 'timeLimitMinutes': 45, 'status': 'active'},
            {'_id': '2', 'title': 'اختبار العلوم', 'subject': 'علوم', 'questionCount': 15, 'timeLimitMinutes': 30, 'status': 'active'},
          ];
          _totalAssessments = 5;
          _averageScore = 78.5;
          _totalPoints = 450;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName?.split(' ').first ?? 'طالب';
    // XP level calculation
    final level = (_totalPoints ~/ 200) + 1;
    final xpInLevel = _totalPoints % 200;
    final xpProgress = xpInLevel / 200.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 1,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Notification button (RTL: left side)
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () =>
                        context.push('/student/notifications'),
                  ),
                  // App name + avatar (RTL: right side)
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'التقييم الذكي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainer,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Content ──────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting & XP section
                  _buildGreeting(firstName, level, _totalPoints, xpProgress),
                  const SizedBox(height: 24),

                  // Stats grid
                  _buildStatsGrid(),
                  const SizedBox(height: 24),

                  // Continue learning section
                  _buildContinueLearningSection(),
                  const SizedBox(height: 24),

                  // Upcoming assessments
                  _buildSectionHeader('الاختبارات القادمة', onSeeAll: () {
                    context.push('/student/assessments-list');
                  }),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_upcomingAssessments.isEmpty)
                    _buildEmptyUpcoming()
                  else
                    ..._upcomingAssessments
                        .map((a) => _buildUpcomingCard(a)),

                  const SizedBox(height: 24),
                  _buildSectionHeader('استكشف المزيد'),
                  const SizedBox(height: 12),
                  // Quick access grid for hidden screens
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _buildExploreCard(
                        context,
                        icon: Icons.diamond_outlined,
                        label: 'متجر النقاط',
                        color: AppColors.primary,
                        bgColor: const Color(0xFFDDE1FF),
                        route: '/student/marketplace',
                      ),
                      _buildExploreCard(
                        context,
                        icon: Icons.emoji_events_outlined,
                        label: 'التحديات',
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        route: '/student/challenges',
                      ),
                      _buildExploreCard(
                        context,
                        icon: Icons.psychology_outlined,
                        label: 'التعلم المصغر',
                        color: AppColors.success,
                        bgColor: const Color(0xFFD1FAE5),
                        route: '/student/micro-learning',
                      ),
                      _buildExploreCard(
                        context,
                        icon: Icons.analytics_outlined,
                        label: 'تحليلاتي',
                        color: AppColors.primaryContainer,
                        bgColor: const Color(0xFFD0E1FB),
                        route: '/student/analytics',
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          const AppBottomNav(currentIndex: 0, role: 'student'),
    );
  }

  // ─── Greeting & XP Progress ─────────────────────────────────────────────

  Widget _buildGreeting(
      String name, int level, int points, double xpProgress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Level badge + XP (RTL: left side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'المستوى $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: AppColors.pointsGold,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$points XP',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Greeting text (RTL: right side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'أهلاً بك، $name! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1B22),
                  ),
                ),
                Text(
                  'أنت تبلي بلاءً حسناً اليوم.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // XP Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: xpProgress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: const Color(0xFFE3E1EB),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'المستوى التالي: ${level * 200} XP',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.outline,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  // ─── Quick Stats Grid ────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.assignment_outlined,
            value: '$_totalAssessments',
            label: 'اختبار',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.insights_outlined,
            value: '${_averageScore.round()}%',
            label: 'متوسط',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.event_available_outlined,
            value: '95%',
            label: 'حضور',
          ),
        ),
      ],
    );
  }

  // ─── Continue Learning Section ───────────────────────────────────────────

  Widget _buildContinueLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 12),
          child: Text(
            'تابع التعلم',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1B22),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        _buildContinueLearningCard(),
      ],
    );
  }

  Widget _buildContinueLearningCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blurred circle
          Positioned(
            left: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: subject badge + play icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Play icon (RTL: left)
                    Icon(
                      Icons.play_circle_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    // Subject badge (RTL: right)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'الرياضيات المتقدمة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Lesson title + subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'المعادلات من الدرجة الثانية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'الدرس 4: تطبيقات عملية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/student/assessments-list'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'استكمال الدرس',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'عرض الكل',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1B22),
          ),
        ),
      ],
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────

  Widget _buildEmptyUpcoming() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: AppColors.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد اختبارات قادمة',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Upcoming Assessment Card ────────────────────────────────────────────

  Widget _buildUpcomingCard(Map<String, dynamic> assessment) {
    final title = assessment['title'] as String? ?? 'اختبار';
    final subject = assessment['subject'] as String? ?? '';
    final questionCount = assessment['questionCount'] as int? ?? 0;
    final timeLimitMinutes = assessment['timeLimitMinutes'] as int? ?? 0;
    final until = assessment['availableUntil'] != null
        ? DateTime.tryParse(assessment['availableUntil'] as String)
        : null;
    final daysLeft = until != null
        ? until.difference(DateTime.now()).inDays
        : null;

    // Pick icon based on subject
    final IconData subjectIcon = _subjectIcon(subject);

    return GestureDetector(
      onTap: () => context.push(
          '/student/assessments/${assessment['_id']}/start'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Days left badge (RTL: left side)
              if (daysLeft != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$daysLeft',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: daysLeft <= 2
                              ? AppColors.error
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        daysLeft == 1 ? 'يوم' : 'أيام',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              // Info (RTL: right side)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1B22),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$questionCount سؤال • $timeLimitMinutes دقيقة',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Subject icon box
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        subjectIcon,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Explore Card ────────────────────────────────────────────────────────

  Widget _buildExploreCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1B22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _subjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('علوم') || s.contains('science') || s.contains('فيزياء') || s.contains('كيمياء') || s.contains('أحياء')) {
      return Icons.science_outlined;
    } else if (s.contains('عربي') || s.contains('arabic') || s.contains('لغة')) {
      return Icons.language_outlined;
    } else if (s.contains('رياضيات') || s.contains('math')) {
      return Icons.calculate_outlined;
    } else if (s.contains('انجليزي') || s.contains('english')) {
      return Icons.translate_outlined;
    }
    return Icons.quiz_outlined;
  }
}

// ─── Stat Card Widget ──────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1B22),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
