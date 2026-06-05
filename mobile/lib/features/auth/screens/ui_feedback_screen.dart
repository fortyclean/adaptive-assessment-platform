import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_section_card.dart';

/// Screen 73 — UI Feedback Components (Alerts, Modals, Status)
/// Matches design: _73/code.html
class UiFeedbackScreen extends StatefulWidget {
  const UiFeedbackScreen({super.key});

  @override
  State<UiFeedbackScreen> createState() => _UiFeedbackScreenState();
}

class _UiFeedbackScreenState extends State<UiFeedbackScreen> {
  bool _showSuccessAlert = true;
  bool _showErrorAlert = true;
  bool _showDeleteModal = true;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageIntro(),
              const SizedBox(height: 20),
              if (_showSuccessAlert) _buildSuccessAlert(),
              const SizedBox(height: 16),
              if (_showErrorAlert) _buildErrorAlert(),
              const SizedBox(height: 16),
              if (_showDeleteModal) _buildDeleteModal(),
              const SizedBox(height: 16),
              _buildStatusBento(),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      );

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          Icon(Icons.school, color: Color(0xFF1E40AF), size: 24),
          SizedBox(width: 8),
          Text(
            'EduAssess',
            style: TextStyle(
                color: Color(0xFF1E40AF),
                fontWeight: FontWeight.w700,
                fontSize: 18),
          ),
        ],
      ),
      actions: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFF1E40AF),
          child: Icon(Icons.person, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => context.push('/notifications'),
        ),
      ],
    );
  }

  Widget _buildPageIntro() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.uiFeedbackTitle,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.uiFeedbackSubtitle,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSuccessAlert() => AppSectionCard(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Color(0xFF16A34A), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.uiFeedbackSuccessTitle,
                      style: const TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.uiFeedbackSuccessMessage,
                      style: const TextStyle(
                          color: Color(0xFF166534), fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showSuccessAlert = false),
                child:
                    const Icon(Icons.close, color: Color(0xFF166534), size: 18),
              ),
            ],
          ),
        ),
      );

  Widget _buildErrorAlert() => AppSectionCard(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.uiFeedbackErrorTitle,
                      style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.uiFeedbackErrorMessage,
                      style: const TextStyle(
                          color: Color(0xFF991B1B), fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showErrorAlert = false),
                child:
                    const Icon(Icons.close, color: Color(0xFF991B1B), size: 18),
              ),
            ],
          ),
        ),
      );

  Widget _buildDeleteModal() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.scrim.withValues(alpha: 0.45),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: AppSectionCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_outlined,
                    color: AppColors.error, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.uiFeedbackDeleteTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.uiFeedbackDeleteMessage,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _showDeleteModal = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(l10n.uiFeedbackDeleteConfirm,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => _showDeleteModal = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBento() => Column(
        children: [
          // Sync status — full width
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.uiFeedbackSyncStatus,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('98.4%',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    Icon(Icons.cloud_done_outlined,
                        color: Colors.white, size: 32),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.984,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppSectionCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.history_outlined,
                          color: AppColors.primary, size: 24),
                      const SizedBox(height: 8),
                      const Text('3',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(l10n.uiFeedbackPendingAlerts,
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppSectionCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security_outlined,
                          color: Color(0xFF872D00), size: 24),
                      const SizedBox(height: 8),
                      Text(l10n.uiFeedbackSafeStatus,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(l10n.uiFeedbackAccessLogged,
                          style: const TextStyle(
                              color: AppColors.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildBottomNav() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, l10n.navHome, false),
          _navItem(Icons.quiz_outlined, l10n.navAssessments, false),
          _navItem(Icons.bar_chart_outlined, l10n.navReports, false),
          _navItem(Icons.settings, l10n.navSettings, true),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        active ? const Color(0xFF1E40AF) : colorScheme.onSurfaceVariant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}
