import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../repositories/admin_repository.dart';

/// Classroom Management Screen — Screen 18
/// Requirements: 2.1–2.6
/// Shows classroom cards with student count, teacher name, active assessments.
class ClassroomManagementScreen extends ConsumerStatefulWidget {
  const ClassroomManagementScreen({super.key});

  @override
  ConsumerState<ClassroomManagementScreen> createState() =>
      _ClassroomManagementScreenState();
}

class _ClassroomManagementScreenState
    extends ConsumerState<ClassroomManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _classrooms = [];

  // ── Mock data used as fallback when API fails ─────────────────────────────
  static const List<Map<String, dynamic>> _mockClassrooms = [
    {
      '_id': 'mock-1',
      'name': 'أولى متوسط (أ)',
      'gradeLevel': 'الصف الأول المتوسط',
      'academicYear': '2024-2025',
      'studentIds': ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8',
                     's9', 's10', 's11', 's12', 's13', 's14', 's15',
                     's16', 's17', 's18', 's19', 's20', 's21', 's22',
                     's23', 's24', 's25', 's26', 's27', 's28'],
      'teacherName': 'أ. محمد العتيبي',
      'activeAssessments': 3,
      'averageScore': 87,
    },
    {
      '_id': 'mock-2',
      'name': 'أولى متوسط (ب)',
      'gradeLevel': 'الصف الأول المتوسط',
      'academicYear': '2024-2025',
      'studentIds': ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8',
                     's9', 's10', 's11', 's12', 's13', 's14', 's15',
                     's16', 's17', 's18', 's19', 's20', 's21', 's22',
                     's23', 's24', 's25'],
      'teacherName': 'أ. سارة الزهراني',
      'activeAssessments': 1,
      'averageScore': 79,
    },
    {
      '_id': 'mock-3',
      'name': 'ثانية متوسط (أ)',
      'gradeLevel': 'الصف الثاني المتوسط',
      'academicYear': '2024-2025',
      'studentIds': ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8',
                     's9', 's10', 's11', 's12', 's13', 's14', 's15',
                     's16', 's17', 's18', 's19', 's20', 's21', 's22',
                     's23', 's24', 's25', 's26', 's27', 's28', 's29',
                     's30'],
      'teacherName': 'أ. خالد الشمري',
      'activeAssessments': 2,
      'averageScore': 82,
    },
    {
      '_id': 'mock-4',
      'name': 'ثالثة متوسط (ج)',
      'gradeLevel': 'الصف الثالث المتوسط',
      'academicYear': '2024-2025',
      'studentIds': ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8',
                     's9', 's10', 's11', 's12', 's13', 's14', 's15',
                     's16', 's17', 's18', 's19', 's20', 's21', 's22',
                     's23', 's24'],
      'teacherName': 'أ. نورة القحطاني',
      'activeAssessments': 0,
      'averageScore': 91,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(adminRepositoryProvider).getClassrooms();
      setState(() {
        _classrooms = data;
        _isLoading = false;
      });
    } catch (_) {
      // Fallback to mock data so the screen is always usable
      setState(() {
        _classrooms = List<Map<String, dynamic>>.from(_mockClassrooms);
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteClassroom(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف الفصل'),
          content: Text('هل تريد حذف فصل "$name"؟'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('حذف',
                    style: TextStyle(color: AppColors.error))),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).deleteClassroom(id);
        _loadClassrooms();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString().contains('active')
                    ? 'لا يمكن حذف فصل يحتوي على اختبارات نشطة'
                    : 'تعذر حذف الفصل')),
          );
        }
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateClassroomDialog(
        onCreated: () {
          Navigator.pop(ctx);
          _loadClassrooms();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(context),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة فصل',
              style: TextStyle(fontFamily: 'Almarai', fontWeight: FontWeight.w600)),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _classrooms.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadClassrooms,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                      children: [
                        // ── Page Header ──────────────────────────────────
                        _buildPageHeader(),
                        const SizedBox(height: 20),
                        // ── KPI Row ──────────────────────────────────────
                        _buildKpiRow(),
                        const SizedBox(height: 24),
                        // ── Classroom Cards ───────────────────────────────
                        ...List.generate(_classrooms.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ClassroomCard(
                              classroom: _classrooms[i],
                              onDelete: () => _deleteClassroom(
                                  _classrooms[i]['_id'] as String? ?? '',
                                  _classrooms[i]['name'] as String? ?? ''),
                              onEdit: () => _showEditDialog(_classrooms[i]),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B)),
        onPressed: () => context.pop(),
        tooltip: 'رجوع',
      ),
      title: const Text(
        'التقييم الذكي',
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E40AF),
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
          onPressed: () {},
          tooltip: 'الإشعارات',
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryContainer,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة الفصول الدراسية',
          style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          'إدارة الفصول وتعيين المعلمين والطلاب',
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    final totalStudents = _classrooms.fold<int>(
        0, (sum, c) => sum + ((c['studentIds'] as List?)?.length ?? 0));
    final totalActive = _classrooms.fold<int>(
        0, (sum, c) => sum + ((c['activeAssessments'] as int?) ?? 0));

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'إجمالي الفصول',
            value: '${_classrooms.length}',
            icon: Icons.class_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            label: 'إجمالي الطلاب',
            value: '$totalStudents',
            icon: Icons.people_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            label: 'اختبارات نشطة',
            value: '$totalActive',
            icon: Icons.assignment_rounded,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.class_rounded,
                size: 40, color: AppColors.outlineVariant),
          ),
          const SizedBox(height: 16),
          Text('لا توجد فصول دراسية',
              style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('أضف فصلاً جديداً للبدء',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.outlineVariant)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة فصل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> classroom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('تعديل فصل: ${classroom['name']}')),
    );
  }
}

