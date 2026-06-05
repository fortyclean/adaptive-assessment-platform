import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/demo_questions.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Question Bank Screen - Screen 6
/// Requirements: 3.3, 3.4
class QuestionBankScreen extends ConsumerStatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  ConsumerState<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends ConsumerState<QuestionBankScreen> {
  static const _allSubjectValue = '__all__';

  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  int _currentPage = 1;
  bool _hasMore = true;

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

      if (!mounted) return;
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
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _questions = DemoQuestions.all
            .take(20)
            .map(
              (q) => {
                '_id': q['_id'],
                'questionText': q['questionText'],
                'subject': q['subject'],
                'difficulty': q['difficulty'] == 1
                    ? 'easy'
                    : q['difficulty'] == 3
                        ? 'hard'
                        : 'medium',
                'mainSkill': l10n.generalSkillFallback,
                'questionType': 'mcq',
              },
            )
            .toList();
        _isLoading = false;
      });
    }
  }

  List<_SubjectFilter> _subjectFilters(AppLocalizations l10n) => [
        _SubjectFilter(_allSubjectValue, l10n.filterAll),
        _SubjectFilter('Mathematics', l10n.subjectMathematics),
        _SubjectFilter('Science', l10n.subjectScience),
        _SubjectFilter('Arabic', l10n.subjectArabic),
        _SubjectFilter('English', l10n.subjectEnglish),
      ];

  void _editQuestion(Map<String, dynamic> question) {
    final l10n = AppLocalizations.of(context);
    final textController =
        TextEditingController(text: question['questionText'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.editQuestionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.questionTextLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final idx =
                    _questions.indexWhere((q) => q['_id'] == question['_id']);
                if (idx != -1) {
                  setState(() {
                    _questions[idx] = Map.from(_questions[idx])
                      ..['questionText'] = textController.text.trim();
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.questionUpdated),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.saveEdits,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(Map<String, dynamic> question) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteQuestionTitle),
        content: Text(l10n.deleteQuestionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      setState(() {
        _questions.removeWhere((q) => q['_id'] == question['_id']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.questionDeleted),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showUnitFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _UnitFilterSheet(
        unit: _filterUnit,
        difficulty: _filterDifficulty,
        onApply: (unit, difficulty) {
          setState(() {
            _filterUnit = unit;
            _filterDifficulty = difficulty;
          });
          _loadQuestions(reset: true);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.questionBankTitle,
          style: const TextStyle(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryContainer,
          ),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(
            selectedSubject: _filterSubject,
            subjectFilters: _subjectFilters(l10n),
            onSubjectSelected: (subject) {
              setState(() {
                _filterSubject =
                    subject.value == _allSubjectValue ? null : subject.value;
              });
              _loadQuestions(reset: true);
            },
            onUnitFilterTap: _showUnitFilterSheet,
            hasActiveFilters: _filterUnit != null || _filterDifficulty != null,
          ),
          _ActionBar(
            onAddQuestion: () => context.push(AppRoutes.teacherAddQuestion),
            onImportExcel: () => context.push(AppRoutes.teacherImportExcel),
          ),
          Expanded(
            child: _isLoading && _questions.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryContainer,
                    ),
                  )
                : _questions.isEmpty
                    ? const _EmptyState()
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
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _questions.length + (_hasMore ? 1 : 0),
                          itemBuilder: (ctx, i) {
                            if (i == _questions.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryContainer,
                                  ),
                                ),
                              );
                            }
                            return _QuestionCard(
                              question: _questions[i],
                              onEdit: () => _editQuestion(_questions[i]),
                              onDelete: () => _deleteQuestion(_questions[i]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SubjectFilter {
  const _SubjectFilter(this.value, this.label);

  final String value;
  final String label;
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedSubject,
    required this.subjectFilters,
    required this.onSubjectSelected,
    required this.onUnitFilterTap,
    required this.hasActiveFilters,
  });

  final String? selectedSubject;
  final List<_SubjectFilter> subjectFilters;
  final ValueChanged<_SubjectFilter> onSubjectSelected;
  final VoidCallback onUnitFilterTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subjectFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final chip = subjectFilters[i];
                final isSelected =
                    chip.value == _QuestionBankScreenState._allSubjectValue
                        ? selectedSubject == null
                        : selectedSubject == chip.value;
                return _SubjectChip(
                  label: chip.label,
                  isSelected: isSelected,
                  onTap: () => onSubjectSelected(chip),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: onUnitFilterTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasActiveFilters
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant,
                    width: hasActiveFilters ? 1.5 : 1,
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
                      Icons.filter_list_rounded,
                      size: 18,
                      color: hasActiveFilters
                          ? AppColors.primaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasActiveFilters
                            ? l10n.activeFilters
                            : l10n.unitOrChapter,
                        style: TextStyle(
                          fontSize: 14,
                          color: hasActiveFilters
                              ? AppColors.primaryContainer
                              : AppColors.onSurfaceVariant,
                          fontWeight: hasActiveFilters
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: hasActiveFilters
                          ? AppColors.primaryContainer
                          : AppColors.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onAddQuestion,
    required this.onImportExcel,
  });

  final VoidCallback onAddQuestion;
  final VoidCallback onImportExcel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_rounded,
              label: l10n.addQuestion,
              isPrimary: true,
              onTap: onAddQuestion,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.upload_file_rounded,
              label: l10n.importExcel,
              isPrimary: false,
              onTap: onImportExcel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryContainer : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppColors.primaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
      );
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, this.onEdit, this.onDelete});

  final Map<String, dynamic> question;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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

  Color get _difficultyBgColor {
    switch (question['difficulty']) {
      case 'easy':
        return AppColors.successContainer;
      case 'hard':
        return AppColors.errorContainer;
      default:
        return AppColors.warningContainer;
    }
  }

  String _difficultyLabel(AppLocalizations l10n) {
    switch (question['difficulty']) {
      case 'easy':
        return l10n.easyDifficulty;
      case 'hard':
        return l10n.hardDifficulty;
      default:
        return l10n.mediumDifficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subject = question['subject'] as String? ?? '';
    final mainSkill = question['mainSkill'] as String? ?? '';
    final questionText = question['questionText'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (subject.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                if (subject.isNotEmpty) const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _difficultyBgColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _difficultyLabel(l10n),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _difficultyColor,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) onEdit!();
                      if (value == 'delete' && onDelete != null) onDelete!();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.delete,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              questionText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
            if (mainSkill.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mainSkill,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.quiz_outlined,
              size: 36,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noQuestionsTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noQuestionsSubtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitFilterSheet extends StatefulWidget {
  const _UnitFilterSheet({
    required this.onApply,
    this.unit,
    this.difficulty,
  });

  final String? unit;
  final String? difficulty;
  final void Function(String?, String?) onApply;

  @override
  State<_UnitFilterSheet> createState() => _UnitFilterSheetState();
}

class _UnitFilterSheetState extends State<_UnitFilterSheet> {
  String? _difficulty;
  final _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _unitController.text = widget.unit ?? '';
  }

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.filterQuestionsTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.difficultyLevel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _DifficultyChip(
                label: l10n.filterAll,
                isSelected: _difficulty == null,
                color: AppColors.primaryContainer,
                onTap: () => setState(() => _difficulty = null),
              ),
              const SizedBox(width: 8),
              _DifficultyChip(
                label: l10n.easyDifficulty,
                isSelected: _difficulty == 'easy',
                color: AppColors.success,
                onTap: () => setState(() => _difficulty = 'easy'),
              ),
              const SizedBox(width: 8),
              _DifficultyChip(
                label: l10n.mediumDifficulty,
                isSelected: _difficulty == 'medium',
                color: AppColors.warning,
                onTap: () => setState(() => _difficulty = 'medium'),
              ),
              const SizedBox(width: 8),
              _DifficultyChip(
                label: l10n.hardDifficulty,
                isSelected: _difficulty == 'hard',
                color: AppColors.error,
                onTap: () => setState(() => _difficulty = 'hard'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.unitOrChapter,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _unitController,
            decoration: InputDecoration(
              hintText: l10n.unitNameHint,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                borderSide: const BorderSide(
                  color: AppColors.primaryContainer,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => widget.onApply(
              _unitController.text.trim().isEmpty
                  ? null
                  : _unitController.text.trim(),
              _difficulty,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.applyFilters,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? color : AppColors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? color : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
}
