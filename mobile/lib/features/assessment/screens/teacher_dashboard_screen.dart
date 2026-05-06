import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../repositories/teacher_repository.dart';
/// Teacher Dashboard Screen — Screen 1 & 12
/// Requirements: 10.1–10.6
class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assessments = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final assessments =
          await ref.read(teacherRepositoryProvider).getAssessments();
      setState(() {
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  int get _activeCount =>
      _assessments.where((a) => a['status'] == 'active').length;
  int get _completedCount =>
      _assessments.where((a) => a['status'] == 'completed').length;
  int get _draftCount =>
      _assessments.where((a) => a['status'] == 'draft').length;

  /// Count of assessments that have pending essay reviews.
  int get _pendingEssayCount =>
      _assessments.where((a) => a['hasPendingEssays'] == true).length;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً، ${user?.fullName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.teacherNotifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.teacherSettings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.teacherCreateAssessment),
        icon: const Icon(Icons.add),
        label: const Text('اختبار جديد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildStatsRow(),
                      const SizedBox(height: 20),
                      _buildRecentAssessments(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loadData, child: const Text('إعادة المحاولة')),
          ],
        ),
      );

  Widget _buildStatsRow() => Row(
      children: [
        Expanded(
            child: _StatCard(
                label: 'نشط',
                value: '$_activeCount',
                color: AppColors.success,
                icon: Icons.play_circle_outline_rounded)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'مكتمل',
                value: '$_completedCount',
                color: AppColors.primary,
                icon: Icons.check_circle_outline_rounded)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'مسودة',
                value: '$_draftCount',
                color: AppColors.onSurfaceVariant,
                icon: Icons.edit_outlined)),
      ],
    );

  Widget _buildRecentAssessments() {
    final recent = _assessments.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending essays alert banner (Req 18.5)
        if (_pendingEssayCount > 0) ...[
          _PendingEssaysBanner(
            count: _pendingEssayCount,
            onTap: () => context.push(AppRoutes.teacherPendingEssays),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('آخر الاختبارات',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () => context.push(AppRoutes.teacherAssessments),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const _EmptyState(message: 'لم تنشئ أي اختبار بعد')
        else
          ...recent.map((a) => _AssessmentTile(
                assessment: a,
                onTap: () {},
              )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile(
      {required this.assessment, required this.onTap});
  final Map<String, dynamic> assessment;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (assessment['status']) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String get _statusLabel {
    switch (assessment['status']) {
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      default:
        return 'مسودة';
    }
  }

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(assessment['title'] as String? ?? ''),
        subtitle: Text(assessment['subject'] as String? ?? ''),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _statusColor),
          ),
          child: Text(_statusLabel,
              style: TextStyle(
                  color: _statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        onTap: onTap,
      ),
    );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
        ),
      );
}

/// Alert banner shown on the teacher dashboard when there are pending essay
/// sessions awaiting manual grading (Requirement 18.5).
class _PendingEssaysBanner extends StatelessWidget {
  const _PendingEssaysBanner({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warningContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.warning.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_actions_rounded,
                color: AppColors.warning, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أسئلة مقالية بانتظار التصحيح',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'جلسة تحتاج' : 'جلسات تحتاج'} مراجعة يدوية',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warning,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.warning, size: 16),
          ],
        ),
      ),
    );
}
