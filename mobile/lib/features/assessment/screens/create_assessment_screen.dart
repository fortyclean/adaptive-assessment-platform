import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../repositories/teacher_repository.dart';

/// Create Assessment Screen — Screen 5
/// Requirements: 5.1–5.5, 5.7
class CreateAssessmentScreen extends ConsumerStatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  ConsumerState<CreateAssessmentScreen> createState() =>
      _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState
    extends ConsumerState<CreateAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form state
  String _title = '';
  String _assessmentType = 'adaptive';
  String? _subject;
  String? _gradeLevel;
  String _unit = '';
  int _questionCount = 10;
  int _timeLimitMinutes = 30;
  final List<String> _classroomIds = [];
  DateTime? _availableFrom;
  DateTime? _availableUntil;

  bool _isLoading = false;
  bool _isLoadingClassrooms = true;
  List<Map<String, dynamic>> _classrooms = [];
  String? _warningMessage;

  final List<String> _gradeLevels = [
    'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'
  ];

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    try {
      final classrooms =
          await ref.read(teacherRepositoryProvider).getClassrooms();
      setState(() {
        _classrooms = classrooms;
        _isLoadingClassrooms = false;
      });
    } catch (_) {
      setState(() => _isLoadingClassrooms = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _warningMessage = null;
    });

    try {
      await ref.read(teacherRepositoryProvider).createAssessment({
        'title': _title,
        'assessmentType': _assessmentType,
        'subject': _subject,
        'gradeLevel': _gradeLevel,
        'units': [_unit],
        'questionCount': _questionCount,
        'timeLimitMinutes': _timeLimitMinutes,
        'classroomIds': _classroomIds,
        if (_availableFrom != null)
          'availableFrom': _availableFrom!.toIso8601String(),
        if (_availableUntil != null)
          'availableUntil': _availableUntil!.toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الاختبار بنجاح')),
        );
        context.pop();
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Insufficient') || msg.contains('422') || msg.contains('insufficient')) {
        setState(() => _warningMessage =
            'تحذير: عدد الأسئلة المتاحة أقل من المطلوب. يمكنك الإنشاء وإضافة أسئلة لاحقاً.');
      } else if (msg.contains('400') || msg.contains('validation')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في البيانات: $msg')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $msg')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateTime(bool isFrom) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isFrom) {
        _availableFrom = dt;
      } else {
        _availableUntil = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء اختبار جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              decoration: const InputDecoration(labelText: 'عنوان الاختبار *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              onSaved: (v) => _title = v!.trim(),
            ),
            const SizedBox(height: 16),

            // Assessment Type
            Text('نوع الاختبار',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: 'تكيفي',
                    icon: Icons.auto_awesome_rounded,
                    selected: _assessmentType == 'adaptive',
                    onTap: () =>
                        setState(() => _assessmentType = 'adaptive'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeButton(
                    label: 'عشوائي',
                    icon: Icons.shuffle_rounded,
                    selected: _assessmentType == 'random',
                    onTap: () =>
                        setState(() => _assessmentType = 'random'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Subject
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'المادة *'),
              initialValue: _subject,
              items: AppConstants.subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            // Grade Level
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'المرحلة الدراسية *'),
              initialValue: _gradeLevel,
              items: _gradeLevels
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gradeLevel = v),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            // Unit
            TextFormField(
              decoration: const InputDecoration(labelText: 'الوحدة *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              onSaved: (v) => _unit = v!.trim(),
            ),
            const SizedBox(height: 16),

            // Question Count
            _SliderField(
              label: 'عدد الأسئلة',
              value: _questionCount.toDouble(),
              min: AppConstants.minQuestions.toDouble(),
              max: AppConstants.maxQuestions.toDouble(),
              divisions: 45,
              displayValue: '$_questionCount سؤال',
              onChanged: (v) => setState(() => _questionCount = v.round()),
            ),
            const SizedBox(height: 16),

            // Time Limit
            _SliderField(
              label: 'الوقت المحدد',
              value: _timeLimitMinutes.toDouble(),
              min: AppConstants.minTimeLimitMinutes.toDouble(),
              max: AppConstants.maxTimeLimitMinutes.toDouble(),
              divisions: 23,
              displayValue: '$_timeLimitMinutes دقيقة',
              onChanged: (v) =>
                  setState(() => _timeLimitMinutes = v.round()),
            ),
            const SizedBox(height: 16),

            // Classrooms
            if (!_isLoadingClassrooms && _classrooms.isNotEmpty) ...[
              Text('الفصول الدراسية',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              ..._classrooms.map((c) => CheckboxListTile(
                    title: Text(c['name'] as String? ?? ''),
                    subtitle: Text(c['gradeLevel'] as String? ?? ''),
                    value: _classroomIds.contains(c['_id'] as String),
                    onChanged: (checked) {
                      setState(() {
                        if (checked ?? false) {
                          _classroomIds.add(c['_id'] as String);
                        } else {
                          _classroomIds.remove(c['_id'] as String);
                        }
                      });
                    },
                  )),
              const SizedBox(height: 16),
            ],

            // Availability Window
            Text('نافذة التوفر',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(_availableFrom != null
                        ? '${_availableFrom!.day}/${_availableFrom!.month}'
                        : 'من'),
                    onPressed: () => _pickDateTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(_availableUntil != null
                        ? '${_availableUntil!.day}/${_availableUntil!.month}'
                        : 'إلى'),
                    onPressed: () => _pickDateTime(false),
                  ),
                ),
              ],
            ),

            // Warning
            if (_warningMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Text(_warningMessage!,
                    style: const TextStyle(color: AppColors.warning)),
              ),
            ],

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('إنشاء الاختبار'),
            ),
          ],
        ),
      ),
    );
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.onPrimaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
          ],
        ),
      ),
    );
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(displayValue,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
}
