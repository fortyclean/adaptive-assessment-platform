import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/student_state_view.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../repositories/assessment_repository.dart';

/// Student Progress Screen — Design _38
/// Shows streak, motivational card, weekly growth chart, earned badges,
/// and a leaderboard snippet.
class StudentProgressScreen extends ConsumerStatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  ConsumerState<StudentProgressScreen> createState() =>
      _StudentProgressScreenState();
}

class _StudentProgressScreenState extends ConsumerState<StudentProgressScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPoints = 0;
  int _attemptCount = 0;
  int _streakDays = 0;
  double _masteryPercent = 0;
  List<Map<String, dynamic>> _leaderboard = [];
  // Weekly performance data (0.0–1.0 per day)
  List<double> _weeklyData = const [0, 0, 0, 0, 0, 0, 0];
  final List<String> _weekDays = [
    'أحد',
    'اثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
    'سبت',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
      final points = history.fold<int>(
          0, (sum, h) => sum + ((h['pointsEarned'] as num?)?.toInt() ?? 0));
      final scores = completed
          .map((h) => (h['scorePercentage'] as num).toDouble())
          .toList();
      final avg =
          scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
      final leaderboard = completed.isEmpty
          ? <Map<String, dynamic>>[]
          : await _loadLeaderboardFallback(points);

      if (mounted) {
        setState(() {
          _totalPoints = points;
          _attemptCount = completed.length;
          _masteryPercent = avg;
          _weeklyData = _buildWeeklyData(completed);
          _streakDays = _calculateStreakDays(completed);
          _isLoading = false;
          _leaderboard = leaderboard;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'تعذر تحميل تقدمك الآن. تحقق من الاتصال ثم أعد المحاولة.';
          _leaderboard = [];
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadLeaderboardFallback(
    int currentPoints,
  ) async {
    try {
      final data = await ref
          .read(assessmentRepositoryProvider)
          .getStudentLeaderboard(limit: 10);
      final rawItems = (data['leaderboard'] as List?) ?? const [];
      final items = rawItems.whereType<Map>().map((item) {
        final isCurrentUser = item['isCurrentUser'] == true;
        return {
          'name': (item['fullName'] ?? '').toString().trim().isEmpty
              ? (isCurrentUser ? 'أنت' : 'طالب')
              : item['fullName'].toString(),
          'points': (item['totalPoints'] as num?)?.toInt() ?? 0,
          'rank': (item['rank'] as num?)?.toInt(),
          'isMe': isCurrentUser,
        };
      }).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Keep the screen usable when the deployed backend does not yet expose
      // the leaderboard endpoint.
    }

    return [
      {
        'name': 'أنت',
        'points': currentPoints,
        'rank': null,
        'isMe': true,
      },
    ];
  }

  List<double> _buildWeeklyData(List<Map<String, dynamic>> history) {
    final buckets = List.generate(7, (_) => <double>[]);
    final now = DateTime.now();

    for (final attempt in history) {
      final score = (attempt['scorePercentage'] as num?)?.toDouble();
      final submittedAt = DateTime.tryParse(
        (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
      );
      if (score == null || submittedAt == null) continue;
      final diff = now.difference(submittedAt).inDays;
      if (diff < 0 || diff > 6) continue;
      buckets[6 - diff].add((score / 100).clamp(0.0, 1.0));
    }

    return buckets
        .map((items) =>
            items.isEmpty ? 0.0 : items.reduce((a, b) => a + b) / items.length)
        .toList();
  }

  int _calculateStreakDays(List<Map<String, dynamic>> history) {
    final days = history
        .map((attempt) => DateTime.tryParse(
              (attempt['submittedAt'] ?? attempt['createdAt'] ?? '').toString(),
            ))
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();
    if (days.isEmpty) return 0;

    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final firstName = user?.fullName.split(' ').first ?? 'طالب';
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 2, role: 'student'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: StudentStateView(
          icon: Icons.wifi_off_rounded,
          title: 'تعذر تحميل التقدم',
          message: _errorMessage!,
          actionLabel: 'إعادة المحاولة',
          onAction: _loadData,
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 2, role: 'student'),
      );
    }

    // Show empty state when no data loaded and not loading
    if (_attemptCount == 0) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: StudentStateView(
          icon: Icons.emoji_events_outlined,
          title: 'مرحباً $firstName',
          message:
              'لا توجد بيانات تقدم بعد. أكمل أول اختبار لبدء تتبع النقاط والإتقان والأوسمة.',
          actionLabel: 'استعرض الاختبارات المتاحة',
          onAction: () => context.push('/student/assessments-list'),
        ),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 2, role: 'student'),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ──────────────────────────────────────────────────
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
                  // Notification icon (RTL: left)
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () => context.push('/student/notifications'),
                  ),
                  // App name + avatar (RTL: right)
                  Row(
                    children: [
                      const Text(
                        'التقييم الذكي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      UserAvatar(
                        user: user,
                        size: 40,
                        borderColor: cs.primary,
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
                  // Welcome + streak
                  _buildWelcomeStreak(firstName),
                  const SizedBox(height: 16),

                  // Motivational card
                  _buildMotivationalCard(),
                  const SizedBox(height: 24),

                  // Progress overview grid
                  _buildProgressGrid(),
                  const SizedBox(height: 24),

                  // Recommended next action
                  _buildNextActionCard(),
                  const SizedBox(height: 24),

                  // Weekly growth chart
                  _buildWeeklyChart(),
                  const SizedBox(height: 24),

                  // Badges section
                  _buildBadgesSection(),
                  const SizedBox(height: 24),

                  // Leaderboard
                  _buildLeaderboard(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2, role: 'student'),
    );
  }

  // ─── Welcome + Streak ────────────────────────────────────────────────────

  Widget _buildWelcomeStreak(String firstName) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Streak badge (RTL: left)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
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
                const Icon(Icons.local_fire_department_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$_streakDays يوم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Greeting (RTL: right)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'أهلاً بك، $firstName! 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Text(
                'أنت تبلي بلاءً حسناً اليوم.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      );

  // ─── Motivational Card ───────────────────────────────────────────────────

  Widget _buildMotivationalCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative icon
            Positioned(
              left: -8,
              bottom: -8,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 100,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '"العلم يرفع بيوتاً لا عماد لها"',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  'استمر في التقدم، متوسط إتقانك الحالي ${_masteryPercent.round()}%.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.90),
                    fontSize: 12,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      );

  // ─── Progress Overview Grid ──────────────────────────────────────────────

  Widget _buildProgressGrid() => Row(
        children: [
          // Mastery circular indicator (RTL: left)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(
                            value: (_masteryPercent / 100).clamp(0.0, 1.0),
                            strokeWidth: 7,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryContainer),
                          ),
                        ),
                        Text(
                          '${_masteryPercent.round()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الإتقان العام',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Points card (RTL: right)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading ? '...' : '$_totalPoints',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Text(
                    'نقطة تميز',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  // ─── Weekly Growth Chart ─────────────────────────────────────────────────

  Widget _buildWeeklyChart() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 4, bottom: 12),
            child: Text(
              'منحنى التطور',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00288E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                    _weeklyData.length,
                    (i) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: _weeklyData[i],
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _weekDays[i],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
              ),
            ),
          ),
        ],
      );

  // ─── Badges Section ──────────────────────────────────────────────────────

  void _showAllBadges(BuildContext context) {
    final allBadges = [
      {
        'icon': Icons.workspace_premium_rounded,
        'label': 'المنضبط',
        'earned': _streakDays >= 7,
        'color': Colors.amber,
        'desc': 'أكملت 7 أيام متتالية',
      },
      {
        'icon': Icons.rocket_launch_rounded,
        'label': 'المنطلق',
        'earned': _attemptCount >= 1,
        'color': Colors.blue,
        'desc': 'أنهيت أول اختبار',
      },
      {
        'icon': Icons.psychology_rounded,
        'label': 'المثابر',
        'earned': _attemptCount >= 10,
        'color': Colors.grey,
        'desc': 'أكمل 10 اختبارات',
      },
      {
        'icon': Icons.star_rounded,
        'label': 'النجم',
        'earned': _masteryPercent >= 90,
        'color': Colors.orange,
        'desc': 'احصل على 90% في اختبار',
      },
      {
        'icon': Icons.emoji_events_rounded,
        'label': 'البطل',
        'earned': false,
        'color': Colors.purple,
        'desc': 'تصدر لوحة المتصدرين',
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'label': 'المتقد',
        'earned': _streakDays >= 30,
        'color': Colors.red,
        'desc': 'أكمل 30 يوماً متتالية',
      },
      {
        'icon': Icons.school_rounded,
        'label': 'العالم',
        'earned': false,
        'color': Colors.green,
        'desc': 'أكمل جميع المواد',
      },
      {
        'icon': Icons.speed_rounded,
        'label': 'السريع',
        'earned': false,
        'color': Colors.teal,
        'desc': 'أجب على 10 أسئلة في دقيقة',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'جميع الأوسمة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: allBadges.length,
                  itemBuilder: (_, i) {
                    final badge = allBadges[i];
                    final earned = badge['earned'] as bool;
                    final color = badge['color'] as Color;
                    return Opacity(
                      opacity: earned ? 1.0 : 0.4,
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: earned
                                  ? color.withValues(alpha: 0.15)
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                            ),
                            child: Icon(
                              earned
                                  ? badge['icon'] as IconData
                                  : Icons.lock_rounded,
                              color: earned ? color : Colors.grey,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge['label'] as String,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            badge['desc'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {
        'icon': Icons.workspace_premium_rounded,
        'label': 'المنضبط',
        'earned': _streakDays >= 7,
        'color': Colors.amber
      },
      {
        'icon': Icons.rocket_launch_rounded,
        'label': 'المنطلق',
        'earned': _attemptCount >= 1,
        'color': Colors.blue
      },
      {
        'icon': Icons.psychology_rounded,
        'label': 'المثابر',
        'earned': _attemptCount >= 10,
        'color': Colors.grey
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _showAllBadges(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'الأوسمة المكتسبة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: badges.map((badge) {
            final earned = badge['earned'] as bool;
            final color = badge['color'] as Color;
            final icon = badge['icon'] as IconData;
            final label = badge['label'] as String;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: earned
                        ? AppColors.outlineVariant
                        : AppColors.outlineVariant,
                    style: earned ? BorderStyle.solid : BorderStyle.solid,
                  ),
                  boxShadow: earned
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Opacity(
                  opacity: earned ? 1.0 : 0.4,
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: earned
                              ? color.withValues(alpha: 0.15)
                              : AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          earned ? icon : Icons.lock_rounded,
                          color: earned ? color : AppColors.outline,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Leaderboard ─────────────────────────────────────────────────────────

  Widget _buildNextActionCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final needsPractice = _masteryPercent < 75;
    final title = needsPractice ? 'ماذا تفعل الآن؟' : 'استمر بنفس الإيقاع';
    final message = _attemptCount == 0
        ? 'ابدأ أول اختبار حتى تظهر لك نقاط القوة والضعف بوضوح.'
        : needsPractice
            ? 'مستوى الإتقان يحتاج جلسة مراجعة قصيرة قبل الاختبار القادم.'
            : 'تقدمك جيد. افتح التحليلات لمعرفة المهارة التي ترفع نتيجتك أكثر.';
    final label = _attemptCount == 0
        ? 'ابدأ اختبارًا'
        : needsPractice
            ? 'افتح التعلم المصغر'
            : 'افتح التحليلات';
    final route = _attemptCount == 0
        ? '/student/assessments-list'
        : needsPractice
            ? '/student/micro-learning'
            : '/student/analytics';

    return Semantics(
      label: '$title. $message',
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Icon(
                  needsPractice
                      ? Icons.school_outlined
                      : Icons.analytics_outlined,
                  color: colorScheme.primary,
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(route),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 12),
            child: Text(
              'ملخص النقاط',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _leaderboard.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'سيظهر ترتيبك عندما يوفر الخادم بيانات لوحة المتصدرين.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Column(
                    children: _leaderboard.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      final isMe = item['isMe'] as bool;
                      final isLast = i == _leaderboard.length - 1;

                      return Container(
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primaryContainer
                                  .withValues(alpha: 0.05)
                              : Colors.transparent,
                          border: !isLast
                              ? Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                )
                              : null,
                          borderRadius: BorderRadius.vertical(
                            top: i == 0
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottom: isLast
                                ? const Radius.circular(16)
                                : Radius.zero,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Points (RTL: left)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item['points']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isMe
                                          ? AppColors.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                  ),
                                  if (isMe)
                                    Text(
                                      'نقاطك المكتسبة',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                              // Name + avatar (RTL: right)
                              Row(
                                children: [
                                  Text(
                                    isMe
                                        ? 'أنت (${item['name']})'
                                        : item['name'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isMe
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isMe
                                          ? AppColors.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                    child: Center(
                                      child: Text(
                                        item['rank'] == null
                                            ? '•'
                                            : '${item['rank']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isMe
                                              ? AppColors.primary
                                              : AppColors.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      );
}
