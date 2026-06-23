import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations_ar.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../repositories/teacher_repository.dart';

/// Teacher dashboard.
///
/// Production mode must never hide API failures behind demo numbers. Demo data is
/// allowed only when mock mode is explicitly enabled or the current session is a
/// demo-token session.
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  List<Map<String, dynamic>> get _demoAssessments => [
        {
          '_id': 'demo-teacher-assessment-1',
          'title': _l10n(context).teacherDashboardDemoUnitOneTitle,
          'subject': _l10n(context).subjectMathematics,
          'status': 'active',
          'averageScore': 82,
          'studentCount': 28,
        },
        {
          '_id': 'demo-teacher-assessment-2',
          'title': _l10n(context).teacherDashboardDemoGrammarTitle,
          'subject': _l10n(context).subjectArabic,
          'status': 'completed',
          'averageScore': 75,
          'studentCount': 24,
        },
        {
          '_id': 'demo-teacher-assessment-3',
          'title': _l10n(context).teacherDashboardDemoPhysicsTitle,
          'subject': _l10n(context).subjectPhysics,
          'status': 'draft',
          'studentCount': 20,
        },
      ];
  bool _isLoading = true;
  List<Map<String, dynamic>> _assessments = [];
  String? _errorMessage;

  AppLocalizations _l10n(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsAr();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final assessments =
          await ref.read(teacherRepositoryProvider).getAssessments();
      if (!mounted) return;
      setState(() {
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = _l10n(context);
      setState(() {
        _assessments = _shouldUseDemoFallback ? _demoAssessments : [];
        _errorMessage =
            _shouldUseDemoFallback ? null : l10n.teacherDashboardLoadFailed;
        _isLoading = false;
      });
    }
  }

  bool get _shouldUseDemoFallback {
    final token = ref.read(authProvider).accessToken ?? '';
    return AppConstants.useMockData || token.startsWith('demo-token-');
  }

  int get _activeCount =>
      _assessments.where((a) => a['status'] == 'active').length;

  int get _completedCount =>
      _assessments.where((a) => a['status'] == 'completed').length;

  int get _studentCount {
    var total = 0;
    var hasRealCount = false;

    for (final assessment in _assessments) {
      final value = assessment['studentCount'] ??
          assessment['studentsCount'] ??
          assessment['assignedStudentCount'] ??
          assessment['participantsCount'];
      if (value is num) {
        total += value.toInt();
        hasRealCount = true;
      }
    }

    return hasRealCount ? total : 0;
  }

  String get _studentCountLabel => _studentCount > 0 ? '$_studentCount' : '--';

  double get _averageScore {
    final withScore =
        _assessments.where((a) => a['averageScore'] != null).toList();
    if (withScore.isEmpty) return 0;
    final sum = withScore.fold<double>(
      0,
      (acc, a) => acc + (a['averageScore'] as num).toDouble(),
    );
    return sum / withScore.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(user),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'teacher'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (_errorMessage != null) ...[
                    _buildErrorCard(),
                    const SizedBox(height: 20),
                  ],
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildCreateButton(),
                  const SizedBox(height: 20),
                  _buildRecentAssessments(),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthUser? user) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = _l10n(context);
    final textDirection = Directionality.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        height: 64 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            textDirection: textDirection,
            children: [
              UserAvatar(user: user, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.teacherWelcome(
                        user?.fullName ?? l10n.teacherFallbackName,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                        fontFamily: 'Almarai',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.dashboard,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded),
                color: colorScheme.primary,
                onPressed: () => context.push(AppRoutes.teacherAssessments),
                tooltip: l10n.search,
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: colorScheme.primary,
                onPressed: () => context.push(AppRoutes.teacherNotifications),
                tooltip: l10n.notifications,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = _l10n(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.wifi_off_rounded, color: colorScheme.error, size: 32),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final l10n = _l10n(context);
    return Row(
      textDirection: Directionality.of(context),
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.totalStudents,
            value: _studentCountLabel,
            icon: Icons.groups_rounded,
            iconColor: AppColors.primaryContainer,
            iconBg: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l10n.active,
            value: '$_activeCount',
            icon: Icons.play_circle_rounded,
            iconColor: AppColors.success,
            iconBg: AppColors.successContainer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l10n.completed,
            value: '$_completedCount',
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.primaryContainer,
            iconBg: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l10n.average,
            value: _averageScore > 0
                ? '${_averageScore.toStringAsFixed(0)}%'
                : '--',
            icon: Icons.analytics_rounded,
            iconColor: AppColors.primaryContainer,
            iconBg: const Color(0xFFEFF6FF),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    final l10n = _l10n(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.teacherCreateAssessment),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          l10n.createNewAssessment,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Almarai',
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssessments() {
    final l10n = _l10n(context);
    final textDirection = Directionality.of(context);
    final recent = _assessments.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: textDirection,
      children: [
        Row(
          textDirection: textDirection,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentAssessments,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                fontFamily: 'Almarai',
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.teacherAssessments),
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryContainer,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          _EmptyState(message: l10n.noAssessmentsCreatedYet)
        else
          ...recent.map(
            (a) => _AssessmentTile(
              assessment: a,
              onTap: () => context.push(AppRoutes.teacherAssessments),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          l10n.additionalTools,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Almarai',
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickLink(
          icon: Icons.task_alt_rounded,
          label: l10n.taskManagement,
          onTap: () => context.push(AppRoutes.taskManagement),
        ),
        _buildQuickLink(
          icon: Icons.workspace_premium_rounded,
          label: l10n.certificates,
          onTap: () => context.push(AppRoutes.certificates),
        ),
        _buildQuickLink(
          icon: Icons.calendar_month_rounded,
          label: l10n.classSchedule,
          onTap: () => context.push(AppRoutes.classSchedule),
        ),
        _buildQuickLink(
          icon: Icons.class_rounded,
          label: l10n.myClasses,
          onTap: () => context.push(AppRoutes.myClasses),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuickLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryContainer, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: iconColor,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({required this.assessment, required this.onTap});

  final Map<String, dynamic> assessment;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (assessment['status']) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primaryContainer;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color get _statusBg {
    switch (assessment['status']) {
      case 'active':
        return AppColors.successContainer;
      case 'completed':
        return const Color(0xFFEFF6FF);
      default:
        return AppColors.surfaceContainer;
    }
  }

  String _statusLabel(BuildContext context) {
    final l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations) ??
            AppLocalizationsAr();
    switch (assessment['status']) {
      case 'active':
        return l10n.active;
      case 'completed':
        return l10n.completed;
      default:
        return l10n.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: Directionality.of(context),
                  children: [
                    Text(
                      assessment['title'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontFamily: 'Almarai',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assessment['subject'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _statusLabel(context),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 48,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
