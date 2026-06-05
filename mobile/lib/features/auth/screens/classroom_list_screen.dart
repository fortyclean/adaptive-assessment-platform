import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Classroom List Screen - Screen 61.
class ClassroomListScreen extends ConsumerStatefulWidget {
  const ClassroomListScreen({super.key});

  @override
  ConsumerState<ClassroomListScreen> createState() =>
      _ClassroomListScreenState();
}

class _ClassroomListScreenState extends ConsumerState<ClassroomListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ClassroomData> _classrooms(AppLocalizations l10n) => [
        _ClassroomData(
          name: l10n.demoClassroomGradeTenA,
          subject: l10n.demoSubjectMathAdvanced,
          studentCount: 28,
          averagePerformance: 84,
          iconBg: const Color(0xFFDDE1FF),
          iconColor: const Color(0xFF001453),
          icon: Icons.school_outlined,
        ),
        _ClassroomData(
          name: l10n.demoClassroomGradeTwelveC,
          subject: l10n.demoSubjectPhysicsScienceTrack,
          studentCount: 22,
          averagePerformance: 79,
          iconBg: const Color(0xFFFFDBCE),
          iconColor: const Color(0xFF380D00),
          icon: Icons.science_outlined,
        ),
        _ClassroomData(
          name: l10n.demoClassroomIntermediateB,
          subject: l10n.demoSubjectEnglishLanguage,
          studentCount: 31,
          averagePerformance: 91,
          iconBg: const Color(0xFFD3E4FE),
          iconColor: const Color(0xFF0B1C30),
          icon: Icons.language_outlined,
        ),
      ];

  List<_ClassroomData> _filtered(AppLocalizations l10n) {
    final classrooms = _classrooms(l10n);
    if (_searchQuery.isEmpty) return classrooms;
    return classrooms
        .where((c) =>
            c.name.contains(_searchQuery) || c.subject.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildAppBar(context, l10n),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildSearchAndAdd(context, l10n),
                const SizedBox(height: 24),
                ..._filtered(l10n).map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ClassroomCard(
                      classroom: c,
                      onViewStudents: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.viewStudentsForClass(c.name)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onViewReports: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.reportsForClass(c.name)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onViewAssessments: () {
                        context.push(AppRoutes.teacherAssessments);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildPerformanceOverview(l10n),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, role: 'teacher'),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) => Container(
        height: 64 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.changesSavedSuccessfully),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
              child: Text(
                l10n.save,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  l10n.classroomManagementTitle,
                  style: const TextStyle(
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

  Widget _buildSearchAndAdd(
    BuildContext context,
    AppLocalizations l10n,
  ) =>
      Row(
        children: [
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
                decoration: InputDecoration(
                  hintText: l10n.classroomSearchHint,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757684),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF757684),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.adminClassrooms),
            icon: const Icon(Icons.add, size: 20),
            label: Text(l10n.addClass),
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

  Widget _buildPerformanceOverview(AppLocalizations l10n) => Row(
        children: [
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
                  Text(
                    l10n.urgentAlerts,
                    style: const TextStyle(
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
                    title: l10n.missingAssessmentSubmissionsAlert,
                    subtitle: l10n.mathGradeTenASubtitle,
                  ),
                  const SizedBox(height: 12),
                  _buildAlert(
                    icon: Icons.notification_important_outlined,
                    iconColor: AppColors.primary,
                    title: l10n.newJoinRequestAlert,
                    subtitle: l10n.englishClassSubtitle,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.viewAllAlerts),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.viewAllAlerts),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                  Text(
                    l10n.academicPerformanceOverview,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.academicPerformanceOverviewSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 8,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '82%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              l10n.completionRate,
                              style: const TextStyle(
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
                        SnackBar(
                          content: Text(l10n.loadingFullReport),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.downloadFullReport),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildAlert({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) =>
      Row(
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

class _ClassroomCard extends StatelessWidget {
  const _ClassroomCard({
    required this.classroom,
    this.onViewStudents,
    this.onViewReports,
    this.onViewAssessments,
  });

  final _ClassroomData classroom;
  final VoidCallback? onViewStudents;
  final VoidCallback? onViewReports;
  final VoidCallback? onViewAssessments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
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
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${classroom.averagePerformance}%',
                  label: l10n.averagePerformance,
                  valueColor: const Color(0xFF611E00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '${classroom.studentCount}',
                  label: l10n.students,
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onViewStudents ?? () {},
              icon: const Icon(Icons.groups_outlined, size: 18),
              label: Text(l10n.viewStudents),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewReports ?? () {},
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: Text(l10n.reports),
                  style: _secondaryButtonStyle(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewAssessments ?? () {},
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: Text(l10n.assessments),
                  style: _secondaryButtonStyle(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle() => OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        side: const BorderSide(color: AppColors.outlineVariant),
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 12),
      );
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
  Widget build(BuildContext context) => Container(
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
