import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
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
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.school, color: Color(0xFF1E40AF), size: 24),
          const SizedBox(width: 8),
          const Text(
            'EduAssess',
            style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      actions: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF1E40AF),
          child: const Icon(Icons.person, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPageIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'UI Feedback Components',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1B22)),
        ),
        SizedBox(height: 4),
        Text(
          'Review the adaptive design of alerts and modals within the mastery environment.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSuccessAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
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
              decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Data Imported Successfully',
                    style: TextStyle(color: Color(0xFF166534), fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "32 new adaptive questions have been added to the 'Advanced Biology' bank.",
                    style: TextStyle(color: Color(0xFF166534), fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showSuccessAlert = false),
              child: const Icon(Icons.close, color: Color(0xFF166534), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
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
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Failed to Save Question',
                    style: TextStyle(color: AppColors.error, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Network connection interrupted. Your progress on 'Item #402' was not synchronized.",
                    style: TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showErrorAlert = false),
              child: const Icon(Icons.close, color: Color(0xFF991B1B), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteModal() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black38,
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC4C5D5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20)],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_outlined, color: AppColors.error, size: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'Deleting an Exam',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'This action is irreversible. All student progress data and associated analytics for the "Mid-Term Physics" exam will be permanently removed.',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Permanently Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => _showDeleteModal = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    side: const BorderSide(color: Color(0xFFC4C5D5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel Action'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBento() {
    return Column(
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
              const Text(
                'CURRENT SYNC STATUS',
                style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('98.4%', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                  Icon(Icons.cloud_done_outlined, color: Colors.white, size: 32),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.984,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC4C5D5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.history_outlined, color: AppColors.primary, size: 24),
                    SizedBox(height: 8),
                    Text('3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Pending Alerts', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC4C5D5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.security_outlined, color: Color(0xFF872D00), size: 24),
                    SizedBox(height: 8),
                    Text('Secure', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Access Logged', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home', false),
          _navItem(Icons.quiz_outlined, 'Tests', false),
          _navItem(Icons.bar_chart_outlined, 'Reports', false),
          _navItem(Icons.settings, 'Settings', true),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xFF1E40AF) : Colors.grey, size: 24),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: active ? const Color(0xFF1E40AF) : Colors.grey)),
      ],
    );
  }
}
