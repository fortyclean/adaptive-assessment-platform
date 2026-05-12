import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/admin_top_actions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Screen 68 — Admin Dashboard v2 (لوحة تحكم المشرف — نسخة محسّنة)
/// Features subject performance chart, top teachers list, admin alerts, quick access.
/// RTL Arabic layout matching _68/code.html design.
class AdminDashboardV2Screen extends ConsumerStatefulWidget {
  const AdminDashboardV2Screen({super.key});

  @override
  ConsumerState<AdminDashboardV2Screen> createState() =>
      _AdminDashboardV2ScreenState();
}

class _AdminDashboardV2ScreenState
    extends ConsumerState<AdminDashboardV2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Search + Notifications (RTL: left)
                Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: AppColors.onSurfaceVariant,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('لا توجد إشعارات جديدة'), behavior: SnackBarBehavior.floating),
                            );
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: AppColors.onSurfaceVariant,
                      onPressed: () => context.push('/admin/users'),
                    ),
                    const AdminTopActions(),
                  ],
                ),
                // Logo + avatar (RTL: right)
                Row(
                  children: [
                    Text(
                      'EduAssess',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryContainer,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Content ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Stats Bento Grid
                _buildStatsBentoGrid(),
                const SizedBox(height: 24),

                // Subject Performance Chart
                _buildSubjectPerformanceChart(),
                const SizedBox(height: 24),

                // Top Teachers
                _buildTopTeachers(),
                const SizedBox(height: 24),

                // Admin Alerts
                _buildAdminAlerts(),
                const SizedBox(height: 24),

                // Quick Access
                _buildQuickAccess(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('إضافة عنصر جديد'), behavior: SnackBarBehavior.floating),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'admin'),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'لوحة تحكم المشرف',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          'مرحباً بك مجدداً، إليك ملخص أداء المدرسة اليوم.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // ─── Stats Bento Grid ────────────────────────────────────────────────────

  Widget _buildStatsBentoGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          icon: Icons.groups,
          iconBg: const Color(0xFFDDE1FF),
          iconColor: AppColors.primary,
          label: 'إجمالي الطلاب',
          value: '1,284',
          badge: '+12%',
          badgeColor: Colors.green,
          onTap: () => context.push('/admin/users'),
        ),
        _buildStatCard(
          icon: Icons.person_outline,
          iconBg: const Color(0xFFFFDBCE),
          iconColor: const Color(0xFF611E00),
          label: 'المعلمون النشطون',
          value: '86',
          onTap: () => context.push('/admin/users'),
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          iconBg: const Color(0xFFD3E4FE),
          iconColor: const Color(0xFF505F76),
          label: 'متوسط الأداء العام',
          value: '82%',
          showCircularProgress: true,
          progressValue: 0.82,
          onTap: () => context.push('/admin/reports'),
        ),
        _buildStatCard(
          icon: Icons.timer,
          iconBg: const Color(0xFFFEE2E2),
          iconColor: AppColors.error,
          label: 'اختبارات جارية',
          value: '14',
          onTap: () => context.push('/admin/classrooms'),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    String? badge,
    Color? badgeColor,
    bool showCircularProgress = false,
    double progressValue = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showCircularProgress)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 4,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: badgeColor ?? Colors.green,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  // ─── Subject Performance Chart ───────────────────────────────────────────

  Widget _buildSubjectPerformanceChart() {
    final subjects = [
      {'label': 'الرياضيات', 'value': 0.65},
      {'label': 'العلوم', 'value': 0.88},
      {'label': 'العربية', 'value': 0.72},
      {'label': 'الإنجليزية', 'value': 0.55},
      {'label': 'التاريخ', 'value': 0.80},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'الفصل الدراسي الحالي',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                'أداء المواد الدراسية',
                style: const TextStyle(
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: subjects.map((s) {
                final value = s['value'] as double;
                final label = s['label'] as String;
                final isHighest = value == 0.88;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(value * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isHighest
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isHighest
                                    ? AppColors.primaryContainer
                                    : AppColors.primaryContainer
                                        .withOpacity(0.2),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Teachers ────────────────────────────────────────────────────────

  Widget _buildTopTeachers() {
    final teachers = [
      {
        'name': 'أ. محمد أحمد',
        'role': 'معلم علوم - تفاعل عالي (98%)',
        'rating': '4.9',
        'initials': 'م.أ',
      },
      {
        'name': 'أ. سارة خالد',
        'role': 'معلمة رياضيات - تقدم طلابي (92%)',
        'rating': '4.8',
        'initials': 'س.خ',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.push('/admin/users'),
                child: const Text('عرض الكل', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
              Text(
                'المعلمون المتميزون (هذا الشهر)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1B22),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...teachers.map((t) => _buildTeacherRow(t)),
        ],
      ),
    );
  }

  Widget _buildTeacherRow(Map<String, dynamic> teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Rating (RTL: left)
          Row(
            children: [
              Text(
                teacher['rating'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 20, color: Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(width: 16),
          // Info (RTL: right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  teacher['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                  textAlign: TextAlign.right,
                ),
                Text(
                  teacher['role'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Avatar (RTL: rightmost)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainer,
            ),
            child: Center(
              child: Text(
                teacher['initials'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Admin Alerts ────────────────────────────────────────────────────────

  Widget _buildAdminAlerts() {
    final alerts = [
      {
        'type': 'error',
        'title': 'مراجعة مطلوبة',
        'body': 'فصل 10-أ يحتاج لمراجعة درجات اختبار العلوم.',
      },
      {
        'type': 'info',
        'title': 'تقارير جاهزة',
        'body': 'تقارير الأداء الشهري للطلاب متاحة الآن للتحميل.',
      },
      {
        'type': 'secondary',
        'title': 'تحديث الجداول',
        'body': 'تم تعديل جدول حصص المرحلة الثانوية ليوم الثلاثاء.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'تنبيهات الإدارة',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1B22),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.campaign, color: AppColors.error),
            ],
          ),
          const SizedBox(height: 16),
          ...alerts.map((a) => _buildAlertItem(a)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    Color bgColor;
    Color borderColor;
    Color titleColor;

    switch (alert['type']) {
      case 'error':
        bgColor = AppColors.errorContainer.withOpacity(0.2);
        borderColor = AppColors.error;
        titleColor = AppColors.error;
        break;
      case 'info':
        bgColor = const Color(0xFFEFF6FF);
        borderColor = AppColors.primary;
        titleColor = AppColors.primary;
        break;
      default:
        bgColor = const Color(0xFFD0E1FB).withOpacity(0.2);
        borderColor = const Color(0xFF505F76);
        titleColor = const Color(0xFF54647A);
    }

    VoidCallback onTap;
    final title = alert['title'] as String;
    if (title == 'مراجعة مطلوبة') {
      onTap = () => context.push('/admin/classrooms');
    } else if (title == 'تقارير جاهزة') {
      onTap = () => context.push('/admin/reports');
    } else {
      onTap = () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الجداول'), behavior: SnackBarBehavior.floating),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            right: BorderSide(color: borderColor, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              alert['title'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Text(
              alert['body'] as String,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Quick Access ────────────────────────────────────────────────────────

  Widget _buildQuickAccess() {
    final items = [
      {'icon': Icons.settings, 'label': 'الإعدادات'},
      {'icon': Icons.calendar_month, 'label': 'الجداول'},
      {'icon': Icons.person_add, 'label': 'إضافة طالب'},
      {'icon': Icons.cloud_download, 'label': 'التقارير'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'وصول سريع',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1B22),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
            children: items.map((item) {
              final label = item['label'] as String;
              VoidCallback onTap;
              if (label == 'الإعدادات') {
                onTap = () => context.push('/admin/institution-settings');
              } else if (label == 'الجداول') {
                onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري فتح إدارة الفصول'), behavior: SnackBarBehavior.floating),
                );
              } else if (label == 'إضافة طالب') {
                onTap = () => context.push('/admin/users');
              } else if (label == 'التقارير') {
                onTap = () => context.push('/admin/reports');
              } else {
                onTap = () {};
              }
              return InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1B22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
