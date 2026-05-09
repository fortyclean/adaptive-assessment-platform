import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// StudentAnalyticsScreen — Screen 50
/// Comprehensive student performance analytics with bento grid metrics,
/// subject progress bars, attachment stats, and achievement badges.
/// RTL Arabic layout matching _50/code.html design.
class StudentAnalyticsScreen extends ConsumerStatefulWidget {
  const StudentAnalyticsScreen({super.key});

  @override
  ConsumerState<StudentAnalyticsScreen> createState() =>
      _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState
    extends ConsumerState<StudentAnalyticsScreen> {
  // Mock data — replace with real API calls
  final double _overallPerformance = 88.5;
  final int _learningHours = 124;
  final int _filesOpened = 48;

  final List<_SubjectProgress> _subjects = const [
    _SubjectProgress(name: 'اللغة العربية', percentage: 0.92),
    _SubjectProgress(name: 'الرياضيات', percentage: 0.78),
    _SubjectProgress(name: 'العلوم', percentage: 0.85),
  ];

  final List<double> _weeklyData = const [0.40, 0.60, 0.85, 0.70, 0.50];
  final List<String> _weekDays = const [
    'أحد',
    'اثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
  ];

  final List<_AttachmentStat> _attachments = const [
    _AttachmentStat(
      icon: Icons.video_library_outlined,
      iconColor: AppColors.primary,
      bgColor: Color(0xFFEFF6FF),
      borderColor: Color(0xFFBFDBFE),
      title: 'الفيديوهات التعليمية',
      subtitle: '42 ساعة مشاهدة هادفة',
      percentage: 85,
      percentageColor: AppColors.primary,
    ),
    _AttachmentStat(
      icon: Icons.folder_open_outlined,
      iconColor: Color(0xFF611E00),
      bgColor: Color(0xFFFFF7ED),
      borderColor: Color(0xFFFFDBC8),
      title: 'الملازم والملفات',
      subtitle: 'تمت مراجعة 15 من أصل 20',
      percentage: 75,
      percentageColor: Color(0xFF611E00),
    ),
  ];

  final List<_Badge> _badges = const [
    _Badge(
      icon: Icons.workspace_premium_rounded,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      borderColor: Color(0xFFFDE68A),
      label: 'الأول دائماً',
      isEarned: true,
      count: 3,
    ),
    _Badge(
      icon: Icons.speed_rounded,
      iconColor: AppColors.primary,
      bgColor: Color(0xFFEFF6FF),
      borderColor: Color(0xFFBFDBFE),
      label: 'سريع البديهة',
      isEarned: true,
    ),
    _Badge(
      icon: Icons.auto_stories_outlined,
      iconColor: Color(0xFF9CA3AF),
      bgColor: Color(0xFFF9FAFB),
      borderColor: Color(0xFFE5E7EB),
      label: 'قارئ نهم',
      isEarned: false,
    ),
    _Badge(
      icon: Icons.verified_rounded,
      iconColor: AppColors.success,
      bgColor: Color(0xFFECFDF5),
      borderColor: Color(0xFFA7F3D0),
      label: 'ملتزم بالوقت',
      isEarned: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName?.split(' ').first ?? 'أحمد';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ─── Top App Bar ─────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: Colors.black12,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Notifications (RTL: left)
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.onSurfaceVariant,
                  onPressed: () => context.push('/student/notifications'),
                ),
                // Logo + Avatar (RTL: right)
                Row(
                  children: [
                    Text(
                      'إحصائيات EduAssess',
                      style: const TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainer,
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          firstName.isNotEmpty ? firstName[0] : 'أ',
                          style: const TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Main Content ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome section
                _buildWelcomeSection(firstName),
                const SizedBox(height: 24),

                // Bento Grid: Main Performance Metrics
                _buildBentoGrid(),
                const SizedBox(height: 24),

                // Subject Progress
                _buildSubjectProgress(),
                const SizedBox(height: 24),

                // Attachment Stats
                _buildAttachmentStats(),
                const SizedBox(height: 24),

                // Achievements & Badges
                _buildAchievements(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const AppBottomNav(currentIndex: 2, role: 'student'),
    );
  }

  // ─── Welcome Section ─────────────────────────────────────────────────────

  Widget _buildWelcomeSection(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'مرحباً، $name!',
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        const Text(
          'إليك نظرة شاملة على أدائك التعليمي لهذا الفصل.',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // ─── Bento Grid ──────────────────────────────────────────────────────────

  Widget _buildBentoGrid() {
    return Column(
      children: [
        // Full-width performance card
        _buildPerformanceCard(),
        const SizedBox(height: 12),
        // Two small cards
        Row(
          children: [
            Expanded(child: _buildSmallMetricCard(
              icon: Icons.schedule_outlined,
              iconColor: const Color(0xFF611E00),
              value: '$_learningHours',
              label: 'ساعة تعليمية',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallMetricCard(
              icon: Icons.description_outlined,
              iconColor: AppColors.primary,
              value: '$_filesOpened',
              label: 'ملف تم فتحه',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
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
          // Circular progress (RTL: left)
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularProgressIndicator(
                    value: _overallPerformance / 100,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer,
                    ),
                  ),
                ),
                const Text(
                  'جيد جداً',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Text info (RTL: right)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'معدل الأداء العام',
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_overallPerformance.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        '+4.2% عن الشهر الماضي',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Subject Progress ─────────────────────────────────────────────────────

  Widget _buildSubjectProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => context.push('/student/subjects'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'تفاصيل أكثر',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Text(
              'تقدم المواد الدراسية',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Subject bars
              ..._subjects.map((s) => _buildSubjectBar(s)),
              const SizedBox(height: 16),
              // Weekly chart
              _buildWeeklyChart(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectBar(_SubjectProgress subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(subject.percentage * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Text(
                subject.name,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: subject.percentage,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Column(
      children: [
        const Divider(color: Color(0xFFF1F5F9), height: 1),
        const SizedBox(height: 16),
        SizedBox(
          height: 128,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_weeklyData.length, (i) {
              final isMax = _weeklyData[i] ==
                  _weeklyData.reduce((a, b) => a > b ? a : b);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FractionallySizedBox(
                    heightFactor: _weeklyData[i],
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMax
                            ? AppColors.primary
                            : AppColors.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _weekDays
              .map((d) => Expanded(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ─── Attachment Stats ─────────────────────────────────────────────────────

  Widget _buildAttachmentStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'استهلاك المرفقات التعليمية',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ..._attachments.map((a) => _buildAttachmentCard(a)),
      ],
    );
  }

  Widget _buildAttachmentCard(_AttachmentStat stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stat.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stat.borderColor),
      ),
      child: Row(
        children: [
          // Percentage (RTL: left)
          Text(
            '${stat.percentage}%',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: stat.percentageColor,
            ),
          ),
          const SizedBox(width: 12),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stat.title,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Icon (RTL: right)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 28),
          ),
        ],
      ),
    );
  }

  // ─── Achievements & Badges ────────────────────────────────────────────────

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'الأوسمة والإنجازات',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true, // RTL scroll
            itemCount: _badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildBadgeCard(_badges[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(_Badge badge) {
    return Opacity(
      opacity: badge.isEarned ? 1.0 : 0.5,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: badge.bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: badge.borderColor, width: 4),
                  ),
                  child: Icon(
                    badge.icon,
                    color: badge.iconColor,
                    size: 28,
                  ),
                ),
                if (badge.count != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'x${badge.count}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badge.label,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class _SubjectProgress {
  const _SubjectProgress({required this.name, required this.percentage});
  final String name;
  final double percentage;
}

class _AttachmentStat {
  const _AttachmentStat({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.percentageColor,
  });
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final int percentage;
  final Color percentageColor;
}

class _Badge {
  const _Badge({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.label,
    required this.isEarned,
    this.count,
  });
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String label;
  final bool isEarned;
  final int? count;
}
