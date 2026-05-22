import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Points marketplace.
///
/// Until the backend exposes a redemption endpoint, this screen uses a clear
/// local redemption state instead of SnackBar-only actions. Purchases deduct
/// points, move the item to the collection, and show a confirmation dialog.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedTab = 0;
  int _pointsBalance = 2450;
  final Set<String> _ownedItemIds = {'extra-time'};
  final Set<String> _activeItemIds = {'extra-time'};

  static const List<String> _tabs = ['الكل', 'الأفاتار', 'القوالب', 'الأدلة'];

  static const List<_MarketItem> _items = [
    _MarketItem(
      id: 'explorer-avatar',
      title: 'أفاتار: المستكشف',
      price: 850,
      badge: 'نادر',
      type: MarketItemType.avatar,
      icon: Icons.face,
      iconColor: Color(0xFF1E40AF),
      description: 'أفاتار مميز يظهر في ملفك الشخصي ولوحة التحديات.',
    ),
    _MarketItem(
      id: 'golden-sunset-theme',
      title: 'قالب: الغروب الذهبي',
      price: 1200,
      badge: 'حصري',
      type: MarketItemType.theme,
      icon: Icons.palette,
      iconColor: Color(0xFF611E00),
      description: 'قالب لوني خاص لتخصيص تجربة التعلم.',
    ),
    _MarketItem(
      id: 'advanced-algebra-guide',
      title: 'أسرار الجبر المتقدم',
      price: 450,
      badge: 'دليل دراسي',
      type: MarketItemType.guide,
      icon: Icons.auto_stories,
      iconColor: AppColors.primary,
      isWide: true,
      description: 'دليل شامل مع تمارين تفاعلية وحلول مختصرة.',
    ),
    _MarketItem(
      id: 'top-student-avatar',
      title: 'أفاتار: المتفوقة',
      price: 600,
      type: MarketItemType.avatar,
      icon: Icons.face_3,
      iconColor: Color(0xFF1E40AF),
      description: 'أفاتار احتفالي للطلاب أصحاب الإنجازات العالية.',
    ),
    _MarketItem(
      id: 'xp-booster',
      title: 'مضاعف XP لمدة ساعة',
      price: 250,
      type: MarketItemType.powerup,
      icon: Icons.rocket_launch,
      iconColor: Colors.white,
      iconBg: AppColors.error,
      description: 'يزيد نقاط الخبرة المكتسبة في الجلسة القادمة.',
    ),
    _MarketItem(
      id: 'extra-time',
      title: 'مكافأة وقت إضافي',
      price: 300,
      type: MarketItemType.powerup,
      icon: Icons.timer,
      iconColor: Colors.green,
      description: 'مقتنى تجريبي نشط يظهر كيف تبدو العناصر المملوكة.',
    ),
  ];

  List<_MarketItem> get _filteredItems {
    if (_selectedTab == 0) return _items;
    final typeMap = {
      1: MarketItemType.avatar,
      2: MarketItemType.theme,
      3: MarketItemType.guide,
    };
    final selectedType = typeMap[_selectedTab];
    if (selectedType == null) return _items;
    return _items.where((item) => item.type == selectedType).toList();
  }

  List<_MarketItem> get _collection =>
      _items.where((item) => _ownedItemIds.contains(item.id)).toList();

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _buildHeroBalance(),
                const SizedBox(height: 24),
                _buildMyCollection(),
                const SizedBox(height: 24),
                _buildMarketplaceTabs(),
                const SizedBox(height: 16),
                _buildItemsList(),
              ],
            ),
          ),
          bottomNavigationBar:
              const AppBottomNav(currentIndex: 0, role: 'student'),
        ),
      );

  PreferredSizeWidget _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFD3E4FE),
            child: Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'EduAssess',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: colorScheme.primary,
          tooltip: 'الإشعارات',
          onPressed: () => context.push(AppRoutes.studentNotifications),
        ),
      ],
    );
  }

  Widget _buildHeroBalance() => Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الرصيد الحالي',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.diamond, color: Color(0xFFFFDBCE), size: 36),
                const SizedBox(width: 8),
                Text(
                  _formatPoints(_pointsBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 16),
                const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.white70, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'XP 12.5k',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المستوى 14: عبقري رياضيات',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(
                    width: 80,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: Colors.white24,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFB59A)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildMyCollection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'مجموعتي',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _showCollectionSheet,
              icon: const Icon(Icons.inventory_2_outlined, size: 16),
              label: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_collection.isEmpty)
          _buildEmptyCollection()
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _collection.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _collection[index];
                return Container(
                  width: 112,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            item.effectiveIconColor.withValues(alpha: 0.12),
                        child: Icon(item.icon, color: item.effectiveIconColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.shortTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_activeItemIds.contains(item.id)) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'نشط',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyCollection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        'لم تضف أي مقتنيات بعد. اشترِ أول مكافأة وستظهر هنا.',
        style: TextStyle(color: colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMarketplaceTabs() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final selected = _selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(_tabs[index]),
                selected: selected,
                onSelected: (_) => setState(() => _selectedTab = index),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            );
          }),
        ),
      );

  Widget _buildItemsList() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return const _InfoState(
        icon: Icons.storefront_outlined,
        title: 'لا توجد عناصر في هذا القسم',
        message: 'جرّب قسمًا آخر أو عد لاحقًا عند إضافة مكافآت جديدة.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 390;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: item.isWide || isNarrow
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2,
                  child: _buildItemCard(item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildItemCard(_MarketItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    final owned = _ownedItemIds.contains(item.id);
    final canAfford = _pointsBalance >= item.price;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: item.isWide ? 112 : 132,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: (item.iconBg ?? const Color(0xFFEFF6FF)),
                    child: Icon(
                      item.icon,
                      color: item.effectiveIconColor,
                      size: 32,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _Badge(label: item.badge!),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: item.isWide ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.diamond,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${item.price}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (owned)
                      const _OwnedLabel()
                    else if (!canAfford)
                      Text(
                        'رصيد غير كافٍ',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: owned
                        ? () => _activateItem(item)
                        : () => _confirmPurchase(item),
                    icon: Icon(
                      owned
                          ? Icons.check_circle_outline
                          : Icons.shopping_bag_outlined,
                      size: 18,
                    ),
                    label: Text(owned ? 'تفعيل' : 'شراء'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPurchase(_MarketItem item) async {
    final canAfford = _pointsBalance >= item.price;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(canAfford ? 'تأكيد الشراء' : 'رصيد غير كافٍ'),
          content: Text(
            canAfford
                ? 'سيتم خصم ${item.price} نقطة من رصيدك لشراء "${item.title}".'
                : 'تحتاج إلى ${item.price - _pointsBalance} نقطة إضافية لشراء "${item.title}".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(canAfford ? 'إلغاء' : 'حسنًا'),
            ),
            if (canAfford)
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('تأكيد الشراء'),
              ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _pointsBalance -= item.price;
      _ownedItemIds.add(item.id);
      if (item.type == MarketItemType.powerup ||
          item.type == MarketItemType.avatar ||
          item.type == MarketItemType.theme) {
        _activeItemIds.add(item.id);
      }
    });

    _showResultDialog(
      title: 'تمت الإضافة إلى مجموعتك',
      message:
          'تم شراء "${item.title}" بنجاح. الرصيد المتبقي: ${_formatPoints(_pointsBalance)} نقطة.',
    );
  }

  void _activateItem(_MarketItem item) {
    setState(() => _activeItemIds.add(item.id));
    _showResultDialog(
      title: 'تم التفعيل',
      message: 'تم تفعيل "${item.title}" داخل مجموعتك.',
    );
  }

  void _showCollectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'مجموعتي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                if (_collection.isEmpty)
                  const _InfoState(
                    icon: Icons.inventory_2_outlined,
                    title: 'لا توجد مقتنيات',
                    message: 'اشترِ عنصرًا من المتجر ليظهر هنا.',
                  )
                else
                  ..._collection.map(
                    (item) => ListTile(
                      leading: Icon(item.icon, color: item.effectiveIconColor),
                      title: Text(item.title),
                      subtitle: Text(
                        _activeItemIds.contains(item.id)
                            ? 'نشط الآن'
                            : 'متاح للتفعيل',
                      ),
                      trailing: _activeItemIds.contains(item.id)
                          ? const Icon(Icons.check_circle,
                              color: AppColors.success)
                          : TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                _activateItem(item);
                              },
                              child: const Text('تفعيل'),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('تم'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPoints(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < text.length; index++) {
      final remaining = text.length - index;
      buffer.write(text[index]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

enum MarketItemType { avatar, theme, guide, powerup }

class _MarketItem {
  const _MarketItem({
    required this.id,
    required this.title,
    required this.price,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.description,
    this.badge,
    this.iconBg,
    this.isWide = false,
  });

  final String id;
  final String title;
  final int price;
  final MarketItemType type;
  final IconData icon;
  final Color iconColor;
  final String description;
  final String? badge;
  final Color? iconBg;
  final bool isWide;

  Color get effectiveIconColor => iconColor;

  String get shortTitle {
    if (id == 'extra-time') return 'وقت إضافي';
    return title.contains(':') ? title.split(':').last.trim() : title;
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
}

class _OwnedLabel extends StatelessWidget {
  const _OwnedLabel();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'مملوك',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
