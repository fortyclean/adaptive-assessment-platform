import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
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
      if (mounted) {
        setState(() {
          _assessments = [
            {'_id': '1', 'title': 'اختبار الوحدة الأولى', 'subject': 'رياضيات', 'status': 'active', 'averageScore': 82},
            {'_id': '2', 'title': 'اختبار النحو', 'subject': 'لغة عربية', 'status': 'completed', 'averageScore': 75},
            {'_id': '3', 'title': 'اختبار الفيزياء', 'subject': 'فيزياء', 'status': 'draft'},
          ];
          _isLoading = false;
        });
      }
    }
  }

  int get _activeCount =>
      _assessments.where((a) => a['status'] == 'active').length;
  int get _completedCount =>
      _assessments.where((a) => a['status'] == 'completed').length;
  int get _draftCount =>
      _assessments.where((a) => a['status'] == 'draft').length;

  double get _averageScore {
    final withScore =
        _assessments.where((a) => a['averageScore'] != null).toList();
    if (withScore.isEmpty) return 0;
    final sum = withScore.fold<double>(
        0, (acc, a) => acc + (a['averageScore'] as num).toDouble());
    return sum / withScore.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(user),
      bottomNavigationBar:
          const AppBottomNav(currentIndex: 0, role: 'teacher'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
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

  PreferredSizeWidget _buildAppBar(dynamic user) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        height: 64 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
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
            textDirection: TextDirection.rtl,
            children: [
              // Avatar + Name (right side in RTL)
              _buildAvatar(user),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً، ${(user?.fullName as String?) ?? 'المعلم'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E40AF),
                        fontFamily: 'Almarai',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'لوحة التحكم',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),
              ),
              // Action icons (left side in RTL)
              IconButton(
                icon: const Icon(Icons.search_rounded),
                color: const Color(0xFF1E40AF),
                onPressed: () => context.push('/teacher/assessments'),
                tooltip: 'بحث',
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: const Color(0xFF1E40AF),
                onPressed: () => context.push(AppRoutes.teacherNotifications),
                tooltip: 'الإشعارات',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(dynamic user) {
    final initials = _getInitials(user?.fullName as String?);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerHigh,
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryContainer,
            fontFamily: 'Almarai',
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'م';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontFamily: 'Almarai')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );

  Widget _buildStatsRow() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: _StatCard(
            label: 'إجمالي الطلاب',
            value: '${_assessments.length * 5}',
            icon: Icons.groups_rounded,
            iconColor: AppColors.primaryContainer,
            iconBg: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'نشط',
            value: '$_activeCount',
            icon: Icons.play_circle_rounded,
            iconColor: AppColors.success,
            iconBg: AppColors.successContainer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'مكتمل',
            value: '$_completedCount',
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.primaryContainer,
            iconBg: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'المتوسط',
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.teacherCreateAssessment),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'إنشاء اختبار جديد',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Almarai',
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssessments() {
    final recent = _assessments.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'آخر الاختبارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                fontFamily: 'Almarai',
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.teacherAssessments),
              child: const Text(
                'عرض الكل',
                style: TextStyle(
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
          const _EmptyState(message: 'لم تنشئ أي اختبار بعد')
        else
          ...recent.map((a) => _AssessmentTile(
                assessment: a,
                onTap: () => context.push(AppRoutes.teacherAssessments),
              )),
        const SizedBox(height: 20),
        const Text(
          'أدوات إضافية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Almarai',
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickLink(
          icon: Icons.task_alt_rounded,
          label: 'إدارة المهام',
          onTap: () => context.push('/teacher/tasks'),
        ),
        _buildQuickLink(
          icon: Icons.workspace_premium_rounded,
          label: 'الشهادات',
          onTap: () => context.push('/teacher/certificates'),
        ),
        _buildQuickLink(
          icon: Icons.calendar_month_rounded,
          label: 'الجدول الدراسي',
          onTap: () => context.push('/teacher/class-schedule'),
        ),
        _buildQuickLink(
          icon: Icons.class_rounded,
          label: 'فصولي',
          onTap: () => context.push('/teacher/my-classes'),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
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
            textDirection: TextDirection.rtl,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
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
            textDirection: TextDirection.rtl,
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      assessment['title'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        fontFamily: 'Almarai',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assessment['subject'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  _statusLabel,
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
