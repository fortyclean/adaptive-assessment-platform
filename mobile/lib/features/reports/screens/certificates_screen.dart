import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Screen 71 — الشهادات والنتائج النهائية (Certificates & Final Results)
/// Matches design: _71/code.html
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  final List<_StudentResult> _students = const [
    _StudentResult(initials: 'أ.ع', name: 'أحمد علي منصور', score: 98.5, grade: 'ممتاز', gradeColor: Color(0xFF611E00), status: ResultStatus.passed),
    _StudentResult(initials: 'س.ك', name: 'سارة كمال السعدي', score: 94.2, grade: 'امتياز', gradeColor: Color(0xFF611E00), status: ResultStatus.passed),
    _StudentResult(initials: 'م.خ', name: 'محمد خالد الحربي', score: 87.0, grade: 'جيد جداً', gradeColor: Color(0xFF54647A), status: ResultStatus.warning),
    _StudentResult(initials: 'ل.س', name: 'ليلى سالم العتيبي', score: 91.8, grade: 'امتياز', gradeColor: Color(0xFF611E00), status: ResultStatus.passed),
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
              _buildPageHeader(context),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 16),
              _buildCertificatePreview(),
              const SizedBox(height: 20),
              _buildStudentsList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('إنشاء شهادة جديدة'), behavior: SnackBarBehavior.floating),
            );
          },
          backgroundColor: const Color(0xFF1E40AF),
          shape: const CircleBorder(),
          child: const Icon(Icons.auto_awesome, color: Colors.white),
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
            backgroundColor: const Color(0xFFE8E7F0),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'التقييم الذكي',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'الشهادات والنتائج النهائية',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1B22)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('تصدير الشهادات'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('اختر صيغة التصدير:'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('جاري تصدير الشهادات بصيغة PDF...'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('جاري تصدير البيانات بصيغة Excel...'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('Excel'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                ],
              ),
            );
          },
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('تصدير الكل', style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(Icons.school_outlined, 'الصف الدراسي', 'الصف التاسع - أ'),
          const SizedBox(width: 10),
          _filterChip(Icons.calendar_today_outlined, 'العام الأكاديمي', '2023 - 2024'),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E7F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC4C5D5)),
            ),
            child: const Icon(Icons.tune, color: AppColors.onSurfaceVariant, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C5D5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.outline, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.white, Color(0xFFEEEDF7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC4C5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF872D00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('نموذج معتمد', style: TextStyle(color: Color(0xFFFFA583), fontSize: 11)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'تصميم الشهادة الحالية',
                    style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Icon(Icons.verified, color: AppColors.primary, size: 32),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC4C5D5), style: BorderStyle.solid, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, color: AppColors.primary, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'شهادة إتمام',
                  style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'أكاديمية المستقبل الدولية',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (ctx) => TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('محرر قالب الشهادة قيد التطوير'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    child: const Text('تعديل القالب', style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('قائمة الطلاب (24)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('مرتب حسب: المعدل', style: TextStyle(color: AppColors.outline, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        ..._students.map(_buildStudentCard),
      ],
    );
  }

  Widget _buildStudentCard(_StudentResult student) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC4C5D5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFD3E4FE),
                  child: Text(
                    student.initials,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: student.status == ResultStatus.passed ? Colors.green : Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      student.status == ResultStatus.passed ? Icons.check : Icons.priority_high,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('النتيجة النهائية:', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        '${student.score}%',
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFC4C5D5), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(student.grade, style: TextStyle(color: student.gradeColor, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDF7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_outlined, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
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
          _navItem(Icons.folder_open_outlined, 'المصادر', false),
          _navItem(Icons.analytics, 'التقارير', true),
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

enum ResultStatus { passed, warning }

class _StudentResult {
  final String initials;
  final String name;
  final double score;
  final String grade;
  final Color gradeColor;
  final ResultStatus status;

  const _StudentResult({
    required this.initials,
    required this.name,
    required this.score,
    required this.grade,
    required this.gradeColor,
    required this.status,
  });
}
