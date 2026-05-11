import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/repositories/admin_repository.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/admin_top_actions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// School Reports Screen — Screen 29
/// Requirements: 19.1–19.5
/// Shows KPI bento grid, classroom comparison bars, strengths/weaknesses.
class SchoolReportsScreen extends ConsumerStatefulWidget {
  const SchoolReportsScreen({
    super.key,
    this.initialGradeLevel,
    this.initialSubject,
  });

  final String? initialGradeLevel;
  final String? initialSubject;

  @override
  ConsumerState<SchoolReportsScreen> createState() =>
      _SchoolReportsScreenState();
}

class _SchoolReportsScreenState extends ConsumerState<SchoolReportsScreen> {
  // ── Summary (Req 19.1) ────────────────────────────────────────────────────
  bool _summaryLoading = true;
  Map<String, dynamic>? _summaryReport;
  String? _summaryError;

  // ── Filters (Req 19.5) ────────────────────────────────────────────────────
  String? _selectedSubject;
  String? _selectedGradeLevel;

  static const List<String> _gradeLevels = [
    '1', '2', '3', '4', '5', '6',
    '7', '8', '9', '10', '11', '12',
  ];

  // ── Classroom Comparison (Req 19.2) ───────────────────────────────────────
  bool _comparisonLoading = false;
  List<Map<String, dynamic>> _comparisonData = [];
  String? _comparisonError;

  // ── Weakness Identification (Req 19.4) ────────────────────────────────────
  bool _weaknessLoading = false;
  List<Map<String, dynamic>> _weaknessData = [];
  String? _weaknessError;

  bool get _allowMockFallback {
    if (AppConstants.useMockData) return true;
    final authState = ref.read(authProvider);
    return (authState.accessToken ?? '').startsWith('demo-token-');
  }

  // ── Mock data fallbacks ───────────────────────────────────────────────────
  static const Map<String, dynamic> _mockSummary = {
    'summary': {
      'totalStudents': 342,
      'totalTeachers': 18,
      'schoolAverage': 84,
      'participationRate': 91,
      'topClassroom': 'أولى متوسط (أ)',
    },
  };

  static const List<Map<String, dynamic>> _mockComparison = [
    {'classroomName': 'أولى متوسط (أ)', 'averageScore': 92, 'completionRate': 100, 'topSkill': 'الجبر'},
    {'classroomName': 'ثالثة متوسط (ج)', 'averageScore': 88, 'completionRate': 95, 'topSkill': 'الهندسة'},
    {'classroomName': 'أولى متوسط (ب)', 'averageScore': 85, 'completionRate': 92, 'topSkill': 'الأعداد'},
    {'classroomName': 'ثانية متوسط (أ)', 'averageScore': 78, 'completionRate': 88, 'topSkill': 'الإحصاء'},
  ];

