import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../repositories/assessment_repository.dart';

/// Student Dashboard Screen — Screen 3 & 13
/// Requirements: 11.1–11.6
class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assessments = [];
  List<Map<String, dynamic>> _recentAttempts = [];
  Map<String, dynamic>? _pointsSummary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(assessmentRepositoryProvider);
      final results = await Future.wait([
        repo.getAssessments(),
        repo.getAttemptHistory(),
        repo.getPointsSummary(),
      ]);
      setState(() {
        _assessments = results[0] as List<Map<String, dynamic>>;
        _recentAttempts =
            (results[1] as List<Map<String, dynamic>>).take(5).toList();
        _pointsSummary = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'تعذر تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً، ${user?.fullName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.studentNotifications),
            tooltip: 'الإشعارات',
          ),
        ],
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
                      _buildUpcomingAssessments(),
                      const SizedBox(height: 20),
                      _buildRecentResults(),
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
          ElevatedButton(onPressed: _loadData, child: const Text('إعادة المحاولة')),
        ],
      ),
    );

  Widget _buildStatsRow() {
    final totalPoints = _pointsSummary?['totalPoints'] ?? 0;
    final totalAttempts = _pointsSummary?['totalAttempts'] ?? 0;
    final masteredSkills =
        (_pointsSummary?['masteredSkills'] as List?)?.length ?? 0;

    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: 'النقاط', value: '$totalPoints', icon: Icons.star_rounded, color: AppColors.pointsGold)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'الاختبارات', value: '$totalAttempts', icon: Icons.assignment_turned_in_rounded, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'المهارات', value: '$masteredSkills', icon: Icons.emoji_events_rounded, color: AppColors.success)),
      ],
    );
  }

  Widget _buildUpcomingAssessments() {
    final upcoming = _assessments
        .where((a) => a['status'] == 'active')
        .toList()
      ..sort((a, b) {
        final aDate = a['availableUntil'] != null
            ? DateTime.parse(a['availableUntil'] as String)
            : DateTime(2099);
        final bDate = b['availableUntil'] != null
            ? DateTime.parse(b['availableUntil'] as String)
            : DateTime(2099);
        return aDate.compareTo(bDate);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الاختبارات القادمة',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (upcoming.isEmpty)
          const _EmptyState(message: 'لا توجد اختبارات قادمة')
        else
          ...upcoming.map((a) => _AssessmentCard(
                assessment: a,
                onTap: () => context.push(
                    '/student/assessments/${a['_id']}/start'),
              )),
      ],
    );
  }

  Widget _buildRecentResults() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('آخر النتائج', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_recentAttempts.isEmpty)
          const _EmptyState(message: 'لم تُكمل أي اختبار بعد')
        else
          ..._recentAttempts.map((a) => _RecentAttemptTile(attempt: a)),
      ],
    );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700, color: color)),
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

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.assessment, required this.onTap});
  final Map<String, dynamic> assessment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dueDate = assessment['availableUntil'] != null
        ? DateFormat('dd/MM/yyyy', 'ar').format(
            DateTime.parse(assessment['availableUntil'] as String))
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.onPrimaryContainer,
          child: Icon(Icons.quiz_rounded, color: AppColors.primary),
        ),
        title: Text(assessment['title'] as String? ?? ''),
        subtitle: Text(
            '${assessment['subject'] ?? ''} • ${assessment['questionCount'] ?? ''} سؤال'
            '${dueDate != null ? ' • حتى $dueDate' : ''}'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _RecentAttemptTile extends StatelessWidget {
  const _RecentAttemptTile({required this.attempt});
  final Map<String, dynamic> attempt;

  @override
  Widget build(BuildContext context) {
    final score = attempt['scorePercentage'] as num?;
    final scoreColor = score != null && score >= 70
        ? AppColors.success
        : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: score != null && score >= 70
              ? AppColors.successContainer
              : AppColors.errorContainer,
          child: Text(
            score != null ? '${score.round()}%' : '-',
            style: TextStyle(
                color: scoreColor,
                fontSize: 12,
                fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
            (attempt['assessmentId'] as Map?)?['title'] as String? ?? 'اختبار'),
        subtitle: Text(
            (attempt['assessmentId'] as Map?)?['subject'] as String? ?? ''),
      ),
    );
  }
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
