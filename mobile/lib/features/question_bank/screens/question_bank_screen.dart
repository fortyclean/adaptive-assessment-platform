import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
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

  // Subject chips
  final List<String> _subjectChips = ['الكل', 'رياضيات', 'علوم', 'لغة عربية', 'إنجليزي'];

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

  void _showUnitFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'بنك الأسئلة',
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
      body: Column(
        children: [
          // Filter chips row + unit filter button
          _FilterBar(
            selectedSubject: _filterSubject,
            subjectChips: _subjectChips,
            onSubjectSelected: (subject) {
              setState(() {
                _filterSubject = subject == 'الكل' ? null : subject;
              });
              _loadQuestions(reset: true);
            },
            onUnitFilterTap: _showUnitFilterSheet,
            hasActiveFilters: _filterUnit != null || _filterDifficulty != null,
          ),

          // Action buttons row
          _ActionBar(
            onAddQuestion: () => context.push(AppRoutes.teacherAddQuestion),
            onImportExcel: () {
              // TODO: implement Excel import
            },
          ),

          // Questions list
          Expanded(
            child: _isLoading && _questions.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryContainer,
                    ),
                  )
                : _questions.isEmpty
                    ? _EmptyState()
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
                            return _QuestionCard(question: _questions[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedSubject,
    required this.subjectChips,
    required this.onSubjectSelected,
    required this.onUnitFilterTap,
    required this.hasActiveFilters,
  });

  final String? selectedSubject;
  final List<String> subjectChips;
  final ValueChanged<String> onSubjectSelected;
  final VoidCallback onUnitFilterTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Subject filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subjectChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final chip = subjectChips[i];
                final isSelected = chip == 'الكل'
                    ? selectedSubject == null
                    : selectedSubject == chip;
                return _SubjectChip(
                  label: chip,
                  isSelected: isSelected,
                  onTap: () => onSubjectSelected(chip),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Unit/chapter dropdown filter
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
                        hasActiveFilters ? 'فلاتر نشطة' : 'الوحدة / الفصل',
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
  Widget build(BuildContext context) {
    return GestureDetector(
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
}

// ─── Action Bar ───────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onAddQuestion,
    required this.onImportExcel,
  });

  final VoidCallback onAddQuestion;
  final VoidCallback onImportExcel;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_rounded,
              label: 'إضافة سؤال',
              isPrimary: true,
              onTap: onAddQuestion,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.upload_file_rounded,
              label: 'استيراد Excel',
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
  Widget build(BuildContext context) {
    return GestureDetector(
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
}

// ─── Question Card ────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) {
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
            // Badges row + menu
            Row(
              children: [
                // Subject badge
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
                // Difficulty badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _difficultyBgColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _difficultyLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _difficultyColor,
                    ),
                  ),
                ),
                const Spacer(),
                // More menu button
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
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('حذف',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Question text
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
            // Skill label
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

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const Text(
            'لا توجد أسئلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ بإضافة أسئلة إلى بنك الأسئلة',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Unit Filter Sheet ────────────────────────────────────────────────────────

class _UnitFilterSheet extends StatefulWidget {
  const _UnitFilterSheet({
    this.unit,
    this.difficulty,
    required this.onApply,
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
          // Handle
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
          const Text(
            'تصفية الأسئلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          // Difficulty
          const Text(
            'مستوى الصعوبة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _DifficultyChip(
                label: 'الكل',
                isSelected: _difficulty == null,
                color: AppColors.primaryContainer,
                onTap: () => setState(() => _difficulty = null),
              ),
              const SizedBox(width: 8),
              _DifficultyChip(
                label: 'سهل',
                isSelected: _difficulty == 'easy',
                color: AppColors.success,
                onTap: () => setState(() => _difficulty = 'easy'),
              ),
              const SizedBox(width: 8),
              _DifficultyChip(
                label: 'متوسط',
                isSelected: _difficulty == 'medium',
                color: AppColors.warning,
                onTap: () => setState(() => _difficulty = 'medium'),
              ),
              const SizedBox(width: 8),
              _DifficultyChip(
                label: 'صعب',
                isSelected: _difficulty == 'hard',
                color: AppColors.error,
                onTap: () => setState(() => _difficulty = 'hard'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Unit
          const Text(
            'الوحدة / الفصل',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _unitController,
            decoration: InputDecoration(
              hintText: 'اكتب اسم الوحدة...',
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
                    color: AppColors.primaryContainer, width: 1.5),
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
            child: const Text(
              'تطبيق الفلاتر',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
  Widget build(BuildContext context) {
    return GestureDetector(
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
}
