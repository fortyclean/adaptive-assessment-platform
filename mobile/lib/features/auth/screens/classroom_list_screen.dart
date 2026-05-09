import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Classroom List Screen — Screen 61
/// Teacher view of all classrooms with student count, performance,
/// and quick actions (view students, assessments, reports).
class ClassroomListScreen extends ConsumerStatefulWidget {
  const ClassroomListScreen({super.key});

  @override
  ConsumerState<ClassroomListScreen> createState() =>
      _ClassroomListScreenState();
}

class _ClassroomListScreenState extends ConsumerState<ClassroomListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample data — replace with real API data
  final List<_ClassroomData> _classrooms = const [
    _ClassroomData(
      name: 'الفصل العاشر (أ)',
      subject: 'الرياضيات - المستوى المتقدم',
      studentCount: 28,
      averagePerformance: 84,
      iconBg: Color(0xFFDDE1FF),
      iconColor: Color(0xFF001453),
      icon: Icons.school_outlined,
    ),
    _ClassroomData(
      name: 'الفصل الثاني عشر (ج)',
      subject: 'الفيزياء - مسار علمي',
      studentCount: 22,
      averagePerformance: 79,
      iconBg: Color(0xFFFFDBCE),
      iconColor: Color(0xFF380D00),
      icon: Icons.science_outlined,
    ),
    _ClassroomData(
      name: 'المستوى المتوسط (ب)',
      subject: 'اللغة الإنجليزية',
      studentCount: 31,
      averagePerformance: 91,
      iconBg: Color(0xFFD3E4FE),
      iconColor: Color(0xFF0B1C30),
      icon: Icons.language_outlined,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ClassroomData> get _filtered {
    if (_searchQuery.isEmpty) return _classrooms;
    return _classrooms
        .where((c) =>
            c.name.contains(_searchQuery) || c.subject.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildSearchAndAdd(context),
                const SizedBox(height: 24),
                ..._filtered.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ClassroomCard(
                        classroom: c,
                        onViewStudents: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('عرض طلاب ${c.name}'), behavior: SnackBarBehavior.floating),
                          );
                        },
                        onViewReports: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تقارير ${c.name}'), behavior: SnackBarBehavior.floating),
                          );
                        },
                        onViewAssessments: () {
                          context.push(AppRoutes.teacherAssessments);
                        },
                      ),
                    )),
                const SizedBox(height: 24),
                _buildPerformanceOverview(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const AppBottomNav(currentIndex: 1, role: 'teacher'),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Save button (RTL: left)
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ التغييرات'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF2E7D32)),
              );
            },
            child: const Text(
              'حفظ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E40AF),
                fontFamily: 'Lexend',
              ),
            ),
          ),
          // Title + back (RTL: right)
          Row(
            children: [
              const Text(
                'إدارة الفصول الدراسية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E40AF),
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                color: const Color(0xFF1E40AF),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search + Add ─────────────────────────────────────────────────────────

  Widget _buildSearchAndAdd(BuildContext context) {
    return Row(
      children: [
        // Search field (RTL: right, takes most space)
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'البحث عن فصل دراسي...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757684),
                ),
                prefixIcon: Icon(Icons.search, color: Color(0xFF757684)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Add button (RTL: left)
        ElevatedButton.icon(
          onPressed: () => context.push(AppRoutes.adminClassrooms),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('إضافة فصل'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }

  // ─── Performance Overview ─────────────────────────────────────────────────

  Widget _buildPerformanceOverview() {
    return Row(
      children: [
        // Alerts card (RTL: left)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'التنبيهات العاجلة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                _buildAlert(
                  icon: Icons.warning_amber_outlined,
                  iconColor: AppColors.error,
                  title: '5 طلاب لم يسلموا الاختبار',
                  subtitle: 'الرياضيات - الفصل العاشر (أ)',
                ),
                const SizedBox(height: 12),
                _buildAlert(
                  icon: Icons.notification_important_outlined,
                  iconColor: AppColors.primary,
                  title: 'طلب انضمام جديد',
                  subtitle: 'فصل اللغة الإنجليزية',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('عرض جميع التنبيهات'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('عرض جميع التنبيهات'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Performance summary card (RTL: right)
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'نظرة عامة على الأداء الأكاديمي',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                const Text(
                  'تظهر البيانات تحسناً بنسبة 12% في متوسط درجات الطلاب خلال الشهر الحالي.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                // Circular progress indicator
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 8,
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '82%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'معدل الإنجاز',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري تحميل التقرير الكامل...'), behavior: SnackBarBehavior.floating),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('تحميل التقرير الكامل'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlert({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1B22),
                ),
                textAlign: TextAlign.right,
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757684),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: iconColor, size: 20),
      ],
    );
  }
}

// ─── Classroom Card ───────────────────────────────────────────────────────────

class _ClassroomCard extends StatelessWidget {
  const _ClassroomCard({required this.classroom, this.onViewStudents, this.onViewReports, this.onViewAssessments});
  final _ClassroomData classroom;
  final VoidCallback? onViewStudents;
  final VoidCallback? onViewReports;
  final VoidCallback? onViewAssessments;

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
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Subject badge (RTL: left)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E1FB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  classroom.subject,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF54647A),
                  ),
                ),
              ),
              // Icon (RTL: right)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: classroom.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  classroom.icon,
                  color: classroom.iconColor,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Class name
          Text(
            classroom.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1B22),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${classroom.averagePerformance}%',
                  label: 'متوسط الأداء',
                  valueColor: const Color(0xFF611E00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '${classroom.studentCount}',
                  label: 'طالب',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // View students button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewStudents ?? () {},
              icon: const Icon(Icons.groups_outlined, size: 18),
              label: const Text('عرض الطلاب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Secondary actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewReports ?? () {},
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text('التقارير'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewAssessments ?? () {},
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('الاختبارات'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.valueColor,
  });
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757684),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

class _ClassroomData {
  const _ClassroomData({
    required this.name,
    required this.subject,
    required this.studentCount,
    required this.averagePerformance,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });
  final String name;
  final String subject;
  final int studentCount;
  final int averagePerformance;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
}
