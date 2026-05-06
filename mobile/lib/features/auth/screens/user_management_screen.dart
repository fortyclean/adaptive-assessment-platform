import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../repositories/admin_repository.dart';

/// User Management Screen — Screen 17
/// Requirements: 13.2–13.5
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  String? _roleFilter;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await ref.read(adminRepositoryProvider).getUsers(
            search: _searchQuery.isNotEmpty ? _searchQuery : null,
            role: _roleFilter,
          );
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deactivateUser(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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

    if (confirmed ?? false) {
      try {
        await ref.read(adminRepositoryProvider).deactivateUser(id);
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تعطيل الحساب')),
          );
        }
      } catch (_) {}
    }
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
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _showCreateUserDialog,
            tooltip: 'إضافة مستخدم',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'بحث بالاسم أو اسم المستخدم',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadUsers();
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) {
                      setState(() => _searchQuery = v);
                      if (v.length >= 2 || v.isEmpty) _loadUsers();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _roleFilter,
                  hint: const Text('الكل'),
                  items: const [
                    DropdownMenuItem(child: Text('الكل')),
                    DropdownMenuItem(value: 'teacher', child: Text('معلم')),
                    DropdownMenuItem(value: 'student', child: Text('طالب')),
                  ],
                  onChanged: (v) {
                    setState(() => _roleFilter = v);
                    _loadUsers();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('لا توجد نتائج'))
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _users.length,
                          itemBuilder: (ctx, i) => _UserTile(
                            user: _users[i],
                            onDeactivate: _users[i]['isActive'] == true
                                ? () => _deactivateUser(
                                    _users[i]['_id'] as String,
                                    _users[i]['fullName'] as String)
                                : null,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, this.onDeactivate});
  final Map<String, dynamic> user;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    final isActive = user['isActive'] as bool? ?? true;
    final role = user['role'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive
              ? AppColors.onPrimaryContainer
              : AppColors.surfaceContainer,
          child: Text(
            (user['fullName'] as String? ?? '?')[0].toUpperCase(),
            style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(user['fullName'] as String? ?? ''),
        subtitle: Text(
            '@${user['username'] ?? ''} • ${role == 'teacher' ? 'معلم' : 'طالب'}'),
        trailing: isActive
            ? IconButton(
                icon: const Icon(Icons.block_rounded, color: AppColors.error),
                onPressed: onDeactivate,
                tooltip: 'تعطيل',
              )
            : const Chip(
                label: Text('معطل'),
                backgroundColor: AppColors.errorContainer,
                labelStyle: TextStyle(color: AppColors.error, fontSize: 11),
              ),
      ),
    );
  }
}

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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إنشاء الحساب')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('إضافة مستخدم جديد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _fullName = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _username = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
                onSaved: (v) => _email = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 8) ? '8 أحرف على الأقل' : null,
                onSaved: (v) => _password = v!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'الدور'),
                initialValue: _role,
                items: const [
                  DropdownMenuItem(value: 'teacher', child: Text('معلم')),
                  DropdownMenuItem(value: 'student', child: Text('طالب')),
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