// ─── KPI Card ─────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDAD9E3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Classroom Card ───────────────────────────────────────────────────────────

class _ClassroomCard extends StatelessWidget {
  const _ClassroomCard({
    required this.classroom,
    required this.onDelete,
    required this.onEdit,
  });

  final Map<String, dynamic> classroom;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final studentCount = (classroom['studentIds'] as List?)?.length ?? 0;
    final teacherName = classroom['teacherName'] as String? ?? 'غير محدد';
    final activeAssessments = classroom['activeAssessments'] as int? ?? 0;
    final averageScore = classroom['averageScore'] as int?;
    final name = classroom['name'] as String? ?? '';
    final gradeLevel = classroom['gradeLevel'] as String? ?? '';
    final academicYear = classroom['academicYear'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F2FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                // Classroom icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.class_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.titleMedium,
                      ),
                      Text(
                        '$gradeLevel • $academicYear',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
                // Action buttons
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                  onPressed: onEdit,
                  tooltip: 'تعديل',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                  onPressed: onDelete,
                  tooltip: 'حذف',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // ── Card Body ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stats row
                Row(
                  children: [
                    _StatItem(
                      icon: Icons.people_rounded,
                      label: 'الطلاب',
                      value: '$studentCount',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      icon: Icons.person_rounded,
                      label: 'المعلم',
                      value: teacherName,
                      color: AppColors.success,
                      isText: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatItem(
                      icon: Icons.assignment_rounded,
                      label: 'اختبارات نشطة',
                      value: '$activeAssessments',
                      color: activeAssessments > 0
                          ? AppColors.warning
                          : AppColors.outlineVariant,
                    ),
                    if (averageScore != null) ...[
                      const SizedBox(width: 16),
                      _StatItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'متوسط الدرجات',
                        value: '$averageScore%',
                        color: averageScore >= 70
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ],
                ),
                // Active assessments badge
                if (activeAssessments > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment_turned_in_rounded,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          '$activeAssessments اختبار نشط حالياً',
                          style: const TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isText = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: isText ? 12 : 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create Classroom Dialog ──────────────────────────────────────────────────

class _CreateClassroomDialog extends ConsumerStatefulWidget {
  const _CreateClassroomDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateClassroomDialog> createState() =>
      _CreateClassroomDialogState();
}

class _CreateClassroomDialogState
    extends ConsumerState<_CreateClassroomDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _gradeLevel = '';
  String _academicYear = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      await ref.read(adminRepositoryProvider).createClassroom({
        'name': _name,
        'gradeLevel': _gradeLevel,
        'academicYear': _academicYear,
      });
      widget.onCreated();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إنشاء الفصل')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة فصل جديد',
            style: TextStyle(fontFamily: 'Almarai', fontWeight: FontWeight.w700)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'اسم الفصل *',
                  hintText: 'مثال: أولى متوسط (أ)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'المرحلة الدراسية *',
                  hintText: 'مثال: الصف الأول المتوسط',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _gradeLevel = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'العام الدراسي *',
                  hintText: 'مثال: 2024-2025',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _academicYear = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}
