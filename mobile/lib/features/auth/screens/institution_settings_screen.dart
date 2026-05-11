import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

/// Screen 69 — إعدادات المؤسسة (Institution Settings)
/// Matches design: _69/code.html
class InstitutionSettingsScreen extends StatefulWidget {
  const InstitutionSettingsScreen({super.key});

  @override
  State<InstitutionSettingsScreen> createState() =>
      _InstitutionSettingsScreenState();
}

class _InstitutionSettingsScreenState
    extends State<InstitutionSettingsScreen> {
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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSchoolProfile(),
              const SizedBox(height: 16),
              _buildSettingsGroup(
                title: 'الهيكل الأكاديمي',
                items: [
                  _SettingsItem(icon: Icons.calendar_today_outlined, title: 'الأعوام الدراسية', subtitle: 'إدارة الفصول والتواريخ الدراسية'),
                  _SettingsItem(icon: Icons.grade_outlined, title: 'مقاييس التقييم', subtitle: 'تحديد سلم الدرجات والتقديرات'),
                ],
              ),
              const SizedBox(height: 12),
              _buildSettingsGroup(
                title: 'إدارة المستخدمين',
                items: [
                  _SettingsItem(icon: Icons.admin_panel_settings_outlined, title: 'الأدوار والصلاحيات', subtitle: 'تخصيص وصول المعلمين والإداريين'),
                  _SettingsItem(icon: Icons.history_edu_outlined, title: 'سجلات الأنشطة', subtitle: 'تتبع الدخول وتغييرات النظام'),
                ],
              ),
              const SizedBox(height: 12),
              _buildSettingsGroup(
                title: 'تفضيلات النظام',
                items: [
                  _SettingsItem(icon: Icons.notifications_active_outlined, title: 'إعدادات التنبيهات', subtitle: 'البريد الإلكتروني والإشعارات الفورية'),
                  _SettingsItem(icon: Icons.translate_outlined, title: 'اللغة والمنطقة', subtitle: 'اللغة العربية، التوقيت المحلي'),
                  _SettingsItem(icon: Icons.hub_outlined, title: 'تكامل الأنظمة', subtitle: 'ربط API والمزودين الخارجيين'),
                ],
              ),
              const SizedBox(height: 20),
              _buildDangerZone(),
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
            backgroundColor: const Color(0xFF1E40AF),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'EduAssess',
            style: TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا توجد إشعارات جديدة'), behavior: SnackBarBehavior.floating),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'إعدادات المؤسسة',
          style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text(
          'إدارة الهوية الأكاديمية وصلاحيات النظام',
          style: TextStyle(color: AppColors.outline, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSchoolProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.school_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('ملف المدرسة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              TextButton(
                onPressed: () {
                  final nameController = TextEditingController(text: 'أكاديمية المستقبل الدولية');
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('تعديل ملف المدرسة'),
                      content: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'اسم المؤسسة'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم تحديث بيانات المؤسسة'), behavior: SnackBarBehavior.floating),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          child: const Text('حفظ'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('تعديل', style: TextStyle(color: AppColors.primary, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC4C5D5), style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.school, color: AppColors.primary, size: 32),
                    SizedBox(height: 4),
                    Text('تغيير الشعار', style: TextStyle(fontSize: 9, color: AppColors.outline)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('اسم المؤسسة', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                    const Text(
                      'أكاديمية المستقبل الدولية',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text('معلومات التواصل', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                    const Text('+966 500 000 000', style: TextStyle(fontSize: 13)),
                    const Text('contact@future-academy.edu', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required List<_SettingsItem> items}) {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F2FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFC4C5D5))),
            ),
            child: Text(
              title,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    if (item.title == 'الأدوار والصلاحيات') {
                      context.push('/admin/users');
                    } else if (item.title == 'سجلات الأنشطة') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سجلات الأنشطة قيد التطوير'), behavior: SnackBarBehavior.floating),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.title}: قيد التطوير'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              Text(item.subtitle, style: const TextStyle(color: AppColors.outline, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left, color: AppColors.outline),
                      ],
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  const Divider(height: 1, color: Color(0xFFC4C5D5), indent: 16, endIndent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('تحذير: أرشفة البيانات'),
            content: const Text('هذا الإجراء سيؤدي إلى أرشفة جميع بيانات المؤسسة. هل أنت متأكد؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إرسال طلب الأرشفة للمراجعة'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.error),
                  );
                },
                child: const Text('تأكيد الأرشفة', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
      label: const Text('أرشفة بيانات المؤسسة', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.error),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(double.infinity, 0),
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
          _navItem(Icons.home_outlined, 'الرئيسية', false, onTap: () => context.go(AppRoutes.adminDashboard)),
          _navItem(Icons.quiz_outlined, 'الاختبارات', false, onTap: () => context.go(AppRoutes.teacherAssessments)),
          _navItem(Icons.bar_chart_outlined, 'التقارير', false, onTap: () => context.go(AppRoutes.adminReports)),
          _navItem(Icons.settings, 'الإعدادات', true, onTap: null),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF1E40AF) : Colors.grey, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: active ? const Color(0xFF1E40AF) : Colors.grey)),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SettingsItem({required this.icon, required this.title, required this.subtitle});
}
