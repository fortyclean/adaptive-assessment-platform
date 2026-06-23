import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/download_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/admin_top_actions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../auth/repositories/admin_repository.dart';
import '../utils/school_report_export_utils.dart';

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
  bool _refreshingReports = false;
  bool _exportingReport = false;
  DateTime? _lastUpdatedAt;

  static const List<String> _gradeLevels = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  // ── Classroom Comparison (Req 19.2) ───────────────────────────────────────
  List<String> _subjectOptions(AppLocalizations l10n) => [
        l10n.subjectMathematics,
        l10n.subjectEnglish,
        l10n.subjectArabic,
        l10n.subjectPhysics,
        l10n.subjectChemistry,
        l10n.subjectBiology,
      ];

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

  Map<String, dynamic> _mockSummary(AppLocalizations l10n) => {
        'summary': {
          'totalStudents': 342,
          'totalTeachers': 18,
          'schoolAverage': 84,
          'participationRate': 91,
          'topClassroom': l10n.schoolReportDemoClassOne,
        },
      };

  List<Map<String, dynamic>> _mockComparison(AppLocalizations l10n) => [
        {
          'classroomName': l10n.schoolReportDemoClassOne,
          'averageScore': 92,
          'completionRate': 100,
          'topSkill': l10n.skillAlgebra
        },
        {
          'classroomName': l10n.schoolReportDemoClassTwo,
          'averageScore': 88,
          'completionRate': 95,
          'topSkill': l10n.skillGeometry
        },
        {
          'classroomName': l10n.schoolReportDemoClassThree,
          'averageScore': 85,
          'completionRate': 92,
          'topSkill': l10n.skillNumbers
        },
        {
          'classroomName': l10n.schoolReportDemoClassFour,
          'averageScore': 78,
          'completionRate': 88,
          'topSkill': l10n.skillStatistics
        },
      ];

  List<Map<String, dynamic>> _mockWeaknesses(AppLocalizations l10n) => [
        {
          'mainSkill': l10n.schoolReportWeaknessEnglishListening,
          'averagePercentage': 52
        },
        {
          'mainSkill': l10n.schoolReportWeaknessPhysicsDynamics,
          'averagePercentage': 58
        },
        {
          'mainSkill': l10n.schoolReportWeaknessMathEquations,
          'averagePercentage': 61
        },
        {
          'mainSkill': l10n.schoolReportWeaknessChemistryReactions,
          'averagePercentage': 64
        },
        {
          'mainSkill': l10n.schoolReportWeaknessArabicSpelling,
          'averagePercentage': 67
        },
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
        _lastUpdatedAt ??= DateTime.now();
      });
    } catch (_) {
      if (_allowMockFallback) {
        setState(() {
          _summaryReport = Map<String, dynamic>.from(
              _mockSummary(AppLocalizations.of(context)));
          _summaryLoading = false;
          _lastUpdatedAt ??= DateTime.now();
        });
      } else {
        setState(() {
          _summaryLoading = false;
          _summaryError =
              AppLocalizations.of(context).schoolReportSummaryLoadFailed;
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
      final data =
          await ref.read(adminRepositoryProvider).getClassroomComparison(
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
          _comparisonData = List<Map<String, dynamic>>.from(
              _mockComparison(AppLocalizations.of(context)));
          _comparisonLoading = false;
        });
      } else {
        setState(() {
          _comparisonLoading = false;
          _comparisonError =
              AppLocalizations.of(context).schoolReportComparisonLoadFailed;
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
          _weaknessData = List<Map<String, dynamic>>.from(
              _mockWeaknesses(AppLocalizations.of(context)));
          _weaknessLoading = false;
        });
      } else {
        setState(() {
          _weaknessLoading = false;
          _weaknessError =
              AppLocalizations.of(context).schoolReportWeaknessLoadFailed;
        });
      }
    }
  }

  void _onFiltersChanged() {
    _loadComparison();
    _loadWeaknesses();
  }

  Future<void> _refreshReports({bool showMessage = false}) async {
    setState(() => _refreshingReports = true);
    await Future.wait([_loadSummary(), _loadComparison(), _loadWeaknesses()]);
    if (!mounted) return;
    setState(() {
      _refreshingReports = false;
      _lastUpdatedAt = DateTime.now();
    });
    if (showMessage) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.schoolReportsUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showExportOptions() async {
    if (_exportingReport) return;
    final l10n = AppLocalizations.of(context);
    final format = await showModalBottomSheet<SchoolReportExportFormat>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.exportReport,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                _filterSummaryText(),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.data_object_rounded,
                    color: AppColors.primary),
                title: const Text('JSON'),
                subtitle: Text(l10n.schoolReportJsonExportSubtitle),
                onTap: () => Navigator.pop(ctx, SchoolReportExportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined,
                    color: AppColors.success),
                title: const Text('CSV'),
                subtitle: Text(l10n.schoolReportCsvExportSubtitle),
                onTap: () => Navigator.pop(ctx, SchoolReportExportFormat.csv),
              ),
            ],
          ),
        ),
      ),
    );
    if (format == null) return;
    await _exportSchoolReport(format);
  }

  Future<void> _exportSchoolReport(SchoolReportExportFormat format) async {
    if (_exportingReport) return;

    setState(() => _exportingReport = true);
    try {
      final report = await ref.read(adminRepositoryProvider).exportSchoolReport(
            subject: _selectedSubject,
            gradeLevel: _selectedGradeLevel,
          );
      if (!SchoolReportExportUtils.hasExportableData(report)) {
        throw const FormatException('School report has no exportable data');
      }
      if (!mounted) return;
      await DownloadHelper.shareTextAsFile(
        content: SchoolReportExportUtils.buildContent(
          report: report,
          format: format,
          filterSummary: _filterSummaryText(),
          labels: _schoolReportExportLabels(context),
        ),
        fileName: SchoolReportExportUtils.buildFileName(
          timestamp: DateTime.now(),
          format: format,
        ),
        context: context,
        subject: 'EduAssess school report (${format.name.toUpperCase()})',
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.schoolReportExportFailure,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _exportingReport = false);
    }
  }

  SchoolReportExportLabels _schoolReportExportLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SchoolReportExportLabels(
      section: l10n.schoolReportExportSection,
      metric: l10n.schoolReportExportMetric,
      value: l10n.schoolReportExportValue,
      report: l10n.schoolReportExportReport,
      generatedAt: l10n.schoolReportExportGeneratedAt,
      filterScope: l10n.schoolReportExportFilterScope,
      summary: l10n.schoolReportExportSummary,
      classroomComparison: l10n.schoolReportExportClassroomComparison,
      weakSkills: l10n.schoolReportExportWeakSkills,
      comparisonValueBuilder: l10n.schoolReportExportComparisonValue,
    );
  }

  String _filterSummaryText() {
    final l10n = AppLocalizations.of(context);
    final subject = _selectedSubject ?? l10n.allSubjects;
    final grade = _selectedGradeLevel == null
        ? l10n.allGradeLevels
        : l10n.gradeLevelValue(_selectedGradeLevel!);
    return l10n.currentScope(subject, grade);
  }

  String _formatLastUpdated() {
    final l10n = AppLocalizations.of(context);
    final value = _lastUpdatedAt;
    if (value == null) return l10n.schoolReportNotUpdatedYet;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return l10n.schoolReportLastUpdated(
      value.year,
      value.month,
      value.day,
      hour,
      minute,
    );
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: _refreshReports,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                // ── Page Header ──────────────────────────────────────────────
                _buildPageHeader(),
                const SizedBox(height: 20),

                // ── KPI Bento Grid ───────────────────────────────────────────
                if (_summaryLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  _summaryError != null
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
          bottomNavigationBar:
              const AppBottomNav(currentIndex: 3, role: 'admin'),
        ),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(color: colorScheme.outlineVariant),
      ),
      leading: context.canPop()
          ? IconButton(
              icon: Icon(
                Icons.arrow_forward_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => context.pop(),
              tooltip: l10n.back,
            )
          : null,
      title: Text(
        l10n.smartAssessment,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: isCompact ? 16 : 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: false,
      actions: [
        const AdminTopActions(),
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => context.push(AppRoutes.notificationCenter),
        ),
        if (!isCompact) ...[
          const SizedBox(width: 4),
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPageHeader() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.schoolReportsOverviewTitle,
                style: AppTextStyles.displayMedium
                    .copyWith(color: AppColors.onSurface),
              ),
            ),
            IconButton.filledTonal(
              onPressed: _refreshingReports
                  ? null
                  : () => _refreshReports(showMessage: true),
              icon: _refreshingReports
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
              tooltip: l10n.refreshReports,
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: _exportingReport ? null : _showExportOptions,
              icon: _exportingReport
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
              tooltip: l10n.exportReport,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.schoolReportsOverviewSubtitle,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.filter_list_rounded, size: 16),
              label: Text(_filterSummaryText()),
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            ),
            Chip(
              avatar: const Icon(Icons.update_rounded, size: 16),
              label: Text(_formatLastUpdated()),
              backgroundColor: AppColors.surfaceContainer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiBentoGrid() {
    final l10n = AppLocalizations.of(context);
    final summary = (_summaryReport?['summary'] as Map<String, dynamic>?) ?? {};
    final avg = summary['schoolAverage'] ?? summary['averageScore'] ?? 84;
    final participation = summary['participationRate'] ?? 91;
    final topClass =
        summary['topClassroom'] as String? ?? l10n.schoolReportDemoClassOne;
    final averageCard = _BentoCard(
      label: l10n.overallAverageScore,
      value: '$avg%',
      valueColor: AppColors.primary,
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 14, color: AppColors.primary),
          SizedBox(width: 2),
          Text('+1.5%',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
    final participationCard = _BentoCard(
      label: l10n.participationRate,
      value: '$participation%',
      valueColor: AppColors.onSurface,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.horizontal_rule_rounded,
              size: 14, color: AppColors.outline),
          const SizedBox(width: 2),
          Text(l10n.stableStatus,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                color: AppColors.outline,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              return Column(
                children: [
                  averageCard,
                  const SizedBox(height: 12),
                  participationCard,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: averageCard),
                const SizedBox(width: 12),
                Expanded(child: participationCard),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        // Card 3: Top classroom (full width)
        SizedBox(
          width: double.infinity,
          child: AppSectionCard(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.topClassroom, style: AppTextStyles.labelSmall),
                    const SizedBox(height: 4),
                    Text(topClass,
                        style: AppTextStyles.titleLarge
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(l10n.topClassroomSummary,
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
                          const Color(0xFFD0E1FB).withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSection() {
    final l10n = AppLocalizations.of(context);
    final quickSubjects = [
      null,
      l10n.subjectMathematics,
      l10n.subjectScience,
      l10n.subjectArabic,
      l10n.subjectEnglish,
    ];
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, constraints) {
              final filterButton = TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.filterComparison,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          Text(l10n.subjectLabel,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: quickSubjects
                                .map(
                                  (s) => ActionChip(
                                    label: Text(s ?? l10n.filterAll),
                                    onPressed: () {
                                      setState(() => _selectedSubject = s);
                                      Navigator.pop(ctx);
                                      _onFiltersChanged();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white),
                            child: Text(l10n.apply),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.filter_list_rounded, size: 16),
                label: Text(constraints.maxWidth < 360 ? '' : l10n.filter),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
                  textStyle:
                      const TextStyle(fontFamily: 'Almarai', fontSize: 12),
                ),
              );

              return Row(
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
                  Expanded(
                    child: Text(
                      l10n.averageScoreComparison,
                      style: AppTextStyles.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  filterButton,
                ],
              );
            },
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
                  c['name'] as String? ??
                  l10n.classroomFallback;
              final score = (c['averageScore'] as num?)?.toDouble() ?? 0.0;
              final colors = [
                AppColors.primary,
                AppColors.outline,
                AppColors.outline,
                AppColors.outline,
              ];
              final barColor =
                  i < colors.length ? colors[i] : AppColors.outline;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: AppTextStyles.labelLarge),
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
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          // Footer
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          Center(
            child: TextButton(
              onPressed: () {
                context.push(AppRoutes.adminClassrooms);
              },
              child: Text(l10n.viewAllClassrooms,
                  style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strengths card
        Expanded(
          child: AppSectionCard(
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
                      child: Text(l10n.strengthPoints,
                          style:
                              AppTextStyles.titleMedium.copyWith(fontSize: 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SkillChip(
                    label: l10n.schoolReportStrengthMathAlgebra,
                    isStrength: true),
                const SizedBox(height: 6),
                _SkillChip(
                    label: l10n.schoolReportStrengthScienceBiology,
                    isStrength: true),
                const SizedBox(height: 6),
                _SkillChip(
                    label: l10n.schoolReportStrengthArabicGrammar,
                    isStrength: true),
                const SizedBox(height: 12),
                Text(
                  l10n.schoolReportStrengthSummary,
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
          child: AppSectionCard(
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
                      child: Text(l10n.needsIntervention,
                          style:
                              AppTextStyles.titleMedium.copyWith(fontSize: 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_weaknessLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_weaknessError != null)
                  Text(
                    _weaknessError!,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 12),
                  )
                else
                  ..._weaknessData.take(3).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _SkillChip(
                            label: s['mainSkill'] as String? ?? '',
                            isStrength: false),
                      )),
                const SizedBox(height: 12),
                Text(
                  l10n.schoolReportWeaknessSummary,
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
    final l10n = AppLocalizations.of(context);
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(l10n.filterData,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final subjectDropdown = _FilterDropdown(
                hint: l10n.subject,
                value: _selectedSubject,
                items: _subjectOptions(l10n),
                allLabel: l10n.filterAll,
                onChanged: (v) {
                  setState(() => _selectedSubject = v);
                  _onFiltersChanged();
                },
              );
              final gradeDropdown = _FilterDropdown(
                hint: l10n.gradeLevel,
                value: _selectedGradeLevel,
                items: _gradeLevels,
                allLabel: l10n.filterAll,
                onChanged: (v) {
                  setState(() => _selectedGradeLevel = v);
                  _onFiltersChanged();
                },
              );
              final clearButton =
                  (_selectedSubject != null || _selectedGradeLevel != null)
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          tooltip: l10n.clearFilters,
                          onPressed: () {
                            setState(() {
                              _selectedSubject = null;
                              _selectedGradeLevel = null;
                            });
                            _onFiltersChanged();
                          },
                        )
                      : null;

              if (constraints.maxWidth < 440) {
                return Column(
                  children: [
                    subjectDropdown,
                    const SizedBox(height: 8),
                    gradeDropdown,
                    if (clearButton != null)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: clearButton,
                      ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: subjectDropdown),
                  const SizedBox(width: 8),
                  Expanded(child: gradeDropdown),
                  if (clearButton != null) ...[
                    const SizedBox(width: 4),
                    clearButton,
                  ],
                ],
              );
            },
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
  Widget build(BuildContext context) => AppSectionCard(
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

// ─── Skill Chip ───────────────────────────────────────────────────────────────

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, required this.isStrength});

  final String label;
  final bool isStrength;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isStrength ? const Color(0xFFD0E1FB) : const Color(0xFFFFDAD6),
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
              color: isStrength ? AppColors.primary : const Color(0xFF93000A),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color:
                      isStrength ? AppColors.primary : const Color(0xFF93000A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

// ─── Filter Dropdown ──────────────────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.allLabel,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final String allLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final distinctItems = <String>{...items}.toList(growable: false);
    final selectedValue = distinctItems.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          child: Text(allLabel,
              style: const TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        ...distinctItems.map(
          (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
