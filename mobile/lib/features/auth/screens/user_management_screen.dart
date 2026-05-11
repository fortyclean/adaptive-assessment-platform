import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../repositories/admin_repository.dart';
import '../../../shared/providers/auth_provider.dart';

/// User Management Screen — Screen 17
/// Requirements: 13.2–13.5
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key, this.initialFilter});
  
  final String? initialFilter;

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends ConsumerState<UserManagementScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  String? _errorMessage;
  String _searchQuery = '';
  String? _roleFilter;
  final _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _mockUsers = [
    {
      '_id': 'u1',
      'fullName': 'أحمد محمد',
      'email': 'ahmed.m@school.edu',
      'role': 'teacher',
      'isActive': true,
      'subject': 'الرياضيات',
      'classroomCount': 3,
    },
    {
      '_id': 'u2',
      'fullName': 'سارة خالد',
      'username': 'STU-2023-045',
      'role': 'student',
      'isActive': true,
      'grade': 'الثالث الثانوي',
      'lastActive': 'منذ يومين',
    },
    {
      '_id': 'u3',
      'fullName': 'عمر سالم',
      'email': 'omar.s@school.edu',
      'role': 'teacher',
      'isActive': false,
      'subject': 'الفيزياء',
      'classroomCount': 0,
    },
    {
      '_id': 'u4',
      'fullName': 'محمود علي',
      'username': 'STU-2023-089',
      'role': 'student',
      'isActive': true,
      'grade': 'الأول الثانوي',
      'lastActive': 'اليوم',
    },
    {
      '_id': 'u5',
      'fullName': 'فاطمة حسن',
      'email': 'fatima.h@school.edu',
      'role': 'teacher',
      'isActive': true,
      'subject': 'اللغة العربية',
      'classroomCount': 2,
    },
    {
      '_id': 'u6',
      'fullName': 'يوسف إبراهيم',
      'username': 'STU-2023-112',
      'role': 'student',
      'isActive': true,
      'grade': 'الثاني الثانوي',
      'lastActive': 'منذ أسبوع',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set initial filter if provided
    if (widget.initialFilter != null) {
      _roleFilter = widget.initialFilter;
    }
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authState = ref.read(authProvider);
    final isDemoSession = (authState.accessToken ?? '').startsWith('demo-token-');
    final backendRoleFilter = _roleFilter == 'pending' ? null : _roleFilter;
    final backendIsActiveFilter = _roleFilter == 'pending' ? false : null;

    try {
      final users = await ref.read(adminRepositoryProvider).getUsers(
            search: _searchQuery.isNotEmpty ? _searchQuery : null,
            role: backendRoleFilter,
            isActive: backendIsActiveFilter,
          );
      setState(() {
        _users = users.isNotEmpty ? users : _getFilteredMock();
        _isLoading = false;
      });
    } catch (_) {
      if (!AppConstants.useMockData && !isDemoSession) {
        setState(() {
          _users = [];
          _isLoading = false;
          _errorMessage =
              'تعذر تحميل المستخدمين. تحقق من الاتصال ثم أعد المحاولة.';
        });
        return;
      }
      setState(() {
        _users = _getFilteredMock();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredMock() {
    var list = List<Map<String, dynamic>>.from(_mockUsers);
    if (_roleFilter != null) {
      if (_roleFilter == 'pending') {
        // Filter for pending users (inactive accounts)
        list = list.where((u) => u['isActive'] == false).toList();
      } else {
        // Filter by role (teacher/student)
        list = list.where((u) => u['role'] == _roleFilter).toList();
      }
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) {
        final name = (u['fullName'] as String? ?? '').toLowerCase();
        final email = (u['email'] as String? ?? '').toLowerCase();
        final username = (u['username'] as String? ?? '').toLowerCase();
        return name.contains(q) ||
            email.contains(q) ||
            username.contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> _deactivateUser(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('تعطيل الحساب'),
        content: Text('هل تريد تعطيل حساب $name؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تعطيل',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).deactivateUser(id);
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تعطيل الحساب')),
          );
        }
      } catch (_) {
        if (!AppConstants.useMockData) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تعذر تعطيل الحساب. يرجى المحاولة مرة أخرى'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        // Mock deactivate
        setState(() {
          final idx = _users.indexWhere((u) => u['_id'] == id);
          if (idx != -1) {
            _users[idx] = Map.from(_users[idx])..['isActive'] = false;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تعطيل الحساب')),
          );
        }
      }
    }
  }

  Future<void> _reactivateUser(String id, String name) async {
    try {
      await ref.read(adminRepositoryProvider).reactivateUser(id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تفعيل حساب $name')),
        );
      }
    } catch (_) {
      if (!AppConstants.useMockData) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر تفعيل الحساب. يرجى المحاولة مرة أخرى'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      final idx = _users.indexWhere((u) => u['_id'] == id);
      if (idx != -1) {
        setState(() {
          _users[idx] = Map.from(_users[idx])..['isActive'] = true;
        });
      }
    }
  }

  void _editUser(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['fullName'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 16, right: 16, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('تعديل: ${user['fullName']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final idx = _users.indexWhere((u) => u['_id'] == user['_id']);
                if (idx != -1) {
                  setState(() {
                    _users[idx] = Map.from(_users[idx])..['fullName'] = nameController.text.trim();
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث بيانات المستخدم'), behavior: SnackBarBehavior.floating),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('حفظ التغييرات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateUserDialog(
        onCreated: () {
          Navigator.pop(ctx);
          _loadUsers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(
            color: Color(0xFF1A1B22),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextButton.icon(
              onPressed: _showCreateUserDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة مستخدم'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: Column(
        children: [
          // ── Search & filter bar ───────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                const Text(
                  'التحكم في حسابات المعلمين والطلاب والصلاحيات',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText:
                          'البحث بالاسم، البريد الإلكتروني، أو الرقم التعريفي...',
                      hintStyle: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.onSurfaceVariant, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadUsers();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      if (v.length >= 2 || v.isEmpty) _loadUsers();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Role filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _RoleChip(
                        label: 'كل الأدوار',
                        selected: _roleFilter == null,
                        onTap: () {
                          setState(() => _roleFilter = null);
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: 'معلم',
                        selected: _roleFilter == 'teacher',
                        onTap: () {
                          setState(() => _roleFilter = 'teacher');
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: 'طالب',
                        selected: _roleFilter == 'student',
                        onTap: () {
                          setState(() => _roleFilter = 'student');
                          _loadUsers();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── User list ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadUsers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      )
                : _users.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length,
                          itemBuilder: (ctx, i) => _UserCard(
                            user: _users[i],
                            onDeactivate: _users[i]['isActive'] == true
                                ? () => _deactivateUser(
                                    _users[i]['_id'] as String,
                                    _users[i]['fullName'] as String)
                                : null,
                            onEdit: () => _editUser(_users[i]),
                            onReactivate: _users[i]['isActive'] == false
                                ? () {
                                    _reactivateUser(
                                      _users[i]['_id'] as String,
                                      _users[i]['fullName'] as String,
                                    );
                                    return;
                                    final idx = _users.indexWhere(
                                        (u) => u['_id'] == _users[i]['_id']);
                                    if (idx != -1) {
                                      setState(() {
                                        _users[idx] = Map.from(_users[idx])
                                          ..['isActive'] = true;
                                      });
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'تم تفعيل حساب ${_users[i]['fullName']}'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded,
                size: 40, color: AppColors.outlineVariant),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'جرب تغيير معايير البحث',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role filter chip ──────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip(
      {required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFFA8B8FF)
                : AppColors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, this.onDeactivate, this.onEdit, this.onReactivate});
  final Map<String, dynamic> user;
  final VoidCallback? onDeactivate;
  final VoidCallback? onEdit;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    final isActive = user['isActive'] as bool? ?? true;
    final role = user['role'] as String? ?? '';
    final isTeacher = role == 'teacher';
    final fullName = user['fullName'] as String? ?? '';
    final email = user['email'] as String?;
    final username = user['username'] as String?;
    final subtitle = email ?? (username != null ? username : '');

    // Initials
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
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
            // ── Header row ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isTeacher
                            ? AppColors.primaryContainer
                            : const Color(0xFFD0E1FB))
                        : AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: isActive
                          ? (isTeacher
                              ? const Color(0xFFDDE1FF)
                              : const Color(0xFF54647A))
                          : AppColors.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Role / status badge
                _RoleBadge(role: role, isActive: isActive),
              ],
            ),

            // ── Info grid ────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCell(
                      label: isTeacher ? 'المادة' : 'الصف',
                      value: isTeacher
                          ? (user['subject'] as String? ?? '—')
                          : (user['grade'] as String? ?? '—'),
                    ),
                  ),
                  Expanded(
                    child: _InfoCell(
                      label: isTeacher ? 'الفصول' : 'النشاط الأخير',
                      value: isTeacher
                          ? (user['classroomCount'] != null
                              ? '${user['classroomCount']} فصول'
                              : '—')
                          : (user['lastActive'] as String? ?? '—'),
                    ),
                  ),
                ],
              ),
            ),

            // ── Action buttons ───────────────────────────────────────────
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0x1AC4C5D5)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'تعديل',
                    onTap: onEdit ?? () {},
                    color: AppColors.primary,
                    isDestructive: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: isActive
                      ? _ActionButton(
                          icon: Icons.block_rounded,
                          label: 'إيقاف',
                          onTap: onDeactivate ?? () {},
                          color: AppColors.error,
                          isDestructive: true,
                        )
                      : _ActionButton(
                          icon: Icons.settings_backup_restore_rounded,
                          label: 'تفعيل',
                          onTap: onReactivate ?? () {},
                          color: AppColors.onSurfaceVariant,
                          isDestructive: false,
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.isActive});
  final String role;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: AppColors.error.withOpacity(0.3)),
        ),
        child: const Text(
          'موقوف',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final isTeacher = role == 'teacher';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTeacher
            ? const Color(0xFFFFDBCE)
            : const Color(0xFFD0E1FB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTeacher
              ? const Color(0xFFFFB59A).withOpacity(0.3)
              : const Color(0xFFB7C8E1).withOpacity(0.3),
        ),
      ),
      child: Text(
        isTeacher ? 'معلم' : 'طالب',
        style: TextStyle(
          color: isTeacher
              ? const Color(0xFF611E00)
              : const Color(0xFF54647A),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.isDestructive,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create user dialog ────────────────────────────────────────────────────────

class _CreateUserDialog extends ConsumerStatefulWidget {
  const _CreateUserDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateUserDialog> createState() =>
      _CreateUserDialogState();
}

class _CreateUserDialogState
    extends ConsumerState<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _role = 'teacher';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      await ref.read(adminRepositoryProvider).createUser({
        'fullName': _fullName,
        'username': _username,
        'email': _email,
        'password': _password,
        'role': _role,
      });
      widget.onCreated();
    } catch (_) {
      if (!AppConstants.useMockData) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر إنشاء المستخدم. يرجى المحاولة مرة أخرى'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      // Demo mode: simulate success
      if (mounted) {
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء حساب "$_fullName" بنجاح'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      title: const Text('إضافة مستخدم جديد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                textDirection: TextDirection.rtl,
                decoration:
                    const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _fullName = v!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'اسم المستخدم'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _username = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _email = v!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 8) ? '8 أحرف على الأقل' : null,
                onSaved: (v) => _password = v!,
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'الدور'),
                value: _role,
                items: const [
                  DropdownMenuItem(
                      value: 'teacher', child: Text('معلم')),
                  DropdownMenuItem(
                      value: 'student', child: Text('طالب')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('إنشاء'),
        ),
      ],
    );
  }
}
