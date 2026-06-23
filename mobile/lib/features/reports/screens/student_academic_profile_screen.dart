import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_section_card.dart';

/// Student Academic Profile Screen — Screen 65
/// Teacher view of a student's full academic profile:
/// identity header, academic summary bento, subject performance,
/// interaction stats, recent exam results, and teacher notes.
class StudentAcademicProfileScreen extends ConsumerStatefulWidget {
  const StudentAcademicProfileScreen({
    super.key,
    this.studentId,
    this.studentName,
  });

  final String? studentId;
  final String? studentName;

  @override
  ConsumerState<StudentAcademicProfileScreen> createState() =>
      _StudentAcademicProfileScreenState();
}

class _StudentAcademicProfileScreenState
    extends ConsumerState<StudentAcademicProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final name = widget.studentName ??
        AppLocalizations.of(context).studentAcademicFallbackName;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildIdentityHeader(name),
                const SizedBox(height: 16),
                _buildAcademicSummary(),
                const SizedBox(height: 16),
                _buildChartsRow(),
                const SizedBox(height: 16),
                _buildRecentExamResults(),
                const SizedBox(height: 16),
                _buildTeacherNotes(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2, role: 'teacher'),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Notifications + avatar (RTL: left)
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_outlined,
                      color: colorScheme.onSurfaceVariant, size: 24),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primaryContainer,
                        width: 2,
                      ),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(Icons.person,
                        size: 22, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          // Back + title (RTL: right)
          Row(
            children: [
              const Text(
                'EduAssess',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                color: colorScheme.onSurfaceVariant,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Identity Header ──────────────────────────────────────────────────────

  Widget _buildIdentityHeader(String name) {
    final colorScheme = Theme.of(context).colorScheme;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).studentAcademicId('#EDU-2024-0891'),
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            fontFamily: 'Lexend',
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTag(
                AppLocalizations.of(context).studentAcademicGrade,
                const Color(0xFFEFF6FF),
                const Color(0xFF1E40AF),
                const Color(0xFFBFDBFE)),
            _buildTag(
                AppLocalizations.of(context).studentAcademicAdvancedTrack,
                colorScheme.surfaceContainerHighest,
                colorScheme.onSurfaceVariant,
                colorScheme.outlineVariant),
          ],
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showReportDialog(name),
          icon: const Icon(Icons.description_outlined, size: 16),
          label: Text(AppLocalizations.of(context).studentAcademicReport),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showMessageSheet(name),
          icon: const Icon(Icons.mail_outline, size: 16),
          label: Text(AppLocalizations.of(context).studentAcademicContact),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );

    final avatar = _buildStudentAvatar(name);

    return AppSectionCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                avatar,
                const SizedBox(height: 16),
                info,
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: actions,
                ),
              ],
            );
          }
          return Row(
            children: [
              actions,
              const Spacer(),
              Expanded(flex: 2, child: info),
              const SizedBox(width: 20),
              avatar,
            ],
          );
        },
      ),
    );
  }

  void _showReportDialog(String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(ctx).studentAcademicReportFor(name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(ctx).studentAcademicChooseReport),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .studentAcademicExportingAcademic),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.school_outlined),
              label:
                  Text(AppLocalizations.of(ctx).studentAcademicAcademicReport),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .studentAcademicExportingPerformance),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart_outlined),
              label: Text(
                  AppLocalizations.of(ctx).studentAcademicPerformanceReport),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).close),
          ),
        ],
      ),
    );
  }

  void _showMessageSheet(String name) {
    final msgController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
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
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(ctx).studentAcademicSendMessageTo(name),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(ctx).studentAcademicMessageHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)
                        .studentAcademicMessageSent(name)),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(AppLocalizations.of(ctx).studentAcademicSend),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAvatar(String name) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.primaryContainer, width: 4),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0] : '؟',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              AppLocalizations.of(context).studentAcademicActive,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(
          String label, Color bg, Color textColor, Color borderColor) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      );

  // ─── Academic Summary Bento ───────────────────────────────────────────────

  Widget _buildAcademicSummary() {
    final cards = [
      _buildSummaryBentoCard(
        label: AppLocalizations.of(context).studentAcademicCumulativeGpa,
        value: '3.85',
        trailing: Row(
          children: [
            const Icon(Icons.trending_up, size: 14, color: Color(0xFF10B981)),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                AppLocalizations.of(context).studentAcademicPreviousMonth,
                style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      _buildSummaryBentoCard(
        label: AppLocalizations.of(context).studentAcademicAttendance,
        value: '94%',
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 0.94,
            backgroundColor: Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            minHeight: 6,
          ),
        ),
      ),
      _buildSummaryBentoCard(
        label: AppLocalizations.of(context).studentAcademicCompletedAssessments,
        value: '24/26',
        trailing: Text(
          AppLocalizations.of(context).studentAcademicAwaitingAssessments,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ),
      _buildSummaryBentoCard(
        label: AppLocalizations.of(context).studentAcademicGeneralBehavior,
        value: '',
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...List.generate(
              4,
              (_) => const Icon(Icons.star, size: 18, color: Color(0xFF1E40AF)),
            ),
            const Icon(Icons.star_border, size: 18, color: Color(0xFF1E40AF)),
          ],
        ),
        extraLabel: AppLocalizations.of(context).studentAcademicExcellent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        crossAxisCount: constraints.maxWidth < 520 ? 1 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth < 520 ? 3.0 : 1.8,
        children: cards,
      ),
    );
  }

  Widget _buildSummaryBentoCard({
    required String label,
    required String value,
    required Widget trailing,
    String? extraLabel,
  }) =>
      AppSectionCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.right,
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                ),
              ),
            trailing,
            if (extraLabel != null)
              Text(
                extraLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.right,
              ),
          ],
        ),
      );

  // ─── Charts Row ───────────────────────────────────────────────────────────

  Widget _buildChartsRow() => LayoutBuilder(
        builder: (context, constraints) {
          final interaction = AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context).studentAcademicInteractionStats,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                _buildInteractionStat(
                  percentage: 88,
                  label: AppLocalizations.of(context)
                      .studentAcademicClassParticipation,
                  sublabel: AppLocalizations.of(context)
                      .studentAcademicHighComparedPeers,
                  color: const Color(0xFF1E40AF),
                ),
                const SizedBox(height: 12),
                _buildInteractionStat(
                  percentage: 62,
                  label: AppLocalizations.of(context).studentAcademicGroupWork,
                  sublabel: AppLocalizations.of(context)
                      .studentAcademicNeedsImprovement,
                  color: const Color(0xFFFB923C),
                ),
                const SizedBox(height: 12),
                _buildInteractionStat(
                  percentage: 95,
                  label: AppLocalizations.of(context).studentAcademicHomework,
                  sublabel: AppLocalizations.of(context)
                      .studentAcademicFullCommitment,
                  color: const Color(0xFFA855F7),
                ),
              ],
            ),
          );
          final subjects = AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        AppLocalizations.of(context).studentAcademicFirstTerm,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)
                          .studentAcademicSubjectPerformance,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1B22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSubjectBar(
                    AppLocalizations.of(context).studentAcademicMath,
                    0.92,
                    const Color(0xFF1E40AF)),
                const SizedBox(height: 8),
                _buildSubjectBar(
                    AppLocalizations.of(context).studentAcademicScience,
                    0.85,
                    const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _buildSubjectBar(
                    AppLocalizations.of(context).studentAcademicArabic,
                    0.78,
                    const Color(0xFFF59E0B)),
                const SizedBox(height: 8),
                _buildSubjectBar(
                    AppLocalizations.of(context).studentAcademicHistory,
                    0.70,
                    const Color(0xFFA855F7)),
                const SizedBox(height: 8),
                _buildSubjectBar(
                    AppLocalizations.of(context).studentAcademicPhysics,
                    0.88,
                    const Color(0xFF06B6D4)),
              ],
            ),
          );

          if (constraints.maxWidth < 720) {
            return Column(
              children: [
                interaction,
                const SizedBox(height: 12),
                subjects,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: interaction),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: subjects),
            ],
          );
        },
      );

  Widget _buildInteractionStat({
    required int percentage,
    required String label,
    required String sublabel,
    required Color color,
  }) =>
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1B22),
                  ),
                  textAlign: TextAlign.right,
                ),
                Text(
                  sublabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 4,
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1B22),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildSubjectBar(String subject, double value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1B22),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      );

  // ─── Recent Exam Results ──────────────────────────────────────────────────

  Widget _buildRecentExamResults() => AppSectionCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)
                                .studentAcademicViewingAllResults),
                            behavior: SnackBarBehavior.floating),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).studentAcademicViewAll,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).studentAcademicLatestResults,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1B22),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _buildExamResultRow(
              icon: Icons.functions,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF1E40AF),
              title: AppLocalizations.of(context).studentAcademicCalculusExam,
              date:
                  AppLocalizations.of(context).studentAcademicCalculusExamDate,
              score: '98/100',
              scoreColor: const Color(0xFF1E40AF),
              badge: AppLocalizations.of(context).studentAcademicOutstanding,
              badgeBg: const Color(0xFFD1FAE5).withValues(alpha: 0.5),
              badgeColor: const Color(0xFF10B981),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _buildExamResultRow(
              icon: Icons.science_outlined,
              iconBg: const Color(0xFFF5F3FF),
              iconColor: const Color(0xFF7C3AED),
              title: AppLocalizations.of(context)
                  .studentAcademicOrganicChemistryLab,
              date:
                  AppLocalizations.of(context).studentAcademicChemistryLabDate,
              score: '85/100',
              scoreColor: const Color(0xFF1A1B22),
              badge: AppLocalizations.of(context).studentAcademicVeryGood,
              badgeBg: const Color(0xFFEFF6FF),
              badgeColor: const Color(0xFF2563EB),
            ),
          ],
        ),
      );

  Widget _buildExamResultRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String date,
    required String score,
    required Color scoreColor,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
  }) =>
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score + badge (RTL: left)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Title + date (RTL: center-right)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1B22),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Icon (RTL: right)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ],
        ),
      );

  // ─── Teacher Notes ────────────────────────────────────────────────────────

  Widget _buildTeacherNotes() => AppSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () {
                    final noteController = TextEditingController();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (ctx) => Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                            left: 16,
                            right: 16,
                            top: 20),
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
                                        borderRadius:
                                            BorderRadius.circular(2)))),
                            const SizedBox(height: 16),
                            Text(
                                AppLocalizations.of(ctx)
                                    .studentAcademicAddBehaviorNote,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: noteController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(ctx)
                                    .studentAcademicNoteHint,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                          .studentAcademicNoteAdded),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF2E7D32)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E40AF),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              child: Text(
                                  AppLocalizations.of(ctx)
                                      .studentAcademicSaveNote,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label:
                      Text(AppLocalizations.of(context).studentAcademicAddNote),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1E40AF),
                  ),
                ),
                Text(
                  AppLocalizations.of(context).studentAcademicTeacherNotes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNoteCard(
              teacherName:
                  AppLocalizations.of(context).studentAcademicTeacherSara,
              timeAgo: AppLocalizations.of(context).studentAcademicTwoDaysAgo,
              note: AppLocalizations.of(context).studentAcademicLeadershipNote,
              accentColor: const Color(0xFF1E40AF),
            ),
            const SizedBox(height: 12),
            _buildNoteCard(
              teacherName:
                  AppLocalizations.of(context).studentAcademicTeacherMohammed,
              timeAgo: AppLocalizations.of(context).studentAcademicWeekAgo,
              note: AppLocalizations.of(context).studentAcademicReviewNote,
              accentColor: const Color(0xFFFB923C),
            ),
          ],
        ),
      );

  Widget _buildNoteCard({
    required String teacherName,
    required String timeAgo,
    required String note,
    required Color accentColor,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            right: BorderSide(color: accentColor, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    teacherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1B22),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      );
}
