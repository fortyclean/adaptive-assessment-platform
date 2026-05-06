import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/repositories/admin_repository.dart';

/// School Reports Screen — Screen 31
/// Requirements: 19.1–19.5
class SchoolReportsScreen extends ConsumerStatefulWidget {
  const SchoolReportsScreen({super.key});

  @override
  ConsumerState<SchoolReportsScreen> createState() =>
      _SchoolReportsScreenState();
}

class _SchoolReportsScreenState extends ConsumerState<SchoolReportsScreen>
    with SingleTickerProviderStateMixin {
  // ─── Summary (Req 19.1) ───────────────────────────────────────────────────
  bool _summaryLoading = true;
  Map<String, dynamic>? _summaryReport;

  // ─── Filters (Req 19.5) ───────────────────────────────────────────────────
  String? _selectedSubject;
  String? _selectedGradeLevel;

  static const List<String> _gradeLevels = [
    '1', '2', '3', '4', '5', '6',
    '7', '8', '9', '10', '11', '12',
  ];

  // ─── Tab 1: Classroom Comparison (Req 19.2) ───────────────────────────────
  bool _comparisonLoading = false;
  List<Map<String, dynamic>> _comparisonData = [];
  String? _comparisonError;

  // ─── Tab 2: Longitudinal Trend (Req 19.3) ────────────────────────────────
  bool _longitudinalLoading = false;
  List<Map<String, dynamic>> _longitudinalData = [];
  String? _longitudinalError;

  // ─── Tab 3: Weakness Identification (Req 19.4) ───────────────────────────
  bool _weaknessLoading = false;
  List<Map<String, dynamic>> _weaknessData = [];
  String? _weaknessError;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadSummary();
    _loadComparison();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 0:
        if (_comparisonData.isEmpty && !_comparisonLoading) _loadComparison();
      case 1:
        if (_longitudinalData.isEmpty && !_longitudinalLoading) _loadLongitudinal();
      case 2:
        if (_weaknessData.isEmpty && !_weaknessLoading) _loadWeaknesses();
    }
  }

  // ─── Loaders ──────────────────────────────────────────────────────────────

  Future<void> _loadSummary() async {
    setState(() => _summaryLoading = true);
    try {
      final data = await ref.read(adminRepositoryProvider).getSchoolReport();
      setState(() {
        _summaryReport = data;
        _summaryLoading = false;
      });
    } catch (_) {
      setState(() => _summaryLoading = false);
    }
  }

  Future<void> _loadComparison() async {
    setState(() {
      _comparisonLoading = true;
      _comparisonError = null;
    });
    try {
      final data = await ref.read(adminRepositoryProvider).getClassroomComparison(
            subject: _selectedSubject,
            gradeLevel: _selectedGradeLevel,
          );
      setState(() {
        _comparisonData = data;
        _comparisonLoading = false;
      });
    } catch (e) {
      setState(() {
        _comparisonError = 'تعذر تحميل بيانات المقارنة';
        _comparisonLoading = false;
      });
    }
  }

  Future<void> _loadLongitudinal() async {
    setState(() {
      _longitudinalLoading = true;
      _longitudinalError = null;
    });
    try {
      final data = await ref.read(adminRepositoryProvider).getLongitudinalReport(
            subject: _selectedSubject,
          );
      setState(() {
        _longitudinalData = data;
        _longitudinalLoading = false;
      });
    } catch (e) {
      setState(() {
        _longitudinalError = 'تعذر تحميل بيانات الأداء عبر الزمن';
        _longitudinalLoading = false;
      });
    }
  }

  Future<void> _loadWeaknesses() async {
    setState(() {
      _weaknessLoading = true;
      _weaknessError = null;
    });
    try {
      final data = await ref.read(adminRepositoryProvider).getWeakestSkills(
            subject: _selectedSubject,
            gradeLevel: _selectedGradeLevel,
          );
      setState(() {
        _weaknessData = data;
        _weaknessLoading = false;
      });
    } catch (e) {
      setState(() {
        _weaknessError = 'تعذر تحميل بيانات المهارات الضعيفة';
        _weaknessLoading = false;
      });
    }
  }

  /// Reload all tabs when filters change.
  void _onFiltersChanged() {
    _loadComparison();
    _loadLongitudinal();
    _loadWeaknesses();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('تقارير المدرسة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'مقارنة الفصول'),
            Tab(text: 'الأداء عبر الزمن'),
            Tab(text: 'المهارات الضعيفة'),
          ],
        ),
      ),
      body: Column(
        children: [
          // School summary (always visible, Req 19.1)
          _buildSummarySection(),
          // Filter row (Req 19.5)
          _buildFilterRow(),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildComparisonTab(),
                _buildLongitudinalTab(),
                _buildWeaknessTab(),
              ],
            ),
          ),
        ],
      ),
    );

  // ─── Summary Section ──────────────────────────────────────────────────────

  Widget _buildSummarySection() {
    if (_summaryLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_summaryReport == null) return const SizedBox.shrink();

    final summary =
        _summaryReport!['summary'] as Map<String, dynamic>? ?? {};

    return Container(
      color: AppColors.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'الطلاب',
              value: '${summary['totalStudents'] ?? 0}',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              label: 'المعلمون',
              value: '${summary['totalTeachers'] ?? 0}',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              label: 'المتوسط',
              value: summary['schoolAverage'] != null
                  ? '${(summary['schoolAverage'] as num).round()}%'
                  : '-',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Row (Req 19.5) ────────────────────────────────────────────────

  Widget _buildFilterRow() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded,
              size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterDropdown(
              hint: 'المادة',
              value: _selectedSubject,
              items: AppConstants.subjects,
              onChanged: (v) {
                setState(() => _selectedSubject = v);
                _onFiltersChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterDropdown(
              hint: 'المرحلة',
              value: _selectedGradeLevel,
              items: _gradeLevels,
              onChanged: (v) {
                setState(() => _selectedGradeLevel = v);
                _onFiltersChanged();
              },
            ),
          ),
          if (_selectedSubject != null || _selectedGradeLevel != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18),
              tooltip: 'مسح الفلاتر',
              onPressed: () {
                setState(() {
                  _selectedSubject = null;
                  _selectedGradeLevel = null;
                });
                _onFiltersChanged();
              },
            ),
          ],
        ],
      ),
    );

  // ─── Tab 1: Classroom Comparison (Req 19.2) ───────────────────────────────

  Widget _buildComparisonTab() {
    if (_comparisonLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_comparisonError != null) {
      return _ErrorView(
          message: _comparisonError!, onRetry: _loadComparison);
    }
    if (_comparisonData.isEmpty) {
      return const _EmptyView(message: 'لا توجد بيانات مقارنة متاحة');
    }

    // Find max score for proportional bar widths
    final maxScore = _comparisonData
        .map((c) => (c['averageScore'] as num?)?.toDouble() ?? 0.0)
        .fold(0.0, (a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: _loadComparison,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _comparisonData.length,
        itemBuilder: (context, index) => _ClassroomComparisonCard(
            classroom: _comparisonData[index],
            maxScore: maxScore > 0 ? maxScore : 100,
          ),
      ),
    );
  }

  // ─── Tab 2: Longitudinal Trend (Req 19.3) ────────────────────────────────

  Widget _buildLongitudinalTab() {
    if (_longitudinalLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_longitudinalError != null) {
      return _ErrorView(
          message: _longitudinalError!, onRetry: _loadLongitudinal);
    }
    if (_longitudinalData.isEmpty) {
      return const _EmptyView(message: 'لا توجد بيانات أداء متاحة');
    }

    // Group by classroomName
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final entry in _longitudinalData) {
      final name = entry['classroomName'] as String? ?? 'غير محدد';
      grouped.putIfAbsent(name, () => []).add(entry);
    }

    return RefreshIndicator(
      onRefresh: _loadLongitudinal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((e) => _LongitudinalClassroomCard(
            classroomName: e.key,
            entries: e.value,
          )).toList(),
      ),
    );
  }

  // ─── Tab 3: Weakness Identification (Req 19.4) ───────────────────────────

  Widget _buildWeaknessTab() {
    if (_weaknessLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_weaknessError != null) {
      return _ErrorView(
          message: _weaknessError!, onRetry: _loadWeaknesses);
    }
    if (_weaknessData.isEmpty) {
      return const _EmptyView(message: 'لا توجد بيانات مهارات متاحة');
    }

    return RefreshIndicator(
      onRefresh: _loadWeaknesses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _weaknessData.length,
        itemBuilder: (context, index) => _WeakSkillCard(
            rank: index + 1,
            skill: _weaknessData[index],
          ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
}

/// Dropdown filter widget used in the filter row.
class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          child: Text('الكل', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        ...items.map(
          (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
        ),
      ],
      onChanged: onChanged,
    );
}

/// Classroom comparison card with proportional bar chart (Req 19.2).
class _ClassroomComparisonCard extends StatelessWidget {
  const _ClassroomComparisonCard({
    required this.classroom,
    required this.maxScore,
  });
  final Map<String, dynamic> classroom;
  final double maxScore;

  @override
  Widget build(BuildContext context) {
    final name = classroom['classroomName'] as String? ??
        classroom['name'] as String? ??
        'فصل';
    final avg = (classroom['averageScore'] as num?)?.toDouble() ?? 0.0;
    final completion =
        (classroom['completionRate'] as num?)?.toDouble() ?? 0.0;
    final topSkill = classroom['topSkill'] as String? ?? '-';
    final barFraction = maxScore > 0 ? (avg / maxScore).clamp(0.0, 1.0) : 0.0;
    final scoreColor = avg >= 70 ? AppColors.success : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classroom name + score
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${avg.round()}%',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Proportional score bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: barFraction,
                minHeight: 10,
                backgroundColor: AppColors.surfaceContainer,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 8),
            // Completion rate + top skill
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'الإتمام: ${completion.round()}%',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star_outline_rounded,
                    size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'أفضل مهارة: $topSkill',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Longitudinal trend card grouped by classroom (Req 19.3).
class _LongitudinalClassroomCard extends StatelessWidget {
  const _LongitudinalClassroomCard({
    required this.classroomName,
    required this.entries,
  });
  final String classroomName;
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    // Sort entries by month string for consistent display
    final sorted = List<Map<String, dynamic>>.from(entries)
      ..sort((a, b) =>
          (a['month'] as String? ?? '').compareTo(b['month'] as String? ?? ''));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classroom header
            Row(
              children: [
                const Icon(Icons.class_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  classroomName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Monthly entries as a simple dot-line representation
            ...sorted.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;
              final month = item['month'] as String? ?? '-';
              final score =
                  (item['averageScore'] as num?)?.toDouble() ?? 0.0;
              final isLast = idx == sorted.length - 1;
              final scoreColor =
                  score >= 70 ? AppColors.success : AppColors.error;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dot + line
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: scoreColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: AppColors.outlineVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Month label + score bar
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 72,
                              child: Text(
                                month,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: AppColors.onSurfaceVariant),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: score / 100,
                                  minHeight: 8,
                                  backgroundColor: AppColors.surfaceContainer,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${score.round()}%',
                              style: TextStyle(
                                color: scoreColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Weak skill card with progress bar (Req 19.4).
class _WeakSkillCard extends StatelessWidget {
  const _WeakSkillCard({required this.rank, required this.skill});
  final int rank;
  final Map<String, dynamic> skill;

  @override
  Widget build(BuildContext context) {
    final pct = (skill['averagePercentage'] as num?)?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill['mainSkill'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: AppColors.surfaceContainer,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${pct.round()}%',
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic error view with retry button.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
}

/// Generic empty state view.
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bar_chart_rounded,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
}
