import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Screen 72 — الدعم الفني والمساعدة (Technical Support & Help)
/// Matches design: _72/code.html
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              _buildHero(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildContactSupport(),
              const SizedBox(height: 24),
              _buildTutorials(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {},
          ),
          const Text(
            'التقييم الذكي',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      actions: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFE8E7F0),
          child: const Icon(Icons.person, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      children: const [
        Text(
          'الدعم الفني والمساعدة',
          style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'نحن هنا للإجابة على استفساراتك ومساعدتك في رحلتك التعليمية.',
          style: TextStyle(color: AppColors.outline, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: 'كيف يمكننا مساعدتك اليوم؟',
        hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.outline),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC4C5D5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC4C5D5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الأقسام الرئيسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        // Full-width general card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('عام', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('الأسئلة الشائعة حول المنصة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Icon(Icons.help_center_outlined, color: Colors.white, size: 40),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCategoryCard(Icons.settings_outlined, 'تقني', 'حلول المشاكل الفنية', const Color(0xFFD0E1FB), const Color(0xFF54647A))),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryCard(Icons.payments_outlined, 'الفواتير', 'الاشتراكات والمدفوعات', const Color(0xFFFFDBCE), const Color(0xFF802A00))),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(IconData icon, String title, String subtitle, Color iconBg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppColors.outline, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD0E1FB).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E1FB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.support_agent_outlined, color: Color(0xFF1E40AF), size: 32),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تواصل مع الدعم', style: TextStyle(color: Color(0xFF1E40AF), fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('فريقنا متواجد 24/7 لمساعدتك', style: TextStyle(color: Color(0xFF54647A), fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: const Text('بدء محادثة فورية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.confirmation_number_outlined, size: 18),
              label: const Text('فتح تذكرة دعم'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorials() {
    final tutorials = [
      _Tutorial(title: 'كيفية بدء اختبارك الأول', duration: '3 دقائق • فيديو', icon: Icons.play_circle_outline),
      _Tutorial(title: 'فهم تقارير الأداء', duration: '5 دقائق • مقال', icon: Icons.article_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('شروحات تعليمية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(onPressed: () {}, child: const Text('عرض الكل', style: TextStyle(color: AppColors.primary))),
          ],
        ),
        const SizedBox(height: 8),
        ...tutorials.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC4C5D5)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E7F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.play_circle_filled, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(t.duration, style: const TextStyle(color: AppColors.outline, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(t.icon, color: AppColors.primary, size: 24),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'الرئيسية', false),
          _navItem(Icons.assignment_outlined, 'الاختبارات', false),
          _navItem(Icons.folder_open, 'المصادر', true),
          _navItem(Icons.analytics_outlined, 'التقارير', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? AppColors.primary : AppColors.outline, size: 24),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.primary : AppColors.outline)),
      ],
    );
  }
}

class _Tutorial {
  final String title;
  final String duration;
  final IconData icon;
  const _Tutorial({required this.title, required this.duration, required this.icon});
}
