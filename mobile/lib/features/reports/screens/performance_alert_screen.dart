import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Performance Alert Screen — Screen 36
/// Displays a performance alert for a specific student with:
/// - Amber warning header card with colored left border
/// - Student info card (photo, name, class, subject)
/// - Reason detail card with red error-container background showing drop %
/// - Metric cards grid: المعدل الحالي, نسبة الحضور
/// - Weekly bar chart (mastery trend)
/// - Action buttons: تواصل مع الطالب، جدولة مراجعة، التقرير الكامل
class PerformanceAlertScreen extends StatelessWidget {
  const PerformanceAlertScreen({
    super.key,
    this.studentId,
    this.studentName,
    this.className,
    this.subject,
    this.currentAverage,
    this.attendanceRate,
    this.dropPercentage,
    this.weeklyData,
  });

  final String? studentId;
  final String? studentName;
  final String? className;
  final String? subject;
  final double? currentAverage;
  final double? attendanceRate;
  final int? dropPercentage;
  final List<double>? weeklyData;

  @override
  Widget build(BuildContext context) {
    // Use provided data or fall back to design defaults
    final name = studentName ?? 'أحمد محمد العتيبي';
    final classLabel = className ?? 'الصف العاشر - ب';
    final subjectLabel = subject ?? 'مادة الرياضيات';
    final average = currentAverage ?? 72.0;
    final attendance = attendanceRate ?? 94.0;
    final drop = dropPercentage ?? 15;
    final weekly = weeklyData ?? [0.80, 0.85, 0.90, 0.72];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(context),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          children: [
            // ── Alert Header Card ──────────────────────────────────────────
            const _AlertHeaderCard(),
            const SizedBox(height: 24),

            // ── Student Info Card ──────────────────────────────────────────
            _StudentInfoCard(
              name: name,
              classLabel: classLabel,
              subjectLabel: subjectLabel,
            ),
            const SizedBox(height: 12),

            // ── Reason Detail Card ─────────────────────────────────────────
            _ReasonDetailCard(drop: drop),
            const SizedBox(height: 12),

            // ── Metric Cards Grid ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'المعدل الحالي',
                    value: '${average.round()}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'نسبة الحضور',
                    value: '${attendance.round()}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Weekly Bar Chart ───────────────────────────────────────────
            _MasteryChartCard(weeklyData: weekly),
            const SizedBox(height: 24),

            // ── Action Buttons ─────────────────────────────────────────────
            _ActionButtons(
              onContact: () => _onContact(context),
              onSchedule: () => _onSchedule(context),
              onFullReport: () => _onFullReport(context),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Color(0xFF64748B)),
          onPressed: () => context.pop(),
          tooltip: 'رجوع',
        ),
        title: const Text(
          'التدريب الذكي',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E40AF),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF64748B)),
            onPressed: () => context.push('/teacher/notifications'),
            tooltip: 'الإشعارات',
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBZG8wAPrHsUncU6hNOfSRbqUNrpj62MiXnhnoV-kSeiIoBR_ytNIAs9j4bn1pjoXTvaei3TAVGFgCwRYNlzsY2oxehfuGhge_jrROrZEvZ14qtdanp6bMt05dGMfKZWwUCaSba3HmPm3eMGzs17b0Kr5EGppwI4LrcWfUJDFsQYvS8yenUm6Wch-Y_6n-BCN1belf91zMP4Gl94s60P_fjoggOsZZpJDecSYj5anh_43k_mtAfJ08y55lcRf-1RKt9QXw2emx3',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  void _onContact(BuildContext context) {
    final msgController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('إرسال رسالة للطالب',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: msgController,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم إرسال الرسالة للطالب'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF2E7D32)),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('إرسال',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _onSchedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('جدولة مراجعة'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_outlined, size: 48, color: Color(0xFF1E40AF)),
            SizedBox(height: 12),
            Text('سيتم جدولة مراجعة مع الطالب خلال الأسبوع القادم.',
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('تم جدولة المراجعة بنجاح'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF2E7D32)),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _onFullReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري فتح التقرير الكامل...')),
    );
  }
}

// ─── Alert Header Card ─────────────────────────────────────────────────────

