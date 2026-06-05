import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_section_card.dart';

/// Screen 72 - Technical Support & Help.
/// Matches design: _72/code.html
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection =
        l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildContactSupport(),
              const SizedBox(height: 24),
              _buildTutorials(),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor:
            Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/admin');
                }
              },
            ),
            Text(
              l10n.smartAssessment,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: const [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE8E7F0),
            child: Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 12),
        ],
      );

  Widget _buildHero() => Column(
        children: [
          Text(
            l10n.supportCenterTitle,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supportCenterSubtitle,
            style: const TextStyle(color: AppColors.outline, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildSearchBar() => TextField(
        controller: _searchController,
        textDirection:
            l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        decoration: InputDecoration(
          hintText: l10n.supportSearchHint,
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.outline),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.42),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );

  Widget _buildCategories() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.supportMainSections,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showInfoDialog(
              title: l10n.supportGeneralDialogTitle,
              heading: l10n.supportGeneralDialogHeading,
              items: [
                l10n.supportGeneralFaqStart,
                l10n.supportGeneralFaqCreateAssessment,
                l10n.supportGeneralFaqAddStudents,
                l10n.supportGeneralFaqReports,
              ],
              footer: l10n.supportGeneralDialogFooter,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.supportGeneralCategory,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.supportGeneralCategorySubtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.help_center_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  Icons.settings_outlined,
                  l10n.supportTechnicalCategory,
                  l10n.supportTechnicalCategorySubtitle,
                  const Color(0xFFD0E1FB),
                  const Color(0xFF54647A),
                  onTap: () => _showInfoDialog(
                    title: l10n.supportTechnicalDialogTitle,
                    heading: l10n.supportTechnicalDialogHeading,
                    items: [
                      l10n.supportTechnicalIssueLogin,
                      l10n.supportTechnicalIssueSlowPages,
                      l10n.supportTechnicalIssueSaveError,
                      l10n.supportTechnicalIssueUpload,
                    ],
                    footer: l10n.supportTechnicalDialogFooter,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryCard(
                  Icons.payments_outlined,
                  l10n.supportBillingCategory,
                  l10n.supportBillingCategorySubtitle,
                  const Color(0xFFFFDBCE),
                  const Color(0xFF802A00),
                  onTap: () => _showInfoDialog(
                    title: l10n.supportBillingDialogTitle,
                    heading: l10n.supportBillingDialogHeading,
                    items: [
                      l10n.supportBillingCurrentPlan,
                      l10n.supportBillingExpiry,
                      l10n.supportBillingUsers,
                    ],
                    footer: l10n.supportBillingDialogFooter,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildCategoryCard(
    IconData icon,
    String title,
    String subtitle,
    Color iconBg,
    Color iconColor, {
    VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AppSectionCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.outline, fontSize: 11),
              ),
            ],
          ),
        ),
      );

  Widget _buildContactSupport() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD0E1FB).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD0E1FB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.support_agent_outlined,
                  color: Color(0xFF1E40AF),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.supportContactTitle,
                        style: const TextStyle(
                          color: Color(0xFF1E40AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.supportContactSubtitle,
                        style: const TextStyle(
                          color: Color(0xFF54647A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showLiveSupportDialog,
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: Text(l10n.supportStartLiveChat),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showSupportTicketSheet,
                icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                label: Text(l10n.supportOpenTicket),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildTutorials() {
    final tutorials = [
      _Tutorial(
        title: l10n.supportTutorialFirstAssessment,
        duration: l10n.supportTutorialFirstDuration,
        icon: Icons.play_circle_outline,
      ),
      _Tutorial(
        title: l10n.supportTutorialReports,
        duration: l10n.supportTutorialReportsDuration,
        icon: Icons.article_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.supportTutorialsTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: _showAllTutorialsDialog,
              child: Text(
                l10n.viewAll,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...tutorials.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _showTutorialDialog(t),
              child: AppSectionCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E7F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.duration,
                            style: const TextStyle(
                              color: AppColors.outline,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(t.icon, color: AppColors.primary, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog({
    required String title,
    required String heading,
    required List<String> items,
    required String footer,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection:
            l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => Text(l10n.supportBulletItem(item))),
              const SizedBox(height: 12),
              Text(
                footer,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.supportLiveDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.support_agent_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.supportTeamAvailable,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.supportDirectContact,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showSupportTicketSheet() {
    final msgController = TextEditingController();
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
              l10n.supportOpenTicket,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgController,
              maxLines: 4,
              textDirection: l10n.localeName == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              decoration: InputDecoration(
                hintText: l10n.supportTicketHint,
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
                    content: Text(l10n.supportTicketSent),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.supportSubmitTicket,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(msgController.dispose);
  }

  void _showAllTutorialsDialog() {
    _showInfoDialog(
      title: l10n.supportAllTutorialsTitle,
      heading: l10n.supportAvailableTutorials,
      items: [
        l10n.supportTutorialFirstAssessment,
        l10n.supportTutorialReports,
        l10n.supportTutorialClassrooms,
        l10n.supportTutorialQuestionBank,
        l10n.supportTutorialAdaptiveAssessment,
      ],
      footer: l10n.supportMoreTutorialsSoon,
    );
  }

  void _showTutorialDialog(_Tutorial tutorial) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection:
            l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(tutorial.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E7F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tutorial.duration,
                style: const TextStyle(color: AppColors.outline, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.supportTutorialDialogMessage,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.supportTutorialDialogFooter,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() => Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, l10n.navHome, false),
            _navItem(Icons.assignment_outlined, l10n.navAssessments, false),
            _navItem(Icons.folder_open, l10n.navResources, true),
            _navItem(Icons.analytics_outlined, l10n.navReports, false),
          ],
        ),
      );

  Widget _navItem(IconData icon, String label, bool active) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? AppColors.primary : AppColors.outline,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? AppColors.primary : AppColors.outline,
            ),
          ),
        ],
      );
}

class _Tutorial {
  const _Tutorial({
    required this.title,
    required this.duration,
    required this.icon,
  });

  final String title;
  final String duration;
  final IconData icon;
}
