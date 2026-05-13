import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

/// OnboardingScreen — Screens 44–48
/// Displays 3 slides introducing the platform's key features.
/// Shown only on first launch; navigates to Login on completion.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.psychology_rounded,
      iconColor: AppColors.primary,
      iconBackgroundColor: Color(0xFFDDE1FF),
      gradientStart: Color(0xFF00288E),
      gradientEnd: Color(0xFF1E40AF),
      accentColor: Color(0xFFDDE1FF),
      title: 'التقييم التكيفي',
      subtitle: 'اختبارات تتكيف مع مستواك',
      description:
          'يتكيف نظام التقييم الذكي مع مستوى أدائك الفعلي، فيختار أسئلة تناسب قدراتك تماماً — لا سهلة جداً ولا صعبة جداً — لتحصل على تقييم دقيق يعكس فهمك الحقيقي.',
    ),
    _OnboardingSlide(
      icon: Icons.analytics_rounded,
      iconColor: Color(0xFF047857),
      iconBackgroundColor: Color(0xFFD1FAE5),
      gradientStart: Color(0xFF047857),
      gradientEnd: Color(0xFF065F46),
      accentColor: Color(0xFFD1FAE5),
      title: 'تحليلات متقدمة',
      subtitle: 'افهم نقاط قوتك وضعفك',
      description:
          'احصل على تقارير بيانية تفصيلية تُظهر أداءك في كل مهارة، وتُصنّف نقاط قوتك وضعفك بوضوح، حتى تعرف بالضبط على ماذا تركز في مراجعتك.',
    ),
    _OnboardingSlide(
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFFD97706),
      iconBackgroundColor: Color(0xFFFEF3C7),
      gradientStart: Color(0xFFD97706),
      gradientEnd: Color(0xFFB45309),
      accentColor: Color(0xFFFEF3C7),
      title: 'نقاط وإنجازات',
      subtitle: 'تعلّم وتحفّز في آنٍ واحد',
      description:
          'اكسب نقاطاً مقابل كل اختبار تُكمله، وحقق شارات الإنجاز عند تميّزك. تابع تقدمك وتنافس مع نفسك لتحقيق مستويات أعلى من الإتقان.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _fadeController.reverse().then((_) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _fadeController.forward();
      });
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

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ─── Animated gradient background ──────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  slide.gradientStart.withValues(alpha: 0.08),
                  AppColors.surface,
                ],
              ),
            ),
          ),

          // ─── Decorative circles ────────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.gradientStart.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.gradientStart.withValues(alpha: 0.05),
              ),
            ),
          ),

          // ─── Main content ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isLastPage)
                        TextButton(
                          onPressed: _skipOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            'تخطي',
                            style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _fadeController.forward(from: 0);
                    },
                    itemBuilder: (context, index) => FadeTransition(
                      opacity: _fadeAnimation,
                      child: _OnboardingSlideWidget(slide: _slides[index]),
                    ),
                  ),
                ),

                // Page indicator dots
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? slide.gradientStart
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                slide.gradientStart,
                                slide.gradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    slide.gradientStart.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastPage ? 'ابدأ الآن' : 'التالي',
                                  style: const TextStyle(
                                    fontFamily: 'Almarai',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLastPage
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_back_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide Data Model ─────────────────────────────────────────────────────────

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color gradientStart;
  final Color gradientEnd;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String description;
}

// ─── Slide Widget ─────────────────────────────────────────────────────────────

class _OnboardingSlideWidget extends StatelessWidget {
  const _OnboardingSlideWidget({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── Illustration ───────────────────────────────────────────────
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.accentColor.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: slide.accentColor.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            slide.gradientStart,
                            slide.gradientEnd,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: slide.gradientStart.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        slide.icon,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // ─── Title ──────────────────────────────────────────────────────
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: slide.gradientStart,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 10),

            // ─── Subtitle ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: slide.accentColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: slide.gradientStart,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Description ────────────────────────────────────────────────
            Text(
              slide.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
                height: 1.75,
              ),
            ),
          ],
        ),
      );
}