  static const List<Map<String, dynamic>> _mockWeaknesses = [
    {'mainSkill': 'اللغة الإنجليزية - الاستماع', 'averagePercentage': 52},
    {'mainSkill': 'الفيزياء - الديناميكا', 'averagePercentage': 58},
    {'mainSkill': 'الرياضيات - المعادلات التفاضلية', 'averagePercentage': 61},
    {'mainSkill': 'الكيمياء - التفاعلات العضوية', 'averagePercentage': 64},
    {'mainSkill': 'اللغة العربية - الإملاء', 'averagePercentage': 67},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial filters from constructor parameters
    if (widget.initialGradeLevel != null) {
      _selectedGradeLevel = widget.initialGradeLevel;
    }
    if (widget.initialSubject != null) {
      _selectedSubject = widget.initialSubject;
    }
    _loadSummary();
    _loadComparison();
    _loadWeaknesses();
    // Call _onFiltersChanged after setting initial filters to load filtered data
    if (widget.initialGradeLevel != null || widget.initialSubject != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onFiltersChanged();
      });
    }
  }

  Future<void> _loadSummary() async {
    setState(() {
      _summaryLoading = true;
      _summaryError = null;
    });
    try {
      final data = await ref.read(adminRepositoryProvider).getSchoolReport();
      setState(() {
        _summaryReport = data;
        _summaryLoading = false;
      });
    } catch (_) {
      if (_allowMockFallback) {
        setState(() {
          _summaryReport = Map<String, dynamic>.from(_mockSummary);
          _summaryLoading = false;
        });
      } else {
        setState(() {
          _summaryLoading = false;
          _summaryError = 'تعذر تحميل ملخص تقارير المدرسة.';
        });
      }
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
    } catch (_) {
      if (_allowMockFallback) {
        setState(() {
          _comparisonData = List<Map<String, dynamic>>.from(_mockComparison);
          _comparisonLoading = false;
        });
      } else {
        setState(() {
          _comparisonLoading = false;
          _comparisonError = 'تعذر تحميل مقارنة الفصول.';
        });
      }
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
    } catch (_) {
      if (_allowMockFallback) {
        setState(() {
          _weaknessData = List<Map<String, dynamic>>.from(_mockWeaknesses);
          _weaknessLoading = false;
        });
      } else {
        setState(() {
          _weaknessLoading = false;
          _weaknessError = 'تعذر تحميل مهارات الضعف.';
        });
      }
    }
  }

  void _onFiltersChanged() {
    _loadComparison();
    _loadWeaknesses();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8FF),
        appBar: _buildAppBar(context),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([_loadSummary(), _loadComparison(), _loadWeaknesses()]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              // ── Page Header ──────────────────────────────────────────────
              _buildPageHeader(),
              const SizedBox(height: 20),

              // ── KPI Bento Grid ───────────────────────────────────────────
              _summaryLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _summaryError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _summaryError!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        )
                  : _buildKpiBentoGrid(),
              const SizedBox(height: 24),

              // ── Classroom Comparison Chart ────────────────────────────────
              _buildComparisonSection(),
              const SizedBox(height: 24),

              // ── Strengths & Weaknesses ────────────────────────────────────
              _buildStrengthsWeaknessesRow(),
              const SizedBox(height: 24),

              // ── Filter Row ────────────────────────────────────────────────
              _buildFilterRow(),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3, role: 'admin'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B)),
        onPressed: () => context.pop(),
        tooltip: 'رجوع',
      ),
      title: const Text(
        'التقييم الذكي',
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E40AF),
        ),
      ),
      centerTitle: false,
      actions: [
        const AdminTopActions(),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
          onPressed: () => context.push('/teacher/notifications'),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryContainer,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تقارير المدرسة الكلية',
          style: AppTextStyles.displayMedium.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'مقارنة شاملة لأداء الفصول ومعدلات المشاركة عبر الأقسام',
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildKpiBentoGrid() {
    final summary =
        (_summaryReport?['summary'] as Map<String, dynamic>?) ?? {};
    final avg = summary['schoolAverage'] ?? summary['averageScore'] ?? 84;
    final participation = summary['participationRate'] ?? 91;
    final topClass = summary['topClassroom'] as String? ?? 'أولى متوسط (أ)';

    return Column(
      children: [
        Row(
          children: [
            // Card 1: Average score
            Expanded(
              child: _BentoCard(
                label: 'متوسط الدرجات العام',
                value: '$avg%',
                valueColor: AppColors.primary,
                trailing: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text('+1.5%',
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Participation
            Expanded(
              child: _BentoCard(
                label: 'نسبة المشاركة',
                value: '$participation%',
                valueColor: AppColors.onSurface,
                trailing: Row(
                  children: [
                    const Icon(Icons.horizontal_rule_rounded,
                        size: 14, color: AppColors.outline),
                    const SizedBox(width: 2),
                    Text('مستقر',
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 12,
                          color: AppColors.outline,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Card 3: Top classroom (full width)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDAD9E3)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الفصل المتصدر',
                      style: AppTextStyles.labelSmall),
                  const SizedBox(height: 4),
                  Text(topClass,
                      style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('بمتوسط درجات 92% ومشاركة كاملة',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
              Positioned(
                bottom: -8,
                left: -8,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD0E1FB).withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDAD9E3)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 8),
              Text('مقارنة متوسط الدرجات',
                  style: AppTextStyles.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('تصفية المقارنة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          const Text('المادة الدراسية:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ['الكل', 'الرياضيات', 'العلوم', 'اللغة العربية', 'الإنجليزية'].map((s) =>
                              ActionChip(
                                label: Text(s),
                                onPressed: () {
                                  setState(() => _selectedSubject = s == 'الكل' ? null : s);
                                  Navigator.pop(ctx);
                                  _onFiltersChanged();
                                },
                              ),
                            ).toList(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                            child: const Text('تطبيق'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.filter_list_rounded, size: 16),
                label: const Text('تصفية'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
                  textStyle: const TextStyle(
                      fontFamily: 'Almarai', fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Comparison bars
          if (_comparisonLoading)
            const Center(child: CircularProgressIndicator())
          else if (_comparisonError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _comparisonError!,
                style: const TextStyle(color: AppColors.error),
              ),
            )
          else
            ..._comparisonData.asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value;
              final name = c['classroomName'] as String? ??
                  c['name'] as String? ?? 'فصل';
              final score =
                  (c['averageScore'] as num?)?.toDouble() ?? 0.0;
              final colors = [
                AppColors.primary,
                AppColors.outline,
                AppColors.outline,
                AppColors.outline,
              ];
              final barColor = i < colors.length ? colors[i] : AppColors.outline;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: AppTextStyles.labelLarge),
                        Text(
                          '${score.round()}%',
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: barColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFE3E1EB),
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          // Footer
          const Divider(color: Color(0xFFDAD9E3)),
          Center(
            child: TextButton(
              onPressed: () {
                context.push('/admin/classrooms');
              },
              child: const Text('عرض جميع الفصول',
                  style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 12,
                      color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsWeaknessesRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strengths card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDAD9E3)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0E1FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lightbulb_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('نقاط القوة',
                          style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SkillChip(
                    label: 'الرياضيات - الجبر',
                    isStrength: true),
                const SizedBox(height: 6),
                _SkillChip(
                    label: 'العلوم - الأحياء',
                    isStrength: true),
                const SizedBox(height: 6),
                _SkillChip(
                    label: 'اللغة العربية - النحو',
                    isStrength: true),
                const SizedBox(height: 12),
                Text(
                  'أداء استثنائي في فصول المرحلة الأولى.',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Weaknesses card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFDAD6)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDAD6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warning_rounded,
                          color: Color(0xFF93000A), size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('تحتاج تدخل',
                          style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_weaknessLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_weaknessError != null)
                  Text(
                    _weaknessError!,
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  )
                else
                  ..._weaknessData.take(3).map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _SkillChip(
                          label: s['mainSkill'] as String? ?? '',
                          isStrength: false),
                    );
                  }),
                const SizedBox(height: 12),
                Text(
                  'انخفاض ملحوظ يتطلب مراجعة المنهج.',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('تصفية البيانات',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
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
        ],
      ),
    );
  }
}

// ─── Bento Card ───────────────────────────────────────────────────────────────

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.trailing,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDAD9E3)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          trailing,
        ],
      ),
    );
  }
}

// ─── Skill Chip ───────────────────────────────────────────────────────────────

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, required this.isStrength});

  final String label;
  final bool isStrength;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isStrength
            ? const Color(0xFFD0E1FB)
            : const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStrength
                ? Icons.check_circle_outline_rounded
                : Icons.arrow_downward_rounded,
            size: 14,
            color: isStrength
                ? AppColors.primary
                : const Color(0xFF93000A),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isStrength
                    ? AppColors.primary
                    : const Color(0xFF93000A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Dropdown ──────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
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
        DropdownMenuItem<String>(
          value: null,
          child: Text('الكل',
              style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        ...items.map(
          (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
