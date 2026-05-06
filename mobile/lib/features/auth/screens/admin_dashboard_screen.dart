import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../repositories/admin_repository.dart';

/// Admin Dashboard Screen — Screen 23
/// Requirements: 13.1
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _schoolReport;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final report = await ref.read(adminRepositoryProvider).getSchoolReport();
      setState(() {
        _schoolReport = report;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final summary = _schoolReport?['summary'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً، ${user?.fullName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.teacherSettings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Bento Grid stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _BentoCard(
                        label: 'المعلمون',
                        value: '${summary['totalTeachers'] ?? 0}',
                        icon: Icons.person_rounded,
                        color: AppColors.primary,
                        onTap: () => context.push(AppRoutes.adminUsers),
                      ),
                      _BentoCard(
                        label: 'الطلاب',
                        value: '${summary['totalStudents'] ?? 0}',
                        icon: Icons.school_rounded,
                        color: AppColors.success,
                        onTap: () => context.push(AppRoutes.adminUsers),
                      ),
                      _BentoCard(
                        label: 'الفصول',
                        value: '0',
                        icon: Icons.class_rounded,
                        color: AppColors.warning,
                        onTap: () => context.push(AppRoutes.adminClassrooms),
                      ),
                      _BentoCard(
                        label: 'الاختبارات',
                        value: '${summary['totalAssessments'] ?? 0}',
                        icon: Icons.quiz_rounded,
                        color: AppColors.primaryContainer,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // School average
                  if (summary['schoolAverage'] != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up_rounded,
                                color: AppColors.primary, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('متوسط أداء المدرسة',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge),
                                Text(
                                  '${(summary['schoolAverage'] as num).round()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quick links
                  Text('روابط سريعة',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _QuickLink(
                    icon: Icons.people_rounded,
                    title: 'إدارة المستخدمين',
                    onTap: () => context.push(AppRoutes.adminUsers),
                  ),
                  _QuickLink(
                    icon: Icons.class_rounded,
                    title: 'إدارة الفصول',
                    onTap: () => context.push(AppRoutes.adminClassrooms),
                  ),
                  _QuickLink(
                    icon: Icons.bar_chart_rounded,
                    title: 'تقارير المدرسة',
                    onTap: () => context.push(AppRoutes.adminReports),
                  ),
                ],
              ),
            ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          )),
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
}
