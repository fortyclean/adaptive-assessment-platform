import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Student Subjects Screen — Design _39
/// Shows a searchable, filterable grid of enrolled subjects with progress.
class StudentSubjectsScreen extends ConsumerStatefulWidget {
  const StudentSubjectsScreen({super.key});

  @override
  ConsumerState<StudentSubjectsScreen> createState() =>
      _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends ConsumerState<StudentSubjectsScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['all', 'firstTerm', 'science', 'literary'];

  // Subject data - in production this would come from the API.
  List<Map<String, dynamic>> get _subjects => [
        {
          'title': AppLocalizations.of(context).studentSubjectAdvancedMath,
          'teacher': AppLocalizations.of(context).studentSubjectTeacherMohammed,
          'progress': 0.75,
          'categoryCode': 'academic',
          'icon': Icons.functions_rounded,
          'iconBg': const Color(0xFFEFF6FF),
          'iconColor': const Color(0xFF1E40AF),
        },
        {
          'title': AppLocalizations.of(context).studentSubjectMolecularBiology,
          'teacher': AppLocalizations.of(context).studentSubjectTeacherSarah,
          'progress': 0.42,
          'categoryCode': 'practical',
          'icon': Icons.biotech_rounded,
          'iconBg': const Color(0xFFFFF7ED),
          'iconColor': const Color(0xFF611E00),
        },
        {
          'title': AppLocalizations.of(context).studentSubjectArabicLiterature,
          'teacher': AppLocalizations.of(context).studentSubjectTeacherIbrahim,
          'progress': 0.90,
          'categoryCode': 'literary',
          'icon': Icons.history_edu_rounded,
          'iconBg': const Color(0xFFEFF6FF),
          'iconColor': const Color(0xFF38485D),
        },
        {
          'title': AppLocalizations.of(context).studentSubjectQuantumPhysics,
          'teacher': AppLocalizations.of(context).studentSubjectTeacherKhaled,
          'progress': 0.15,
          'categoryCode': 'science',
          'icon': Icons.rocket_launch_rounded,
          'iconBg': const Color(0xFFEFF6FF),
          'iconColor': const Color(0xFF1E3A8A),
        },
        {
          'title': AppLocalizations.of(context).studentSubjectOrganicChemistry,
          'teacher': AppLocalizations.of(context).studentSubjectTeacherLaila,
          'progress': 0.60,
          'categoryCode': 'science',
          'icon': Icons.science_rounded,
          'iconBg': const Color(0xFFF0FDF4),
          'iconColor': const Color(0xFF047857),
        },
        {
          'title': AppLocalizations.of(context).studentSubjectEnglishLanguage,
          'teacher': AppLocalizations.of(context).studentSubjectTeacherNoura,
          'progress': 0.55,
          'categoryCode': 'academic',
          'icon': Icons.translate_rounded,
          'iconBg': const Color(0xFFFFF7ED),
          'iconColor': const Color(0xFFD97706),
        },
      ];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSubjects => _subjects.where((s) {
        final matchesSearch = _searchQuery.isEmpty ||
            (s['title'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (s['teacher'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        final matchesFilter =
            _selectedFilter == 'all' || s['categoryCode'] == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();

  String _filterLabel(AppLocalizations l10n, String filter) => switch (filter) {
        'firstTerm' => l10n.filterFirstTerm,
        'science' => l10n.filterScience,
        'literary' => l10n.filterLiterary,
        _ => l10n.filterAll,
      };

  String _categoryLabel(AppLocalizations l10n, String categoryCode) =>
      switch (categoryCode) {
        'science' => l10n.filterScience,
        'literary' => l10n.filterLiterary,
        'practical' => l10n.filterPractical,
        _ => l10n.filterAcademic,
      };

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final l10n = AppLocalizations.of(context);
    final firstName =
        user?.fullName.split(' ').first ?? l10n.studentFallbackName;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ─── App Bar ────────────────────────────────────────────────
            _buildAppBar(user),

            // ─── Content ────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                // Welcome
                                _buildWelcome(firstName),
                                const SizedBox(height: 16),

                                // Search bar
                                _buildSearchBar(),
                                const SizedBox(height: 12),

                                // Filter chips
                                _buildFilterChips(),
                                const SizedBox(height: 20),

                                // Subjects grid
                                _buildSubjectsGrid(),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, role: 'student'),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(AuthUser? user) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom:
                BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Notification icon (RTL: left)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.onSurfaceVariant,
              onPressed: () => context.push('/student/notifications'),
            ),
            // App name + avatar (RTL: right)
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).smartAssessment,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                UserAvatar(
                  user: user,
                  size: 40,
                  borderColor: Theme.of(context).colorScheme.outlineVariant,
                ),
              ],
            ),
          ],
        ),
      );

  // ─── Welcome ─────────────────────────────────────────────────────────────

  Widget _buildWelcome(String firstName) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.welcomeName(firstName),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.registeredSubjectsCount(_subjects.length),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ─── Search Bar ──────────────────────────────────────────────────────────

  Widget _buildSearchBar() => TextField(
        controller: _searchController,
        textDirection: Directionality.of(context),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchSubjectHint,
          hintTextDirection: Directionality.of(context),
          prefixIcon: const Icon(Icons.search_rounded),
          prefixIconColor: AppColors.outline,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00288E), width: 2),
          ),
        ),
      );

  // ─── Filter Chips ────────────────────────────────────────────────────────

  Widget _buildFilterChips() => SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          reverse: Directionality.of(context) == TextDirection.rtl,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final filter = _filters[i];
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filterLabel(AppLocalizations.of(context), filter),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      );

  // ─── Subjects Grid ───────────────────────────────────────────────────────

  Widget _buildSubjectsGrid() {
    final l10n = AppLocalizations.of(context);
    final filtered = _filteredSubjects;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 48, color: AppColors.outline),
              const SizedBox(height: 12),
              Text(
                l10n.noMatchingSubjects,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Banner card spans full width at the end
    final regularSubjects =
        filtered.where((s) => s['title'] != '__banner__').toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: regularSubjects.length,
          itemBuilder: (context, i) => _buildSubjectCard(regularSubjects[i]),
        ),
        const SizedBox(height: 12),
        // Promotional banner
        _buildPromoBanner(),
      ],
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final l10n = AppLocalizations.of(context);
    final progress = subject['progress'] as double;
    final progressPercent = (progress * 100).round();

    return GestureDetector(
      onTap: () => context.push('/student/assessments-list'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Icon + category badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge (RTL: left)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _categoryLabel(
                      l10n,
                      subject['categoryCode'] as String? ?? 'academic',
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                // Subject icon (RTL: right)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: subject['iconBg'] as Color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    subject['icon'] as IconData,
                    color: subject['iconColor'] as Color,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              subject['title'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Teacher name
            Text(
              subject['teacher'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
            const Spacer(),
            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  l10n.progressAchieved,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F0FA),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative overlay
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 120,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.finalExamsPrepTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.finalExamsPrepSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.90),
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () => context.push('/student/assessments-list'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.startNow,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
