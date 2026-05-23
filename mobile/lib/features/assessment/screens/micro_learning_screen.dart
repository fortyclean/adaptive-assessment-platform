import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/student_state_view.dart';
import '../models/micro_learning_plan.dart';
import '../repositories/assessment_repository.dart';
import '../repositories/micro_learning_progress_store.dart';

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
  Set<String> _completedLessonIds = {};

  // Daily micro-lessons
  List<MicroLearningLesson> _lessons = const [
    MicroLearningLesson(
      id: 'initial-diagnostic',
      title: 'ابدأ بأول اختبار تشخيصي',
      subtitle: '3 دقائق • يفتح توصياتك الشخصية',
      icon: Icons.psychology_outlined,
      status: MicroLessonStatus.available,
      skill: 'تشخيص',
      estimatedMinutes: 3,
      mastery: 0,
    ),
    MicroLearningLesson(
      id: 'locked-review',
      title: 'التفاعلات الكيميائية',
      subtitle: '3 دقيقة • مراجعة',
      icon: Icons.science_outlined,
      status: MicroLessonStatus.locked,
      skill: 'تحليل النتائج',
      estimatedMinutes: 4,
      mastery: 0,
    ),
  ];

  // AI-recommended weak areas
  List<MicroLearningFocusArea> _weakAreas = const [
    MicroLearningFocusArea(
      title: 'قواعد اللغة',
      description: 'تحتاج لتعزيز مهاراتك هنا',
      progress: 0.33,
      color: Color(0xFFF59E0B),
      icon: Icons.trending_down_rounded,
    ),
    MicroLearningFocusArea(
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
      _completedLessonIds = _loadCompletedLessonIds();
      final history =
          await ref.read(assessmentRepositoryProvider).getAttemptHistory();
      final plan = const MicroLearningPlanSource().fromAttemptHistory(
        history,
        completedLessonIds: _completedLessonIds,
      );
      final completionProgress = plan.lessons.isEmpty
          ? 0.0
          : (_completedLessonIds.length / plan.lessons.length).clamp(0.0, 1.0);

      if (!mounted) return;
      setState(() {
        _xpPoints = plan.xpPoints;
        _dailyGoalProgress = plan.dailyGoalProgress > completionProgress
            ? plan.dailyGoalProgress
            : completionProgress;
        _streakDays = plan.streakDays;
        _weakAreas = plan.focusAreas;
        _lessons = plan.lessons;
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

  Set<String> _loadCompletedLessonIds() {
    return _progressStore.loadCompletedLessonIds(_studentId);
  }

  Future<void> _markLessonCompleted(MicroLearningLesson lesson) async {
    if (lesson.isLocked || lesson.isCompleted) return;
    final nextCompleted =
        await _progressStore.markCompleted(_studentId, lesson.id);
    if (!mounted) return;
    setState(() {
      _completedLessonIds = nextCompleted;
      _lessons = _lessons
          .map((item) => item.id == lesson.id
              ? item.copyWith(
                  status: MicroLessonStatus.completed,
                  subtitle: '${item.subtitle} - مكتمل',
                )
              : item)
          .toList();
      _dailyGoalProgress =
          (_completedLessonIds.length / _lessons.length).clamp(0.0, 1.0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ إكمال الدرس'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  MicroLearningProgressStore get _progressStore => MicroLearningProgressStore(
        Hive.box<dynamic>(AppConstants.sessionStateBoxName),
      );

  String? get _studentId => ref.read(authProvider).user?.id;

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
      body: RefreshIndicator(
        onRefresh: _loadLearningPlan,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  // Refresh button (RTL: left)
                  TextButton.icon(
                    onPressed: _isLoading ? null : _loadLearningPlan,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'تحديث',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/student');
                          }
                        },
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

                  // Actionable learning path
                  _buildLearningPathCard(),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
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
            backgroundColor: colorScheme.surfaceContainerHighest,
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

  Widget _buildLessonCard(MicroLearningLesson lesson) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: !lesson.isLocked,
      enabled: !lesson.isLocked,
      label: lesson.isLocked
          ? '${lesson.title}. درس مغلق حتى تنهي الدرس السابق.'
          : lesson.isCompleted
              ? '${lesson.title}. درس مكتمل ومحفوظ.'
              : '${lesson.title}. افتح تدريبًا قصيرًا لهذا الدرس.',
      child: Opacity(
        opacity: lesson.isLocked ? 0.62 : 1.0,
        child: InkWell(
          onTap: lesson.isLocked
              ? null
              : () => context.push('/student/assessments-list'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: lesson.isCompleted
                    ? AppColors.success
                    : colorScheme.outlineVariant,
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
                // Lock / Play icon (RTL: left)
                IconButton(
                  tooltip:
                      lesson.isCompleted ? 'درس مكتمل' : 'تعليم الدرس كمكتمل',
                  onPressed: lesson.isLocked || lesson.isCompleted
                      ? null
                      : () => _markLessonCompleted(lesson),
                  icon: Icon(
                    lesson.isLocked
                        ? Icons.lock_outline_rounded
                        : lesson.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                    color: lesson.isCompleted
                        ? AppColors.success
                        : lesson.isLocked
                            ? colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.55)
                            : AppColors.primary,
                    size: 28,
                  ),
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
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.primaryContainer
                                  .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          lesson.icon,
                          color: lesson.isLocked
                              ? colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.65)
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
        ),
      ),
    );
  }

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
            Text(
              'بناءً على ${_weakAreas.isEmpty ? 'آخر نتائجك' : _weakAreas.first.title}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    context.push('/student/micro-learning/flashcards'),
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

  Widget _buildWeakAreaCard(MicroLearningFocusArea area) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: area.progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(area.color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Featured Video ────────────────────────────────────────────────────

  Widget _buildLearningPathCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final focusArea =
        _weakAreas.isEmpty ? 'المهارة الأضعف' : _weakAreas.first.title;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, color: colorScheme.primary),
              const Spacer(),
              Text(
                'مسار تعلم مقترح',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLearningStep(
            number: '1',
            title: 'راجع $focusArea',
            subtitle: 'ابدأ بأقصر درس متاح قبل الانتقال للاختبار.',
          ),
          _buildLearningStep(
            number: '2',
            title: 'حل تدريبًا قصيرًا',
            subtitle: 'اختبار واحد كافٍ لمعرفة إن كان الفهم تحسن.',
          ),
          _buildLearningStep(
            number: '3',
            title: 'افتح التحليلات',
            subtitle: 'قارن النتيجة الجديدة مع آخر محاولة وحدد الخطوة التالية.',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/student/analytics'),
              icon: const Icon(Icons.insights_rounded),
              label: const Text('راجع تحليلاتك'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStep({
    required String number,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────
