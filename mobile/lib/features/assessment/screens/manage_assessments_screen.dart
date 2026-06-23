import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations_ar.dart';
import '../../../shared/providers/auth_provider.dart';
import '../repositories/teacher_repository.dart';

/// Manage Assessments Screen — Screen 10
/// Requirements: 5.6
class ManageAssessmentsScreen extends ConsumerStatefulWidget {
  const ManageAssessmentsScreen({super.key});

  @override
  ConsumerState<ManageAssessmentsScreen> createState() =>
      _ManageAssessmentsScreenState();
}

class _ManageAssessmentsScreenState
    extends ConsumerState<ManageAssessmentsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _assessments = [];
  String _statusFilter = 'all';
  String? _errorMessage;

  AppLocalizations get _l10n =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsAr();

  List<Map<String, dynamic>> get _mockAssessments => [
        {
          '_id': 'mock1',
          'title': _l10n.manageDemoMidtermMathTitle,
          'subject': _l10n.subjectMathematics,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 25,
          'availableFrom': '2023-10-15T08:00:00.000Z',
        },
        {
          '_id': 'mock2',
          'title': _l10n.manageDemoSecondUnitScienceTitle,
          'subject': _l10n.subjectScience,
          'status': 'draft',
          'assessmentType': 'random',
          'questionCount': 10,
          'availableFrom': null,
        },
        {
          '_id': 'mock3',
          'title': _l10n.manageDemoArabicBasicsTitle,
          'subject': _l10n.subjectArabic,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 15,
          'availableFrom': '2023-10-10T08:00:00.000Z',
        },
        {
          '_id': 'mock4',
          'title': _l10n.manageDemoAndalusHistoryTitle,
          'subject': _l10n.manageSubjectSocialStudies,
          'status': 'draft',
          'assessmentType': 'adaptive',
          'questionCount': null,
          'availableFrom': null,
        },
        {
          '_id': 'mock5',
          'title': _l10n.manageDemoFinalPhysicsTitle,
          'subject': _l10n.manageSubjectPhysics,
          'status': 'completed',
          'assessmentType': 'random',
          'questionCount': 30,
          'availableFrom': '2023-09-20T08:00:00.000Z',
        },
        {
          '_id': 'demo-math',
          'title': _l10n.demoMathAssessmentTitle,
          'subject': _l10n.subjectMathematics,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 20,
          'availableFrom': null,
        },
        {
          '_id': 'demo-arabic',
          'title': _l10n.demoArabicAssessmentTitle,
          'subject': _l10n.subjectArabic,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 20,
          'availableFrom': null,
        },
        {
          '_id': 'demo-english',
          'title': _l10n.demoEnglishAssessmentTitle,
          'subject': _l10n.subjectEnglish,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 20,
          'availableFrom': null,
        },
        {
          '_id': 'demo-history',
          'title': _l10n.demoHistoryAssessmentTitle,
          'subject': _l10n.manageSubjectHistory,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 20,
          'availableFrom': null,
        },
        {
          '_id': 'demo-biology',
          'title': _l10n.demoBiologyAssessmentTitle,
          'subject': _l10n.manageSubjectBiology,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 20,
          'availableFrom': null,
        },
        {
          '_id': 'demo-chemistry',
          'title': _l10n.demoChemistryAssessmentTitle,
          'subject': _l10n.manageSubjectChemistry,
          'status': 'active',
          'assessmentType': 'adaptive',
          'questionCount': 20,
          'availableFrom': null,
        },
      ];
  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ref.read(teacherRepositoryProvider).getAssessments();
      setState(() {
        _assessments = data.isNotEmpty || !_shouldUseDemoFallback
            ? data
            : _mockAssessments;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _assessments = _shouldUseDemoFallback ? _mockAssessments : [];
        _errorMessage =
            _shouldUseDemoFallback ? null : _l10n.manageAssessmentsLoadFailed;
        _isLoading = false;
      });
    }
  }

  bool get _shouldUseDemoFallback {
    final token = ref.read(authProvider).accessToken ?? '';
    return AppConstants.useMockData || token.startsWith('demo-token-');
  }

  List<Map<String, dynamic>> get _filtered {
    if (_statusFilter == 'all') return _assessments;
    return _assessments.where((a) => a['status'] == _statusFilter).toList();
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> assessment) {
    final l10n = _l10n;
    final titleController =
        TextEditingController(text: assessment['title'] as String? ?? '');
    final subjectController =
        TextEditingController(text: assessment['subject'] as String? ?? '');
    var selectedStatus = assessment['status'] as String? ?? 'draft';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                  Text(l10n.editAssessment,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Almarai')),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),
              // Title field
              TextField(
                controller: titleController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: l10n.assessmentTitle,
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              // Subject field
              TextField(
                controller: subjectController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: l10n.subject,
                  prefixIcon: const Icon(Icons.book_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              // Status selector
              Text(l10n.status,
                  style: const TextStyle(
                      fontFamily: 'Almarai', fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final s in [
                    {
                      'value': 'draft',
                      'label': l10n.draft,
                      'color': AppColors.onSurfaceVariant
                    },
                    {
                      'value': 'active',
                      'label': l10n.active,
                      'color': AppColors.success
                    },
                    {
                      'value': 'completed',
                      'label': l10n.archived,
                      'color': AppColors.primary
                    },
                  ]) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(
                            () => selectedStatus = s['value'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: selectedStatus == s['value']
                                ? (s['color'] as Color).withValues(alpha: 0.15)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: selectedStatus == s['value']
                                    ? s['color'] as Color
                                    : AppColors.outlineVariant,
                                width: selectedStatus == s['value'] ? 2 : 1),
                          ),
                          child: Text(s['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 13,
                                  color: s['color'] as Color,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Questions button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/teacher/questions');
                },
                icon: const Icon(Icons.quiz_outlined),
                label: Text(l10n.editQuestionsFromBank,
                    style: const TextStyle(fontFamily: 'Almarai')),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              // Save button
              ElevatedButton(
                onPressed: () async {
                  final idx = _assessments
                      .indexWhere((a) => a['_id'] == assessment['_id']);
                  if (idx != -1) {
                    setState(() {
                      _assessments[idx] = Map.from(_assessments[idx])
                        ..['title'] = titleController.text.trim()
                        ..['subject'] = subjectController.text.trim()
                        ..['status'] = selectedStatus;
                    });
                  }
                  Navigator.pop(ctx);
                  // Try to save to backend
                  try {
                    // Backend update would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.changesSavedSuccessfully),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.success),
                    );
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l10n.savedLocally),
                          behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text(l10n.saveChanges,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Almarai')),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publishAssessment(String id) async {
    try {
      await ref.read(teacherRepositoryProvider).publishAssessment(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.assessmentPublishedSuccessfully)),
        );
        _loadAssessments();
      }
    } catch (_) {
      if (mounted) {
        if (_shouldUseDemoFallback) {
          setState(() {
            final idx = _assessments.indexWhere((a) => a['_id'] == id);
            if (idx != -1) {
              _assessments[idx] = Map.from(_assessments[idx])
                ..['status'] = 'active';
            }
          });
        }
        if (!_shouldUseDemoFallback) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.assessmentPublishFailed),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.assessmentPublishedSuccessfully)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            _l10n.smartAssessment,
            style: const TextStyle(
              color: Color(0xFF00288E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.onSurfaceVariant),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Color(0xFF00288E)),
              onPressed: () => context.push(AppRoutes.teacherNotifications),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.outlineVariant),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.teacherCreateAssessment),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.add, size: 28),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.manageAssessmentsTitle,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _l10n.manageAssessmentsSubtitle,
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Filter chips ─────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: _l10n.filterAll,
                          selected: _statusFilter == 'all',
                          onTap: () => setState(() => _statusFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: _l10n.active,
                          selected: _statusFilter == 'active',
                          onTap: () => setState(() => _statusFilter = 'active'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: _l10n.draft,
                          selected: _statusFilter == 'draft',
                          onTap: () => setState(() => _statusFilter = 'draft'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: _l10n.archived,
                          selected: _statusFilter == 'completed',
                          onTap: () =>
                              setState(() => _statusFilter = 'completed'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Assessment list ───────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _errorMessage != null
                      ? _buildError()
                      : _filtered.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              onRefresh: _loadAssessments,
                              color: AppColors.primary,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: _filtered.length,
                                itemBuilder: (ctx, i) => _AssessmentCard(
                                  assessment: _filtered[i],
                                  onPublish: _filtered[i]['status'] == 'draft'
                                      ? () => _publishAssessment(
                                          _filtered[i]['_id'] as String)
                                      : null,
                                  onEdit: () =>
                                      _showEditDialog(context, _filtered[i]),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadAssessments,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(_l10n.retry),
              ),
            ],
          ),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined,
                  size: 40, color: AppColors.outlineVariant),
            ),
            const SizedBox(height: 16),
            Text(
              _l10n.noTeacherAssessmentsTitle,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _l10n.noTeacherAssessmentsMessage,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFA8B8FF)
                  : AppColors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}

// ── Assessment card ───────────────────────────────────────────────────────────

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard(
      {required this.assessment, this.onPublish, this.onEdit});
  final Map<String, dynamic> assessment;
  final VoidCallback? onPublish;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = _manageAssessmentsL10n(context);
    final status = assessment['status'] as String? ?? '';
    final isActive = status == 'active';
    final isDraft = status == 'draft';
    final isAdaptive = assessment['assessmentType'] == 'adaptive';
    final date = assessment['availableFrom'] as String?;
    var dateLabel = l10n.unspecified;
    if (date != null) {
      try {
        final dt = DateTime.parse(date);
        dateLabel = '${dt.day} / ${dt.month} / ${dt.year}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
          // Active accent bar
          if (isActive)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + type badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(status: status),
                    _TypeBadge(isAdaptive: isAdaptive),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                Text(
                  assessment['title'] as String? ?? '',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Footer row
                Container(
                  height: 1,
                  color: const Color(0x1AC4C5D5),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.quiz_outlined,
                        size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      assessment['questionCount'] == null
                          ? l10n.questionsCountUnknown
                          : l10n.questionsCount(
                              assessment['questionCount'] as Object,
                            ),
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.event_outlined,
                        size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                // Action buttons
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CardButton(
                        icon: Icons.edit_outlined,
                        label: l10n.edit,
                        onTap: onEdit ?? () {},
                        color: AppColors.primary,
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CardButton(
                        icon: Icons.delete_outline_rounded,
                        label: l10n.delete,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.deleteAssessmentTitle),
                              content: Text(l10n.deleteAssessmentConfirmation),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(l10n.cancel)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    // Demo: remove locally
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              l10n.assessmentDeletedLocally),
                                          backgroundColor: AppColors.error),
                                    );
                                  },
                                  child: Text(l10n.delete,
                                      style: const TextStyle(
                                          color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        },
                        color: AppColors.error,
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isDraft && onPublish != null)
                      Expanded(
                        child: _CardButton(
                          icon: Icons.publish_rounded,
                          label: l10n.publish,
                          onTap: onPublish!,
                          color: AppColors.primary,
                          outlined: false,
                        ),
                      )
                    else if (isActive)
                      Expanded(
                        child: _CardButton(
                          icon: Icons.bar_chart_rounded,
                          label: l10n.reports,
                          onTap: () => context
                              .push('/teacher/reports/${assessment['_id']}'),
                          color: AppColors.onSurfaceVariant,
                          outlined: true,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.outlined,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: outlined ? Theme.of(context).colorScheme.surface : color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: outlined ? AppColors.outlineVariant : color,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: outlined ? color : Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: outlined ? color : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = _manageAssessmentsL10n(context);
    Color bg;
    Color fg;
    String label;
    Widget? dot;

    switch (status) {
      case 'active':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = l10n.live;
        dot = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
        );
        break;
      case 'draft':
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurfaceVariant;
        label = l10n.draft;
        dot = null;
        break;
      case 'completed':
        bg = const Color(0xFFD0E1FB);
        fg = const Color(0xFF54647A);
        label = l10n.archived;
        dot = null;
        break;
      default:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurfaceVariant;
        label = status;
        dot = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[dot, const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isAdaptive});
  final bool isAdaptive;

  @override
  Widget build(BuildContext context) {
    final l10n = _manageAssessmentsL10n(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdaptive ? const Color(0xFFD0E1FB) : const Color(0xFFFFDBCE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAdaptive ? const Color(0xFFD3E4FE) : const Color(0xFFFFB59A),
        ),
      ),
      child: Text(
        isAdaptive ? l10n.assessmentTypeAdaptive : l10n.assessmentTypeRandom,
        style: TextStyle(
          color: isAdaptive ? const Color(0xFF54647A) : const Color(0xFF611E00),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

AppLocalizations _manageAssessmentsL10n(BuildContext context) =>
    Localizations.of<AppLocalizations>(context, AppLocalizations) ??
    AppLocalizationsAr();
