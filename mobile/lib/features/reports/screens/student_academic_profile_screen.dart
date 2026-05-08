import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Student Academic Profile Screen — Screen 65
/// Teacher view of a student's full academic profile:
/// identity header, academic summary bento, subject performance,
/// interaction stats, recent exam results, and teacher notes.
class StudentAcademicProfileScreen extends ConsumerStatefulWidget {
  const StudentAcademicProfileScreen({
    super.key,
    this.studentId,
    this.studentName,
  });

  final String? studentId;
  final String? studentName;

  @override
  ConsumerState<StudentAcademicProfileScreen> createState() =>
      _StudentAcademicProfileScreenState();
}

class _StudentAcademicProfileScreenState
    extends ConsumerState<StudentAcademicProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final name = widget.studentName ?? 'أحمد خالد المنصوري';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildIdentityHeader(name),
                const SizedBox(height: 16),
                _buildAcademicSummary(),
                const SizedBox(height: 16),
                _buildChartsRow(),
                const SizedBox(height: 16),
                _buildRecentExamResults(),
                const SizedBox(height: 16),
                _buildTeacherNotes(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const AppBottomNav(currentIndex: 2, role: 'teacher'),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notifications + avatar (RTL: left)
          Row(
            children: [
              const Icon(Icons.notifications_outlined,
                  color: Color(0xFF475569), size: 24),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFDDE1FF),
                    width: 2,
                  ),
                  color: AppColors.surfaceContainer,
                ),
                child: const Icon(Icons.person, size: 22, color: Color(0xFF444653)),
              ),
            ],
          ),
          // Back + title (RTL: right)
          Row(
            children: [
              const Text(
                'EduAssess',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                color: const Color(0xFF475569),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Identity Header ──────────────────────────────────────────────────────

  Widget _buildIdentityHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Action buttons (RTL: left)
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('تقرير'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E40AF),
                      side: const BorderSide(color: Color(0xFF1E40AF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('تواصل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E40AF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Name + info (RTL: right)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1B22),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'الرقم الأكاديمي: #EDU-2024-0891',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontFamily: 'Lexend',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      children: [
                        _buildTag('الصف العاشر - أ',
                            const Color(0xFFEFF6FF), const Color(0xFF1E40AF),
                            const Color(0xFFBFDBFE)),
                        _buildTag('مسار متقدم',
                            const Color(0xFFF8FAFC), const Color(0xFF475569),
                            const Color(0xFFE2E8F0)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Avatar (RTL: far right)
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surfaceContainer,
                      border: Border.all(
                        color: const Color(0xFFDDE1FF),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0] : '؟',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'نشط',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color textColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // ─── Academic Summary Bento ───────────────────────────────────────────────

  Widget _buildAcademicSummary() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildSummaryBentoCard(
          label: 'المعدل التراكمي',
          value: '3.85',
          trailing: Row(
            children: const [
              Icon(Icons.trending_up, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 2),
              Text(
                '+0.12 الشهر الماضي',
                style: TextStyle(fontSize: 11, color: Color(0xFF10B981)),
              ),
            ],
          ),
        ),
        _buildSummaryBentoCard(
          label: 'نسبة الحضور',
          value: '94%',
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.94,
              backgroundColor: Color(0xFFF1F5F9),
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 6,
            ),
          ),
        ),
        _buildSummaryBentoCard(
          label: 'الاختبارات المكتملة',
          value: '24/26',
          trailing: const Text(
            'بانتظار اختبارين',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ),
        _buildSummaryBentoCard(
          label: 'السلوك العام',
          value: '',
          trailing: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...List.generate(
                4,
                (_) => const Icon(Icons.star, size: 18, color: Color(0xFF1E40AF)),
              ),
              const Icon(Icons.star_border, size: 18, color: Color(0xFF1E40AF)),
            ],
          ),
          extraLabel: 'ممتاز جداً',
        ),
      ],
    );
  }

  Widget _buildSummaryBentoCard({
    required String label,
    required String value,
    required Widget trailing,
    String? extraLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.right,
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E40AF),
              ),
            ),
          trailing,
          if (extraLabel != null)
            Text(
              extraLabel,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.right,
            ),
        ],
      ),
    );
  }

  // ─── Charts Row ───────────────────────────────────────────────────────────

  Widget _buildChartsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interaction stats (RTL: left)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'إحصائيات التفاعل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                _buildInteractionStat(
                  percentage: 88,
                  label: 'المشاركة الصفية',
                  sublabel: 'مرتفع مقارنة بالأقران',
                  color: const Color(0xFF1E40AF),
                ),
                const SizedBox(height: 12),
                _buildInteractionStat(
                  percentage: 62,
                  label: 'العمل الجماعي',
                  sublabel: 'يحتاج إلى تحسين بسيط',
                  color: const Color(0xFFFB923C),
                ),
                const SizedBox(height: 12),
                _buildInteractionStat(
                  percentage: 95,
                  label: 'الواجبات المنزلية',
                  sublabel: 'التزام تام بالمواعيد',
                  color: const Color(0xFFA855F7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Subject performance (RTL: right)
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'الفصل الدراسي الأول',
                        style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ),
                    const Text(
                      'أداء المواد الدراسية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1B22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Subject bars
                _buildSubjectBar('الرياضيات', 0.92, const Color(0xFF1E40AF)),
                const SizedBox(height: 8),
                _buildSubjectBar('العلوم', 0.85, const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _buildSubjectBar('اللغة العربية', 0.78, const Color(0xFFF59E0B)),
                const SizedBox(height: 8),
                _buildSubjectBar('التاريخ', 0.70, const Color(0xFFA855F7)),
                const SizedBox(height: 8),
                _buildSubjectBar('الفيزياء', 0.88, const Color(0xFF06B6D4)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionStat({
    required int percentage,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1B22),
                ),
                textAlign: TextAlign.right,
              ),
              Text(
                sublabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 4,
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1B22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectBar(String subject, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              subject,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1B22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // ─── Recent Exam Results ──────────────────────────────────────────────────

  Widget _buildRecentExamResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
                const Text(
                  'آخر نتائج الاختبارات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildExamResultRow(
            icon: Icons.functions,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF1E40AF),
            title: 'اختبار التفاضل والتكامل',
            date: '12 أكتوبر 2024',
            score: '98/100',
            scoreColor: const Color(0xFF1E40AF),
            badge: 'متفوق',
            badgeBg: const Color(0xFFD1FAE5).withOpacity(0.5),
            badgeColor: const Color(0xFF10B981),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildExamResultRow(
            icon: Icons.science_outlined,
            iconBg: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
            title: 'كيمياء عضوية - عملي',
            date: '08 أكتوبر 2024',
            score: '85/100',
            scoreColor: const Color(0xFF1A1B22),
            badge: 'جيد جداً',
            badgeBg: const Color(0xFFEFF6FF),
            badgeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildExamResultRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String date,
    required String score,
    required Color scoreColor,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Score + badge (RTL: left)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                score,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Title + date (RTL: center-right)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1B22),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Icon (RTL: right)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  // ─── Teacher Notes ────────────────────────────────────────────────────────

  Widget _buildTeacherNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('إضافة ملاحظة'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E40AF),
                ),
              ),
              const Text(
                'ملاحظات المعلم السلوكية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1B22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNoteCard(
            teacherName: 'أ. سارة الأحمد',
            timeAgo: 'منذ يومين',
            note:
                'أظهر الطالب مهارات قيادية متميزة خلال المشروع الجماعي الأسبوع الماضي. لديه قدرة عالية على تبسيط المفاهيم المعقدة لزملائه.',
            accentColor: const Color(0xFF1E40AF),
          ),
          const SizedBox(height: 12),
          _buildNoteCard(
            teacherName: 'أ. محمد عمر',
            timeAgo: 'منذ أسبوع',
            note:
                'يحتاج الطالب إلى التركيز أكثر على مراجعة التفاصيل الصغيرة في حلول المسائل الرياضية لتفادي الأخطاء البسيطة.',
            accentColor: const Color(0xFFFB923C),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard({
    required String teacherName,
    required String timeAgo,
    required String note,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          right: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                teacherName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1B22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
