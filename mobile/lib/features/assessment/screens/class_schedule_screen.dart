import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Class Schedule Screen — Design _70 (الجداول الدراسية)
/// Weekly timetable with subject color coding and RTL Arabic layout.
class ClassScheduleScreen extends StatefulWidget {
  const ClassScheduleScreen({super.key});

  @override
  State<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  int _selectedDayIndex = 0;

  final List<_DayItem> _days = const [
    _DayItem(name: 'الأحد', date: '15'),
    _DayItem(name: 'الاثنين', date: '16'),
    _DayItem(name: 'الثلاثاء', date: '17'),
    _DayItem(name: 'الأربعاء', date: '18'),
    _DayItem(name: 'الخميس', date: '19'),
  ];

  final List<_ScheduleItem> _schedule = const [
    _ScheduleItem(
      time: '08:00',
      subject: 'الرياضيات',
      teacher: 'أ. أحمد المنصور',
      location: 'مختبر 4 - الطابق الثاني',
      tag: 'المستوى المتقدم',
      accentColor: AppColors.primary,
      tagBg: Color(0xFFDDE1FF),
      tagFg: Color(0xFF001453),
      isBreak: false,
    ),
    _ScheduleItem(
      time: '09:30',
      subject: 'العلوم الطبيعية',
      teacher: 'د. سارة العتيبي',
      location: 'القاعة الكبرى',
      tag: 'فيزياء',
      accentColor: Color(0xFF611E00),
      tagBg: Color(0xFFFFDBCE),
      tagFg: Color(0xFF380D00),
      isBreak: false,
    ),
    _ScheduleItem(
      time: '11:00',
      subject: 'استراحة الصلاة والغداء',
      teacher: '',
      location: '',
      tag: '',
      accentColor: Colors.transparent,
      tagBg: Colors.transparent,
      tagFg: Colors.transparent,
      isBreak: true,
    ),
    _ScheduleItem(
      time: '12:30',
      subject: 'اللغة العربية',
      teacher: 'أ. فاطمة الزهراء',
      location: 'فصل 302',
      tag: 'أدب ونصوص',
      accentColor: Color(0xFF802A00),
      tagBg: Color(0xFFD3E4FE),
      tagFg: Color(0xFF0B1C30),
      isBreak: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                child: Column(
                  children: [
                    _buildWeeklyCalendar(),
                    const SizedBox(height: 24),
                    _buildTimeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        bottomNavigationBar: const AppBottomNav(
          currentIndex: 1,
          role: 'teacher',
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        right: 16,
        left: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + Title (RTL: right side)
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
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'الجداول الدراسية',
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          // Menu button (RTL: left side)
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            color: AppColors.primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ─── Weekly Calendar ─────────────────────────────────────────────────────

  Widget _buildWeeklyCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0E1FB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'سبتمبر 2024',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF54647A),
                  ),
                ),
              ),
              const Text(
                'جدول الأسبوع',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // RTL scroll
            child: Row(
              children: _days.asMap().entries.map((entry) {
                final i = entry.key;
                final day = entry.value;
                final isActive = i == _selectedDayIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isActive
                          ? null
                          : Border.all(color: AppColors.outlineVariant),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.name,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white.withOpacity(0.85)
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.date,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Timeline ────────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    return Column(
      children: _schedule.map((item) => _buildTimelineItem(item)).toList(),
    );
  }

  Widget _buildTimelineItem(_ScheduleItem item) {
    if (item.isBreak) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column (RTL: right)
            SizedBox(
              width: 48,
              child: Text(
                item.time,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.outline,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 16),
            // Break card
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.subject,
                    style: const TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time + line (RTL: right)
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Text(
                  item.time,
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 2,
                  height: 80,
                  color: AppColors.outlineVariant,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Lesson card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subject + tag row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tag (RTL: left)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.tagBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.tag,
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: item.tagFg,
                          ),
                        ),
                      ),
                      // Subject name (RTL: right)
                      Text(
                        item.subject,
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: item.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Teacher row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.teacher,
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Location row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.location,
                        style: const TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.outline,
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
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.edit_calendar_outlined),
      label: const Text(
        'إضافة / تعديل حصة',
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _DayItem {
  const _DayItem({required this.name, required this.date});
  final String name;
  final String date;
}

class _ScheduleItem {
  const _ScheduleItem({
    required this.time,
    required this.subject,
    required this.teacher,
    required this.location,
    required this.tag,
    required this.accentColor,
    required this.tagBg,
    required this.tagFg,
    required this.isBreak,
  });

  final String time;
  final String subject;
  final String teacher;
  final String location;
  final String tag;
  final Color accentColor;
  final Color tagBg;
  final Color tagFg;
  final bool isBreak;
}
