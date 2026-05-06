import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../repositories/teacher_repository.dart';

/// Manage Assessments Screen — Screen 10
/// Requirements: 5.6
class ManageAssessmentsScreen extends ConsumerStatefulWidget {
  const ManageAssessmentsScreen({super.key});

  @override
  ConsumerState<ManageAssessmentsScreen> createState() =>
      _ManageAssessmentsScreenState();
}

class _ManageAssessmentsScreenState
    extends ConsumerState<ManageAssessmentsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assessments = [];
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref.read(teacherRepositoryProvider).getAssessments();
      setState(() {
        _assessments = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_statusFilter == 'all') return _assessments;
    return _assessments
        .where((a) => a['status'] == _statusFilter)
        .toList();
  }

  Future<void> _publishAssessment(String id) async {
    try {
      await ref.read(teacherRepositoryProvider).publishAssessment(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نشر الاختبار بنجاح')),
        );
        _loadAssessments();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر نشر الاختبار')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الاختبارات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.teacherCreateAssessment),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterChip(
                    label: 'الكل',
                    selected: _statusFilter == 'all',
                    onTap: () => setState(() => _statusFilter = 'all')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'مسودة',
                    selected: _statusFilter == 'draft',
                    onTap: () => setState(() => _statusFilter = 'draft')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'نشط',
                    selected: _statusFilter == 'active',
                    onTap: () => setState(() => _statusFilter = 'active')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'مكتمل',
                    selected: _statusFilter == 'completed',
                    onTap: () =>
                        setState(() => _statusFilter = 'completed')),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('لا توجد اختبارات'))
                    : RefreshIndicator(
                        onRefresh: _loadAssessments,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => _AssessmentCard(
                            assessment: _filtered[i],
                            onPublish: _filtered[i]['status'] == 'draft'
                                ? () => _publishAssessment(
                                    _filtered[i]['_id'] as String)
                                : null,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard(
      {required this.assessment, this.onPublish});
  final Map<String, dynamic> assessment;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assessment['title'] as String? ?? '',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${assessment['subject'] ?? ''} • ${assessment['questionCount'] ?? ''} سؤال • ${assessment['timeLimitMinutes'] ?? ''} دقيقة',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            if (onPublish != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.publish_rounded, size: 18),
                  label: const Text('نشر الاختبار'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
}
