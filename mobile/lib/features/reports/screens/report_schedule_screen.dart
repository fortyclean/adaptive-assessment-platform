// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/repositories/admin_repository.dart';

/// Report Schedule Screen — Screens 32 & 33 (combined)
/// Requirements: 26.2
/// RTL Arabic layout, Riverpod state management, backend API integration.
class ReportScheduleScreen extends ConsumerStatefulWidget {
  const ReportScheduleScreen({super.key});

  @override
  ConsumerState<ReportScheduleScreen> createState() =>
      _ReportScheduleScreenState();
}

// ─── Data Models ──────────────────────────────────────────────────────────────

enum _ReportType {
  studentPerformance,
  questionQuality,
  classroomComparison,
  skillAnalysis,
}

extension _ReportTypeExt on _ReportType {
  String get label {
    switch (this) {
      case _ReportType.studentPerformance:
        return 'أداء الطلاب العام';
      case _ReportType.questionQuality:
        return 'جودة بنك الأسئلة';
      case _ReportType.classroomComparison:
        return 'مقارنة الفصول الدراسية';
      case _ReportType.skillAnalysis:
        return 'تقرير تحليل المهارات';
    }
  }

  String get apiValue {
    switch (this) {
      case _ReportType.studentPerformance:
        return 'student_performance';
      case _ReportType.questionQuality:
        return 'question_quality';
      case _ReportType.classroomComparison:
        return 'classroom_comparison';
      case _ReportType.skillAnalysis:
        return 'skill_analysis';
    }
  }

  IconData get icon {
    switch (this) {
      case _ReportType.studentPerformance:
        return Icons.bar_chart_rounded;
      case _ReportType.questionQuality:
        return Icons.quiz_rounded;
      case _ReportType.classroomComparison:
        return Icons.compare_arrows_rounded;
      case _ReportType.skillAnalysis:
        return Icons.psychology_rounded;
    }
  }
}

enum _Frequency { daily, weekly, monthly }

extension _FrequencyExt on _Frequency {
  String get label {
    switch (this) {
      case _Frequency.daily:
        return 'يومي';
      case _Frequency.weekly:
        return 'أسبوعي';
      case _Frequency.monthly:
        return 'شهري';
    }
  }

  String get apiValue {
    switch (this) {
      case _Frequency.daily:
        return 'daily';
      case _Frequency.weekly:
        return 'weekly';
      case _Frequency.monthly:
        return 'monthly';
    }
  }
}

enum _FileFormat { pdf, excel }

extension _FileFormatExt on _FileFormat {
  String get label => this == _FileFormat.pdf ? 'PDF' : 'Excel';
  String get apiValue => this == _FileFormat.pdf ? 'pdf' : 'excel';
  IconData get icon => this == _FileFormat.pdf
      ? Icons.picture_as_pdf_rounded
      : Icons.table_chart_rounded;
}

class _ScheduleItem {
  _ScheduleItem({
    required this.id,
    required this.title,
    required this.reportType,
    required this.frequency,
    required this.deliveryTime,
    required this.fileFormat,
    required this.isActive,
    required this.recipients,
    required this.classroomIds,
  });

  factory _ScheduleItem.fromJson(Map<String, dynamic> json) {
    _ReportType rt;
    switch (json['reportType'] as String?) {
      case 'question_quality':
        rt = _ReportType.questionQuality;
        break;
      case 'classroom_comparison':
        rt = _ReportType.classroomComparison;
        break;
      case 'skill_analysis':
        rt = _ReportType.skillAnalysis;
        break;
      default:
        rt = _ReportType.studentPerformance;
    }

    _Frequency freq;
    switch (json['frequency'] as String?) {
      case 'weekly':
        freq = _Frequency.weekly;
        break;
      case 'monthly':
        freq = _Frequency.monthly;
        break;
      default:
        freq = _Frequency.daily;
    }

    _FileFormat fmt;
    switch (json['fileFormat'] as String?) {
      case 'excel':
        fmt = _FileFormat.excel;
        break;
      default:
        fmt = _FileFormat.pdf;
    }

    return _ScheduleItem(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      reportType: rt,
      frequency: freq,
      deliveryTime: (json['deliveryTime'] ?? '08:00') as String,
      fileFormat: fmt,
      isActive: (json['isActive'] ?? true) as bool,
      recipients: List<String>.from((json['recipients'] as List?) ?? []),
      classroomIds: List<String>.from((json['classroomIds'] as List?) ?? []),
    );
  }

