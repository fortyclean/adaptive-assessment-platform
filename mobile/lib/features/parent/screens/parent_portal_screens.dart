import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

const _parentChildren = [
  _ParentChildSummary(
    id: 'child-001',
    name: 'سارة أحمد',
    classroom: 'الصف الخامس - أ',
    average: 88,
    attendance: 96,
    pendingAssessments: 2,
    latestNote: 'تحسّن واضح في الرياضيات ويُنصح بمراجعة الكسور.',
  ),
  _ParentChildSummary(
    id: 'child-002',
    name: 'عمر أحمد',
    classroom: 'الصف الثالث - ب',
    average: 81,
    attendance: 91,
    pendingAssessments: 1,
    latestNote: 'يحتاج متابعة قصيرة في القراءة اليومية.',
  ),
];

const _parentMessages = [
  _ParentMessage(
    from: 'أ. خالد',
    subject: 'متابعة واجب الرياضيات',
    body: 'يرجى مراجعة تمرين الكسور مع سارة قبل اختبار الأحد.',
    time: 'اليوم',
  ),
  _ParentMessage(
    from: 'إدارة المدرسة',
    subject: 'تحديث جدول الاختبارات',
    body: 'تم تحديث موعد اختبار العلوم للصف الخامس إلى الثلاثاء القادم.',
    time: 'أمس',
  ),
];

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة ولي الأمر'),
        actions: [
          IconButton(
            tooltip: 'الرسائل',
            onPressed: () => context.push(AppRoutes.parentMessages),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, role: 'parent'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroCard(
            title: 'مرحبًا بك',
            subtitle:
                'تابع تقدم الأبناء، الاختبارات القادمة، ورسائل المدرسة من مكان واحد.',
            icon: Icons.family_restroom_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'الأبناء',
                  value: '2',
                  icon: Icons.child_care_rounded,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'اختبارات قادمة',
                  value: '3',
                  icon: Icons.assignment_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'ملخص الأبناء',
            actionLabel: 'عرض الكل',
            onAction: () => context.push(AppRoutes.parentChildren),
          ),
          const SizedBox(height: 8),
          ..._parentChildren.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChildSummaryCard(
                child: child,
                onTap: () => context.push(
                  AppRoutes.parentChildDetailPath(child.id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionHeader(
            title: 'آخر الرسائل',
            actionLabel: 'كل الرسائل',
            onAction: () => context.push(AppRoutes.parentMessages),
          ),
          const SizedBox(height: 8),
          ..._parentMessages.take(2).map(
                (message) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MessageCard(message: message),
                ),
              ),
        ],
      ),
    );
  }
}

class ParentChildrenScreen extends StatelessWidget {
  const ParentChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الأبناء')),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 1, role: 'parent'),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _parentChildren.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final child = _parentChildren[index];
            return _ChildSummaryCard(
              child: child,
              onTap: () => context.push(
                AppRoutes.parentChildDetailPath(child.id),
              ),
            );
          },
        ),
      );
}

class ParentChildDetailScreen extends StatelessWidget {
  const ParentChildDetailScreen({
    required this.childId,
    super.key,
  });

  final String childId;

  @override
  Widget build(BuildContext context) {
    final child = _parentChildren.firstWhere(
      (item) => item.id == childId,
      orElse: () => _parentChildren.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(child.name)),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, role: 'parent'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeroCard(
            title: child.name,
            subtitle: '${child.classroom} • حضور ${child.attendance}%',
            icon: Icons.account_circle_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'المعدل',
                  value: '${child.average}%',
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'اختبارات معلقة',
                  value: '${child.pendingAssessments}',
                  icon: Icons.pending_actions_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionHeader(title: 'توصية المتابعة'),
          const SizedBox(height: 8),
          _InfoPanel(
            icon: Icons.lightbulb_outline_rounded,
            title: 'إجراء مقترح',
            body: child.latestNote,
          ),
          const SizedBox(height: 12),
          const _InfoPanel(
            icon: Icons.quiz_outlined,
            title: 'اختبار قريب',
            body:
                'اختبار قصير في الرياضيات خلال 3 أيام. المراجعة المقترحة: 20 دقيقة يوميًا.',
          ),
          const SizedBox(height: 12),
          const _InfoPanel(
            icon: Icons.school_outlined,
            title: 'ملاحظة المعلم',
            body:
                'المشاركة داخل الفصل جيدة، ونحتاج فقط إلى تثبيت روتين المذاكرة الأسبوعي.',
          ),
        ],
      ),
    );
  }
}

class ParentMessagesScreen extends StatelessWidget {
  const ParentMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('رسائل ولي الأمر')),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 2, role: 'parent'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _InfoPanel(
              icon: Icons.notifications_active_outlined,
              title: 'مركز تواصل المدرسة',
              body:
                  'تظهر هنا رسائل المعلمين والإدارة والتنبيهات المهمة المرتبطة بأبنائك.',
            ),
            const SizedBox(height: 16),
            ..._parentMessages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MessageCard(message: message, expanded: true),
              ),
            ),
          ],
        ),
      );
}

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('إعدادات ولي الأمر')),
        bottomNavigationBar:
            const AppBottomNav(currentIndex: 3, role: 'parent'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _InfoPanel(
              icon: Icons.verified_user_outlined,
              title: 'خصوصية بيانات الأبناء',
              body:
                  'يعرض الحساب بيانات الأبناء المرتبطين فقط، مع إخفاء أي بيانات لا تخص ولي الأمر.',
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'إعدادات الإشعارات',
              subtitle: 'إدارة تنبيهات الرسائل والاختبارات والتقارير.',
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'بيانات الحساب',
              subtitle: 'تحديث الاسم وكلمة المرور وتفضيلات الحساب.',
              onTap: () => context.push(AppRoutes.accountSettings),
            ),
          ],
        ),
      );
}

class _ChildSummaryCard extends StatelessWidget {
  const _ChildSummaryCard({
    required this.child,
    required this.onTap,
  });

  final _ParentChildSummary child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.school_rounded,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          child.classroom,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left_rounded),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: child.average / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(99),
              ),
              const SizedBox(height: 8),
              Text('المعدل ${child.average}% • الحضور ${child.attendance}%'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label),
            ],
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    this.expanded = false,
  });

  final _ParentMessage message;
  final bool expanded;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.mark_email_unread_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message.subject,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(message.time),
                ],
              ),
              const SizedBox(height: 6),
              Text('من: ${message.from}'),
              const SizedBox(height: 6),
              Text(
                message.body,
                maxLines: expanded ? null : 2,
                overflow: expanded ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_left_rounded),
          onTap: onTap,
        ),
      );
}

class _ParentChildSummary {
  const _ParentChildSummary({
    required this.id,
    required this.name,
    required this.classroom,
    required this.average,
    required this.attendance,
    required this.pendingAssessments,
    required this.latestNote,
  });

  final String id;
  final String name;
  final String classroom;
  final int average;
  final int attendance;
  final int pendingAssessments;
  final String latestNote;
}

class _ParentMessage {
  const _ParentMessage({
    required this.from,
    required this.subject,
    required this.body,
    required this.time,
  });

  final String from;
  final String subject;
  final String body;
  final String time;
}
