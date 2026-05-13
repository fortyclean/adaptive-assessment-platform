import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Teacher Home Screen — Screen 59
/// Alternative teacher dashboard with greeting, summary cards,
/// quick actions, bar chart, and upcoming schedule.
class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final firstName = user?.fullName.split(' ').first ?? 'نورة';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildAppBar(context, user?.fullName ?? 'أ. نورة'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildGreeting(firstName),
                const SizedBox(height: 24),
                _buildSummaryCards(),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildPerformanceChart(),
                const SizedBox(height: 24),
                _buildUpcomingSchedule(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'teacher'),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, String teacherName) => Container(
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
              onPressed: () => context.push(AppRoutes.teacherNotifications),
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
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 2,
                    ),
                    color: AppColors.surfaceContainer,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 22,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // ─── Greeting ────────────────────────────────────────────────────────────

  Widget _buildGreeting(String name) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'أهلاً بك، أ. $name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          const Text(
            'إليك ملخص سريع لأداء طلابك اليوم.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF505F76),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      );

  // ─── Summary Cards ───────────────────────────────────────────────────────

  Widget _buildSummaryCards() => Column(
        children: [
          // Full-width card
          _buildSummaryCard(
            label: 'الفصول النشطة',
            value: '8 فصول',
            icon: Icons.school_outlined,
            iconBg: const Color(0xFFDDE1FF),
            iconColor: AppColors.primary,
            fullWidth: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  label: 'اختبارات قيد التصحيح',
                  value: '12',
                  badge: 'عاجل',
                  badgeColor: AppColors.error,
                  fullWidth: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  label: 'رسائل غير مقروءة',
                  value: '5',
                  badge: 'جديد',
                  badgeColor: AppColors.primary,
                  fullWidth: false,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required bool fullWidth,
    IconData? icon,
    Color? iconBg,
    Color? iconColor,
    String? badge,
    Color? badgeColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: fullWidth
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (icon != null)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBg ?? AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon,
                          color: iconColor ?? AppColors.primary, size: 28),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF505F76),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF505F76),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (badge != null)
                        Text(
                          badge,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: badgeColor ?? AppColors.primary,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: badgeColor == AppColors.error
                              ? const Color(0xFF872D00)
                              : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );

  // ─── Quick Actions ───────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1B22),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // RTL scroll
            child: Row(
              children: [
                _buildActionButton(
                  label: 'إنشاء اختبار',
                  icon: Icons.add_circle_outline,
                  isPrimary: true,
                  onTap: () => context.push(AppRoutes.teacherCreateAssessment),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  label: 'إضافة سؤال',
                  icon: Icons.quiz_outlined,
                  isPrimary: false,
                  hasBorder: true,
                  onTap: () => context.push(AppRoutes.teacherAddQuestion),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  label: 'إرسال إعلان',
                  icon: Icons.campaign_outlined,
                  isPrimary: false,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (ctx) {
                        final msgController = TextEditingController();
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                              left: 16,
                              right: 16,
                              top: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                  child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                          color: AppColors.outlineVariant,
                                          borderRadius:
                                              BorderRadius.circular(2)))),
                              const SizedBox(height: 16),
                              const Text('إرسال إعلان للطلاب',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 16),
                              TextField(
                                controller: msgController,
                                maxLines: 3,
                                textDirection: TextDirection.rtl,
                                decoration: InputDecoration(
                                  hintText: 'اكتب نص الإعلان هنا...',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'تم إرسال الإعلان لجميع الطلاب'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Color(0xFF2E7D32)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: const Text('إرسال الإعلان',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primary
                  : hasBorder
                      ? AppColors.primary
                      : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPrimary
                      ? Colors.white
                      : hasBorder
                          ? AppColors.primary
                          : const Color(0xFF505F76),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 20,
                color: isPrimary
                    ? Colors.white
                    : hasBorder
                        ? AppColors.primary
                        : const Color(0xFF505F76),
              ),
            ],
          ),
        ),
      );

  // ─── Performance Chart ───────────────────────────────────────────────────

  Widget _buildPerformanceChart() {
    final data = [
      const _ChartBar(day: 'أحد', heightFraction: 0.40),
      const _ChartBar(day: 'إثنين', heightFraction: 0.60),
      const _ChartBar(day: 'ثلاثاء', heightFraction: 0.85),
      const _ChartBar(day: 'أربعاء', heightFraction: 0.70),
      const _ChartBar(day: 'خميس', heightFraction: 0.95),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'آخر 7 أيام',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF505F76),
                  ),
                ),
              ),
              const Text(
                'متوسط تقدم الطلاب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1B22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data
                  .map((bar) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: bar.heightFraction,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.2 + bar.heightFraction * 0.8,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bar.day,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF505F76),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Upcoming Schedule ───────────────────────────────────────────────────

  Widget _buildUpcomingSchedule() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.push(AppRoutes.classSchedule),
                child: const Text(
                  'الكل',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Text(
                'الجدول القادم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1B22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            time: '08:00',
            period: 'صباحاً',
            title: 'رياضيات - الصف العاشر',
            location: 'القاعة 402',
            accentColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildScheduleCard(
            time: '10:30',
            period: 'صباحاً',
            title: 'فيزياء - الصف الحادي عشر',
            location: 'المختبر العلمي',
            accentColor: const Color(0xFF505F76),
          ),
        ],
      );

  Widget _buildScheduleCard({
    required String time,
    required String period,
    required String title,
    required String location,
    required Color accentColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
            // Right accent bar (RTL)
            Positioned(
              right: -16,
              top: -16,
              bottom: -16,
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
            Row(
              children: [
                // Chevron (RTL: left)
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCBD5E1),
                  size: 24,
                ),
                const Spacer(),
                // Title + location (RTL: center)
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF505F76),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF505F76),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Time box (RTL: right)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF505F76),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _ChartBar {
  const _ChartBar({required this.day, required this.heightFraction});
  final String day;
  final double heightFraction;
}
