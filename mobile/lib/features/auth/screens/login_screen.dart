import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/google_auth_service.dart';

/// Login Screen — Screen 19
/// Requirements: 1.2, 1.3
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  String _loadingMessage = 'جاري تسجيل الدخول...';
  int _loadingSeconds = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Demo Login (no backend needed) ──────────────────────────────────────

  void _demoLogin(UserRole role) {
    final demoUsers = {
      UserRole.student: const AuthUser(
        id: 'demo-student-001',
        username: 'student_demo',
        fullName: 'أحمد محمد الطالب',
        email: 'student@demo.edu',
        role: UserRole.student,
        classroomIds: ['cls-001'],
      ),
      UserRole.teacher: const AuthUser(
        id: 'demo-teacher-001',
        username: 'teacher_demo',
        fullName: 'سارة أحمد المعلمة',
        email: 'teacher@demo.edu',
        role: UserRole.teacher,
      ),
      UserRole.admin: const AuthUser(
        id: 'demo-admin-001',
        username: 'admin_demo',
        fullName: 'محمد علي المشرف',
        email: 'admin@demo.edu',
        role: UserRole.admin,
      ),
    };

    final user = demoUsers[role]!;
    ref.read(authProvider.notifier).setUser(user, 'demo-token-${role.name}');

    switch (role) {
      case UserRole.admin:
        context.go(AppRoutes.adminDashboard);
      case UserRole.teacher:
        context.go(AppRoutes.teacherDashboard);
      case UserRole.student:
        context.go(AppRoutes.studentDashboard);
    }
  }

  // ─── Real Login ───────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingMessage = 'جاري تسجيل الدخول...';
      _loadingSeconds = 0;
    });

    // Timer to update loading message if server is slow (Render free tier wakeup)
    Timer? loadingTimer;
    loadingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _loadingSeconds++;
        if (_loadingSeconds >= 5 && _loadingSeconds < 30) {
          _loadingMessage = 'جاري تشغيل الخادم... ($_loadingSeconds ث)';
        } else if (_loadingSeconds >= 30) {
          _loadingMessage = 'يرجى الانتظار، الخادم يستيقظ...';
        }
      });
    });

    try {
      final result = await ref.read(authRepositoryProvider).login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );

      ref.read(authProvider.notifier).setUser(result.user, result.accessToken);

      if (!mounted) return;

      switch (result.user.role) {
        case UserRole.admin:
          context.go(AppRoutes.adminDashboard);
        case UserRole.teacher:
          context.go(AppRoutes.teacherDashboard);
        case UserRole.student:
          context.go(AppRoutes.studentDashboard);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String message;
      final responseStatus = e.response?.data is Map<String, dynamic>
          ? (e.response?.data as Map<String, dynamic>)['status'] as String?
          : null;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        message = 'الخادم يستيقظ، يرجى الانتظار 30 ثانية والمحاولة مجدداً';
      } else if (responseStatus == 'pending_approval') {
        message = 'الحساب بانتظار اعتماد المشرف. تواصل مع إدارة المؤسسة.';
      } else if (e.response?.statusCode == 401) {
        message = 'اسم المستخدم أو كلمة المرور غير صحيحة';
      } else if (e.response?.statusCode == 403) {
        message = 'الحساب بانتظار اعتماد المشرف أو تم تعطيله. تواصل مع المشرف.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'لا يوجد اتصال بالإنترنت';
      } else {
        message = 'حدث خطأ، يرجى المحاولة مجدداً';
      }
      setState(() => _errorMessage = message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'حدث خطأ غير متوقع، يرجى المحاولة مجدداً');
    } finally {
      loadingTimer.cancel();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel('اسم المستخدم'),
                            const SizedBox(height: 6),
                            _buildUsernameField(),
                            const SizedBox(height: 16),
                            _buildLabel('كلمة المرور'),
                            const SizedBox(height: 6),
                            _buildPasswordField(),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              _buildErrorBanner(),
                            ],
                            const SizedBox(height: 8),
                            // ── Remember me + Forgot password row ──────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Forgot password (RTL: left)
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                      fontFamily: 'Almarai',
                                    ),
                                  ),
                                ),
                                // Remember me (RTL: right)
                                Row(
                                  children: [
                                    const Text(
                                      'تذكرني',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.onSurfaceVariant,
                                        fontFamily: 'Almarai',
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (v) => setState(
                                            () => _rememberMe = v ?? false),
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        side: const BorderSide(
                                            color: AppColors.outlineVariant),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            const SizedBox(height: 16),
                            // ── Create account link ─────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.signup),
                                  child: const Text(
                                    'إنشاء حساب جديد',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontFamily: 'Almarai',
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'ليس لديك حساب؟',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                    fontFamily: 'Almarai',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // ── Google Sign-In ──────────────────────────────
                            _buildGoogleSignIn(),
                            const SizedBox(height: 24),
                            _buildDemoSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildHeader() => Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE1FF),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'منصة التقييم التكيفي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'تسجيل الدخول إلى حسابك',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildLabel(String text) => Text(
        text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
          fontFamily: 'Almarai',
        ),
      );

  Widget _buildUsernameField() => TextFormField(
        controller: _usernameController,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.text,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: 'أدخل اسم المستخدم',
          hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            fontFamily: 'Almarai',
          ),
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى إدخال اسم المستخدم';
          }
          return null;
        },
      );

  Widget _buildPasswordField() => TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          hintText: 'أدخل كلمة المرور',
          hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            fontFamily: 'Almarai',
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال كلمة المرور';
          }
          return null;
        },
      );

  Widget _buildErrorBanner() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.error,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildLoginButton() => SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            elevation: 1,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    if (_loadingSeconds >= 5) ...[
                      const SizedBox(height: 4),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontFamily: 'Almarai',
                        ),
                      ),
                    ],
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Almarai',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_back_rounded, size: 20),
                  ],
                ),
        ),
      );

  Widget _buildGoogleSignIn() => Column(
        children: [
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'أو',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEA4335),
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'تسجيل الدخول بـ Google',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingMessage = 'جاري تسجيل الدخول بـ Google...';
      _loadingSeconds = 0;
    });

    try {
      final result =
          await ref.read(googleAuthServiceProvider).signInWithGoogle();
      ref.read(authProvider.notifier).setUser(result.user, result.accessToken);

      if (!mounted) return;
      switch (result.user.role) {
        case UserRole.admin:
          context.go(AppRoutes.adminDashboard);
        case UserRole.teacher:
          context.go(AppRoutes.teacherDashboard);
        case UserRole.student:
          context.go(AppRoutes.studentDashboard);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.data is Map &&
          (e.response?.data as Map)['status'] == 'pending_approval') {
        setState(() => _errorMessage =
            'تم إرسال طلب الانضمام بحساب Google. سيحتاج المشرف إلى الموافقة قبل الدخول.');
        return;
      }
      final msg = e.response?.statusCode == 503
          ? 'تسجيل الدخول بـ Google غير مفعّل على الخادم حالياً'
          : 'فشل تسجيل الدخول بـ Google، يرجى المحاولة مجدداً';
      setState(() => _errorMessage = msg);
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('pending_approval')) {
        setState(() => _errorMessage =
            'تم إرسال طلب الانضمام بحساب Google. سيحتاج المشرف إلى الموافقة قبل الدخول.');
        return;
      }
      final msg = e.toString().contains('إلغاء')
          ? 'تم إلغاء تسجيل الدخول'
          : 'فشل تسجيل الدخول بـ Google';
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDemoSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'أو جرّب وضع العرض',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DemoButton(
                  label: 'طالب',
                  icon: Icons.school_rounded,
                  color: const Color(0xFF047857),
                  bgColor: const Color(0xFFD1FAE5),
                  onTap: () => _demoLogin(UserRole.student),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DemoButton(
                  label: 'معلم',
                  icon: Icons.person_rounded,
                  color: const Color(0xFF1E40AF),
                  bgColor: const Color(0xFFDDE1FF),
                  onTap: () => _demoLogin(UserRole.teacher),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DemoButton(
                  label: 'مشرف',
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFFEDE9FE),
                  onTap: () => _demoLogin(UserRole.admin),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'بيانات تجريبية — لا يتطلب اتصالاً بالإنترنت',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.outline,
                fontFamily: 'Almarai',
              ),
            ),
          ),
        ],
      );
}

// ─── Demo Button ──────────────────────────────────────────────────────────────

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
        ),
      );
}
