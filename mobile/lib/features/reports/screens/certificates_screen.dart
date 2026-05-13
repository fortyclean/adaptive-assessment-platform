import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/download_helper.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../assessment/repositories/teacher_repository.dart';

/// Screen 71 — الشهادات والنتائج النهائية
class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _classrooms = [];
  List<Map<String, dynamic>> _students = [];
  String? _selectedClassroomId;
  String? _selectedClassroomName;
  String _sortBy = 'score';
  int _selectedTemplate = 0; // 0=classic, 1=modern, 2=elegant

  // ── Certificate templates ─────────────────────────────────────────────────
  final List<Map<String, dynamic>> _templates = [
    {
      'id': 0,
      'name': 'الكلاسيكي',
      'primaryColor': const Color(0xFF1E40AF),
      'accentColor': const Color(0xFFDDE1FF),
      'borderColor': const Color(0xFF1E40AF),
      'icon': Icons.workspace_premium,
      'description': 'تصميم رسمي بألوان زرقاء',
    },
    {
      'id': 1,
      'name': 'الذهبي',
      'primaryColor': const Color(0xFF92400E),
      'accentColor': const Color(0xFFFEF3C7),
      'borderColor': const Color(0xFFD97706),
      'icon': Icons.emoji_events,
      'description': 'تصميم فاخر بألوان ذهبية',
    },
    {
      'id': 2,
      'name': 'الأخضر',
      'primaryColor': const Color(0xFF065F46),
      'accentColor': const Color(0xFFD1FAE5),
      'borderColor': const Color(0xFF059669),
      'icon': Icons.military_tech,
      'description': 'تصميم حديث بألوان خضراء',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    setState(() => _isLoading = true);
    try {
      final classrooms =
          await ref.read(teacherRepositoryProvider).getClassrooms();
      if (mounted) {
        setState(() {
          _classrooms = classrooms;
          if (classrooms.isNotEmpty) {
            _selectedClassroomId = classrooms.first['_id'] as String?;
            _selectedClassroomName = classrooms.first['name'] as String?;
          }
          _isLoading = false;
        });
        if (_selectedClassroomId != null) _loadStudents(_selectedClassroomId!);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _classrooms = [
            {
              '_id': 'cls-001',
              'name': 'أولى متوسط (أ)',
              'gradeLevel': 'الصف الأول المتوسط'
            },
          ];
          _selectedClassroomId = 'cls-001';
          _selectedClassroomName = 'أولى متوسط (أ)';
          _students = _demoStudents();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStudents(String classroomId) async {
    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(teacherRepositoryProvider)
          .getClassroomCertificates(classroomId);
      final studentList =
          (result['students'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (mounted) {
        setState(() {
          _students = studentList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _students = _demoStudents();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _demoStudents() => [
        {
          '_id': 's1',
          'fullName': 'أحمد علي منصور',
          'score': 98.5,
          'grade': 'ممتاز',
          'passed': true
        },
        {
          '_id': 's2',
          'fullName': 'سارة كمال السعدي',
          'score': 94.2,
          'grade': 'امتياز',
          'passed': true
        },
        {
          '_id': 's3',
          'fullName': 'محمد خالد الحربي',
          'score': 87.0,
          'grade': 'جيد جداً',
          'passed': true
        },
        {
          '_id': 's4',
          'fullName': 'ليلى سالم العتيبي',
          'score': 91.8,
          'grade': 'امتياز',
          'passed': true
        },
        {
          '_id': 's5',
          'fullName': 'عمر فيصل الزهراني',
          'score': 62.0,
          'grade': 'مقبول',
          'passed': false
        },
      ];

  List<Map<String, dynamic>> get _sortedStudents {
    final list = List<Map<String, dynamic>>.from(_students);
    if (_sortBy == 'score') {
      list.sort((a, b) =>
          ((b['score'] as num?) ?? 0).compareTo((a['score'] as num?) ?? 0));
    } else {
      list.sort((a, b) => (a['fullName'] as String? ?? '')
          .compareTo(b['fullName'] as String? ?? ''));
    }
    return list;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}.${parts[1][0]}';
    return parts[0][0];
  }

  String _getGradeLabel(double score) {
    if (score >= 95) return 'ممتاز';
    if (score >= 85) return 'امتياز';
    if (score >= 75) return 'جيد جداً';
    if (score >= 65) return 'جيد';
    if (score >= 50) return 'مقبول';
    return 'راسب';
  }

  Color _getGradeColor(double score) {
    if (score >= 85) return const Color(0xFF611E00);
    if (score >= 65) return const Color(0xFF54647A);
    return AppColors.error;
  }

  // ── Certificate preview widget ────────────────────────────────────────────
  Widget _buildCertificateCard({
    required String studentName,
    required double score,
    required String grade,
    required String classroomName,
    required Map<String, dynamic> template,
    bool isPreview = false,
  }) {
    final primary = template['primaryColor'] as Color;
    final accent = template['accentColor'] as Color;
    final border = template['borderColor'] as Color;
    final icon = template['icon'] as IconData;

    return Container(
      margin: isPreview ? EdgeInsets.zero : const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(
              color: primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Header band
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const Text(
                  'شهادة إتمام',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Almarai'),
                ),
                Icon(Icons.verified,
                    color: Colors.white.withValues(alpha: 0.8), size: 20),
              ],
            ),
          ),
          // Body
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.3),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  'تُمنح هذه الشهادة إلى',
                  style: TextStyle(
                      color: primary.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontFamily: 'Almarai'),
                ),
                const SizedBox(height: 6),
                Text(
                  studentName,
                  style: TextStyle(
                      color: primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Almarai'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  width: 80,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لإتمامه بنجاح مادة $classroomName',
                  style: TextStyle(
                      color: primary.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontFamily: 'Almarai'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${score.toStringAsFixed(1)}%  •  $grade',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Almarai'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'العام الدراسي 2024-2025',
                  style: TextStyle(
                      color: primary.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontFamily: 'Almarai'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCertificatePreview(Map<String, dynamic> student) {
    final name = student['fullName'] as String? ?? '';
    final score = (student['score'] as num?)?.toDouble() ?? 0;
    final grade = student['grade'] as String? ?? _getGradeLabel(score);
    final template = _templates[_selectedTemplate];
    final nameCtrl = TextEditingController(text: name);
    final titleCtrl = TextEditingController(text: 'شهادة إتمام');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                const Text('تخصيص وإصدار الشهادة',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Almarai')),
                const SizedBox(height: 16),
                // Name field
                TextField(
                  controller: nameCtrl,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    labelText: 'اسم الطالب على الشهادة',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                // Certificate title field
                TextField(
                  controller: titleCtrl,
                  textDirection: TextDirection.rtl,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    labelText: 'عنوان الشهادة',
                    prefixIcon: const Icon(Icons.workspace_premium_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                // Live preview
                _buildCertificateCard(
                  studentName: nameCtrl.text.isEmpty ? name : nameCtrl.text,
                  score: score,
                  grade: grade,
                  classroomName: _selectedClassroomName ?? '',
                  template: template,
                  isPreview: true,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final token =
                              ref.read(authProvider).accessToken ?? '';
                          final success = await DownloadHelper.sendNotification(
                            message:
                                'تهانينا! لقد حصلت على شهادة إتمام بدرجة ${score.toStringAsFixed(1)}%',
                            recipientId: student['_id'] as String? ?? '',
                            token: token,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'تم إرسال الشهادة إلى ${nameCtrl.text.isEmpty ? name : nameCtrl.text}'
                                  : 'تم الإرسال (وضع تجريبي)'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: const Text('إرسال',
                            style: TextStyle(fontFamily: 'Almarai')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          DownloadHelper.downloadCertificate(
                            context: context,
                            studentName:
                                nameCtrl.text.isEmpty ? name : nameCtrl.text,
                            score: score,
                            grade: grade,
                            classroomName: _selectedClassroomName ?? '',
                            token: ref.read(authProvider).accessToken ?? '',
                          );
                        },
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('تحميل PDF',
                            style: TextStyle(fontFamily: 'Almarai')),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تصدير الشهادات',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Almarai')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                // Export all students as CSV
                final headers = ['الاسم', 'الدرجة', 'التقدير', 'الحالة'];
                final rows = _sortedStudents
                    .map((s) => [
                          s['fullName'] as String? ?? '',
                          '${(s['score'] as num?)?.toStringAsFixed(1) ?? '0'}%',
                          s['grade'] as String? ?? '',
                          if ((s['passed'] as bool?) ?? false)
                            'ناجح'
                          else
                            'راسب',
                        ])
                    .toList();
                DownloadHelper.exportReportCsv(
                  context: context,
                  rows: rows,
                  headers: headers,
                  fileName:
                      'certificates_${_selectedClassroomName ?? 'class'}.csv',
                );
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('تصدير PDF/CSV للكل',
                  style: TextStyle(fontFamily: 'Almarai')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                final headers = ['الاسم', 'الدرجة', 'التقدير', 'الحالة'];
                final rows = _sortedStudents
                    .map((s) => [
                          s['fullName'] as String? ?? '',
                          '${(s['score'] as num?)?.toStringAsFixed(1) ?? '0'}%',
                          s['grade'] as String? ?? '',
                          if ((s['passed'] as bool?) ?? false)
                            'ناجح'
                          else
                            'راسب',
                        ])
                    .toList();
                DownloadHelper.exportReportCsv(
                  context: context,
                  rows: rows,
                  headers: headers,
                  fileName:
                      'certificates_${_selectedClassroomName ?? 'class'}.csv',
                );
              },
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('تصدير Excel/CSV',
                  style: TextStyle(fontFamily: 'Almarai')),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                final token = ref.read(authProvider).accessToken ?? '';
                var sent = 0;
                for (final s in _students
                    .where((s) => (s['passed'] as bool?) ?? false)) {
                  DownloadHelper.sendNotification(
                    message:
                        'تهانينا! لقد حصلت على شهادة إتمام بدرجة ${(s['score'] as num?)?.toStringAsFixed(1)}%',
                    recipientId: s['_id'] as String? ?? '',
                    token: token,
                  );
                  sent++;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('تم إرسال $sent شهادة للطلاب الناجحين'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success),
                );
              },
              icon: const Icon(Icons.send_outlined),
              label: const Text('إرسال للجميع',
                  style: TextStyle(fontFamily: 'Almarai')),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passed = _students
        .where(
            (s) => (s['passed'] as bool?) ?? ((s['score'] as num?) ?? 0) >= 50)
        .length;
    final failed = _students.length - passed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppColors.primary,
            onPressed: () => context.pop()),
        title: const Text('الشهادات والنتائج',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: 'Almarai')),
        actions: [
          IconButton(
              icon: const Icon(Icons.file_download_outlined),
              color: AppColors.primary,
              onPressed: _showExportDialog,
              tooltip: 'تصدير'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadClassrooms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Classroom selector ──────────────────────────────
                    if (_classrooms.isNotEmpty) _buildClassroomSelector(),
                    const SizedBox(height: 16),

                    // ── Stats ───────────────────────────────────────────
                    _buildStatsRow(passed, failed),
                    const SizedBox(height: 20),

                    // ── Template selector ───────────────────────────────
                    _buildTemplateSelector(),
                    const SizedBox(height: 20),

                    // ── Certificate preview ─────────────────────────────
                    if (_students.isNotEmpty) ...[
                      const Text('معاينة النموذج',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Almarai')),
                      const SizedBox(height: 10),
                      _buildCertificateCard(
                        studentName:
                            (_sortedStudents.first['fullName'] as String?) ??
                                'اسم الطالب',
                        score: (_sortedStudents.first['score'] as num?)
                                ?.toDouble() ??
                            0,
                        grade: (_sortedStudents.first['grade'] as String?) ??
                            'ممتاز',
                        classroomName: _selectedClassroomName ?? '',
                        template: _templates[_selectedTemplate],
                        isPreview: true,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Students list ───────────────────────────────────
                    _buildListHeader(),
                    const SizedBox(height: 12),
                    if (_students.isEmpty)
                      _buildEmptyState()
                    else
                      ..._sortedStudents.map(_buildStudentCard),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('جاري إصدار شهادات لجميع الناجحين...'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('إصدار الكل',
            style: TextStyle(color: Colors.white, fontFamily: 'Almarai')),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2, role: 'teacher'),
    );
  }

  Widget _buildClassroomSelector() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedClassroomId,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 15,
                color: AppColors.onSurface),
            items: _classrooms
                .map((c) => DropdownMenuItem<String>(
                    value: c['_id'] as String?,
                    child: Text(c['name'] as String? ?? '')))
                .toList(),
            onChanged: (id) {
              if (id == null) return;
              final cls = _classrooms.firstWhere((c) => c['_id'] == id);
              setState(() {
                _selectedClassroomId = id;
                _selectedClassroomName = cls['name'] as String?;
              });
              _loadStudents(id);
            },
          ),
        ),
      );

  Widget _buildTemplateSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('اختر نموذج الشهادة',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Almarai')),
          const SizedBox(height: 10),
          Row(
            children: _templates.map((t) {
              final isSelected = _selectedTemplate == t['id'];
              final primary = t['primaryColor'] as Color;
              final accent = t['accentColor'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedTemplate = t['id'] as int),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? accent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              isSelected ? primary : AppColors.outlineVariant,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      children: [
                        Icon(t['icon'] as IconData, color: primary, size: 28),
                        const SizedBox(height: 6),
                        Text(t['name'] as String,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primary,
                                fontFamily: 'Almarai')),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Icon(Icons.check_circle, color: primary, size: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );

  Widget _buildStatsRow(int passed, int failed) => Row(
        children: [
          Expanded(
              child: _statCard('الناجحون', '$passed', AppColors.success,
                  Icons.check_circle_outline)),
          const SizedBox(width: 10),
          Expanded(
              child: _statCard('الراسبون', '$failed', AppColors.error,
                  Icons.cancel_outlined)),
          const SizedBox(width: 10),
          Expanded(
              child: _statCard('الإجمالي', '${_students.length}',
                  AppColors.primary, Icons.people_outline)),
        ],
      );

  Widget _statCard(String label, String value, Color color, IconData icon) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Almarai')),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'Almarai')),
          ],
        ),
      );

  Widget _buildListHeader() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('قائمة الطلاب (${_students.length})',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Almarai')),
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Almarai'),
            items: const [
              DropdownMenuItem(value: 'score', child: Text('ترتيب: الدرجة')),
              DropdownMenuItem(value: 'name', child: Text('ترتيب: الاسم')),
            ],
            onChanged: (v) => setState(() => _sortBy = v ?? 'score'),
          ),
        ],
      );

  Widget _buildEmptyState() => Container(
        padding: const EdgeInsets.all(32),
        child: const Column(
          children: [
            Icon(Icons.workspace_premium_outlined,
                size: 48, color: AppColors.outline),
            SizedBox(height: 12),
            Text('لا توجد نتائج لهذا الفصل',
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, fontFamily: 'Almarai')),
            SizedBox(height: 8),
            Text('يجب أن يكمل الطلاب اختباراً أولاً لتظهر نتائجهم هنا',
                style: TextStyle(
                    color: AppColors.outline,
                    fontSize: 12,
                    fontFamily: 'Almarai'),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final name =
        student['fullName'] as String? ?? student['name'] as String? ?? 'طالب';
    final score = (student['score'] as num?)?.toDouble() ?? 0.0;
    final passed = (student['passed'] as bool?) ?? score >= 50;
    final grade = student['grade'] as String? ?? _getGradeLabel(score);
    final template = _templates[_selectedTemplate];
    final primary = template['primaryColor'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            // Issue certificate button
            GestureDetector(
              onTap: () => _showCertificatePreview(student),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.workspace_premium_outlined,
                    color: primary, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Almarai')),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(grade,
                          style: TextStyle(
                              color: _getGradeColor(score),
                              fontSize: 11,
                              fontFamily: 'Almarai')),
                      const SizedBox(width: 6),
                      Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                              color: Color(0xFFC4C5D5),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('${score.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Almarai')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Avatar + status
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFD3E4FE),
                  child: Text(_getInitials(name),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          fontFamily: 'Almarai')),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: passed ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    child: Icon(passed ? Icons.check : Icons.close,
                        color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
