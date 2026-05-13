import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_service.dart';

/// Advanced Notification Center — Screen 34
/// Matches _34/code.html design exactly.
/// Features:
///   - Today / Yesterday section grouping with dividers
///   - Unread indicator dot (blue circle) on unread items
///   - Notification icons per type (quiz, trending_up, settings, bar_chart)
///   - Empty state illustration at bottom
///   - Swipe-to-dismiss gesture support
///   - "تحديد الكل كمقروء" button
/// Requirements: 21.4, 21.5, 21.6, 21.7
class AdvancedNotificationCenterScreen extends ConsumerStatefulWidget {
  const AdvancedNotificationCenterScreen({super.key});

  @override
  ConsumerState<AdvancedNotificationCenterScreen> createState() =>
      _AdvancedNotificationCenterScreenState();
}

class _AdvancedNotificationCenterScreenState
    extends ConsumerState<AdvancedNotificationCenterScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await ref.read(apiServiceProvider).dio.get('/notifications');
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(
            response.data['notifications'] as List);
        _unreadCount = response.data['unreadCount'] as int? ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      // Use sample data for preview when API is unavailable
      setState(() {
        _notifications = _sampleNotifications();
        _unreadCount =
            _notifications.where((n) => !(n['isRead'] as bool? ?? true)).length;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(apiServiceProvider).dio.patch('/notifications/read-all');
    } catch (_) {}
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
      _unreadCount = 0;
    });
  }

  Future<void> _markRead(String id) async {
    try {
      await ref.read(apiServiceProvider).dio.patch('/notifications/$id/read');
    } catch (_) {}
    setState(() {
      final idx = _notifications.indexWhere((n) => n['_id'] == id);
      if (idx != -1) {
        _notifications[idx]['isRead'] = true;
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
      }
    });
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['_id'] == id);
      _unreadCount =
          _notifications.where((n) => !(n['isRead'] as bool? ?? true)).length;
    });
  }

  // ── Grouping ──────────────────────────────────────────────────────────────
  /// Returns groups: 'اليوم', 'أمس', 'السابقة'
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final today = <Map<String, dynamic>>[];
    final yesterday = <Map<String, dynamic>>[];
    final previous = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    for (final n in _notifications) {
      final createdAt = n['createdAt'] != null
          ? DateTime.parse(n['createdAt'] as String)
          : now;
      final itemDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

      if (itemDate == todayDate) {
        today.add(n);
      } else if (itemDate == yesterdayDate) {
        yesterday.add(n);
      } else {
        previous.add(n);
      }
    }

    return {
      'اليوم': today,
      'أمس': yesterday,
      'السابقة': previous,
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: _buildBody(),
              ),
      );

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
        title: const Text(
          'التقييم الذكي',
          style: TextStyle(
            color: Color(0xFF1E40AF),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Almarai',
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1E40AF).withValues(alpha: 0.15),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF1E40AF),
              size: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1E40AF),
            ),
            onPressed: () {}, // keep as is - already on notifications screen
          ),
        ],
      );

  Widget _buildBody() {
    final grouped = _grouped;
    final hasAnyNotifications = grouped.values.any((list) => list.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // ── Page Header ──────────────────────────────────────────────────
        _buildPageHeader(),
        const SizedBox(height: 24),

        // ── Grouped Sections ─────────────────────────────────────────────
        for (final entry in grouped.entries)
          if (entry.value.isNotEmpty) ...[
            _SectionHeader(title: entry.key),
            const SizedBox(height: 8),
            ...entry.value.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SwipeableNotificationCard(
                  notification: n,
                  onTap: () => _markRead(n['_id'] as String? ?? ''),
                  onDismiss: () =>
                      _dismissNotification(n['_id'] as String? ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

        // ── Empty State ───────────────────────────────────────────────────
        _buildEmptyState(hasAnyNotifications),
      ],
    );
  }

  Widget _buildPageHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مركز التنبيهات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1B22),
                  fontFamily: 'Almarai',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _unreadCount > 0
                    ? 'لديك $_unreadCount تنبيهات جديدة غير مقروءة'
                    : 'لا توجد تنبيهات غير مقروءة',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF444653),
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
          // Mark all read button
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'تحديد الكل كمقروء',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
        ],
      );

  Widget _buildEmptyState(bool hasNotifications) => Padding(
        padding: const EdgeInsets.only(top: 48, bottom: 24),
        child: Column(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainer,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: Color(0xFFC4C5D5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasNotifications
                  ? 'لا توجد تنبيهات أقدم لعرضها'
                  : 'لا توجد تنبيهات',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF444653),
                fontFamily: 'Almarai',
              ),
            ),
          ],
        ),
      );

  // ── Sample data for offline/preview ──────────────────────────────────────
  List<Map<String, dynamic>> _sampleNotifications() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return [
      {
        '_id': '1',
        'title': 'نتائج اختبار الرياضيات',
        'body':
            'تم إصدار نتائج اختبار "الجبر المتقدم". لقد حققت نسبة 92%، رائع!',
        'type': 'quiz',
        'isRead': false,
        'createdAt':
            DateTime(now.year, now.month, now.day, 10, 30).toIso8601String(),
      },
      {
        '_id': '2',
        'title': 'تقدم في المسار التعليمي',
        'body': 'تهانينا! لقد أكملت 80% من مسار العلوم لهذا الأسبوع.',
        'type': 'trending_up',
        'isRead': false,
        'createdAt':
            DateTime(now.year, now.month, now.day, 9, 15).toIso8601String(),
      },
      {
        '_id': '3',
        'title': 'تحديث النظام',
        'body':
            'تم تحديث تطبيق التقييم الذكي إلى الإصدار 2.4.5 مع تحسينات في الأداء.',
        'type': 'settings',
        'isRead': true,
        'createdAt':
            DateTime(yesterday.year, yesterday.month, yesterday.day, 16)
                .toIso8601String(),
      },
      {
        '_id': '4',
        'title': 'تقرير شهري جديد',
        'body':
            'التقرير الشهري لشهر أكتوبر متاح الآن للعرض والتحميل بصيغة PDF.',
        'type': 'bar_chart',
        'isRead': true,
        'createdAt':
            DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 30)
                .toIso8601String(),
      },
    ];
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1B22),
              fontFamily: 'Almarai',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFC4C5D5),
            ),
          ),
        ],
      );
}

