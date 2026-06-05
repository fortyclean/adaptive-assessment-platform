import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/admin_top_actions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../repositories/admin_repository.dart';

/// Screen 68 — Admin Dashboard v2
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
  bool _isLoadingSummary = true;
  Map<String, dynamic> _summary = const {
    'totalStudents': 245,
    'totalTeachers': 12,
    'totalClassrooms': 9,
    'totalAssessments': 38,
    'schoolAverage': 82,
  };

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final report = await ref.read(adminRepositoryProvider).getSchoolReport();
      final summary = report['summary'];
      if (summary is Map<String, dynamic>) {
        setState(() {
          _summary = summary;
          _isLoadingSummary = false;
        });
        return;
      }
    } on Object {
      final token = ref.read(authProvider).accessToken ?? '';
      if (!AppConstants.useMockData && !token.startsWith('demo-token-')) {
        setState(() => _isLoadingSummary = false);
        return;
      }
    }
    setState(() => _isLoadingSummary = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            // ─── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            onPressed: () =>
                                context.push(AppRoutes.notificationCenter),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        onPressed: () => context.push(AppRoutes.adminUsers),
                      ),
                      const AdminTopActions(),
                    ],
                  ),
                  // Logo + avatar (RTL: right)
                  Row(
                    children: [
                      const Text(
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
          onPressed: () => context.push(AppRoutes.adminUsers),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'admin'),
      );

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.adminDashboardTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.adminDashboardV2Subtitle,
          style: const TextStyle(
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
    final students = (_summary['totalStudents'] as num?)?.round() ?? 0;
    final teachers = (_summary['totalTeachers'] as num?)?.round() ?? 0;
    final classrooms = (_summary['totalClassrooms'] as num?)?.round() ?? 0;
    final assessments = (_summary['totalAssessments'] as num?)?.round() ?? 0;
    final average = (_summary['schoolAverage'] as num?)?.round() ?? 0;
    final averageProgress = average.clamp(0, 100) / 100;
    final l10n = AppLocalizations.of(context);

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
          label: l10n.adminDashboardTotalStudents,
          value: _isLoadingSummary ? '...' : '$students',
          badge: l10n.active,
          badgeColor: Colors.green,
          onTap: () => context.push(
            AppRoutes.adminUsers,
            extra: {'initialFilter': 'student'},
          ),
        ),
        _buildStatCard(
          icon: Icons.person_outline,
          iconBg: const Color(0xFFFFDBCE),
          iconColor: const Color(0xFF611E00),
          label: l10n.adminDashboardActiveTeachers,
          value: _isLoadingSummary ? '...' : '$teachers',
          onTap: () => context.push(
            AppRoutes.adminUsers,
            extra: {'initialFilter': 'teacher'},
          ),
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          iconBg: const Color(0xFFD3E4FE),
          iconColor: const Color(0xFF505F76),
          label: l10n.adminDashboardOverallAverage,
          value: _isLoadingSummary ? '...' : '$average%',
          showCircularProgress: true,
          progressValue: averageProgress.toDouble(),
          onTap: () => context.push(AppRoutes.adminReports),
        ),
        _buildStatCard(
          icon: Icons.timer,
          iconBg: const Color(0xFFFEE2E2),
          iconColor: AppColors.error,
          label: classrooms > 0
              ? l10n.classrooms
              : l10n.adminDashboardRunningAssessments,
          value: _isLoadingSummary
              ? '...'
              : (classrooms > 0 ? '$classrooms' : '$assessments'),
          onTap: () => context.push(AppRoutes.adminClassrooms),
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
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AppSectionCard(
          padding: const EdgeInsets.all(16),
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
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    )
                  else if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (badgeColor ?? Colors.green).withValues(alpha: 0.1),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
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

  // ─── Subject Performance Chart ───────────────────────────────────────────

  Widget _buildSubjectPerformanceChart() {
    final l10n = AppLocalizations.of(context);
    final subjects = [
      {'label': l10n.math, 'value': 0.65},
      {'label': l10n.science, 'value': 0.88},
      {'label': l10n.arabicSubject, 'value': 0.72},
      {'label': l10n.englishSubject, 'value': 0.55},
      {'label': l10n.historySubject, 'value': 0.80},
    ];

    final colorScheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      padding: const EdgeInsets.all(24),
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
                  l10n.currentTerm,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                l10n.adminDashboardSubjectPerformance,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
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
                                        .withValues(alpha: 0.2),
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
                          style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
    final teachers = [
      {
        'name': l10n.adminDashboardTopTeacherOneName,
        'role': l10n.adminDashboardTopTeacherOneRole,
        'rating': '4.9',
        'initials': l10n.adminDashboardTopTeacherOneInitials,
      },
      {
        'name': l10n.adminDashboardTopTeacherTwoName,
        'role': l10n.adminDashboardTopTeacherTwoRole,
        'rating': '4.8',
        'initials': l10n.adminDashboardTopTeacherTwoInitials,
      },
    ];

    final colorScheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.push(AppRoutes.adminUsers),
                child: Text(l10n.viewAll,
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 13)),
              ),
              Text(
                l10n.adminDashboardTopTeachersThisMonth,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...teachers.map(_buildTeacherRow),
        ],
      ),
    );
  }

  Widget _buildTeacherRow(Map<String, dynamic> teacher) => Container(
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
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    teacher['role'] as String,
                    style: const TextStyle(
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainer,
              ),
              child: Center(
                child: Text(
                  teacher['initials'] as String,
                  style: const TextStyle(
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

  // ─── Admin Alerts ────────────────────────────────────────────────────────

  Widget _buildAdminAlerts() {
    final l10n = AppLocalizations.of(context);
    final alerts = [
      {
        'type': 'error',
        'route': AppRoutes.adminClassrooms,
        'title': l10n.adminDashboardReviewRequiredTitle,
        'body': l10n.adminDashboardReviewRequiredBody,
      },
      {
        'type': 'info',
        'route': AppRoutes.adminReports,
        'title': l10n.adminDashboardReportsReadyTitle,
        'body': l10n.adminDashboardReportsReadyBody,
      },
      {
        'type': 'secondary',
        'route': AppRoutes.adminClassrooms,
        'title': l10n.adminDashboardScheduleUpdateTitle,
        'body': l10n.adminDashboardScheduleUpdateBody,
      },
    ];

    final colorScheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.adminDashboardManagementAlerts,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.campaign, color: AppColors.error),
            ],
          ),
          const SizedBox(height: 16),
          ...alerts.map(_buildAlertItem),
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
        bgColor = AppColors.errorContainer.withValues(alpha: 0.2);
        borderColor = AppColors.error;
        titleColor = AppColors.error;
        break;
      case 'info':
        bgColor = const Color(0xFFEFF6FF);
        borderColor = AppColors.primary;
        titleColor = AppColors.primary;
        break;
      default:
        bgColor = const Color(0xFFD0E1FB).withValues(alpha: 0.2);
        borderColor = const Color(0xFF505F76);
        titleColor = const Color(0xFF54647A);
    }

    final route = alert['route'] as String;

    void onTap() => context.push(route);

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
              style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
    final items = [
      {
        'icon': Icons.settings,
        'label': l10n.settings,
        'route': AppRoutes.institutionSettings,
      },
      {
        'icon': Icons.calendar_month,
        'label': l10n.adminDashboardSchedules,
        'route': AppRoutes.adminClassrooms,
      },
      {
        'icon': Icons.person_add,
        'label': l10n.adminDashboardAddStudent,
        'route': AppRoutes.adminUsers,
      },
      {
        'icon': Icons.cloud_download,
        'label': l10n.reports,
        'route': AppRoutes.adminReports,
      },
    ];

    final colorScheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.quickAccess,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
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
              final route = item['route'] as String;
              return InkWell(
                onTap: () => context.push(route),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
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
