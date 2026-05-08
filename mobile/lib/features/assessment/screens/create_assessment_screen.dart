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
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12'
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
      if (msg.contains('Insufficient')) {
        setState(() => _warningMessage =
            'تحذير: عدد الأسئلة المتاحة أقل من المطلوب');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ. يرجى المحاولة مرة أخرى')),
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

    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isFrom) {
        _availableFrom = dt;
      } else {
        _availableUntil = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'إنشاء اختبار جديد',
          style: TextStyle(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryContainer),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            // ── Title ──────────────────────────────────────────────────────
            _FormLabel(label: 'عنوان الاختبار'),
            const SizedBox(height: 8),
            _StyledTextFormField(
              hintText: 'مثال: اختبار الوحدة الأولى',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              onSaved: (v) => _title = v!.trim(),
            ),
            const SizedBox(height: 20),

            // ── Subject ────────────────────────────────────────────────────
            _FormLabel(label: 'المادة الدراسية'),
            const SizedBox(height: 8),
            _StyledDropdown<String>(
              hint: 'اختر المادة...',
              value: _subject,
              items: AppConstants.subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),

            // ── Unit ───────────────────────────────────────────────────────
            _FormLabel(label: 'الوحدة / الفصل'),
            const SizedBox(height: 8),
            _StyledTextFormField(
              hintText: 'مثال: الوحدة الأولى',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              onSaved: (v) => _unit = v!.trim(),
            ),
            const SizedBox(height: 20),

            // ── Assessment Type ────────────────────────────────────────────
            _FormLabel(label: 'نوع الاختبار'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    label: 'اختبار عشوائي',
                    description:
                        'يتم اختيار الأسئلة بشكل عشوائي من بنك الأسئلة.',
                    icon: Icons.shuffle_rounded,
                    selected: _assessmentType == 'random',
                    onTap: () => setState(() => _assessmentType = 'random'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeCard(
                    label: 'اختبار تكيفي',
                    description:
                        'تتغير صعوبة الأسئلة بناءً على إجابات الطالب.',
                    icon: Icons.auto_awesome_rounded,
                    selected: _assessmentType == 'adaptive',
                    onTap: () => setState(() => _assessmentType = 'adaptive'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Question Count & Time ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormLabel(label: 'عدد الأسئلة'),
                      const SizedBox(height: 8),
                      _CounterField(
                        value: _questionCount,
                        min: AppConstants.minQuestions,
                        max: AppConstants.maxQuestions,
                        suffix: 'سؤال',
                        onChanged: (v) => setState(() => _questionCount = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormLabel(label: 'الزمن (بالدقائق)'),
                      const SizedBox(height: 8),
                      _CounterField(
                        value: _timeLimitMinutes,
                        min: AppConstants.minTimeLimitMinutes,
                        max: AppConstants.maxTimeLimitMinutes,
                        suffix: 'دقيقة',
                        onChanged: (v) =>
                            setState(() => _timeLimitMinutes = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Grade Level ────────────────────────────────────────────────
            _FormLabel(label: 'المرحلة الدراسية'),
            const SizedBox(height: 8),
            _StyledDropdown<String>(
              hint: 'اختر المرحلة...',
              value: _gradeLevel,
              items: _gradeLevels
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gradeLevel = v),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 20),

            // ── Classrooms ─────────────────────────────────────────────────
            if (!_isLoadingClassrooms && _classrooms.isNotEmpty) ...[
              _FormLabel(label: 'الفصول الدراسية'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: _classrooms.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    final isLast = i == _classrooms.length - 1;
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(
                            c['name'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            c['gradeLevel'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          value: _classroomIds.contains(c['_id'] as String),
                          activeColor: AppColors.primaryContainer,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _classroomIds.add(c['_id'] as String);
                              } else {
                                _classroomIds.remove(c['_id'] as String);
                              }
                            });
                          },
                        ),
                        if (!isLast)
                          const Divider(
                              height: 1, color: AppColors.outlineVariant),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Availability Window ────────────────────────────────────────
            _FormLabel(label: 'نافذة التوفر'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: _availableFrom != null
                        ? '${_availableFrom!.day}/${_availableFrom!.month}/${_availableFrom!.year}'
                        : 'تاريخ البداية',
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _pickDateTime(true),
                    hasValue: _availableFrom != null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateButton(
                    label: _availableUntil != null
                        ? '${_availableUntil!.day}/${_availableUntil!.month}/${_availableUntil!.year}'
                        : 'تاريخ الانتهاء',
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _pickDateTime(false),
                    hasValue: _availableUntil != null,
                  ),
                ),
              ],
            ),

            // ── Warning ────────────────────────────────────────────────────
            if (_warningMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _warningMessage!,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Submit Button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primaryContainer.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'تأكيد وإنشاء الاختبار',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form Label ───────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

// ─── Styled Text Form Field ───────────────────────────────────────────────────

class _StyledTextFormField extends StatelessWidget {
  const _StyledTextFormField({
    required this.hintText,
    this.validator,
    this.onSaved,
    this.keyboardType,
  });

  final String hintText;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Styled Dropdown ──────────────────────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
      icon: const Icon(Icons.expand_more_rounded, color: AppColors.outline),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

// ─── Type Card ────────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryContainer : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? AppColors.primaryContainer
                      : AppColors.onSurfaceVariant,
                ),
                // Radio indicator
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryContainer
                          : AppColors.outline,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primaryContainer
                    : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Counter Field ────────────────────────────────────────────────────────────

class _CounterField extends StatelessWidget {
  const _CounterField({
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Decrement
          _CounterButton(
            icon: Icons.remove_rounded,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          // Value
          Expanded(
            child: Column(
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Increment
          _CounterButton(
            icon: Icons.add_rounded,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFEFF6FF)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? AppColors.primaryContainer
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── Date Button ──────────────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.hasValue,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool hasValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasValue ? AppColors.primaryContainer : AppColors.outlineVariant,
            width: hasValue ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: hasValue
                  ? AppColors.primaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: hasValue
                      ? AppColors.primaryContainer
                      : AppColors.onSurfaceVariant,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
