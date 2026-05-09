import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Student Files Screen — Screen 63
/// Teacher view of all student profiles in a classroom with
/// search/filter, stats overview, and student cards with performance bars.
class StudentFilesScreen extends ConsumerStatefulWidget {
  const StudentFilesScreen({super.key});

  @override
  ConsumerState<StudentFilesScreen> createState() => _StudentFilesScreenState();
}

class _StudentFilesScreenState extends ConsumerState<StudentFilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'الأداء';

  // Sample data — replace with real API data
  final List<_StudentData> _students = const [
    _StudentData(
      name: 'أحمد محمود علي',
      fileNumber: '#1042',
      performance: 94,
      isOnline: true,
    ),
    _StudentData(
      name: 'سارة إبراهيم حسن',
      fileNumber: '#1055',
      performance: 88,
      isOnline: true,
    ),
    _StudentData(
      name: 'خالد يوسف كمال',
      fileNumber: '#1021',
      performance: 67,
      isOnline: false,
    ),
    _StudentData(
      name: 'ليلى عبد العزيز',
      fileNumber: '#1068',
      performance: 91,
      isOnline: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_StudentData> get _filtered {
    var list = _students.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.contains(_searchQuery) ||
          s.fileNumber.contains(_searchQuery);
    }).toList();

    if (_sortBy == 'الأداء') {
      list.sort((a, b) => b.performance.compareTo(a.performance));
    } else {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchAndFilter(),
                const SizedBox(height: 16),
                _buildStatsOverview(),
                const SizedBox(height: 16),
                ..._buildStudentGrid(),
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
          // Notifications (RTL: left)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: const Color(0xFF1E40AF),
            onPressed: () => context.push('/teacher/notifications'),
          ),
          // Logo + avatar (RTL: right)
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
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant, width: 1),
                  color: AppColors.surfaceContainer,
                ),
                child: const Icon(Icons.person, size: 22, color: Color(0xFF444653)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'إدارة ملفات الطلاب',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1B22),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        const Text(
          'الصف الثالث الثانوي - علوم الحاسب',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF444653),
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  // ─── Search & Filter ─────────────────────────────────────────────────────

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        // Sort buttons (RTL: left)
        _buildFilterButton(
          label: _sortBy == 'الاسم' ? 'الاسم ✓' : 'الاسم',
          icon: Icons.filter_list,
          onTap: () => setState(() => _sortBy = 'الاسم'),
        ),
        const SizedBox(width: 8),
        _buildFilterButton(
          label: _sortBy == 'الأداء' ? 'الأداء ✓' : 'الأداء',
          icon: Icons.sort,
          onTap: () => setState(() => _sortBy = 'الأداء'),
        ),
        const SizedBox(width: 12),
        // Search field (RTL: right)
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'البحث عن اسم الطالب أو الرقم التعريفي...',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF757684)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF757684)),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF505F76),
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 18, color: const Color(0xFF505F76)),
          ],
        ),
      ),
    );
  }

  // ─── Stats Overview ───────────────────────────────────────────────────────

  Widget _buildStatsOverview() {
    final stats = [
      _StatItem(label: 'إجمالي الطلاب', value: '${_students.length}'),
      _StatItem(
        label: 'متوسط الأداء',
        value:
            '${(_students.map((s) => s.performance).reduce((a, b) => a + b) ~/ _students.length)}%',
      ),
      _StatItem(label: 'المكلفون حديثاً', value: '5'),
      _StatItem(
        label: 'الطلاب المتفوقين',
        value: '${_students.where((s) => s.performance >= 85).length}',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: stats
          .map((s) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF505F76),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ─── Student Grid ─────────────────────────────────────────────────────────

  List<Widget> _buildStudentGrid() {
    final filtered = _filtered;
    final List<Widget> rows = [];

    for (int i = 0; i < filtered.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _StudentCard(student: filtered[i])),
            const SizedBox(width: 12),
            if (i + 1 < filtered.length)
              Expanded(child: _StudentCard(student: filtered[i + 1]))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      rows.add(const SizedBox(height: 12));
    }
    return rows;
  }
}

// ─── Student Card ─────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final _StudentData student;

  Color get _performanceColor {
    if (student.performance >= 85) return AppColors.success;
    if (student.performance >= 70) return AppColors.primary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
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
          // Header with avatar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Name + file number (RTL: right)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1B22),
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'رقم الملف: ${student.fileNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF505F76),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar with online indicator (RTL: left)
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainer,
                        border: Border.all(
                          color: const Color(0xFFDDE1FF),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          student.name.isNotEmpty ? student.name[0] : '؟',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: student.isOnline
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFCBD5E1),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Performance bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${student.performance}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _performanceColor,
                      ),
                    ),
                    const Text(
                      'الأداء العام',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF505F76),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: student.performance / 100,
                    backgroundColor: AppColors.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('عرض ملف الطالب: ${student.name}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class _StudentData {
  const _StudentData({
    required this.name,
    required this.fileNumber,
    required this.performance,
    required this.isOnline,
  });
  final String name;
  final String fileNumber;
  final int performance;
  final bool isOnline;
}

class _StatItem {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;
}
