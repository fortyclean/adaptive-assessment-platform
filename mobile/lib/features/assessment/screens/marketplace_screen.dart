import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Screen 66 — متجر النقاط والمكافآت (Points Marketplace)
/// Matches design: _66/code.html
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = ['الكل', 'الأفاتار', 'القوالب', 'الأدلة'];

  final List<_MarketItem> _items = [
    _MarketItem(
      title: 'أفاتار: المستكشف',
      price: 850,
      badge: 'نادر',
      badgeColor: Colors.black54,
      type: MarketItemType.avatar,
      icon: Icons.face,
      iconColor: const Color(0xFF1E40AF),
    ),
    _MarketItem(
      title: 'قالب: الغروب الذهبي',
      price: 1200,
      badge: 'حصري',
      badgeColor: const Color(0xFF611E00),
      type: MarketItemType.theme,
      icon: Icons.palette,
      iconColor: const Color(0xFF611E00),
    ),
    _MarketItem(
      title: 'أسرار الجبر المتقدم',
      price: 450,
      badge: 'دليل دراسي',
      badgeColor: AppColors.primary,
      type: MarketItemType.guide,
      icon: Icons.auto_stories,
      iconColor: AppColors.primary,
      isWide: true,
      description: 'دليل شامل مع تمارين تفاعلية وحلول مبتكرة.',
    ),
    _MarketItem(
      title: 'أفاتار: المتفوقة',
      price: 600,
      type: MarketItemType.avatar,
      icon: Icons.face_3,
      iconColor: const Color(0xFF1E40AF),
    ),
    _MarketItem(
      title: 'مضاعف XP (ساعة)',
      price: 250,
      type: MarketItemType.powerup,
      icon: Icons.rocket_launch,
      iconColor: Colors.white,
      iconBg: AppColors.error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8FF),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBalance(),
              const SizedBox(height: 24),
              _buildMyCollection(),
              const SizedBox(height: 24),
              _buildMarketplaceTabs(),
              const SizedBox(height: 16),
              _buildItemsGrid(),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFD3E4FE),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'EduAssess',
            style: TextStyle(
              color: Color(0xFF1E40AF),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1E40AF)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroBalance() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.diamond, color: Color(0xFFFFDBCE), size: 36),
              const SizedBox(width: 8),
              const Text(
                '2,450',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: const [
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المستوى 14: عبقري رياضيات',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(
                  width: 80,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB59A)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCollection() {
    final collection = [
      {'icon': Icons.timer, 'label': 'وقت إضافي', 'badge': 'نشط', 'bg': const Color(0xFFF0FDF4), 'color': Colors.green},
      {'icon': Icons.workspace_premium, 'label': 'أول 100', 'badge': null, 'bg': const Color(0xFFFFFBEB), 'color': Colors.amber},
      {'icon': Icons.face_6, 'label': 'قبعة الحكيم', 'badge': null, 'bg': const Color(0xFFEFF6FF), 'color': const Color(0xFF1E40AF)},
    ];

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
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عرض جميع مقتنياتك'), behavior: SnackBarBehavior.floating),
                );
              },
              child: const Text('عرض الكل', style: TextStyle(color: AppColors.outline, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: collection.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final item = collection[i];
              return Container(
                width: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    if (item['badge'] != null)
                      Text(
                        item['badge'] as String,
                        style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _selectedTab == i;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? AppColors.primary : const Color(0xFFC4C5D5),
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 6)]
                      : [],
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF444653),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        if (item.isWide) {
          return const SizedBox.shrink(); // handled separately
        }
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(_MarketItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDF7),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: item.iconBg ?? const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 28),
                    ),
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.badgeColor ?? Colors.black54,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.diamond, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item.price.toString(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('شراء: ${item.title}'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.diamond, color: AppColors.primary, size: 32),
                                  const SizedBox(width: 8),
                                  Text('${item.price} نقطة', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('هل تريد شراء هذا العنصر؟', textAlign: TextAlign.center),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('تم شراء "${item.title}" بنجاح!'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                              child: const Text('تأكيد الشراء'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('شراء', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'الرئيسية', true),
          _navItem(Icons.quiz_outlined, 'الاختبارات', false),
          _navItem(Icons.bar_chart_outlined, 'التقارير', false),
          _navItem(Icons.settings_outlined, 'الإعدادات', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xFF1E40AF) : Colors.grey, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? const Color(0xFF1E40AF) : Colors.grey,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

enum MarketItemType { avatar, theme, guide, powerup }

class _MarketItem {
  final String title;
  final int price;
  final String? badge;
  final Color? badgeColor;
  final MarketItemType type;
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final bool isWide;
  final String? description;

  const _MarketItem({
    required this.title,
    required this.price,
    this.badge,
    this.badgeColor,
    required this.type,
    required this.icon,
    required this.iconColor,
    this.iconBg,
    this.isWide = false,
    this.description,
  });
}