// ─── Swipeable Notification Card ─────────────────────────────────────────────

class _SwipeableNotificationCard extends StatelessWidget {
  const _SwipeableNotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Dismissible(
        key: ValueKey(notification['_id']),
        direction: DismissDirection.startToEnd,
        background: _buildSwipeBackground(),
        onDismissed: (_) => onDismiss(),
        child: _NotificationCard(
          notification: notification,
          onTap: onTap,
        ),
      );

  Widget _buildSwipeBackground() => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFFBA1A1A), Color(0xFFFFDAD6)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      );
}

// ─── Notification Card ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'] as bool? ?? true;
    final type = notification['type'] as String? ?? 'quiz';
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final createdAt = notification['createdAt'] != null
        ? DateTime.parse(notification['createdAt'] as String)
        : DateTime.now();

    final timeStr = _formatTime(createdAt);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon Container ──────────────────────────────────────────
              _NotificationIcon(type: type, isRead: isRead),
              const SizedBox(width: 16),

              // ── Content ─────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1B22),
                              fontFamily: 'Almarai',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF444653),
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF444653),
                        height: 1.5,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ── Unread Dot ───────────────────────────────────────────────
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(dt.year, dt.month, dt.day);

    if (itemDate == todayDate) {
      // Today: show time only e.g. "10:30 ص"
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? 'ص' : 'م';
      final displayHour = hour == 0
          ? 12
          : hour > 12
              ? hour - 12
              : hour;
      return '$displayHour:$minute $period';
    } else {
      // Yesterday or older: show "أمس، HH:MM ص/م"
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? 'ص' : 'م';
      final displayHour = hour == 0
          ? 12
          : hour > 12
              ? hour - 12
              : hour;
      final prefix = itemDate == todayDate.subtract(const Duration(days: 1))
          ? 'أمس،'
          : DateFormat('d MMM', 'ar').format(dt);
      return '$prefix $displayHour:$minute $period';
    }
  }
}

// ─── Notification Icon ────────────────────────────────────────────────────────

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type, required this.isRead});

  final String type;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig(type, isRead);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: config.backgroundColor,
      ),
      child: Icon(
        config.icon,
        color: config.iconColor,
        size: 24,
      ),
    );
  }

  _IconConfig _iconConfig(String type, bool isRead) {
    switch (type) {
      case 'quiz':
        return const _IconConfig(
          icon: Icons.quiz_outlined,
          backgroundColor: AppColors.primaryContainer,
          iconColor: Colors.white,
        );
      case 'trending_up':
        return const _IconConfig(
          icon: Icons.trending_up_rounded,
          backgroundColor: Color(0xFFEFF6FF),
          iconColor: Color(0xFF1E40AF),
        );
      case 'settings':
        return const _IconConfig(
          icon: Icons.settings_outlined,
          backgroundColor: AppColors.surfaceContainer,
          iconColor: AppColors.onSurfaceVariant,
        );
      case 'bar_chart':
        return const _IconConfig(
          icon: Icons.bar_chart_rounded,
          backgroundColor: AppColors.surfaceContainer,
          iconColor: AppColors.onSurfaceVariant,
        );
      case 'assessment':
        return const _IconConfig(
          icon: Icons.assignment_outlined,
          backgroundColor: AppColors.primaryContainer,
          iconColor: Colors.white,
        );
      case 'reminder':
        return const _IconConfig(
          icon: Icons.alarm_outlined,
          backgroundColor: Color(0xFFFEF3C7),
          iconColor: Color(0xFFD97706),
        );
      default:
        return const _IconConfig(
          icon: Icons.notifications_outlined,
          backgroundColor: AppColors.surfaceContainer,
          iconColor: AppColors.onSurfaceVariant,
        );
    }
  }
}

class _IconConfig {
  const _IconConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}
