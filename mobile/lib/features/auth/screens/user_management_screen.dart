import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/admin_top_actions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../repositories/admin_repository.dart';

/// User Management Screen — Screen 17
/// Requirements: 13.2–13.5
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

String _localizedRoleLabel(AppLocalizations l10n, String role) {
  if (role == 'teacher') return l10n.teacherRole;
  if (role == 'student') return l10n.studentRole;
  if (role == 'parent') return 'ولي الأمر';
  return l10n.adminRole;
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  String? _errorMessage;
  String _searchQuery = '';
  String? _roleFilter;
  String? _classroomFilterId;
  List<Map<String, dynamic>> _classroomOptions = [];
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
      'classroomIds': ['c1', 'c2', 'c3'],
    },
    {
      '_id': 'u2',
      'fullName': 'سارة خالد',
      'username': 'STU-2023-045',
      'role': 'student',
      'isActive': true,
      'grade': 'الثالث الثانوي',
      'lastActive': 'منذ يومين',
      'classroomIds': ['c3'],
    },
    {
      '_id': 'u3',
      'fullName': 'عمر سالم',
      'email': 'omar.s@school.edu',
      'role': 'teacher',
      'isActive': false,
      'subject': 'الفيزياء',
      'classroomCount': 0,
      'classroomIds': <String>[],
    },
    {
      '_id': 'u4',
      'fullName': 'محمود علي',
      'username': 'STU-2023-089',
      'role': 'student',
      'isActive': true,
      'grade': 'الأول الثانوي',
      'lastActive': 'اليوم',
      'classroomIds': ['c1'],
    },
    {
      '_id': 'u5',
      'fullName': 'فاطمة حسن',
      'email': 'fatima.h@school.edu',
      'role': 'teacher',
      'isActive': true,
      'subject': 'اللغة العربية',
      'classroomCount': 2,
      'classroomIds': ['c2', 'c4'],
    },
    {
      '_id': 'u6',
      'fullName': 'يوسف إبراهيم',
      'username': 'STU-2023-112',
      'role': 'student',
      'isActive': true,
      'grade': 'الثاني الثانوي',
      'lastActive': 'منذ أسبوع',
      'classroomIds': ['c2'],
    },
    {
      '_id': 'u7',
      'fullName': 'نورة فهد',
      'email': 'noura.f@school.edu',
      'role': 'teacher',
      'isActive': true,
      'subject': 'اللغة الإنجليزية',
      'classroomCount': 4,
      'classroomIds': ['c1', 'c2', 'c3', 'c4'],
    },
    {
      '_id': 'u8',
      'fullName': 'عبدالله راشد',
      'username': 'STU-2024-014',
      'role': 'student',
      'isActive': true,
      'grade': 'الثاني المتوسط',
      'lastActive': 'منذ 3 ساعات',
      'classroomIds': ['c4'],
    },
    {
      '_id': 'u9',
      'fullName': 'ريم سعد',
      'email': 'reem.s@school.edu',
      'role': 'teacher',
      'isActive': false,
      'subject': 'الكيمياء',
      'classroomCount': 1,
      'classroomIds': ['c4'],
    },
    {
      '_id': 'u10',
      'fullName': 'سلمان عادل',
      'username': 'STU-2024-102',
      'role': 'student',
      'isActive': false,
      'grade': 'الأول المتوسط',
      'lastActive': 'منذ أسبوعين',
      'classroomIds': ['c1'],
    },
    {
      '_id': 'u11',
      'fullName': 'هند جابر',
      'email': 'hind.j@school.edu',
      'role': 'teacher',
      'isActive': true,
      'subject': 'الأحياء',
      'classroomCount': 2,
      'classroomIds': ['c2', 'c3'],
    },
    {
      '_id': 'u12',
      'fullName': 'تركي ناصر',
      'username': 'STU-2024-130',
      'role': 'student',
      'isActive': true,
      'grade': 'الثالث المتوسط',
      'lastActive': 'اليوم',
      'classroomIds': ['c3'],
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
    _loadClassroomFilterOptions();
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
    final isDemoSession =
        (authState.accessToken ?? '').startsWith('demo-token-');
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
    } on Object {
      if (!AppConstants.useMockData && !isDemoSession) {
        setState(() {
          _users = [];
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context).userManagementLoadFailed;
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
        return name.contains(q) || email.contains(q) || username.contains(q);
      }).toList();
    }
    return list;
  }

  Future<void> _deactivateUser(String id, String name) async {
    final authState = ref.read(authProvider);
    final isDemoSession =
        (authState.accessToken ?? '').startsWith('demo-token-');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context).disableAccount),
        content:
            Text(AppLocalizations.of(context).disableAccountQuestion(name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context).cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context).disable,
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await ref.read(adminRepositoryProvider).deactivateUser(id);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context).accountDisabled)),
          );
        }
      } on Object {
        if (!AppConstants.useMockData && !isDemoSession) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context).accountDisableFailed),
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
            SnackBar(
                content: Text(AppLocalizations.of(context).accountDisabled)),
          );
        }
      }
    }
  }

  Future<void> _reactivateUser(String id, String name) async {
    final authState = ref.read(authProvider);
    final isDemoSession =
        (authState.accessToken ?? '').startsWith('demo-token-');
    try {
      await ref.read(adminRepositoryProvider).reactivateUser(id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).accountActivated(name))),
        );
      }
    } on Object {
      if (!AppConstants.useMockData && !isDemoSession) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).accountActivateFailed),
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

  Future<List<Map<String, dynamic>>> _loadClassroomOptions() async {
    const fallbackClassrooms = [
      {'_id': 'c1', 'name': 'الأول المتوسط (أ)', 'gradeLevel': '1'},
      {'_id': 'c2', 'name': 'الأول المتوسط (ب)', 'gradeLevel': '1'},
      {'_id': 'c3', 'name': 'الثاني المتوسط (أ)', 'gradeLevel': '2'},
      {'_id': 'c4', 'name': 'الثالث المتوسط (أ)', 'gradeLevel': '3'},
    ];

    try {
      final classrooms =
          await ref.read(adminRepositoryProvider).getClassrooms();
      return classrooms.isNotEmpty
          ? classrooms
          : List<Map<String, dynamic>>.from(fallbackClassrooms);
    } on Object {
      final authState = ref.read(authProvider);
      final isDemoSession =
          (authState.accessToken ?? '').startsWith('demo-token-');
      if (!AppConstants.useMockData && !isDemoSession) {
        return const [];
      }
      return List<Map<String, dynamic>>.from(fallbackClassrooms);
    }
  }

  Future<void> _loadClassroomFilterOptions() async {
    final classrooms = await _loadClassroomOptions();
    if (!mounted) return;
    setState(() => _classroomOptions = classrooms);
  }

  String _classroomName(Map<String, dynamic> classroom) =>
      classroom['name'] as String? ??
      classroom['classroomName'] as String? ??
      classroom['title'] as String? ??
      AppLocalizations.of(context).classroom;

  Set<String> _userClassroomIds(Map<String, dynamic> user) => {
        for (final item in (user['classroomIds'] as List?) ?? const [])
          if (item is Map && (item['_id'] ?? item['id']) != null)
            (item['_id'] ?? item['id']).toString()
          else if (item is String && item.isNotEmpty)
            item,
      };

  List<Map<String, dynamic>> _visibleUsers() {
    if (_classroomFilterId == null) return _users;
    return _users
        .where((user) => _userClassroomIds(user).contains(_classroomFilterId))
        .toList();
  }

  String _classroomFilterLabel(String id) {
    Map<String, dynamic>? classroom;
    for (final candidate in _classroomOptions) {
      final classroomId = (candidate['_id'] ?? candidate['id'])?.toString();
      if (classroomId == id) {
        classroom = candidate;
        break;
      }
    }
    if (classroom == null) {
      return AppLocalizations.of(context).selectedClassroom;
    }
    return _classroomName(classroom);
  }

  List<String> _classroomNamesForUser(Map<String, dynamic> user) {
    final ids = _userClassroomIds(user);
    if (ids.isEmpty) return const [];
    final names = <String>[];
    for (final classroom in _classroomOptions) {
      final id = (classroom['_id'] ?? classroom['id'])?.toString();
      if (id != null && ids.contains(id)) {
        names.add(_classroomName(classroom));
      }
    }
    return names;
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final nameController =
        TextEditingController(text: user['fullName'] as String? ?? '');
    final usernameController =
        TextEditingController(text: user['username'] as String? ?? '');
    final emailController =
        TextEditingController(text: user['email'] as String? ?? '');
    final classroomOptions = await _loadClassroomOptions();
    final selectedClassroomIds = <String>{
      for (final item in (user['classroomIds'] as List?) ?? const [])
        if (item is Map && (item['_id'] ?? item['id']) != null)
          (item['_id'] ?? item['id']).toString()
        else if (item is String && item.isNotEmpty)
          item,
    };
    var classroomSearchQuery = '';
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filteredClassrooms = classroomOptions.where((classroom) {
            final haystack =
                '${_classroomName(classroom)} ${classroom['gradeLevel'] ?? ''}'
                    .toLowerCase();
            return haystack.contains(classroomSearchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.86,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppColors.outlineVariant,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text(l10n.editEntity((user['fullName'] ?? '').toString()),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                        labelText: l10n.fullName,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    readOnly: true,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      helperText: l10n.usernameReadOnlyHelper,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                        labelText: l10n.email,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: l10n.searchClassrooms,
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) =>
                        setModalState(() => classroomSearchQuery = value),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.linkedClassrooms(selectedClassroomIds.length),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  if (classroomOptions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l10n.classroomsUnavailableRetry,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filteredClassrooms.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final classroom = filteredClassrooms[index];
                          final id =
                              (classroom['_id'] ?? classroom['id']).toString();
                          final isSelected = selectedClassroomIds.contains(id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (checked) {
                              setModalState(() {
                                if (checked ?? false) {
                                  selectedClassroomIds.add(id);
                                } else {
                                  selectedClassroomIds.remove(id);
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              _classroomName(classroom),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              l10n.gradeValue(
                                (classroom['gradeLevel'] ?? l10n.unspecified)
                                    .toString(),
                              ),
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          _localizedRoleLabel(
                            l10n,
                            user['role'] as String? ?? 'user',
                          ),
                        ),
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.08),
                        labelStyle: const TextStyle(color: AppColors.primary),
                      ),
                      Chip(
                        label: Text((user['isActive'] as bool? ?? false)
                            ? l10n.active
                            : l10n.pendingApproval),
                        backgroundColor: (user['isActive'] as bool? ?? false)
                            ? AppColors.success.withValues(alpha: 0.08)
                            : AppColors.warningContainer,
                        labelStyle: TextStyle(
                          color: (user['isActive'] as bool? ?? false)
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      final newEmail = emailController.text.trim();
                      final classroomIds = selectedClassroomIds.toList();
                      if (newName.length < 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.nameTooShort),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      if (newEmail.isNotEmpty && !newEmail.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.emailInvalid),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final idx =
                          _users.indexWhere((u) => u['_id'] == user['_id']);
                      final authState = ref.read(authProvider);
                      final isDemoSession = (authState.accessToken ?? '')
                          .startsWith('demo-token-');
                      final payload = <String, dynamic>{
                        'fullName': newName,
                        if (newEmail.isNotEmpty) 'email': newEmail,
                        'classroomIds': classroomIds,
                      };

                      try {
                        if (!AppConstants.useMockData && !isDemoSession) {
                          await ref.read(adminRepositoryProvider).updateUser(
                                user['_id'] as String? ?? '',
                                payload,
                              );
                        }
                        if (idx != -1) {
                          setState(() {
                            _users[idx] = Map.from(_users[idx])
                              ..['fullName'] = newName
                              ..['email'] = newEmail
                              ..['username'] = usernameController.text.trim()
                              ..['classroomIds'] = classroomIds;
                          });
                        }
                        if (mounted && ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.userUpdated),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } on Object {
                        if (!AppConstants.useMockData && !isDemoSession) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.userUpdateFailed),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                          return;
                        }
                        if (idx != -1) {
                          setState(() {
                            _users[idx] = Map.from(_users[idx])
                              ..['fullName'] = newName
                              ..['email'] = newEmail
                              ..['username'] = usernameController.text.trim()
                              ..['classroomIds'] = classroomIds;
                          });
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Text(l10n.saveChanges,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateUserDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CreateUserDialog(
        onCreated: () {
          Navigator.pop(ctx);
          _loadUsers();
        },
      ),
    );
  }

  Widget _buildClassroomFilter() => DropdownButtonFormField<String>(
        key: ValueKey(_classroomFilterId),
        initialValue: _classroomFilterId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).filterByClassroom,
          prefixIcon: const Icon(Icons.class_outlined),
          suffixIcon: _classroomFilterId == null
              ? null
              : IconButton(
                  tooltip: AppLocalizations.of(context).clearClassroomFilter,
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => setState(() => _classroomFilterId = null),
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: [
          DropdownMenuItem<String>(
            child: Text(AppLocalizations.of(context).allClassrooms),
          ),
          ..._classroomOptions.map((classroom) {
            final id = (classroom['_id'] ?? classroom['id']).toString();
            return DropdownMenuItem<String>(
              value: id,
              child: Text(_classroomName(classroom)),
            );
          }),
        ],
        selectedItemBuilder: (context) => [
          Text(AppLocalizations.of(context).allClassrooms),
          ..._classroomOptions.map((classroom) {
            final id = (classroom['_id'] ?? classroom['id']).toString();
            return Text(_classroomFilterLabel(id));
          }),
        ],
        onChanged: (value) => setState(() => _classroomFilterId = value),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  size: 40, color: AppColors.outlineVariant),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noResults,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).tryChangingSearchCriteria,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.userManagement,
          style: TextStyle(
            color: colorScheme.onSurface,
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
          const AdminTopActions(),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextButton.icon(
              onPressed: _showCreateUserDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addUser),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle
                Text(
                  l10n.userManagementSubtitle,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: l10n.userManagementSearchHint,
                      hintStyle: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.onSurfaceVariant, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
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
                        label: l10n.allRoles,
                        selected: _roleFilter == null,
                        onTap: () {
                          setState(() => _roleFilter = null);
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: l10n.teacherRole,
                        selected: _roleFilter == 'teacher',
                        onTap: () {
                          setState(() => _roleFilter = 'teacher');
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: l10n.studentRole,
                        selected: _roleFilter == 'student',
                        onTap: () {
                          setState(() => _roleFilter = 'student');
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: 'ولي الأمر',
                        selected: _roleFilter == 'parent',
                        onTap: () {
                          setState(() => _roleFilter = 'parent');
                          _loadUsers();
                        },
                      ),
                      const SizedBox(width: 8),
                      _RoleChip(
                        label: l10n.pendingApproval,
                        selected: _roleFilter == 'pending',
                        onTap: () {
                          setState(() => _roleFilter = 'pending');
                          _loadUsers();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _buildClassroomFilter(),
              ],
            ),
          ),

          // ── User list ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
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
                                label: Text(l10n.retry),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _visibleUsers().isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _visibleUsers().length,
                              itemBuilder: (ctx, i) {
                                final users = _visibleUsers();
                                final user = users[i];
                                return _UserCard(
                                  user: user,
                                  classroomNames: _classroomNamesForUser(user),
                                  onDeactivate: user['isActive'] == true
                                      ? () => _deactivateUser(
                                          user['_id'] as String,
                                          user['fullName'] as String)
                                      : null,
                                  onEdit: () => _editUser(user),
                                  onReactivate: user['isActive'] == false
                                      ? () => _reactivateUser(
                                            user['_id'] as String,
                                            user['fullName'] as String,
                                          )
                                      : null,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, role: 'admin'),
    );
  }
}

// ── Role filter chip ──────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.outlineVariant,
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

// ── User card ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard(
      {required this.user,
      required this.classroomNames,
      this.onDeactivate,
      this.onEdit,
      this.onReactivate});
  final Map<String, dynamic> user;
  final List<String> classroomNames;
  final VoidCallback? onDeactivate;
  final VoidCallback? onEdit;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isActive = user['isActive'] as bool? ?? true;
    final role = user['role'] as String? ?? '';
    final isTeacher = role == 'teacher';
    final fullName = user['fullName'] as String? ?? '';
    final email = user['email'] as String?;
    final username = user['username'] as String?;
    final subtitle = email ?? (username ?? '');
    final classroomSummary = classroomNames.isEmpty
        ? (user['classroomCount'] != null
            ? l10n.classroomsCount(user['classroomCount'] as Object)
            : '—')
        : classroomNames.take(2).join(l10n.listSeparator);

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
          color: colorScheme.surface,
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
                      label: isTeacher ? l10n.subject : l10n.grade,
                      value: isTeacher
                          ? (user['subject'] as String? ?? '—')
                          : (user['grade'] as String? ?? '—'),
                    ),
                  ),
                  Expanded(
                    child: _InfoCell(
                      label: isTeacher ? l10n.classrooms : l10n.lastActivity,
                      value: isTeacher
                          ? classroomSummary
                          : (user['lastActive'] as String? ?? '—'),
                    ),
                  ),
                ],
              ),
            ),
            if (classroomNames.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final name in classroomNames.take(3))
                    Chip(
                      avatar: const Icon(Icons.class_outlined, size: 14),
                      label: Text(name),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.06),
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  if (classroomNames.length > 3)
                    Chip(
                      label: Text('+${classroomNames.length - 3}'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.surfaceContainer,
                    ),
                ],
              ),
            ],

            // ── Action buttons ───────────────────────────────────────────
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0x1AC4C5D5)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: l10n.edit,
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
                          label: l10n.stop,
                          onTap: onDeactivate ?? () {},
                          color: AppColors.error,
                          isDestructive: true,
                        )
                      : _ActionButton(
                          icon: Icons.settings_backup_restore_rounded,
                          label: l10n.approve,
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
    final l10n = AppLocalizations.of(context);
    if (!isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Text(
          l10n.disabled,
          style: const TextStyle(
            color: AppColors.error,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final isTeacher = role == 'teacher';
    final isParent = role == 'parent';
    final backgroundColor = isTeacher
        ? const Color(0xFFFFDBCE)
        : isParent
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFD0E1FB);
    final borderColor = isTeacher
        ? const Color(0xFFFFB59A).withValues(alpha: 0.3)
        : isParent
            ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
            : const Color(0xFFB7C8E1).withValues(alpha: 0.3);
    final textColor = isTeacher
        ? const Color(0xFF611E00)
        : isParent
            ? const Color(0xFF92400E)
            : const Color(0xFF54647A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        _localizedRoleLabel(l10n, role),
        style: TextStyle(
          color: textColor,
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
  Widget build(BuildContext context) => Column(
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
  Widget build(BuildContext context) => GestureDetector(
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

// ── Create user dialog ────────────────────────────────────────────────────────

class _CreateUserDialog extends ConsumerStatefulWidget {
  const _CreateUserDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<_CreateUserDialog> {
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
    } on Object {
      final isDemoSession =
          (ref.read(authProvider).accessToken ?? '').startsWith('demo-token-');
      if (!AppConstants.useMockData && !isDemoSession) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).userCreateFailed),
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
            content: Text(AppLocalizations.of(context).userCreated(_fullName)),
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.addNewUser),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(labelText: l10n.fullName),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
                onSaved: (v) => _fullName = v!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.username),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
                onSaved: (v) => _username = v!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
                onSaved: (v) => _email = v!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                validator: (v) => (v == null || v.length < 8)
                    ? l10n.passwordRequirementMin8
                    : null,
                onSaved: (v) => _password = v!,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: l10n.role),
                initialValue: _role,
                items: [
                  DropdownMenuItem(
                      value: 'teacher', child: Text(l10n.teacherRole)),
                  DropdownMenuItem(
                      value: 'student', child: Text(l10n.studentRole)),
                  const DropdownMenuItem(
                      value: 'parent', child: Text('ولي الأمر')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(l10n.create),
        ),
      ],
    );
  }
}