class _AlertHeaderCard extends StatelessWidget {
  const _AlertHeaderCard();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amber left border (right in RTL = leading side)
              Container(
                width: 8,
                color: const Color(0xFFF59E0B), // amber-500
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning icon circle
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFBEB), // amber-50
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          color: Color(0xFFD97706), // amber-600
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تنبيه: تراجع ملحوظ في الأداء',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تم الكشف عن انخفاض مفاجئ يتطلب تدخلًا تربويًا',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Student Info Card ─────────────────────────────────────────────────────

class _StudentInfoCard extends StatelessWidget {
  const _StudentInfoCard({
    required this.name,
    required this.classLabel,
    required this.subjectLabel,
  });

  final String name;
  final String classLabel;
  final String subjectLabel;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Student photo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainer,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCzxPOImoH_gsGadfE0jgW6U5mhQcBGyQjUIgCmBqw-cm9mgA1yjOV4eieR_PTknNUNIkDjMMTzzK_0DDdDdE2GnJ_9m88XX_wfPc6gMoup1PugYh_Gm23NCGAInQNsaiLM6CiwFmjJLDSMUk8v8okwRcWwEDjs8DKFf2P7tKEKGjy_BUmOBCp6XLXhmuHu0tibWBm3nYSPaphwA529uq8WyBYqOVf3Gu-9LezGuzq9iTplX_kHDtV9QQrwIE8',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceContainer,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.outline,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _InfoChip(
                        label: classLabel,
                        backgroundColor: AppColors.surfaceContainer,
                        textColor: AppColors.outline,
                      ),
                      _InfoChip(
                        label: subjectLabel,
                        backgroundColor:
                            AppColors.primaryContainer.withValues(alpha: 0.1),
                        textColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: textColor),
        ),
      );
}

// ─── Reason Detail Card ────────────────────────────────────────────────────

class _ReasonDetailCard extends StatelessWidget {
  const _ReasonDetailCard({required this.drop});

  final int drop;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السبب الرئيسي',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '-$drop%',
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'انخفاض بنسبة $drop% في درجات اختبارات الوحدة الثانية (الجبر المتقدم) مقارنة بمتوسط درجات الطالب في الفصل الدراسي الأول.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      );
}

// ─── Metric Card ───────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

// ─── Mastery Chart Card ────────────────────────────────────────────────────

class _MasteryChartCard extends StatelessWidget {
  const _MasteryChartCard({required this.weeklyData});

  /// List of values between 0.0 and 1.0 representing weekly mastery percentages.
  final List<double> weeklyData;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مسار التحصيل الأكاديمي',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: _WeeklyBarChart(data: weeklyData),
            ),
            const SizedBox(height: 16),
            _WeeklyLabels(count: weeklyData.length),
          ],
        ),
      );
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final lastIndex = data.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(data.length, (i) {
        final isLast = i == lastIndex;
        final barColor =
            isLast ? AppColors.primaryContainer : AppColors.surfaceContainer;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // "الآن" label above the last bar
                if (isLast)
                  const Positioned(
                    top: -24,
                    child: Text(
                      'الآن',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                // Bar
                FractionallySizedBox(
                  heightFactor: data[i],
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _WeeklyLabels extends StatelessWidget {
  const _WeeklyLabels({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(count, (i) {
          final isLast = i == count - 1;
          return Text(
            'أسبوع ${i + 1}',
            style: AppTextStyles.labelSmall.copyWith(
              color: isLast ? AppColors.primary : AppColors.outline,
              fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        }),
      );
}

// ─── Action Buttons ────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onContact,
    required this.onSchedule,
    required this.onFullReport,
  });

  final VoidCallback onContact;
  final VoidCallback onSchedule;
  final VoidCallback onFullReport;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Primary: تواصل مع الطالب
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onContact,
              icon: const Icon(Icons.chat_outlined, size: 20),
              label: const Text('تواصل مع الطالب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary row: جدولة مراجعة + التقرير الكامل
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSchedule,
                  icon: const Icon(Icons.event_outlined, size: 20),
                  label: const Text('جدولة مراجعة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onFullReport,
                  icon: const Icon(Icons.analytics_outlined, size: 20),
                  label: const Text('التقرير الكامل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}
