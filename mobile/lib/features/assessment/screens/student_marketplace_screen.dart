import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Screen 66 — Student Marketplace (متجر النقاط)
/// Students can spend diamond points on avatars, themes, power-ups, and study guides.
class StudentMarketplaceScreen extends ConsumerStatefulWidget {
  const StudentMarketplaceScreen({super.key});

  @override
  ConsumerState<StudentMarketplaceScreen> createState() =>
      _StudentMarketplaceScreenState();
}

class _StudentMarketplaceScreenState
    extends ConsumerState<StudentMarketplaceScreen> {
  int _selectedTab = 0; // 0=الكل, 1=الأفاتار, 2=القوالب, 3=الأدلة

  final List<String> _tabs = ['الكل', 'الأفاتار', 'القوالب', 'الأدلة'];

  // Mock collection items
  final List<Map<String, dynamic>> _collection = [
    {
      'icon': Icons.timer,
      'label': 'وقت إضافي',
      'active': true,
      'color': Colors.green
    },
    {
      'icon': Icons.workspace_premium,
      'label': 'أول 100',
      'active': false,
      'color': Colors.amber
    },
    {
      'icon': Icons.face,
      'label': 'قبعة الحكيم',
      'active': false,
      'color': Colors.blue
    },
  ];

  // Mock marketplace items
  final List<Map<String, dynamic>> _items = [
    {
      'type': 'avatar',
      'title': 'أفاتار: المستكشف',
      'price': 850,
      'badge': 'نادر',
      'badgeColor': Colors.black54,
      'wide': false,
    },
    {
      'type': 'theme',
      'title': 'قالب: الغروب الذهبي',
      'price': 1200,
      'badge': 'حصري',
      'badgeColor': const Color(0xFF611E00),
      'wide': false,
    },
    {
      'type': 'guide',
      'title': 'أسرار الجبر المتقدم',
      'price': 450,
      'badge': 'دليل دراسي',
      'badgeColor': AppColors.primaryContainer,
      'wide': true,
      'description': 'دليل شامل مع تمارين تفاعلية وحلول مبتكرة.',
    },
    {
      'type': 'avatar',
      'title': 'أفاتار: المتفوقة',
      'price': 600,
      'badge': null,
      'wide': false,
    },
    {
      'type': 'powerup',
      'title': 'مضاعف XP (ساعة)',
      'price': 250,
      'badge': null,
      'wide': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedTab == 0) return _items;
    final typeMap = {1: 'avatar', 2: 'theme', 3: 'guide'};
    final type = typeMap[_selectedTab];
    if (type == null) return _items;
    return _items.where((i) => i['type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: CustomScrollView(
            slivers: [
              // ─── App Bar ────────────────────────────────────────────────
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
                    // Avatar + App name
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceContainer,
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: const Icon(Icons.person,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'EduAssess',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                    // Notifications
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: AppColors.primaryContainer,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // ─── Content ────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero: Point Balance
                    _buildHeroSection(),
                    const SizedBox(height: 24),

                    // My Collection
                    _buildCollectionSection(),
                    const SizedBox(height: 24),

                    // Marketplace Tabs + Grid
                    _buildMarketplaceSection(),
                  ]),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              const AppBottomNav(currentIndex: 0, role: 'student'),
        ),
      );

  // ─── Hero Section ────────────────────────────────────────────────────────

  Widget _buildHeroSection() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background blur circle
            Positioned(
              top: -16,
              left: -16,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الرصيد الحالي',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.diamond, color: Color(0xFFFFDBCE), size: 36),
                    SizedBox(width: 8),
                    Text(
                      '2,450',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.white70, size: 20),
                        SizedBox(width: 4),
                        Text(
                          'XP 12.5k',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المستوى 14: عبقري رياضيات',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 96,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerRight,
                          widthFactor: 0.75,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB59A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  // ─── My Collection Section ───────────────────────────────────────────────

  Widget _buildCollectionSection() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('عرض جميع مقتنياتك'),
                        behavior: SnackBarBehavior.floating),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.outline,
                  ),
                ),
              ),
              const Text(
                'مجموعتي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: _collection.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _collection[index];
                return _buildCollectionItem(item);
              },
            ),
          ),
        ],
      );

  Widget _buildCollectionItem(Map<String, dynamic> item) => Container(
        width: 112,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (item['color'] as Color).withValues(alpha: 0.1),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['label'] as String,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item['active'] == true) ...[
              const SizedBox(height: 4),
              const Text(
                'نشط',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      );

  // ─── Marketplace Section ─────────────────────────────────────────────────

  Widget _buildMarketplaceSection() => Column(
        children: [
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTab == index;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Items grid
          _buildItemsGrid(),
        ],
      );

  Widget _buildItemsGrid() {
    final items = _filteredItems;
    final rows = <Widget>[];
    var i = 0;

    while (i < items.length) {
      final item = items[i];
      if (item['wide'] == true) {
        rows.add(_buildWideCard(item));
        rows.add(const SizedBox(height: 12));
        i++;
      } else {
        // Try to pair with next non-wide item
        if (i + 1 < items.length && items[i + 1]['wide'] != true) {
          rows.add(
            Row(
              children: [
                Expanded(child: _buildNarrowCard(item)),
                const SizedBox(width: 12),
                Expanded(child: _buildNarrowCard(items[i + 1])),
              ],
            ),
          );
          i += 2;
        } else {
          rows.add(
            Row(
              children: [
                Expanded(child: _buildNarrowCard(item)),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
          );
          i++;
        }
        rows.add(const SizedBox(height: 12));
      }
    }

    return Column(children: rows);
  }

  Widget _buildNarrowCard(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final isAvatar = type == 'avatar';
    final isPowerup = type == 'powerup';
    final isTheme = type == 'theme';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image/icon area
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isAvatar
                        ? AppColors.surfaceContainer
                        : isPowerup
                            ? const Color(0xFFFEE2E2).withValues(alpha: 0.3)
                            : AppColors.surfaceContainer,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: isAvatar
                        ? Icon(
                            Icons.person,
                            size: 64,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          )
                        : isPowerup
                            ? Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.error,
                                ),
                                child: const Icon(
                                  Icons.rocket_launch,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              )
                            : isTheme
                                ? Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFFB59A),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.palette,
                                        size: 40,
                                        color: Color(0xFF611E00),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                  ),
                ),
                if (item['badge'] != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (item['badgeColor'] as Color? ?? Colors.black54)
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item['badge'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info + buy
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.diamond,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${item['price']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _showPurchaseDialog(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'شراء',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideCard(Map<String, dynamic> item) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Icon area
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.auto_stories,
                    size: 48, color: AppColors.primary),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item['badge'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1B22),
                      ),
                    ),
                    if (item['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['description'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showPurchaseDialog(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text(
                            'فتح الآن',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.diamond,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item['price']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  // ─── Purchase Dialog ─────────────────────────────────────────────────────

  void _showPurchaseDialog(Map<String, dynamic> item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('تأكيد الشراء'),
          content: Text(
            'هل تريد شراء "${item['title']}" مقابل ${item['price']} نقطة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم شراء "${item['title']}" بنجاح!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('شراء'),
            ),
          ],
        ),
      ),
    );
  }
}
