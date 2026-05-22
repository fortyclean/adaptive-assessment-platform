import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/student_state_view.dart';
import '../repositories/assessment_repository.dart';

/// Micro-Learning Screen — Design _62
/// "التعلم المصغر الذكي" — Smart Micro-Learning
/// Short learning cards per skill weakness with progress tracking.
class MicroLearningScreen extends ConsumerStatefulWidget {
  const MicroLearningScreen({super.key});

  @override
  ConsumerState<MicroLearningScreen> createState() =>
      _MicroLearningScreenState();
}

class _MicroLearningScreenState extends ConsumerState<MicroLearningScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Daily goal progress (0.0 – 1.0)
  double _dailyGoalProgress = 0;

  // Streak days
  int _streakDays = 0;

  // XP points
  int _xpPoints = 0;

  // Daily micro-lessons
  List<_MicroLesson> _lessons = const [
    _MicroLesson(
      title: 'ابدأ بأول اختبار تشخيصي',
      subtitle: '3 دقائق • يفتح توصياتك الشخصية',
      icon: Icons.psychology_outlined,
      isLocked: false,
    ),
    _MicroLesson(
      title: 'التفاعلات الكيميائية',
      subtitle: '3 دقيقة • مراجعة',
      icon: Icons.science_outlined,
      isLocked: true,
    ),
  ];

  // AI-recommended weak areas
  List<_WeakArea> _weakAreas = const [
    _WeakArea(
      title: 'قواعد اللغة',
      description: 'تحتاج لتعزيز مهاراتك هنا',
      progress: 0.33,
      color: Color(0xFFF59E0B),
      icon: Icons.trending_down_rounded,
    ),
    _WeakArea(
      title: 'المنطق الصوري',
      description: 'أداء متميز في التطور',
      progress: 0.85,
      color: Color(0xFF10B981),
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLearningPlan();
  }

  Future<void> _loadLearningPlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();
      final completed = history
          .where((h) =>
              h['status'] == 'completed' && (h['scorePercentage'] is num))
          .toList();

      if (!mounted) return;
      setState(() {
        _xpPoints = completed.fold<int>(
          0,
          (sum, h) => sum + ((h['pointsEarned'] as num?)?.toInt() ?? 0),
        );
        _dailyGoalProgress =
            (_todayAttemptCount(completed) / 3).clamp(0.0, 1.0);
        _streakDays = _calculateStreakDays(completed);
        _weakAreas = _buildWeakAreas(completed);
        _lessons = _buildLessonsFromWeakAreas(_weakAreas, completed.isEmpty);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'تعذر تحميل خطة التعلم المصغر. تحقق من الاتصال ثم حاول مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  int _todayAttemptCount(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return history.where((attempt) {
      final date = DateTime.tryParse(
        (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
      );
      if (date == null) return false;
      return DateTime(date.year, date.month, date.day) == today;
    }).length;
  }

  int _calculateStreakDays(List<Map<String, dynamic>> history) {
    final days = history
        .map((attempt) => DateTime.tryParse(
              (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
            ))
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<_WeakArea> _buildWeakAreas(List<Map<String, dynamic>> history) {
    final skills = <String, List<double>>{};
    for (final attempt in history) {
      final breakdown = attempt['skillBreakdown'];
      if (breakdown is! List) continue;
      for (final item in breakdown) {
        if (item is! Map) continue;
        final total = (item['totalQuestions'] as num?)?.toDouble() ?? 0;
        final correct = (item['correctAnswers'] as num?)?.toDouble() ?? 0;
        final skill = (item['mainSkill'] ?? item['skill'] ?? '').toString();
        if (skill.isEmpty || total <= 0) continue;
        skills.putIfAbsent(skill, () => []).add(correct / total);
      }
    }

    if (skills.isEmpty) {
      return const [
        _WeakArea(
          title: 'اختبار تشخيصي',
          description: 'ابدأ اختباراً لفتح توصيات مبنية على أدائك',
          progress: 0,
          color: AppColors.primary,
          icon: Icons.route_outlined,
        ),
      ];
    }

    final ranked = skills.entries.map((entry) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, avg);
    }).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return ranked.take(2).map((entry) {
      final progress = entry.value.clamp(0.0, 1.0);
      return _WeakArea(
        title: entry.key,
        description: progress >= 0.75
            ? 'مهارة قوية، حافظ على مستواك'
            : 'تحتاج مراجعة قصيرة اليوم',
        progress: progress,
        color: progress >= 0.75 ? AppColors.success : AppColors.warning,
        icon: progress >= 0.75
            ? Icons.auto_awesome_rounded
            : Icons.trending_down_rounded,
      );
    }).toList();
  }

  List<_MicroLesson> _buildLessonsFromWeakAreas(
    List<_WeakArea> weakAreas,
    bool isEmptyHistory,
  ) {
    if (isEmptyHistory) {
      return const [
        _MicroLesson(
          title: 'ابدأ بأول اختبار تشخيصي',
          subtitle: '3 دقائق • يفتح توصياتك الشخصية',
          icon: Icons.psychology_outlined,
          isLocked: false,
        ),
        _MicroLesson(
          title: 'راجع نتائجك بعد الاختبار',
          subtitle: 'مغلق حتى تظهر أول نتيجة',
          icon: Icons.insights_outlined,
          isLocked: true,
        ),
      ];
    }

    return weakAreas.map((area) {
      final percent = (area.progress * 100).round();
      return _MicroLesson(
        title: 'مراجعة قصيرة: ${area.title}',
        subtitle: '4 دقائق • مستوى الإتقان $percent%',
        icon: area.icon,
        isLocked: false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'student'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: StudentStateView(
          icon: Icons.wifi_off_rounded,
          title: 'تعذر تحميل خطة التعلم',
          message: _errorMessage!,
          actionLabel: 'إعادة المحاولة',
          onAction: _loadLearningPlan,
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'student'),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Save button (RTL: left)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم حفظ التقدم'),
                          behavior: SnackBarBehavior.floating),
                    );
                  },
                  child: const Text(
                    'حفظ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Title + back (RTL: right)
                Row(
                  children: [
                    const Text(
                      'التعلم المصغر',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Content ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Section
                _buildHeroSection(),
                const SizedBox(height: 24),

                // Daily Goal Progress
                _buildDailyGoal(),
                const SizedBox(height: 24),

                // Daily Micro-lessons
                _buildDailyLessons(),
                const SizedBox(height: 24),

                // AI Recommendations Bento Grid
                _buildAIRecommendations(),
                const SizedBox(height: 24),

                // Featured Video Card
                _buildFeaturedVideo(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, role: 'student'),
    );
  }

  // ─── Hero Section ──────────────────────────────────────────────────────

  Widget _buildHeroSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // XP Badge (RTL: left)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_xpPoints XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Greeting + title (RTL: right)
              Column(
                key: ValueKey(
                  ref.watch(authProvider).user?.fullName ?? 'student',
                ),
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'أهلاً بك مجدداً، ${ref.watch(authProvider).user?.fullName.split(' ').first ?? 'طالب'}',
                    semanticsLabel:
                        ref.watch(authProvider).user?.fullName ?? 'student',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'التعلم المصغر الذكي',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak Card
          _buildStreakCard(),
        ],
      );

  Widget _buildStreakCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text (RTL: right)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'سلسلة تعلمك الحالية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'أنت في اليوم الـ '),
                        TextSpan(
                          text: '$_streakDays',
                          style: const TextStyle(
                            color: Color(0xFFEA580C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' على التوالي! حافظ على نشاطك.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Fire icon (RTL: left)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFEA580C),
                size: 32,
              ),
            ),
          ],
        ),
      );

  // ─── Daily Goal ────────────────────────────────────────────────────────

  Widget _buildDailyGoal() {
    final percent = (_dailyGoalProgress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percent% مكتمل',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'هدف اليوم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _dailyGoalProgress,
            minHeight: 12,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF10B981),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Daily Micro-lessons ───────────────────────────────────────────────

  Widget _buildDailyLessons() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'دروس اليوم السريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          ..._lessons.map(_buildLessonCard),
        ],
      );

  Widget _buildLessonCard(_MicroLesson lesson) => Opacity(
        opacity: lesson.isLocked ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
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
              // Lock / Play icon (RTL: left)
              Icon(
                lesson.isLocked
                    ? Icons.lock_outline_rounded
                    : Icons.play_circle_outline_rounded,
                color: lesson.isLocked
                    ? const Color(0xFFCBD5E1)
                    : AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              // Info (RTL: right)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            lesson.title,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.subtitle,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: lesson.isLocked
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        lesson.icon,
                        color: lesson.isLocked
                            ? const Color(0xFF94A3B8)
                            : AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // ─── AI Recommendations ────────────────────────────────────────────────

  Widget _buildAIRecommendations() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'توصيات الذكاء الاصطناعي لك',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),

          // Flashcard challenge (full width)
          _buildFlashcardChallenge(),
          const SizedBox(height: 12),

          // Weak areas grid
          Row(
            children: _weakAreas
                .map((area) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: area == _weakAreas.first ? 6 : 0,
                          left: area == _weakAreas.last ? 6 : 0,
                        ),
                        child: _buildWeakAreaCard(area),
                      ),
                    ))
                .toList(),
          ),
        ],
      );

  Widget _buildFlashcardChallenge() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryContainer.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تحدي البطاقات الخاطفة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'بناءً على أخطائك الأخيرة في الرياضيات',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جاري تحميل تحدي البطاقات الخاطفة...'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primaryContainer,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'ابدأ التحدي (10 بطاقات)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildWeakAreaCard(_WeakArea area) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
            Icon(area.icon, color: area.color, size: 24),
            const SizedBox(height: 8),
            Text(
              area.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Text(
              area.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: area.progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(area.color),
              ),
            ),
          ],
        ),
      );

  // ─── Featured Video ────────────────────────────────────────────────────

  Widget _buildFeaturedVideo() => Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryContainer.withValues(alpha: 0.6),
              AppColors.primary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Play button overlay
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // Bottom text overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'فيديو تعليمي مقترح',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'لماذا نفشل في تذكر القوانين؟',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

// ─── Data Models ────────────────────────────────────────────────────────────

class _MicroLesson {
  const _MicroLesson({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isLocked,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLocked;
}

class _WeakArea {
  const _WeakArea({
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
    required this.icon,
  });

  final String title;
  final String description;
  final double progress;
  final Color color;
  final IconData icon;
}
