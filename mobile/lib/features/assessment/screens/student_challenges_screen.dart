import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Student Challenges Screen — Screen 64
/// Live challenges, leaderboard, personal challenge stats, and badges.
class StudentChallengesScreen extends ConsumerStatefulWidget {
  const StudentChallengesScreen({super.key});

  @override
  ConsumerState<StudentChallengesScreen> createState() =>
      _StudentChallengesScreenState();
}

class _StudentChallengesScreenState
    extends ConsumerState<StudentChallengesScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _buildLiveChallenges(),
                  const SizedBox(height: 24),
                  _buildLeaderboard(),
                  const SizedBox(height: 24),
                  _buildMyChallenges(),
                  const SizedBox(height: 24),
                  _buildBadges(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20))),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('إنشاء تحدي جديد',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('يمكنك تحدي زملائك في أي مادة دراسية.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تم إنشاء التحدي بنجاح'),
                              behavior: SnackBarBehavior.floating),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3755C3),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48)),
                      child: const Text('إنشاء تحدي'),
                    ),
                  ],
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF3755C3),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'student'),
      );

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) => Container(
        height: 64 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Notifications (RTL: left)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: const Color(0xFF475569),
              onPressed: () => context.push('/student/notifications'),
            ),
            // Logo + avatar (RTL: right)
            Row(
              children: [
                const Text(
                  'EduAssess',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryContainer,
                      width: 2,
                    ),
                    color: AppColors.surfaceContainer,
                  ),
                  child: const Icon(Icons.person,
                      size: 22, color: Color(0xFF444653)),
                ),
              ],
            ),
          ],
        ),
      );

  // ─── Live Challenges ──────────────────────────────────────────────────────

  Widget _buildLiveChallenges() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Live badge (RTL: left)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'مباشر الآن',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              // Title (RTL: right)
              const Row(
                children: [
                  Text(
                    'تحديات مباشرة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1B22),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.rocket_launch_outlined,
                    color: AppColors.error,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildChallengeCard(
            title: 'ماراثون الرياضيات الذهنية',
            subtitle: 'المستوى المتقدم • الجبر والهندسة',
            points: '500 نقطة',
            participants: '1,240 مشارك',
            timeLeft: '14:25 دقيقة',
            progressFraction: 0.75,
            accentColor: AppColors.primaryContainer,
            pointsBg: const Color(0xFFDDE1FF),
            pointsTextColor: const Color(0xFF173BAB),
            isJoinable: true,
            timeColor: AppColors.error,
          ),
          const SizedBox(height: 12),
          _buildChallengeCard(
            title: 'مسابقة اللغة العربية الفصحى',
            subtitle: 'النحو والصرف • البلاغة',
            points: '350 نقطة',
            participants: '850 مشارك',
            timeLeft: '05:10 دقيقة',
            progressFraction: 0,
            accentColor: const Color(0xFF611E00),
            pointsBg: const Color(0xFFFFDBCE),
            pointsTextColor: const Color(0xFF802A00),
            isJoinable: false,
            timeColor: AppColors.onSurfaceVariant,
          ),
        ],
      );

  Widget _buildChallengeCard({
    required String title,
    required String subtitle,
    required String points,
    required String participants,
    required String timeLeft,
    required double progressFraction,
    required Color accentColor,
    required Color pointsBg,
    required Color pointsTextColor,
    required bool isJoinable,
    required Color timeColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left accent bar (RTL: right side in HTML = right side in Flutter RTL)
            Positioned(
              top: -16,
              bottom: -16,
              right: -16,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Points badge (RTL: left)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: pointsBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        points,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: pointsTextColor,
                        ),
                      ),
                    ),
                    // Title (RTL: right)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1B22),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF444653),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          timeLeft,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: timeColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.timer_outlined, size: 18, color: timeColor),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Row(
                      children: [
                        Text(
                          participants,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF444653),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.group_outlined,
                            size: 18, color: Color(0xFF444653)),
                      ],
                    ),
                  ],
                ),
                if (progressFraction > 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3755C3),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: isJoinable
                      ? ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: Text('الانضمام إلى: $title'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.rocket_launch_outlined,
                                        size: 48, color: Color(0xFF3755C3)),
                                    const SizedBox(height: 12),
                                    Text(
                                        'ستحصل على $points عند إكمال التحدي بنجاح.'),
                                    const SizedBox(height: 8),
                                    Text('المشاركون: $participants',
                                        style: const TextStyle(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 13)),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('إلغاء')),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'تم الانضمام إلى تحدي: $title'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor:
                                              const Color(0xFF3755C3),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF3755C3),
                                        foregroundColor: Colors.white),
                                    child: const Text('انضم الآن'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'انضم للتحدي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('تم إضافتك لقائمة انتظار: $title'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'قائمة الانتظار',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      );

  // ─── Leaderboard ──────────────────────────────────────────────────────────

  Widget _buildLeaderboard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأسبوع الحالي',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'لوحة المتصدرين',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFFDBCE),
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Rank 1 (highlighted)
            _buildLeaderboardRow(
              rank: '1',
              name: 'سارة العتيبي',
              level: 'المستوى 42',
              points: '4,850',
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildLeaderboardRow(
              rank: '2',
              name: 'عمر خالد',
              level: '',
              points: '4,200',
              isHighlighted: false,
            ),
            const SizedBox(height: 8),
            _buildLeaderboardRow(
              rank: '3',
              name: 'علي حسن',
              level: '',
              points: '3,950',
              isHighlighted: false,
            ),
            const SizedBox(height: 16),
            // Divider
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 8),
            // User's rank
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Color(0xFFFFDBCE),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'تقدمت 3 مراكز',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'مركزك الحالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDBCE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '#12',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF380D00),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildLeaderboardRow({
    required String rank,
    required String name,
    required String level,
    required String points,
    required bool isHighlighted,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted
              ? Border.all(color: Colors.white.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            // Points (RTL: left)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  points,
                  style: TextStyle(
                    fontSize: isHighlighted ? 24 : 18,
                    fontWeight: FontWeight.w700,
                    color:
                        isHighlighted ? const Color(0xFFFFDBCE) : Colors.white,
                  ),
                ),
                if (isHighlighted)
                  const Text(
                    'نقطة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Name + level (RTL: center)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                        .withValues(alpha: isHighlighted ? 1.0 : 0.9),
                  ),
                ),
                if (level.isNotEmpty)
                  Text(
                    level,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Avatar placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(
                  color: isHighlighted
                      ? const Color(0xFFFFDBCE)
                      : Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0] : '؟',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Rank number
            SizedBox(
              width: 32,
              child: Text(
                rank,
                style: TextStyle(
                  fontSize: isHighlighted ? 24 : 18,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted
                      ? const Color(0xFFFFDBCE)
                      : Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  // ─── My Challenges ────────────────────────────────────────────────────────

  Widget _buildMyChallenges() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'تحدياتي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1B22),
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.assignment_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildChallengeStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF3755C3),
                  value: '12',
                  label: 'تحديات مكتملة',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChallengeStatCard(
                  icon: Icons.event_outlined,
                  iconColor: const Color(0xFF505F76),
                  value: '4',
                  label: 'قادمة قريباً',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Challenge list items
          _buildChallengeListItem(
            icon: Icons.science_outlined,
            iconBg: const Color(0xFFD0E1FB),
            iconColor: const Color(0xFF54647A),
            title: 'تحدي الكيمياء الأسبوعي',
            subtitle: 'ينتهي في: غداً، 10:00 ص',
            trailingIcon: Icons.chevron_right,
            trailingColor: const Color(0xFFCBD5E1),
            isCompleted: false,
          ),
          const SizedBox(height: 8),
          _buildChallengeListItem(
            icon: Icons.language_outlined,
            iconBg: const Color(0xFFFFDBCE).withValues(alpha: 0.3),
            iconColor: const Color(0xFF611E00),
            title: 'المفردات الإنجليزية',
            subtitle: 'اكتمل • 90% دقة',
            subtitleColor: const Color(0xFF16A34A),
            trailingIcon: Icons.verified,
            trailingColor: const Color(0xFF22C55E),
            isCompleted: true,
          ),
        ],
      );

  Widget _buildChallengeStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F2FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1B22),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF444653),
              ),
            ),
          ],
        ),
      );

  Widget _buildChallengeListItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required IconData trailingIcon,
    required Color trailingColor,
    required bool isCompleted,
    Color? subtitleColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Trailing icon (RTL: left)
            Icon(trailingIcon, color: trailingColor, size: 24),
            const Spacer(),
            // Title + subtitle (RTL: center-right)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1B22),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor ?? const Color(0xFF444653),
                    ),
                    textAlign: TextAlign.right,
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
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ],
        ),
      );

  // ─── Badges ───────────────────────────────────────────────────────────────

  Widget _buildBadges() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'الأوسمة المحققة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1B22),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBadge(
                  icon: Icons.workspace_premium_outlined,
                  label: 'الخارق',
                  isLocked: true,
                  gradient: null,
                ),
                _buildBadge(
                  icon: Icons.bolt,
                  label: 'المتسابق السريع',
                  isLocked: false,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                  ),
                ),
                _buildBadge(
                  icon: Icons.psychology,
                  label: 'المفكر',
                  isLocked: false,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF60A5FA), Color(0xFF4F46E5)],
                  ),
                ),
                _buildBadge(
                  icon: Icons.star,
                  label: 'النجم الصاعد',
                  isLocked: false,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF34D399), Color(0xFF0D9488)],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required bool isLocked,
    required Gradient? gradient,
  }) =>
      Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isLocked ? null : gradient,
              color: isLocked ? null : null,
              border: isLocked
                  ? Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 2,
                    )
                  : null,
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: isLocked ? const Color(0xFF94A3B8) : Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isLocked ? FontWeight.w400 : FontWeight.w600,
              color:
                  isLocked ? const Color(0xFF94A3B8) : const Color(0xFF1A1B22),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
}
