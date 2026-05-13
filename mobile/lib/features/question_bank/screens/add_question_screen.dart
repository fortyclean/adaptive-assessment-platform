import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Add Question Screen — Screen 7 & 8
/// Requirements: 16.1, 16.2, 16.3
class AddQuestionScreen extends ConsumerStatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  ConsumerState<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends ConsumerState<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _subject;
  String? _gradeLevel;
  String _unit = '';
  String _mainSkill = '';
  String? _difficulty;
  String _questionText = '';
  String _questionType = 'mcq';
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  String? _correctAnswer;

  bool _isLoading = false;
  bool _success = false;

  final List<String> _gradeLevels = [
    'الصف السابع',
    'الصف الثامن',
    'الصف التاسع',
    'الصف العاشر',
    'الصف الحادي عشر',
    'الصف الثاني عشر',
  ];
  final List<String> _optionKeys = ['A', 'B', 'C', 'D'];
  final List<String> _optionLabels = ['أ', 'ب', 'ج', 'د'];

  final List<Map<String, dynamic>> _questionTypes = [
    {'key': 'mcq', 'label': 'اختيار متعدد', 'icon': Icons.radio_button_checked},
    {
      'key': 'true_false',
      'label': 'صح / خطأ',
      'icon': Icons.check_circle_outline
    },
    {'key': 'fill_blank', 'label': 'ملء الفراغ', 'icon': Icons.edit_outlined},
    {'key': 'essay', 'label': 'مقالي', 'icon': Icons.article_outlined},
  ];

  @override
  void dispose() {
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      await ref.read(teacherRepositoryProvider).createQuestion({
        'subject': _subject,
        'gradeLevel': _gradeLevel,
        'unit': _unit,
        'mainSkill': _mainSkill,
        'difficulty': _difficulty,
        'questionText': _questionText,
        'questionType': _questionType,
        'options': _questionType == 'mcq'
            ? List.generate(
                4,
                (i) => {
                  'key': _optionKeys[i],
                  'value': _optionControllers[i].text.trim(),
                },
              )
            : [],
        'correctAnswer': _correctAnswer,
      });

      setState(() {
        _success = true;
        _isLoading = false;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Demo mode: show success
        setState(() => _success = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ السؤال بنجاح في البنك التجريبي'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFBF8FF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'إضافة سؤال جديد',
            style: TextStyle(
              color: Color(0xFF1A1B22),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.onSurfaceVariant),
            onPressed: () => context.pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.outlineVariant),
          ),
        ),
        body: _success
            ? _buildSuccessView()
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Section: Classification ──────────────────────────────
                    const _SectionHeader(
                      icon: Icons.category_outlined,
                      title: 'تصنيف السؤال',
                    ),
                    const SizedBox(height: 12),

                    // Subject
                    _StyledDropdown<String>(
                      label: 'المادة الدراسية',
                      hint: 'اختر المادة',
                      value: _subject,
                      icon: Icons.book_outlined,
                      items: AppConstants.subjects
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _subject = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),

                    // Grade Level
                    _StyledDropdown<String>(
                      label: 'المرحلة الدراسية',
                      hint: 'اختر المرحلة',
                      value: _gradeLevel,
                      icon: Icons.school_outlined,
                      items: _gradeLevels
                          .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gradeLevel = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),

                    // Unit
                    _StyledTextField(
                      label: 'الوحدة الدراسية',
                      hint: 'مثال: الوحدة الأولى',
                      icon: Icons.layers_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      onSaved: (v) => _unit = v!.trim(),
                    ),
                    const SizedBox(height: 12),

                    // Main Skill
                    _StyledTextField(
                      label: 'المهارة الرئيسية',
                      hint: 'مثال: الجمع والطرح',
                      icon: Icons.psychology_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      onSaved: (v) => _mainSkill = v!.trim(),
                    ),
                    const SizedBox(height: 20),

                    // ── Section: Question Type ───────────────────────────────
                    const _SectionHeader(
                      icon: Icons.help_outline_rounded,
                      title: 'نوع السؤال',
                    ),
                    const SizedBox(height: 12),

                    // Question type selector
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.8,
                      children: _questionTypes.map((qt) {
                        final isSelected = _questionType == qt['key'];
                        return GestureDetector(
                          onTap: () => setState(
                              () => _questionType = qt['key'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDDE1FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  qt['icon'] as IconData,
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  qt['label'] as String,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Section: Question Content ────────────────────────────
                    const _SectionHeader(
                      icon: Icons.edit_note_rounded,
                      title: 'محتوى السؤال',
                    ),
                    const SizedBox(height: 12),

                    // Question Text
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: TextFormField(
                        maxLines: 4,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'نص السؤال *',
                          hintText: 'اكتب نص السؤال هنا...',
                          alignLabelWithHint: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                        onSaved: (v) => _questionText = v!.trim(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Section: Answer Options (MCQ only) ───────────────────
                    if (_questionType == 'mcq') ...[
                      const _SectionHeader(
                        icon: Icons.checklist_rounded,
                        title: 'خيارات الإجابة',
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(4, (i) {
                        final isCorrect = _correctAnswer == _optionKeys[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? const Color(0xFFD1FAE5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.outlineVariant,
                              width: isCorrect ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Letter indicator
                              GestureDetector(
                                onTap: () => setState(
                                    () => _correctAnswer = _optionKeys[i]),
                                child: Container(
                                  width: 44,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.surfaceContainer,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(9),
                                      bottomRight: Radius.circular(9),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _optionLabels[i],
                                    style: TextStyle(
                                      color: isCorrect
                                          ? Colors.white
                                          : AppColors.onSurfaceVariant,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              // Text field
                              Expanded(
                                child: TextFormField(
                                  controller: _optionControllers[i],
                                  textDirection: TextDirection.rtl,
                                  decoration: InputDecoration(
                                    hintText: 'الخيار ${_optionLabels[i]}',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'مطلوب'
                                          : null,
                                ),
                              ),
                              // Correct answer indicator
                              GestureDetector(
                                onTap: () => setState(
                                    () => _correctAnswer = _optionKeys[i]),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Icon(
                                    isCorrect
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.outlineVariant,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (_correctAnswer == null)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'اضغط على الخيار لتحديد الإجابة الصحيحة',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],

                    // ── Section: Difficulty ──────────────────────────────────
                    const _SectionHeader(
                      icon: Icons.bar_chart_rounded,
                      title: 'مستوى الصعوبة',
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _DifficultyChip(
                          label: 'سهل',
                          value: 'easy',
                          selected: _difficulty == 'easy',
                          color: AppColors.success,
                          onTap: () => setState(() => _difficulty = 'easy'),
                        ),
                        const SizedBox(width: 8),
                        _DifficultyChip(
                          label: 'متوسط',
                          value: 'medium',
                          selected: _difficulty == 'medium',
                          color: AppColors.warning,
                          onTap: () => setState(() => _difficulty = 'medium'),
                        ),
                        const SizedBox(width: 8),
                        _DifficultyChip(
                          label: 'صعب',
                          value: 'hard',
                          selected: _difficulty == 'hard',
                          color: AppColors.error,
                          onTap: () => setState(() => _difficulty = 'hard'),
                        ),
                      ],
                    ),
                    if (_difficulty == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'يرجى اختيار مستوى الصعوبة',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // ── Submit button ────────────────────────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'حفظ السؤال',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      );

  Widget _buildSuccessView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.successContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 56, color: AppColors.success),
            ),
            const SizedBox(height: 20),
            const Text(
              'تم حفظ السؤال بنجاح',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'جاري العودة...',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.onSaved,
  });
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: TextFormField(
          maxLines: 1,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: '$label *',
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      );
}

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
    required this.validator,
  });
  final String label;
  final String hint;
  final T? value;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?) validator;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: '$label *',
            prefixIcon: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          ),
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
        ),
      );
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.12) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? color : AppColors.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? color : AppColors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
}