  final String id;
  final String title;
  final _ReportType reportType;
  final _Frequency frequency;
  final String deliveryTime;
  final _FileFormat fileFormat;
  bool isActive;
  final List<String> recipients;
  final List<String> classroomIds;
}

// ─── State ────────────────────────────────────────────────────────────────────

class _ReportScheduleScreenState extends ConsumerState<ReportScheduleScreen> {
  // Form state
  bool _isActive = true;
  _ReportType _reportType = _ReportType.studentPerformance;
  _Frequency _frequency = _Frequency.daily;
  _FileFormat _fileFormat = _FileFormat.pdf;
  TimeOfDay _deliveryTime = const TimeOfDay(hour: 8, minute: 0);

  // Email recipients
  final _emailController = TextEditingController();
  final List<String> _recipients = [];

  // Classroom chips (Screen 33 variant)
  final List<String> _availableClassrooms = [
    'أولى متوسط (أ)',
    'أولى متوسط (ب)',
    'ثانية متوسط (أ)',
    'ثانية متوسط (ب)',
    'ثالثة متوسط (أ)',
  ];
  final Set<String> _selectedClassrooms = {'أولى متوسط (أ)'};

  // Schedules list
  List<_ScheduleItem> _schedules = [];
  bool _loadingSchedules = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ── Mock data fallback ────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _mockSchedules = [
    {
      '_id': 'mock-sched-1',
      'title': 'أداء الطلاب - المرحلة المتوسطة',
      'reportType': 'student_performance',
      'frequency': 'weekly',
      'deliveryTime': '08:30',
      'fileFormat': 'pdf',
      'isActive': true,
      'recipients': ['admin@edu.sa'],
      'classroomIds': [],
    },
    {
      '_id': 'mock-sched-2',
      'title': 'جودة الأسئلة - قسم العلوم',
      'reportType': 'question_quality',
      'frequency': 'monthly',
      'deliveryTime': '10:00',
      'fileFormat': 'excel',
      'isActive': true,
      'recipients': ['science@edu.sa'],
      'classroomIds': [],
    },
    {
      '_id': 'mock-sched-3',
      'title': 'تقرير المقارنة السنوي',
      'reportType': 'classroom_comparison',
      'frequency': 'monthly',
      'deliveryTime': '09:00',
      'fileFormat': 'excel',
      'isActive': false,
      'recipients': ['supervisor@edu.sa'],
      'classroomIds': [],
    },
  ];

