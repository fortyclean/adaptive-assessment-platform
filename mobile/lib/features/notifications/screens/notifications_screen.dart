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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ref
          .read(apiServiceProvider)
          .dio
          .patch('/notifications/read-all');
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
      await ref
          .read(apiServiceProvider)
          .dio
          .patch('/notifications/$id/read');
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
      appBar: AppBar(
        title: Row(
          children: [
            const Text('الإشعارات'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('تحديد الكل كمقروء'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('لا توجد إشعارات'))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView(
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

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(
      {required this.notification, required this.onTap});
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'] as bool? ?? true;
    final createdAt = notification['createdAt'] != null
        ? DateTime.parse(notification['createdAt'] as String)
        : DateTime.now();
    final timeStr = DateFormat('hh:mm a', 'ar').format(createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? null : AppColors.notificationUnread,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, left: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead
                    ? Colors.transparent
                    : AppColors.notificationUnreadIndicator,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['body'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.onSurfaceVariant),
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
