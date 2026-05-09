import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

/// Screen 68 — لوحة تحكم المشرف المتقدمة (Supervisor/Admin Advanced Dashboard)
/// Matches design: _68/code.html
class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8FF),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildSubjectPerformanceChart(),
                        const SizedBox(height: 16),
                        _buildTopTeachers(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAlertsSection(),
              const SizedBox(height: 16),
              _buildQuickAccess(),
              const SizedBox(height: 80),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('ماذا تريد إضافة؟', textAlign: TextAlign.right),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.push('/admin/users');
                    },
                    child: const Text('إضافة مستخدم'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.push('/admin/classrooms');
                    },
                    child: const Text('إضافة فصل'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            );
          },
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1E40AF),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'EduAssess',
            style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.grey), onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('البحث قيد التطوير'), behavior: SnackBarBehavior.floating),
          );
        }),
        Stack(
          children: [
            IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.grey), onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('لا توجد إشعارات جديدة'), behavior: SnackBarBehavior.floating),
              );
            }),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'لوحة تحكم المشرف',
          style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4),
        Text(
          'مرحباً بك مجدداً، إليك ملخص أداء المدرسة اليوم.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatCard(icon: Icons.groups, iconBg: const Color(0xFFDDE1FF), iconColor: AppColors.primary, label: 'إجمالي الطلاب', value: '1,284', badge: '+12%', badgeColor: Colors.green),
      _StatCard(icon: Icons.person_outline, iconBg: const Color(0xFFFFDBCE), iconColor: const Color(0xFF872D00), label: 'المعلمون النشطون', value: '86'),
      _StatCard(icon: Icons.trending_up, iconBg: const Color(0xFFD3E4FE), iconColor: const Color(0xFF505F76), label: 'متوسط الأداء العام', value: '82%', showCircle: true, circleValue: 0.82),
      _StatCard(icon: Icons.timer_outlined, iconBg: const Color(0xFFFEE2E2), iconColor: AppColors.error, label: 'اختبارات جارية', value: '14'),
    ];

    final onTaps = [
      () => context.push('/admin/users'),
      () => context.push('/admin/users'),
      () => context.push('/admin/reports'),
      () => context.push('/admin/classrooms'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: List.generate(stats.length, (i) => _buildStatCard(stats[i], onTap: onTaps[i])),
    );
  }

  Widget _buildStatCard(_StatCard stat, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: stat.iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(stat.icon, color: stat.iconColor, size: 20),
              ),
              if (stat.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(stat.badge!, style: TextStyle(color: stat.badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              if (stat.showCircle)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: stat.circleValue,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              const SizedBox(height: 2),
              Text(stat.value, style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSubjectPerformanceChart() {
    final subjects = [
      _SubjectBar(name: 'الرياضيات', value: 0.65),
      _SubjectBar(name: 'العلوم', value: 0.88, highlighted: true),
      _SubjectBar(name: 'العربية', value: 0.72),
      _SubjectBar(name: 'الإنجليزية', value: 0.55),
      _SubjectBar(name: 'التاريخ', value: 0.80),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('أداء المواد الدراسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('الفصل الدراسي الحالي', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: subjects.map((s) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(s.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: s.highlighted ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 36,
                      height: 120 * s.value,
                      decoration: BoxDecoration(
                        color: s.highlighted ? const Color(0xFF1E40AF) : const Color(0xFF1E40AF).withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(s.name, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTeachers() {
    final teachers = [
      _TeacherItem(name: 'أ. محمد أحمد', role: 'معلم علوم - تفاعل عالي (98%)', rating: 4.9),
      _TeacherItem(name: 'أ. سارة خالد', role: 'معلمة رياضيات - تقدم طلابي (92%)', rating: 4.8),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.push('/admin/users'),
                child: const Text('عرض الكل', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
              const Text('المعلمون المتميزون (هذا الشهر)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...teachers.map((t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEEEDF7),
                  child: Text(t.name[3], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(t.role, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    Text(t.rating.toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alerts = [
      _AlertItem(type: 'مراجعة مطلوبة', message: 'فصل 10-أ يحتاج لمراجعة درجات اختبار العلوم.', borderColor: AppColors.error, bgColor: const Color(0xFFFEE2E2), textColor: AppColors.error),
      _AlertItem(type: 'تقارير جاهزة', message: 'تقارير الأداء الشهري للطلاب متاحة الآن للتحميل.', borderColor: AppColors.primary, bgColor: const Color(0xFFEFF6FF), textColor: AppColors.primary),
      _AlertItem(type: 'تحديث الجداول', message: 'تم تعديل جدول حصص المرحلة الثانوية ليوم الثلاثاء.', borderColor: const Color(0xFF505F76), bgColor: const Color(0xFFD0E1FB).withOpacity(0.3), textColor: const Color(0xFF54647A)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.campaign_outlined, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text('تنبيهات الإدارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map((a) {
            VoidCallback onTap;
            if (a.type == 'مراجعة مطلوبة') {
              onTap = () => context.push('/admin/classrooms');
            } else if (a.type == 'تقارير جاهزة') {
              onTap = () => context.push('/admin/reports');
            } else {
              onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث الجداول'), behavior: SnackBarBehavior.floating),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: a.bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(right: BorderSide(color: a.borderColor, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.type, style: TextStyle(color: a.textColor, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(a.message, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    final items = [
      {'icon': Icons.settings_outlined, 'label': 'الإعدادات'},
      {'icon': Icons.calendar_month_outlined, 'label': 'الجداول'},
      {'icon': Icons.person_add_outlined, 'label': 'إضافة طالب'},
      {'icon': Icons.cloud_download_outlined, 'label': 'التقارير'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('وصول سريع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: items.map((item) {
              final label = item['label'] as String;
              VoidCallback onTap;
              if (label == 'الإعدادات') {
                onTap = () => context.push('/admin/institution-settings');
              } else if (label == 'الجداول') {
                onTap = () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الجداول قيد التطوير'), behavior: SnackBarBehavior.floating),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(label, style: const TextStyle(fontSize: 12)),
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

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'الرئيسية', true, onTap: null),
          _navItem(Icons.quiz_outlined, 'الاختبارات', false, onTap: () => context.push('/admin/classrooms')),
          _navItem(Icons.bar_chart_outlined, 'التقارير', false, onTap: () => context.push('/admin/reports')),
          _navItem(Icons.settings_outlined, 'الإعدادات', false, onTap: () => context.push('/admin/institution-settings')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF1E40AF) : Colors.grey, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: active ? const Color(0xFF1E40AF) : Colors.grey)),
        ],
      ),
    );
  }
}

class _StatCard {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String? badge;
  final Color? badgeColor;
  final bool showCircle;
  final double circleValue;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.badge,
    this.badgeColor,
    this.showCircle = false,
    this.circleValue = 0,
  });
}

class _SubjectBar {
  final String name;
  final double value;
  final bool highlighted;
  const _SubjectBar({required this.name, required this.value, this.highlighted = false});
}

class _TeacherItem {
  final String name;
  final String role;
  final double rating;
  const _TeacherItem({required this.name, required this.role, required this.rating});
}

class _AlertItem {
  final String type;
  final String message;
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  const _AlertItem({required this.type, required this.message, required this.borderColor, required this.bgColor, required this.textColor});
}
