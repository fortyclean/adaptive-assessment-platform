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
  String _subSkill = '';
  String? _difficulty;
  String _questionText = '';
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  String? _correctAnswer;

  bool _isLoading = false;
  bool _success = false;

  final List<String> _gradeLevels = [
    'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'
  ];
  final List<String> _optionKeys = ['A', 'B', 'C', 'D'];

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
        'subSkill': _subSkill,
        'difficulty': _difficulty,
        'questionText': _questionText,
        'options': List.generate(
          4,
          (i) => {
            'key': _optionKeys[i],
            'value': _optionControllers[i].text.trim(),
          },
        ),
        'correctAnswer': _correctAnswer,
        'questionType': 'mcq',
      });

      setState(() {
        _success = true;
        _isLoading = false;
      });

      // Auto-navigate back after 2 seconds (Req 16.3)
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().contains('duplicate')
                  ? 'هذا السؤال موجود بالفعل'
                  : 'حدث خطأ. يرجى المحاولة مرة أخرى')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سؤال جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _success
          ? _buildSuccessView()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Subject
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'المادة *'),
                    initialValue: _subject,
                    items: AppConstants.subjects
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _subject = v),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),

                  // Grade Level
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'المرحلة الدراسية *'),
                    initialValue: _gradeLevel,
                    items: _gradeLevels
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _gradeLevel = v),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),

                  // Unit
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الوحدة *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                    onSaved: (v) => _unit = v!.trim(),
                  ),
                  const SizedBox(height: 12),

                  // Main Skill
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'المهارة الرئيسية *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                    onSaved: (v) => _mainSkill = v!.trim(),
                  ),
                  const SizedBox(height: 12),

                  // Sub Skill
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'المهارة الفرعية *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                    onSaved: (v) => _subSkill = v!.trim(),
                  ),
                  const SizedBox(height: 12),

                  // Difficulty
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'مستوى الصعوبة *'),
                    initialValue: _difficulty,
                    items: const [
                      DropdownMenuItem(value: 'easy', child: Text('سهل')),
                      DropdownMenuItem(
                          value: 'medium', child: Text('متوسط')),
                      DropdownMenuItem(value: 'hard', child: Text('صعب')),
                    ],
                    onChanged: (v) => setState(() => _difficulty = v),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),

                  // Question Text
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'نص السؤال *',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                    onSaved: (v) => _questionText = v!.trim(),
                  ),
                  const SizedBox(height: 16),

                  // Options
                  Text('خيارات الإجابة *',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  ...List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: _optionControllers[i],
                        decoration: InputDecoration(
                          labelText: 'الخيار ${_optionKeys[i]} *',
                          prefixIcon: Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(_optionKeys[i],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Correct Answer
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'الإجابة الصحيحة *'),
                    initialValue: _correctAnswer,
                    items: _optionKeys
                        .map((k) =>
                            DropdownMenuItem(value: k, child: Text('الخيار $k')))
                        .toList(),
                    onChanged: (v) => setState(() => _correctAnswer = v),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('حفظ السؤال'),
                  ),
                ],
              ),
            ),
    );

  Widget _buildSuccessView() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 80, color: AppColors.success),
          const SizedBox(height: 16),
          Text('تم حفظ السؤال بنجاح',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('جاري العودة...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
}
