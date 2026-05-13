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
    required this.currentIndex,
    required this.role,
    super.key,
  });

  final int currentIndex;

  /// 'teacher', 'student', or 'admin'
  final String role;

  @override
  Widget build(BuildContext context) {
    final items = _itemsForRole(role);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: const [
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                              : colorScheme.onSurface.withValues(alpha: 0.72),
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.primaryContainer
                                : colorScheme.onSurface.withValues(alpha: 0.72),
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
          return;
        case 1:
          context.go('/student/assessments-list');
          return;
        case 2:
          context.go('/student/progress');
          return;
        case 3:
          context.go('/student/settings');
          return;
      }
    } else if (role == 'teacher') {
      switch (index) {
        case 0:
          context.go('/teacher');
          return;
        case 1:
          context.go('/teacher/assessments');
          return;
        case 2:
          context.go('/teacher/questions');
          return;
        case 3:
          context.go('/teacher/report-schedules');
          return;
        case 4:
          context.go('/teacher/settings');
          return;
      }
    } else if (role == 'admin') {
      switch (index) {
        case 0:
          context.go('/admin');
          return;
        case 1:
          context.go('/admin/users');
          return;
        case 2:
          context.go('/admin/classrooms');
          return;
        case 3:
          context.go('/admin/reports');
          return;
        case 4:
          context.go('/admin/institution-settings');
          return;
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
