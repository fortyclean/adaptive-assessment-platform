import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_service.dart';

/// Notifications Screen — Screen 21
/// Requirements: 21.4–21.7
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
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
      setState(() {
        _notifications = [
          {
            '_id': 'n1',
            'title': 'اختبار جديد متاح',
            'body': 'تم نشر اختبار الرياضيات الدوري. يمكنك البدء الآن.',
            'type': 'assessment',
            'isRead': false,
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            '_id': 'n2',
            'title': 'نتيجة اختبارك',
            'body': 'حصلت على 78% في اختبار اللغة العربية. أحسنت!',
            'type': 'grade',
            'isRead': false,
            'createdAt': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
          },
          {
            '_id': 'n3',
            'title': 'تنبيه أداء',
            'body': 'انخفض متوسط أداء الطالب أحمد في مادة الفيزياء.',
            'type': 'alert',
            'isRead': true,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          },
          {
            '_id': 'n4',
            'title': 'رسالة من المعلم',
            'body': 'يرجى مراجعة الوحدة الثالثة قبل الاختبار القادم.',
            'type': 'message',
            'isRead': true,
            'createdAt': DateTime.now()
                .subtract(const Duration(days: 2))
                .toIso8601String(),
          },
        ];
        _unreadCount = 2;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(apiServiceProvider).dio.patch('/notifications/read-all');
      setState(() {
        for (final n in _notifications) {
          n['isRead'] = true;
        }
        _unreadCount = 0;
      });
    } catch (_) {}
  }

  Future<void> _markRead(String id) async {
    try {
      await ref.read(apiServiceProvider).dio.patch('/notifications/$id/read');
      setState(() {
        final idx = _notifications.indexWhere((n) => n['_id'] == id);
        if (idx != -1) {
          _notifications[idx]['isRead'] = true;
          _unreadCount = (_unreadCount - 1).clamp(0, 999);
        }
      });
    } catch (_) {}
  }

  // Group notifications by Today / Previous (Req 21.5)
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final today = <Map<String, dynamic>>[];
    final previous = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final n in _notifications) {
      final createdAt = n['createdAt'] != null
          ? DateTime.parse(n['createdAt'] as String)
          : now;
      final isToday = createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day;
      if (isToday) {
        today.add(n);
      } else {
        previous.add(n);
      }
    }
    return {'اليوم': today, 'السابقة': previous};
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              const Text(
                'الإشعارات',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (_unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (_unreadCount > 0)
              TextButton(
                onPressed: _markAllRead,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text(
                  'تحديد الكل كمقروء',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _notifications.isEmpty
                ? _EmptyState()
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (final entry in _grouped.entries)
                          if (entry.value.isNotEmpty) ...[
                            _GroupHeader(title: entry.key),
                            ...entry.value.map((n) => _NotificationTile(
                                  notification: n,
                                  onTap: () => _markRead(n['_id'] as String),
                                )),
                          ],
                      ],
                    ),
                  ),
      );
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFDDE1FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر هنا إشعاراتك الجديدة',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
}

// ─── Group Header ─────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
}

// ─── Notification Tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'assessment':
        return Icons.quiz_rounded;
      case 'grade':
        return Icons.grade_rounded;
      case 'alert':
        return Icons.warning_rounded;
      case 'message':
        return Icons.message_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'assessment':
        return AppColors.primary;
      case 'grade':
        return AppColors.success;
      case 'alert':
        return AppColors.error;
      case 'message':
        return AppColors.primaryContainer;
      default:
        return AppColors.primary;
    }
  }

  Color _getNotificationBgColor(String? type) {
    switch (type) {
      case 'assessment':
        return const Color(0xFFDDE1FF);
      case 'grade':
        return const Color(0xFFD1FAE5);
      case 'alert':
        return AppColors.errorContainer;
      case 'message':
        return const Color(0xFFD0E1FB);
      default:
        return const Color(0xFFDDE1FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'] as bool? ?? true;
    final type = notification['type'] as String?;
    final createdAt = notification['createdAt'] != null
        ? DateTime.parse(notification['createdAt'] as String)
        : DateTime.now();
    final timeStr = DateFormat('hh:mm a', 'ar').format(createdAt);
    final iconColor = _getNotificationColor(type);
    final iconBgColor = _getNotificationBgColor(type);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.notificationUnread,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? AppColors.outlineVariant.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(type),
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] as String? ?? '',
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 14,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.notificationUnreadIndicator,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['body'] as String? ?? '',
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
