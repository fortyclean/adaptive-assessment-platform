import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Question Bank Screen — Screen 6
/// Requirements: 3.3, 3.4
class QuestionBankScreen extends ConsumerStatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  ConsumerState<QuestionBankScreen> createState() =>
      _QuestionBankScreenState();
}

class _QuestionBankScreenState extends ConsumerState<QuestionBankScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  int _currentPage = 1;
  bool _hasMore = true;

  // Filters
  String? _filterSubject;
  String? _filterDifficulty;
  String? _filterUnit;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _questions = [];
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);
    try {
      final filters = <String, dynamic>{};
      if (_filterSubject != null) filters['subject'] = _filterSubject;
      if (_filterDifficulty != null) filters['difficulty'] = _filterDifficulty;
      if (_filterUnit != null && _filterUnit!.isNotEmpty) {
        filters['unit'] = _filterUnit;
      }

      final data = await ref.read(teacherRepositoryProvider).getQuestions(
            filters: filters,
            page: _currentPage,
          );

      final newQuestions =
          List<Map<String, dynamic>>.from(data['questions'] as List? ?? []);
      final total = data['total'] as int? ?? 0;

      setState(() {
        if (reset) {
          _questions = newQuestions;
        } else {
          _questions.addAll(newQuestions);
        }
        _hasMore = _questions.length < total;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(
        subject: _filterSubject,
        difficulty: _filterDifficulty,
        unit: _filterUnit,
        onApply: (subject, difficulty, unit) {
          setState(() {
            _filterSubject = subject;
            _filterDifficulty = difficulty;
            _filterUnit = unit;
          });
          _loadQuestions(reset: true);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('بنك الأسئلة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
            tooltip: 'تصفية',
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(AppRoutes.teacherAddQuestion),
            tooltip: 'إضافة سؤال',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters
          if (_filterSubject != null ||
              _filterDifficulty != null ||
              (_filterUnit != null && _filterUnit!.isNotEmpty))
            _ActiveFilters(
              subject: _filterSubject,
              difficulty: _filterDifficulty,
              unit: _filterUnit,
              onClear: () {
                setState(() {
                  _filterSubject = null;
                  _filterDifficulty = null;
                  _filterUnit = null;
                });
                _loadQuestions(reset: true);
              },
            ),

          Expanded(
            child: _isLoading && _questions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _questions.isEmpty
                    ? const Center(child: Text('لا توجد أسئلة'))
                    : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n is ScrollEndNotification &&
                              n.metrics.pixels >=
                                  n.metrics.maxScrollExtent - 200 &&
                              _hasMore &&
                              !_isLoading) {
                            _currentPage++;
                            _loadQuestions();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              _questions.length + (_hasMore ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i == _questions.length) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ));
                            }
                            return _QuestionCard(
                                question: _questions[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.onClear, this.subject,
    this.difficulty,
    this.unit,
  });
  final String? subject;
  final String? difficulty;
  final String? unit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceContainer,
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded,
              size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              [
                if (subject != null) subject!,
                if (difficulty != null) difficulty!,
                if (unit != null && unit!.isNotEmpty) unit!,
              ].join(' • '),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('مسح')),
        ],
      ),
    );
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});
  final Map<String, dynamic> question;

  Color get _difficultyColor {
    switch (question['difficulty']) {
      case 'easy':
        return AppColors.success;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String get _difficultyLabel {
    switch (question['difficulty']) {
      case 'easy':
        return 'سهل';
      case 'hard':
        return 'صعب';
      default:
        return 'متوسط';
    }
  }

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _difficultyColor),
                  ),
                  child: Text(_difficultyLabel,
                      style: TextStyle(
                          color: _difficultyColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(
                  question['mainSkill'] as String? ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question['questionText'] as String? ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.onApply, this.subject,
    this.difficulty,
    this.unit,
  });
  final String? subject;
  final String? difficulty;
  final String? unit;
  final void Function(String?, String?, String?) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _subject;
  String? _difficulty;
  final _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subject = widget.subject;
    _difficulty = widget.difficulty;
    _unitController.text = widget.unit ?? '';
  }

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('تصفية الأسئلة',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'المادة'),
            initialValue: _subject,
            items: [
              const DropdownMenuItem(child: Text('الكل')),
              ...AppConstants.subjects.map(
                  (s) => DropdownMenuItem(value: s, child: Text(s))),
            ],
            onChanged: (v) => setState(() => _subject = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'الصعوبة'),
            initialValue: _difficulty,
            items: const [
              DropdownMenuItem(child: Text('الكل')),
              DropdownMenuItem(value: 'easy', child: Text('سهل')),
              DropdownMenuItem(value: 'medium', child: Text('متوسط')),
              DropdownMenuItem(value: 'hard', child: Text('صعب')),
            ],
            onChanged: (v) => setState(() => _difficulty = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _unitController,
            decoration: const InputDecoration(labelText: 'الوحدة'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.onApply(
                _subject, _difficulty, _unitController.text.trim()),
            child: const Text('تطبيق'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
}
