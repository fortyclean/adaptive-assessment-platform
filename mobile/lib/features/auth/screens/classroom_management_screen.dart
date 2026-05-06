import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../repositories/admin_repository.dart';

/// Classroom Management Screen — Screen 18
/// Requirements: 2.1–2.6
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteClassroom(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
    );

    if (confirmed ?? false) {
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
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفصول'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showCreateDialog,
            tooltip: 'إضافة فصل',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classrooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.class_rounded,
                          size: 64, color: AppColors.outlineVariant),
                      const SizedBox(height: 12),
                      const Text('لا توجد فصول دراسية'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _showCreateDialog,
                          child: const Text('إضافة فصل')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadClassrooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _classrooms.length,
                    itemBuilder: (ctx, i) => _ClassroomCard(
                      classroom: _classrooms[i],
                      onDelete: () => _deleteClassroom(
                          _classrooms[i]['_id'] as String,
                          _classrooms[i]['name'] as String),
                    ),
                  ),
                ),
    );
}

class _ClassroomCard extends StatelessWidget {
  const _ClassroomCard(
      {required this.classroom, required this.onDelete});
  final Map<String, dynamic> classroom;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final studentCount =
        (classroom['studentIds'] as List?)?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(classroom['name'] as String? ?? '',
                    style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: 'حذف',
                ),
              ],
            ),
            Text(
              '${classroom['gradeLevel'] ?? ''} • ${classroom['academicYear'] ?? ''}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_rounded,
                    size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('$studentCount طالب',
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('إضافة فصل جديد'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'اسم الفصل *'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'مطلوب' : null,
              onSaved: (v) => _name = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'المرحلة الدراسية *'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'مطلوب' : null,
              onSaved: (v) => _gradeLevel = v!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'العام الدراسي *'),
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
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('إنشاء'),
        ),
      ],
    );
}