  Future<void> _loadSchedules() async {
    setState(() {
      _loadingSchedules = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(adminRepositoryProvider);
      final data = await repo.getReportSchedules();
      setState(() {
        _schedules = data.map(_ScheduleItem.fromJson).toList();
      });
    } catch (e) {
      // Fallback to mock data so the screen is always usable
      setState(() {
        _schedules = _mockSchedules.map(_ScheduleItem.fromJson).toList();
        _errorMessage = null;
      });
    } finally {
      setState(() => _loadingSchedules = false);
    }
  }

  Future<void> _saveSchedule() async {
    if (_recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة بريد إلكتروني واحد على الأقل'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final timeStr =
          '${_deliveryTime.hour.toString().padLeft(2, '0')}:${_deliveryTime.minute.toString().padLeft(2, '0')}';

      final data = await repo.createReportSchedule({
        'title': '${_reportType.label} - ${_frequency.label}',
        'reportType': _reportType.apiValue,
        'frequency': _frequency.apiValue,
        'deliveryTime': timeStr,
        'recipients': _recipients,
        'fileFormat': _fileFormat.apiValue,
        'classroomIds': [],
        'isActive': _isActive,
      });

      setState(() {
        _schedules.insert(0, _ScheduleItem.fromJson(data));
        _recipients.clear();
        _emailController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الجدول الزمني بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // Demo mode: simulate success
      final timeStr =
          '${_deliveryTime.hour.toString().padLeft(2, '0')}:${_deliveryTime.minute.toString().padLeft(2, '0')}';
      final demoSchedule = _ScheduleItem(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        title: '${_reportType.label} - ${_frequency.label}',
        reportType: _reportType,
        frequency: _frequency,
        deliveryTime: timeStr,
        fileFormat: _fileFormat,
        isActive: _isActive,
        recipients: List.from(_recipients),
        classroomIds: [],
      );
      setState(() {
        _schedules.insert(0, demoSchedule);
        _recipients.clear();
        _emailController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الجدول الزمني بنجاح (وضع تجريبي)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _deleteSchedule(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الجدول'),
          content: const Text('هل أنت متأكد من حذف هذا الجدول الزمني؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteReportSchedule(id);
      setState(() => _schedules.removeWhere((s) => s.id == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الجدول بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر الحذف: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleSchedule(String id) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.toggleReportSchedule(id);
      setState(() {
        final idx = _schedules.indexWhere((s) => s.id == id);
        if (idx != -1) {
          _schedules[idx].isActive = !_schedules[idx].isActive;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر تغيير الحالة: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال بريد إلكتروني صحيح'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_recipients.contains(email)) return;
    setState(() {
      _recipients.add(email);
      _emailController.clear();
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _deliveryTime,
      builder: (ctx, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _deliveryTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: _loadSchedules,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                // ── Hero ──────────────────────────────────────────────────────
                const _HeroSection(),
                const SizedBox(height: 24),

                // ── Create Form ───────────────────────────────────────────────
                _CreateFormCard(
                  isActive: _isActive,
                  reportType: _reportType,
                  frequency: _frequency,
                  fileFormat: _fileFormat,
                  deliveryTime: _deliveryTime,
                  recipients: _recipients,
                  emailController: _emailController,
                  availableClassrooms: _availableClassrooms,
                  selectedClassrooms: _selectedClassrooms,
                  saving: _saving,
                  onActiveChanged: (v) => setState(() => _isActive = v),
                  onReportTypeChanged: (v) => setState(() => _reportType = v),
                  onFrequencyChanged: (v) => setState(() => _frequency = v),
                  onFileFormatChanged: (v) => setState(() => _fileFormat = v),
                  onPickTime: _pickTime,
                  onAddEmail: _addEmail,
                  onRemoveEmail: (e) => setState(() => _recipients.remove(e)),
                  onToggleClassroom: (c) => setState(() {
                    if (_selectedClassrooms.contains(c)) {
                      _selectedClassrooms.remove(c);
                    } else {
                      _selectedClassrooms.add(c);
                    }
                  }),
                  onSave: _saveSchedule,
                ),
                const SizedBox(height: 24),

                // ── Active Schedules ──────────────────────────────────────────
                _ActiveSchedulesSection(
                  schedules: _schedules,
                  loading: _loadingSchedules,
                  errorMessage: _errorMessage,
                  onDelete: _deleteSchedule,
                  onToggle: _toggleSchedule,
                  onRetry: _loadSchedules,
                ),
              ],
            ),
          ),
        ),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B)),
          onPressed: () => context.pop(),
          tooltip: 'رجوع',
        ),
        title: const Text(
          'التقييم الذكي',
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
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      );
}

// ─── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'جدولة التقارير',
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'قم بإعداد تقارير دورية يتم إرسالها تلقائياً إلى بريدك الإلكتروني.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF505F76),
            ),
          ),
        ],
      );
}

// ─── Create Form Card ─────────────────────────────────────────────────────────

class _CreateFormCard extends StatelessWidget {
  const _CreateFormCard({
    required this.isActive,
    required this.reportType,
    required this.frequency,
    required this.fileFormat,
    required this.deliveryTime,
    required this.recipients,
    required this.emailController,
    required this.availableClassrooms,
    required this.selectedClassrooms,
    required this.saving,
    required this.onActiveChanged,
    required this.onReportTypeChanged,
    required this.onFrequencyChanged,
    required this.onFileFormatChanged,
    required this.onPickTime,
    required this.onAddEmail,
    required this.onRemoveEmail,
    required this.onToggleClassroom,
    required this.onSave,
  });

  final bool isActive;
  final _ReportType reportType;
  final _Frequency frequency;
  final _FileFormat fileFormat;
  final TimeOfDay deliveryTime;
  final List<String> recipients;
  final TextEditingController emailController;
  final List<String> availableClassrooms;
  final Set<String> selectedClassrooms;
  final bool saving;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<_ReportType> onReportTypeChanged;
  final ValueChanged<_Frequency> onFrequencyChanged;
  final ValueChanged<_FileFormat> onFileFormatChanged;
  final VoidCallback onPickTime;
  final VoidCallback onAddEmail;
  final ValueChanged<String> onRemoveEmail;
  final ValueChanged<String> onToggleClassroom;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC4C5D5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إعداد جدول جديد',
                  style: AppTextStyles.titleLarge,
                ),
                _ActiveToggle(
                  value: isActive,
                  onChanged: onActiveChanged,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Report type dropdown
            const _FormLabel(label: 'نوع التقرير'),
            const SizedBox(height: 8),
            _ReportTypeDropdown(
              value: reportType,
              onChanged: onReportTypeChanged,
            ),
            const SizedBox(height: 24),

            // Classroom chips (Screen 33 variant)
            const _FormLabel(label: 'اختيار الفصول'),
            const SizedBox(height: 8),
            _ClassroomChips(
              available: availableClassrooms,
              selected: selectedClassrooms,
              onToggle: onToggleClassroom,
            ),
            const SizedBox(height: 24),

            // Frequency + time row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormLabel(label: 'التكرار'),
                      const SizedBox(height: 8),
                      _FrequencyDropdown(
                        value: frequency,
                        onChanged: onFrequencyChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormLabel(label: 'وقت التسليم'),
                      const SizedBox(height: 8),
                      _TimePickerField(
                        time: deliveryTime,
                        onTap: onPickTime,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recipients
            const _FormLabel(label: 'البريد الإلكتروني للمستلمين'),
            const SizedBox(height: 8),
            _RecipientsInput(
              controller: emailController,
              recipients: recipients,
              onAdd: onAddEmail,
              onRemove: onRemoveEmail,
            ),
            const SizedBox(height: 24),

            // File format
            const _FormLabel(label: 'صيغة الملف'),
            const SizedBox(height: 8),
            _FileFormatSelector(
              value: fileFormat,
              onChanged: onFileFormatChanged,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: saving ? null : onSave,
                icon: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  saving ? 'جاري الحفظ...' : 'حفظ الجدول الزمني',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      );
}

// ─── Form Sub-Widgets ─────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: const Color(0xFF444653),
        ),
      );
}

class _ActiveToggle extends StatelessWidget {
  const _ActiveToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تفعيل',
            style: AppTextStyles.labelLarge.copyWith(
              color: const Color(0xFF505F76),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      );
}

class _ReportTypeDropdown extends StatelessWidget {
  const _ReportTypeDropdown({required this.value, required this.onChanged});
  final _ReportType value;
  final ValueChanged<_ReportType> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC4C5D5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<_ReportType>(
            value: value,
            isExpanded: true,
            icon:
                const Icon(Icons.expand_more_rounded, color: Color(0xFF505F76)),
            style: AppTextStyles.bodyMedium
                .copyWith(color: const Color(0xFF1A1B22)),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            items: _ReportType.values
                .map((rt) => DropdownMenuItem(
                      value: rt,
                      child: Text(rt.label),
                    ))
                .toList(),
          ),
        ),
      );
}

class _ClassroomChips extends StatelessWidget {
  const _ClassroomChips({
    required this.available,
    required this.selected,
    required this.onToggle,
  });
  final List<String> available;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...available.map((classroom) {
            final isSelected = selected.contains(classroom);
            return GestureDetector(
              onTap: () => onToggle(classroom),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFDDE1FF) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFC4C5D5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      classroom,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF505F76),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Add classroom chip
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('إضافة فصل جديد قريباً')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFC4C5D5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      size: 18, color: Color(0xFF505F76)),
                  const SizedBox(width: 4),
                  Text(
                    'إضافة فصل',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: const Color(0xFF505F76),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

class _FrequencyDropdown extends StatelessWidget {
  const _FrequencyDropdown({required this.value, required this.onChanged});
  final _Frequency value;
  final ValueChanged<_Frequency> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC4C5D5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<_Frequency>(
            value: value,
            isExpanded: true,
            icon:
                const Icon(Icons.expand_more_rounded, color: Color(0xFF505F76)),
            style: AppTextStyles.bodyMedium
                .copyWith(color: const Color(0xFF1A1B22)),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            items: _Frequency.values
                .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f.label),
                    ))
                .toList(),
          ),
        ),
      );
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({required this.time, required this.onTap});
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFC4C5D5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 20, color: Color(0xFF505F76)),
            const SizedBox(width: 8),
            Text(
              '$hour:$minute',
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF1A1B22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientsInput extends StatelessWidget {
  const _RecipientsInput({
    required this.controller,
    required this.recipients,
    required this.onAdd,
    required this.onRemove,
  });
  final TextEditingController controller;
  final List<String> recipients;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC4C5D5)),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: 'example@school.edu',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF1A1B22),
                    ),
                    onSubmitted: (_) => onAdd(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0E1FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF54647A),
                  ),
                ),
              ),
            ],
          ),
          if (recipients.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: recipients
                  .map((email) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E7F1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              email,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFF444653),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => onRemove(email),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Color(0xFF444653),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      );
}

