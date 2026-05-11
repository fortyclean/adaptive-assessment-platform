import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/admin_top_actions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../repositories/admin_repository.dart';

/// Admin Dashboard Screen — Screen 23
/// Requirements: 13.1
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _schoolReport;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final report = await ref.read(adminRepositoryProvider).getSchoolReport();
      setState(() {
        _schoolReport = report;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final authState = ref.read(authProvider);
      final isDemoSession =
          (authState.accessToken ?? '').startsWith('demo-token-');
      if (!AppConstants.useMockData && !isDemoSession) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'تعذر تحميل بيانات لوحة المشرف. تحقق من الاتصال ثم أعد المحاولة.';
        });
        return;
      }
      setState(() {
        _schoolReport = {
          'summary': {
            'totalTeachers': 12,
            'totalStudents': 245,
            'totalAssessments': 38,
            'schoolAverage': 76,
          }
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final summary = _schoolReport?['summary'] as Map<String, dynamic>? ?? {};
    final schoolAverage = summary['schoolAverage'] as num?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً، ${user?.fullName ?? ''}',
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'لوحة تحكم المشرف',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          const AdminTopActions(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ─── School Performance Banner ──────────────────────────
                  if (schoolAverage != null) ...[
                    _PerformanceBanner(average: schoolAverage.round()),
                    const SizedBox(height: 20),
                  ],

                  // ─── Bento Grid Stats ───────────────────────────────────
                  _SectionHeader(title: 'إحصائيات المدرسة'),
                  const SizedBox(height: 12),
                  _BentoGrid(
                    children: [
                      _BentoCard(
                        label: 'المعلمون',
                        value: '${summary['totalTeachers'] ?? 0}',
                        icon: Icons.person_rounded,
                        color: AppColors.primary,
                        bgColor: const Color(0xFFDDE1FF),
                        onTap: () => context.push(
                          AppRoutes.adminUsers,
                          extra: {'initialFilter': 'teacher'},
                        ),
                      ),
                      _BentoCard(
                        label: 'الطلاب',
                        value: '${summary['totalStudents'] ?? 0}',
                        icon: Icons.school_rounded,
                        color: AppColors.success,
                        bgColor: const Color(0xFFD1FAE5),
                        onTap: () => context.push(
                          AppRoutes.adminUsers,
                          extra: {'initialFilter': 'student'},
                        ),
                      ),
                      _BentoCard(
                        label: 'الفصول',
                        value: '0',
                        icon: Icons.class_rounded,
                        color: AppColors.warning,
                        bgColor: const Color(0xFFFEF3C7),
                        onTap: () => context.push(AppRoutes.adminClassrooms),
                      ),
                      _BentoCard(
                        label: 'الاختبارات',
                        value: '${summary['totalAssessments'] ?? 0}',
                        icon: Icons.quiz_rounded,
                        color: AppColors.primaryContainer,
                        bgColor: const Color(0xFFD0E1FB),
                        onTap: () => context.push(AppRoutes.teacherAssessments),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Administrative Alerts ──────────────────────────────
                  _SectionHeader(title: 'التنبيهات الإدارية'),
                  const SizedBox(height: 12),
                  _AlertCard(
                    icon: Icons.warning_rounded,
                    iconColor: AppColors.error,
                    iconBgColor: AppColors.errorContainer,
                    title: 'طلاب لم يؤدوا الاختبار',
                    subtitle: 'يوجد 5 طلاب لم يسلموا الاختبار الأخير',
                    onTap: () => context.push(
                      AppRoutes.adminReports,
                      extra: {'focus': 'participation'},
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AlertCard(
                    icon: Icons.notification_important_rounded,
                    iconColor: AppColors.primary,
                    iconBgColor: const Color(0xFFDDE1FF),
                    title: 'طلبات انضمام جديدة',
                    subtitle: 'يوجد 3 طلبات انضمام تنتظر الموافقة',
                    onTap: () => context.push(
                      AppRoutes.adminUsers,
                      extra: {'initialFilter': 'pending'},
                    ),
                  ),
                  const SizedBox(height: 8),
                  _AlertCard(
                    icon: Icons.trending_down_rounded,
                    iconColor: AppColors.warning,
                    iconBgColor: const Color(0xFFFEF3C7),
                    title: 'انخفاض في الأداء',
                    subtitle: 'فصل الرياضيات - المستوى العاشر',
                    onTap: () => context.push(
                      AppRoutes.adminReports,
                      extra: {
                        'gradeLevel': '10',
                        'subject': 'الرياضيات',
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Quick Access Links ─────────────────────────────────
                  _SectionHeader(title: 'روابط سريعة'),
                  const SizedBox(height: 12),
                  _QuickLink(
                    icon: Icons.people_rounded,
                    title: 'إدارة المستخدمين',
                    subtitle: 'إضافة وتعديل حسابات المعلمين والطلاب',
                    color: AppColors.primary,
                    bgColor: const Color(0xFFDDE1FF),
                    onTap: () => context.push(AppRoutes.adminUsers),
                  ),
                  const SizedBox(height: 8),
                  _QuickLink(
                    icon: Icons.class_rounded,
                    title: 'إدارة الفصول',
                    subtitle: 'عرض وتنظيم الفصول الدراسية',
                    color: AppColors.warning,
                    bgColor: const Color(0xFFFEF3C7),
                    onTap: () => context.push(AppRoutes.adminClassrooms),
                  ),
                  const SizedBox(height: 8),
                  _QuickLink(
                    icon: Icons.bar_chart_rounded,
                    title: 'تقارير المدرسة',
                    subtitle: 'تحليلات شاملة لأداء المدرسة',
                    color: AppColors.success,
                    bgColor: const Color(0xFFD1FAE5),
                    onTap: () => context.push(AppRoutes.adminReports),
                  ),
                  const SizedBox(height: 8),
                  _QuickLink(
                    icon: Icons.dashboard_customize_rounded,
                    title: 'لوحة التحكم المتقدمة',
                    subtitle: 'إحصائيات وتحليلات تفصيلية للمشرف',
                    color: AppColors.primaryContainer,
                    bgColor: const Color(0xFFD0E1FB),
                    onTap: () => context.push(AppRoutes.adminDashboardV2),
                  ),
                  const SizedBox(height: 8),
                  _QuickLink(
                    icon: Icons.supervisor_account_rounded,
                    title: 'لوحة المشرف المتقدمة',
                    subtitle: 'إحصائيات وتحليلات تفصيلية',
                    color: AppColors.primaryContainer,
                    bgColor: const Color(0xFFD0E1FB),
                    onTap: () => context.push('/supervisor'),
                  ),
                  const SizedBox(height: 8),
                  _QuickLink(
                    icon: Icons.settings_outlined,
                    title: 'إعدادات المؤسسة',
                    subtitle: 'ضبط إعدادات المؤسسة التعليمية',
                    color: AppColors.onSurfaceVariant,
                    bgColor: AppColors.surfaceContainer,
                    onTap: () => context.push('/admin/institution-settings'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'admin'),
    );
  }
}

// ─── Performance Banner ───────────────────────────────────────────────────────

class _PerformanceBanner extends StatelessWidget {
  const _PerformanceBanner({required this.average});
  final int average;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نظرة عامة على الأداء',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'متوسط أداء المدرسة هذا الشهر',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'تحسن بنسبة 12% هذا الشهر',
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$average%',
                      style: const TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'المعدل',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
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
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Almarai',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }
}

// ─── Bento Grid ───────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: children,
    );
  }
}

// ─── Bento Card ───────────────────────────────────────────────────────────────

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
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
          ],
        ),
      ),
    );
  }
}

// ─── Alert Card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
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
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Link ───────────────────────────────────────────────────────────────

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
