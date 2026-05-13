import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

/// Screen 67 — إدارة المهام (Teacher Task Management)
/// Matches design: _67/code.html
class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0;

  final List<String> _filters = [
    'الكل',
    'رياضيات - الصف العاشر',
    'فيزياء - الصف الحادي عشر'
  ];

  final List<_AssignmentCard> _assignments = [
    const _AssignmentCard(
      subject: 'رياضيات',
      subjectColor: Color(0xFFD0E1FB),
      subjectTextColor: Color(0xFF54647A),
      title: 'الجبر المتطور: المعادلات التربيعية',
      className: 'الصف العاشر - أ',
      dueDate: 'تسليم: 15 أكتوبر',
      dueDateColor: Color(0xFF444653),
      completionRate: 0.85,
    ),
    const _AssignmentCard(
      subject: 'فيزياء',
      subjectColor: Color(0xFFFFDBCE),
      subjectTextColor: Color(0xFF802A00),
      title: 'مقدمة في قوانين نيوتن',
      className: 'الصف الحادي عشر - ج',
      dueDate: 'تسليم: غداً',
      dueDateColor: AppColors.error,
      completionRate: 0.42,
    ),
    const _AssignmentCard(
      subject: 'رياضيات',
      subjectColor: Color(0xFFD0E1FB),
      subjectTextColor: Color(0xFF54647A),
      title: 'الاحتمالات والإحصاء الوصفي',
      className: 'الصف العاشر - ب',
      dueDate: 'تسليم: 20 أكتوبر',
      dueDateColor: Color(0xFF444653),
      completionRate: 0.12,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFFBF8FF),
          appBar: _buildAppBar(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إدارة المهام',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'تابع واجبات طلابك ونسب الإنجاز بكل سهولة.',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _buildTabs(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _assignments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _buildAssignmentCard(_assignments[i]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('إضافة مهمة جديدة'),
                    behavior: SnackBarBehavior.floating),
              );
            },
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      );

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFD0E1FB),
              child: Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'EduAssess',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () => context.push('/teacher/notifications'),
          ),
        ],
      );

  Widget _buildFilterChips() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (i) {
            final selected = _selectedFilter == i;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF1E40AF) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFFC4C5D5),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (i == 0) ...[
                        Icon(Icons.filter_list,
                            size: 16,
                            color: selected
                                ? Colors.white
                                : AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _filters[i],
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      );

  Widget _buildTabs() => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFC4C5D5))),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'المهام النشطة'),
            Tab(text: 'المسودات'),
            Tab(text: 'المكتملة'),
          ],
        ),
      );

  Widget _buildAssignmentCard(_AssignmentCard card) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: card.subjectColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          card.subject,
                          style: TextStyle(
                            color: card.subjectTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1B22),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.outline),
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
                            ListTile(
                              leading: const Icon(Icons.edit_outlined,
                                  color: AppColors.primary),
                              title: const Text('تعديل المهمة'),
                              onTap: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تعديل المهمة'),
                                      behavior: SnackBarBehavior.floating),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete_outline,
                                  color: AppColors.error),
                              title: const Text('حذف المهمة',
                                  style: TextStyle(color: AppColors.error)),
                              onTap: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('تم حذف المهمة'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.error),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.groups_outlined,
                    size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(card.className,
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.event_outlined, size: 16, color: card.dueDateColor),
                const SizedBox(width: 4),
                Text(card.dueDate,
                    style: TextStyle(color: card.dueDateColor, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('نسبة الإنجاز',
                    style: TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 12)),
                Text(
                  '${(card.completionRate * 100).toInt()}%',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: card.completionRate,
                backgroundColor: const Color(0xFFEEEDF7),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomNav() => Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'الرئيسية', false,
                onTap: () => context.push('/teacher')),
            _navItem(Icons.quiz, 'الاختبارات', true,
                onTap: () => context.push('/teacher/assessments')),
            _navItem(Icons.bar_chart_outlined, 'التقارير', false,
                onTap: () => context.push('/teacher/report-schedules')),
            _navItem(Icons.settings_outlined, 'الإعدادات', false,
                onTap: () => context.push('/teacher/settings')),
          ],
        ),
      );

  Widget _navItem(IconData icon, String label, bool active,
          {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? const Color(0xFF1E40AF) : Colors.grey,
                size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? const Color(0xFF1E40AF) : Colors.grey,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      );
}

class _AssignmentCard {
  const _AssignmentCard({
    required this.subject,
    required this.subjectColor,
    required this.subjectTextColor,
    required this.title,
    required this.className,
    required this.dueDate,
    required this.dueDateColor,
    required this.completionRate,
  });
  final String subject;
  final Color subjectColor;
  final Color subjectTextColor;
  final String title;
  final String className;
  final String dueDate;
  final Color dueDateColor;
  final double completionRate;
}