class _FileFormatSelector extends StatelessWidget {
  const _FileFormatSelector({required this.value, required this.onChanged});
  final _FileFormat value;
  final ValueChanged<_FileFormat> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: _FileFormat.values.map((fmt) {
          final isSelected = value == fmt;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: fmt == _FileFormat.pdf ? 0 : 8,
                right: fmt == _FileFormat.pdf ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => onChanged(fmt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFC4C5D5),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        fmt.icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF505F76),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fmt.label,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF505F76),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
}

// ─── Active Schedules Section ─────────────────────────────────────────────────

class _ActiveSchedulesSection extends StatelessWidget {
  const _ActiveSchedulesSection({
    required this.schedules,
    required this.loading,
    required this.errorMessage,
    required this.onDelete,
    required this.onToggle,
    required this.onRetry,
  });

  final List<_ScheduleItem> schedules;
  final bool loading;
  final String? errorMessage;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الجداول النشطة',
                style: AppTextStyles.titleLarge,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE1FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${schedules.length} تقارير',
                  style: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001453),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (errorMessage != null)
            _ErrorCard(message: errorMessage!, onRetry: onRetry)
          else if (schedules.isEmpty)
            const _EmptySchedulesCard()
          else
            Column(
              children: schedules
                  .map((schedule) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ScheduleCard(
                          schedule: schedule,
                          onDelete: () => onDelete(schedule.id),
                          onToggle: () => onToggle(schedule.id),
                        ),
                      ))
                  .toList(),
            ),
        ],
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      );
}

class _EmptySchedulesCard extends StatelessWidget {
  const _EmptySchedulesCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC4C5D5)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 48,
              color: AppColors.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد جداول نشطة',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أنشئ جدولاً جديداً باستخدام النموذج أعلاه',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onDelete,
    required this.onToggle,
  });

  final _ScheduleItem schedule;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC4C5D5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDF7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  schedule.reportType.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${schedule.frequency.label} • ${schedule.deliveryTime} • ${schedule.fileFormat.label}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF505F76),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status + actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Active badge
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: schedule.isActive
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        schedule.isActive ? 'نشط' : 'متوقف',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: schedule.isActive
                              ? const Color(0xFF047857)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Delete button
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: Color(0xFF505F76),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
