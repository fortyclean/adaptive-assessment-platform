import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../repositories/assessment_repository.dart';

/// Student Assessments List Screen — Design _40
/// Shows available, upcoming, and past assessments with tabs.
/// Matches the HTML design pixel-perfectly with RTL layout.
class StudentAssessmentsScreen extends ConsumerStatefulWidget {
  const StudentAssessmentsScreen({super.key});

  @override
  ConsumerState<StudentAssessmentsScreen> createState() =>
      _StudentAssessmentsScreenState();
}

class _StudentAssessmentsScreenState
    extends ConsumerState<StudentAssessmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _available = [];
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _past = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final assessments =
          await ref.read(assessmentRepositoryProvider).getAssessments();
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();

      final now = DateTime.now();
      final available = <Map<String, dynamic>>[];
      final upcoming = <Map<String, dynamic>>[];

      for (final a in assessments) {
        if (a['status'] != 'active') continue;
        final from = a['availableFrom'] != null
            ? DateTime.tryParse(a['availableFrom'] as String)
            : null;
        if (from != null && now.isBefore(from)) {
          upcoming.add(a);
        } else {
          available.add(a);
        }
      }

      if (mounted) {
        setState(() {
          _available = available;
          _upcoming = upcoming;
          _past = history.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        if (!AppConstants.useMockData) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'تعذر تحميل الاختبارات. تحقق من الاتصال ثم أعد المحاولة.';
          });
          return;
        }
        setState(() {
          _available = [
            {'_id': 'demo-math', 'title': 'اختبار الرياضيات التجريبي', 'subject': 'الرياضيات', 'questionCount': 20, 'timeLimitMinutes': 45, 'status': 'active'},
            {'_id': 'demo-arabic', 'title': 'اختبار اللغة العربية التجريبي', 'subject': 'اللغة العربية', 'questionCount': 20, 'timeLimitMinutes': 30, 'status': 'active'},
            {'_id': 'demo-english', 'title': 'اختبار اللغة الإنجليزية التجريبي', 'subject': 'الإنجليزية', 'questionCount': 20, 'timeLimitMinutes': 30, 'status': 'active'},
            {'_id': 'demo-biology', 'title': 'اختبار الأحياء التجريبي', 'subject': 'الأحياء', 'questionCount': 20, 'timeLimitMinutes': 35, 'status': 'active'},
            {'_id': 'demo-history', 'title': 'اختبار التاريخ التجريبي', 'subject': 'التاريخ', 'questionCount': 20, 'timeLimitMinutes': 40, 'status': 'active'},
            {'_id': 'demo-chemistry', 'title': 'اختبار الكيمياء التجريبي', 'subject': 'الكيمياء', 'questionCount': 20, 'timeLimitMinutes': 40, 'status': 'active'},
          ];
          _past = [
            {
              '_id': 'demo-attempt-1',
              'assessmentId': {'title': 'اختبار الرياضيات الدوري', 'subject': 'رياضيات'},
              'scorePercentage': 85.0,
              'status': 'completed',
              'submittedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            },
            {
              '_id': 'demo-attempt-2',
              'assessmentId': {'title': 'اختبار قواعد اللغة العربية', 'subject': 'لغة عربية'},
              'scorePercentage': 72.0,
              'status': 'completed',
              'submittedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            },
            {
              '_id': 'demo-attempt-3',
              'assessmentId': {'title': 'اختبار الأحياء', 'subject': 'أحياء'},
              'scorePercentage': 91.0,
              'status': 'completed',
              'submittedAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
            },
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName?.split(' ').first ?? 'أحمد';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 1,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Notifications icon (RTL: left side)
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.onSurfaceVariant,
                  onPressed: () => context.push('/student/notifications'),
                ),
                // App title + avatar (RTL: right side)
                Row(
                  children: [
                    Text(
                      'التقييم الذكي',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainer,
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          firstName.isNotEmpty ? firstName[0] : 'أ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Content ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Greeting section
                _buildGreeting(firstName),
                const SizedBox(height: 24),

                // Tabs navigation
                _buildTabsNavigation(),
                const SizedBox(height: 24),

                // Tab content
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  _buildErrorState()
                else
                  _buildTabContent(),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const AppBottomNav(currentIndex: 1, role: 'student'),
    );
  }

  // ─── Greeting Section ────────────────────────────────────────────────────

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'مرحباً بك، $name',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Text(
          'لديك ${_available.length} ${_available.length == 1 ? 'اختبار متاح' : 'اختبارات متاحة'} اليوم للبدء بها.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // ─── Tabs Navigation ─────────────────────────────────────────────────────

  Widget _buildTabsNavigation() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'الاختبارات المتاحة',
              isActive: _tabController.index == 0,
              onTap: () => setState(() => _tabController.index = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'القادمة',
              isActive: _tabController.index == 1,
              onTap: () => setState(() => _tabController.index = 1),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'النتائج السابقة',
              isActive: _tabController.index == 2,
              onTap: () => setState(() => _tabController.index = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ─── Tab Content ─────────────────────────────────────────────────────────

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0:
        return _buildAvailableTab();
      case 1:
        return _buildUpcomingTab();
      case 2:
        return _buildPastTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvailableTab() {
    if (_available.isEmpty) {
      return _buildEmptyState(
        icon: Icons.quiz_outlined,
        title: 'لا توجد اختبارات متاحة',
        subtitle: 'ستظهر الاختبارات المتاحة هنا عند نشرها من قِبل المعلم',
      );
    }

    return Column(
      children: [
        ..._available.map(_buildAvailableCard),
        const SizedBox(height: 16),
        _buildFeaturedBanner(),
        const SizedBox(height: 24),
        if (_past.isNotEmpty) _buildPastResultsPreview(),
      ],
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcoming.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event_outlined,
        title: 'لا توجد اختبارات قادمة',
        subtitle: 'ستظهر الاختبارات المجدولة مستقبلاً هنا',
      );
    }
    return Column(
      children: _upcoming.map(_buildUpcomingCard).toList(),
    );
  }

  Widget _buildPastTab() {
    if (_past.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'لا توجد نتائج سابقة',
        subtitle: 'ستظهر نتائج اختباراتك المكتملة هنا',
      );
    }
    return Column(
      children: _past.map(_buildPastCard).toList(),
    );
  }

  // ─── Available Assessment Card ───────────────────────────────────────────

  Widget _buildAvailableCard(Map<String, dynamic> assessment) {
    final title = assessment['title'] as String? ?? 'اختبار';
    final questionCount = assessment['questionCount'] as int? ?? 0;
    final timeLimitMinutes = assessment['timeLimitMinutes'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status badge + icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'لم يبدأ بعد',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1B22),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            // Meta info
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$questionCount سؤال',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.list_alt,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Text(
                  '$timeLimitMinutes دقيقة',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(
                  '/student/assessments/${assessment['_id']}/start',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'ابدأ الآن',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Featured Banner ─────────────────────────────────────────────────────

  Widget _buildFeaturedBanner() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primaryContainer,
                      AppColors.primaryContainer.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text(
                  'المراجعة النهائية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 4),
                Text(
                  'استعد لاختبارات نهاية العام مع نماذجنا الذكية',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Past Results Preview ────────────────────────────────────────────────

  Widget _buildPastResultsPreview() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() => _tabController.index = 2),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(
              'النتائج الأخيرة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._past.take(2).map(_buildPastCard),
      ],
    );
  }

  // ─── Upcoming Assessment Card ────────────────────────────────────────────

  Widget _buildUpcomingCard(Map<String, dynamic> assessment) {
    final title = assessment['title'] as String? ?? 'اختبار';
    final from = assessment['availableFrom'] != null
        ? DateTime.tryParse(assessment['availableFrom'] as String)
        : null;
    final daysUntil =
        from != null ? from.difference(DateTime.now()).inDays : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$daysUntil',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1B22),
                  ),
                ),
                Text(
                  'يوم',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1B22),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Past Assessment Card ────────────────────────────────────────────────

  Widget _buildPastCard(Map<String, dynamic> attempt) {
    final assessment = attempt['assessmentId'] as Map<String, dynamic>?;
    final title = assessment?['title'] as String? ?? 'اختبار';
    final score =
        (attempt['scorePercentage'] as num?)?.toDouble() ?? 0.0;
    final submittedAt = attempt['submittedAt'] != null
        ? DateTime.tryParse(attempt['submittedAt'] as String)
        : null;
    final dateStr = submittedAt != null
        ? 'تم الانتهاء: ${submittedAt.day} ${_getMonthName(submittedAt.month)}'
        : '';
    final scoreColor =
        score >= 70 ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () =>
                context.push('/student/results/${attempt['_id']}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'مراجعة',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1B22),
                  ),
                  textAlign: TextAlign.right,
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scoreColor, width: 4),
            ),
            child: Center(
              child: Text(
                '${score.round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1B22),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 42),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'حدث خطأ غير متوقع',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper Methods ──────────────────────────────────────────────────────

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return months[month - 1];
  }
}
