import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

/// ExtendedOnboardingScreen — Screens 51–54
/// A 4-slide onboarding flow with:
///   Slide 1 (Screen 51): Welcome to Smart Education
///   Slide 2 (Screen 53): Smart Adaptive Assessments
///   Slide 3 (Screen 52): Deep Analytics
///   Slide 4 (Screen 54): Role Selection
/// RTL Arabic layout matching _51/_52/_53/_54/code.html designs.
class ExtendedOnboardingScreen extends StatefulWidget {
  const ExtendedOnboardingScreen({super.key});

  @override
  State<ExtendedOnboardingScreen> createState() =>
      _ExtendedOnboardingScreenState();
}

class _ExtendedOnboardingScreenState extends State<ExtendedOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedRole; // 'teacher' or 'student' — used on slide 4

  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final box = Hive.box<dynamic>(AppConstants.sessionStateBoxName);
    await box.put(AppConstants.onboardingSeenKey, true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  bool get _isLastPage => _currentPage == _totalPages - 1;
  bool get _canProceedLastPage => !_isLastPage || _selectedRole != null;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Header ───────────────────────────────────────────────
              _buildHeader(),

              // ─── Page View ────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildSlide1(),
                    _buildSlide2(),
                    _buildSlide3(),
                    _buildSlide4(),
                  ],
                ),
              ),

              // ─── Footer ───────────────────────────────────────────────
              _buildFooter(),
            ],
          ),
        ),
      );

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip button (RTL: left)
            if (!_isLastPage)
              TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'تخطي',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              const SizedBox(width: 60),
            // Logo (RTL: right)
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                SizedBox(width: 6),
                Text(
                  'EduAssess',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // ─── Footer ──────────────────────────────────────────────────────────────

  Widget _buildFooter() => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          children: [
            // Step indicators
            _buildStepIndicators(),
            const SizedBox(height: 24),
            // Action button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceedLastPage ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceedLastPage
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  foregroundColor: _canProceedLastPage
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                  disabledBackgroundColor: AppColors.outlineVariant,
                  disabledForegroundColor: AppColors.onSurfaceVariant,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLastPage ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_back, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Step label
            Text(
              'الخطوة ${_currentPage + 1} من $_totalPages',
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.outline,
              ),
            ),
            if (_isLastPage && _selectedRole == null) ...[
              const SizedBox(height: 4),
              const Text(
                'يرجى اختيار أحد الأدوار للمتابعة',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 12,
                  color: AppColors.outline,
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildStepIndicators() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          final isActive = index == _currentPage;
          final isPast = index < _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 32 : 8,
            height: 6,
            decoration: BoxDecoration(
              color: isActive || isPast
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      );

  // ─── Slide 1: Welcome (Screen 51) ────────────────────────────────────────

  Widget _buildSlide1() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryContainer.withValues(alpha: 0.15),
                        AppColors.surface,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title
            const Text(
              'مرحباً بك في مستقبل التعليم الذكي',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'اكتشف تجربة تعليمية مخصصة تعتمد على الذكاء الاصطناعي لتحقيق أفضل النتائج الدراسية.',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  // ─── Slide 2: Smart Assessments (Screen 53) ──────────────────────────────

  Widget _buildSlide2() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration with floating badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.primaryContainer.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        size: 80,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ),
                // Floating badge
                Positioned(
                  bottom: -12,
                  left: -12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.quiz_rounded,
                          color: AppColors.primaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 48,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 0.67,
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Title
            const Text(
              'تقييمات ذكية ومخصصة',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'خوارزميات متطورة تصمم اختبارات تناسب مستوى كل طالب وتحدد نقاط القوة والضعف بدقة.',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  // ─── Slide 3: Deep Analytics (Screen 52) ─────────────────────────────────

  Widget _buildSlide3() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bento-style analytics illustration
            SizedBox(
              width: 320,
              height: 200,
              child: Column(
                children: [
                  // Top wide card
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'متوسط الأداء الأكاديمي',
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '84%',
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Mini bar chart
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [0.40, 0.65, 0.55, 0.85, 0.70]
                                .map((h) => Container(
                                      width: 12,
                                      height: 40 * h,
                                      margin: const EdgeInsets.only(right: 3),
                                      decoration: BoxDecoration(
                                        color: h == 0.85
                                            ? AppColors.primaryContainer
                                            : const Color(0xFFD3E4FE),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(3),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom two cards
                  Expanded(
                    child: Row(
                      children: [
                        // Mastery ring
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.outlineVariant),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: 0.75,
                                        strokeWidth: 5,
                                        backgroundColor:
                                            AppColors.surfaceContainerHigh,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryContainer,
                                        ),
                                      ),
                                      Text(
                                        '75%',
                                        style: TextStyle(
                                          fontFamily: 'Almarai',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'الإتقان',
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Growth card
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  AppColors.primaryContainer,
                                  AppColors.primary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'نمو الطلاب',
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Title
            const Text(
              'تقارير تحليلية عميقة',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'حول بيانات الطلاب إلى رؤى واضحة تساعدك على اتخاذ قرارات تعليمية أفضل وتتبع التطور لحظة بلحظة.',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  // ─── Slide 4: Role Selection (Screen 54) ─────────────────────────────────

  Widget _buildSlide4() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header text
            const Text(
              'لنبدأ رحلتك التعليمية',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'اختر دورك للبدء في تخصيص تجربتك',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Hero image placeholder
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: const Center(
                child: Icon(
                  Icons.groups_rounded,
                  size: 64,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Role cards
            _buildRoleCard(
              role: 'teacher',
              icon: Icons.school_rounded,
              iconBgColor: AppColors.primaryContainer,
              title: 'أنا معلم',
              subtitle: 'إنشاء الاختبارات وإدارة الفصول',
            ),
            const SizedBox(height: 12),
            _buildRoleCard(
              role: 'student',
              icon: Icons.person_search_rounded,
              iconBgColor: const Color(0xFF872D00),
              title: 'أنا طالب',
              subtitle: 'خوض الاختبارات ومتابعة التقدم',
            ),
            const SizedBox(height: 16),
          ],
        ),
      );

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD0E1FB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
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
            // Radio indicator (RTL: left)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const Spacer(),
            // Text (RTL: right)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
