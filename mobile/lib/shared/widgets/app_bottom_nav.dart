import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

/// Shared Bottom Navigation Bar matching the design system.
/// Used across Teacher, Student, and Admin dashboards.
///
/// Active item: blue pill background (#EFF6FF), primary color icon.
/// Inactive: gray icon, no background.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.role,
  });

  final int currentIndex;

  /// 'teacher', 'student', or 'admin'
  final String role;

  @override
  Widget build(BuildContext context) {
    final items = _itemsForRole(role);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTap(context, index, role),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      // Active: #EFF6FF pill background
                      color: isActive
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          // Active: primary container blue, Inactive: gray
                          color: isActive
                              ? AppColors.primaryContainer
                              : AppColors.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.primaryContainer
                                : AppColors.onSurfaceVariant,
                            fontFamily: 'Almarai',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index, String role) {
    if (role == 'student') {
      switch (index) {
        case 0:
          context.go('/student');
        case 1:
          context.go('/student/assessments-list');
        case 2:
          context.go('/student/progress');  // Fix: was /student/results
        case 3:
          context.go('/student/settings');  // Fix: was /student/notifications
      }
    } else if (role == 'teacher') {
      switch (index) {
        case 0:
          context.go('/teacher');
        case 1:
          context.go('/teacher/assessments');
        case 2:
          context.go('/teacher/questions');
        case 3:
          context.go('/teacher/report-schedules');
        case 4:
          context.go('/teacher/settings');
      }
    } else if (role == 'admin') {
      switch (index) {
        case 0:
          context.go('/admin');
        case 1:
          context.go('/admin/users');
        case 2:
          context.go('/admin/classrooms');
        case 3:
          context.go('/admin/reports');
        case 4:
          context.go('/admin/institution-settings');
      }
    }
  }

  List<_NavItem> _itemsForRole(String role) {
    if (role == 'student') {
      return const [
        _NavItem(
          label: 'الرئيسية',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        _NavItem(
          label: 'الاختبارات',
          icon: Icons.quiz_outlined,
          activeIcon: Icons.quiz_rounded,
        ),
        _NavItem(
          label: 'التقدم',
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart_rounded,
        ),
        _NavItem(
          label: 'الإعدادات',
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
        ),
      ];
    } else if (role == 'teacher') {
      return const [
        _NavItem(
          label: 'الرئيسية',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        _NavItem(
          label: 'الاختبارات',
          icon: Icons.quiz_outlined,
          activeIcon: Icons.quiz_rounded,
        ),
        _NavItem(
          label: 'بنك الأسئلة',
          icon: Icons.library_books_outlined,
          activeIcon: Icons.library_books_rounded,
        ),
        _NavItem(
          label: 'التقارير',
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart_rounded,
        ),
        _NavItem(
          label: 'الإعدادات',
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
        ),
      ];
    } else {
      // admin
      return const [
        _NavItem(
          label: 'الرئيسية',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        _NavItem(
          label: 'المستخدمون',
          icon: Icons.group_outlined,
          activeIcon: Icons.group_rounded,
        ),
        _NavItem(
          label: 'الفصول',
          icon: Icons.school_outlined,
          activeIcon: Icons.school_rounded,
        ),
        _NavItem(
          label: 'التقارير',
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart_rounded,
        ),
        _NavItem(
          label: 'الإعدادات',
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
        ),
      ];
    }
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
