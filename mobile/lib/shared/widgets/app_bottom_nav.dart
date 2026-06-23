import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Shared bottom navigation bar for Teacher, Student, and Admin dashboards.
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
    final l10n = AppLocalizations.of(context);
    final items = _itemsForRole(role, l10n);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
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
          height: 72,
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == currentIndex;

              return Expanded(
                child: Semantics(
                  label: item.label,
                  button: true,
                  selected: isActive,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primaryContainer.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () => _onTap(context, index, role),
                      behavior: HitTestBehavior.opaque,
                      excludeFromSemantics: true,
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.72),
                              size: 23,
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isActive
                                        ? colorScheme.primary
                                        : colorScheme.onSurface
                                            .withValues(alpha: 0.72),
                                    fontFamily: 'Almarai',
                                    fontSize: 10,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  List<_NavItem> _itemsForRole(String role, AppLocalizations l10n) {
    if (role == 'student') {
      return [
        _NavItem(
          label: l10n.navHome,
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        _NavItem(
          label: l10n.navAssessments,
          icon: Icons.quiz_outlined,
          activeIcon: Icons.quiz_rounded,
        ),
        _NavItem(
          label: l10n.navProgress,
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart_rounded,
        ),
        _NavItem(
          label: l10n.navSettings,
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
        ),
      ];
    } else if (role == 'teacher') {
      return [
        _NavItem(
          label: l10n.navHome,
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
        ),
        _NavItem(
          label: l10n.navAssessments,
          icon: Icons.quiz_outlined,
          activeIcon: Icons.quiz_rounded,
        ),
        _NavItem(
          label: l10n.navQuestionBank,
          icon: Icons.library_books_outlined,
          activeIcon: Icons.library_books_rounded,
        ),
        _NavItem(
          label: l10n.navReports,
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart_rounded,
        ),
        _NavItem(
          label: l10n.navSettings,
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
        ),
      ];
    }

    return [
      _NavItem(
        label: l10n.navHome,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      _NavItem(
        label: l10n.navUsers,
        icon: Icons.group_outlined,
        activeIcon: Icons.group_rounded,
      ),
      _NavItem(
        label: l10n.navClassrooms,
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded,
      ),
      _NavItem(
        label: l10n.navReports,
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
      ),
      _NavItem(
        label: l10n.navSettings,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
      ),
    ];
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
