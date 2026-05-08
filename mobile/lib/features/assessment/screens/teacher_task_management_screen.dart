import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Screen 67 — Teacher Task Management (إدارة المهام)
/// Shows assignment cards with completion progress bars and filter chips.
class TeacherTaskManagementScreen extends ConsumerStatefulWidget {
  const TeacherTaskManagementScreen({super.key});

  @override
  ConsumerState<TeacherTaskManagementScreen> createState() =>
      _TeacherTaskManagementScreenState();
}

class _TeacherTaskManagementScreenState
    extends ConsumerState<TeacherTaskManagementScreen> {
  int _activeTab = 0; // 0=المهام النشطة, 1=المسودات, 2=المكتملة
  int _selectedFilter = 0; // 0=الكل, 1=رياضيات, 2=فيزياء

  final List<String> _tabs = ['المهام النشطة', 'المسودات', 'المكتملة'];
  final List<String> _filters = [
    'الكل',
    'رياضيات - الصف العاشر',
    'فيزياء - الصف الحادي عشر',
  ];

  final List<Map<String, dynamic>> _activeTasks = [
    {
      'subject': 'رياضيات',
      'subjectColor': Color(0xFFD0E1FB),
      'subjectTextColor': Color(0xFF54647A),
      'title': 'الجبر المتطور: المعادلات التربيعية',
      'class': 'الصف العاشر - أ',
      'deadline': 'تسليم: 15 أكتوبر',
      'deadlineUrgent': false,
      'progress': 0.85,
    },
    {
      'subject': 'فيزياء',
      'subjectColor': Color(0xFFFFDBCE),
      'subjectTextColor': Color(0xFF802A00),
      'title': 'مقدمة في قوانين نيوتن',
      'class': 'الصف الحادي عشر - ج',
      'deadline': 'تسليم: غداً',
      'deadlineUrgent': true,
      'progress': 0.42,
    },
    {
      'subject': 'رياضيات',
      'subjectColor': Color(0xFFD0E1FB),
      'subjectTextColor': Color(0xFF54647A),
      'title': 'الاحتمالات والإحصاء الوصفي',
      'class': 'الصف العاشر - ب',
      'deadline': 'تسليم: 20 أكتوبر',
      'deadlineUrgent': false,
      'progress': 0.12,
    },
  ];

  List<Map<String, dynamic>> get _filteredTasks {
    if (_selectedFilter == 0) return _activeTasks;
    if (_selectedFilter == 1) {
      return _activeTasks
          .where((t) => t['subject'] == 'رياضيات')
          .toList();
    }
    return _activeTasks
        .where((t) => t['subject'] == 'فيزياء')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: CustomScrollView(
          slivers: [
            // ─── App Bar ────────────────────────────────────────────────
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
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainer,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'EduAssess',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ─── Content ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // Filter chips
                  _buildFilterChips(),
                  const SizedBox(height: 16),

                  // Tabs
                  _buildTabs(),
                  const SizedBox(height: 16),

                  // Task cards
                  ..._filteredTasks.map(_buildTaskCard),
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'teacher'),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'إدارة المهام',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'تابع واجبات طلابك ونسب الإنجاز بكل سهولة.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ─── Filter Chips ────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    if (index == 0) ...[
                      Icon(
                        Icons.filter_list,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _filters[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
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
  }

  // ─── Tabs ────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isActive = _activeTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Task Card ───────────────────────────────────────────────────────────

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final progress = task['progress'] as double;
    final progressPercent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // More options
              Icon(Icons.more_vert, color: AppColors.outline, size: 20),
              // Subject + title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: task['subjectColor'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task['subject'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: task['subjectTextColor'] as Color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1B22),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Meta info
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                task['deadline'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: task['deadlineUrgent'] == true
                      ? AppColors.error
                      : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.event,
                size: 16,
                color: task['deadlineUrgent'] == true
                    ? AppColors.error
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                task['class'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.groups, size: 16, color: AppColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'نسبة الإنجاز',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
