import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../repositories/auth_repository.dart';

/// SignupScreen — Screen 55
/// New user registration form with role selection (Student/Teacher),
/// full name, email, password, confirm password, and terms checkbox.
/// RTL Arabic layout matching _55/code.html design.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'student';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _termsAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى الموافقة على الشروط والأحكام',
            style: TextStyle(fontFamily: 'Almarai'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).registerStudent(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال طلب الانضمام. سيظهر للمشرف للموافقة قبل تسجيل الدخول.',
            style: TextStyle(fontFamily: 'Almarai'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.login);
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.statusCode == 409
          ? 'هذا البريد مسجل بالفعل. استخدم تسجيل الدخول أو تواصل مع المشرف.'
          : 'تعذر إنشاء طلب الانضمام، تحقق من البيانات وحاول مرة أخرى.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Almarai')),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء إنشاء الحساب: $e',
            style: const TextStyle(fontFamily: 'Almarai'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ─── App Bar ──────────────────────────────────────────────
            _buildAppBar(),

            // ─── Scrollable Content ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  children: [
                    // Hero section
                    _buildHeroSection(),
                    const SizedBox(height: 24),

                    // Signup form
                    _buildSignupForm(),
                    const SizedBox(height: 24),

                    // Login link
                    _buildLoginLink(),
                    const SizedBox(height: 24),

                    // Decorative divider
                    _buildDecorativeDivider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button (RTL: left)
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: AppColors.onSurfaceVariant,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.login);
              }
            },
          ),
          // Logo (RTL: right)
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 6),
              const Text(
                'Adaptive Mastery',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Hero Section ─────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 48,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'إنشاء حساب جديد',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'انضم إلى مجتمع التعلم الذكي وباشر رحلتك التعليمية',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Signup Form ──────────────────────────────────────────────────────────

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildRoleSelector(),
          const SizedBox(height: 16),

          // Full name
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل',
            hint: 'أدخل اسمك الثلاثي',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.name,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'الاسم الكامل مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'example@domain.com',
            icon: Icons.mail_outlined,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'البريد الإلكتروني مطلوب';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'البريد الإلكتروني غير صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Password
          _buildPasswordField(
            controller: _passwordController,
            label: 'كلمة المرور',
            isVisible: _passwordVisible,
            onToggleVisibility: () =>
                setState(() => _passwordVisible = !_passwordVisible),
            validator: (v) {
              if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
              if (v.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                return 'يجب أن تحتوي على حرف كبير';
              }
              if (!RegExp(r'[0-9]').hasMatch(v)) {
                return 'يجب أن تحتوي على رقم';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Confirm password
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'تأكيد كلمة المرور',
            icon: Icons.enhanced_encryption_outlined,
            isVisible: _confirmPasswordVisible,
            onToggleVisibility: () => setState(
                () => _confirmPasswordVisible = !_confirmPasswordVisible),
            showToggle: false,
            validator: (v) {
              if (v == null || v.isEmpty) return 'تأكيد كلمة المرور مطلوب';
              if (v != _passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Terms checkbox
          _buildTermsCheckbox(),
          const SizedBox(height: 20),

          // Submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ─── Role Selector ────────────────────────────────────────────────────────

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton(
              role: 'student',
              icon: Icons.person_rounded,
              label: 'طالب',
            ),
          ),
          Expanded(
            child: _buildRoleButton(
              role: 'teacher',
              icon: Icons.workspace_premium_rounded,
              label: 'معلم',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String role,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        if (role == 'teacher') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'حسابات المعلمين يضيفها المشرف من إدارة المستخدمين.',
                style: TextStyle(fontFamily: 'Almarai'),
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          return;
        }
        setState(() => _selectedRole = role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Text Field ───────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          textAlign: TextAlign.right,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 14,
              color: AppColors.outline,
            ),
            prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Password Field ───────────────────────────────────────────────────────

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    IconData icon = Icons.lock_outlined,
    bool showToggle = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Almarai',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          validator: validator,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(
              fontFamily: 'Almarai',
              fontSize: 14,
              color: AppColors.outline,
            ),
            prefixIcon: showToggle
                ? IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.outline,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            suffixIcon: Icon(icon, color: AppColors.outline, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Terms Checkbox ───────────────────────────────────────────────────────

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _termsAccepted = !_termsAccepted),
            child: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('الشروط والأحكام'),
                            content: const SingleChildScrollView(
                              child: Text(
                                'باستخدام منصة التقييم التكيفي، أنت توافق على:\n\n'
                                '1. استخدام المنصة للأغراض التعليمية فقط.\n'
                                '2. الحفاظ على سرية بيانات الدخول.\n'
                                '3. عدم مشاركة محتوى الاختبارات مع الآخرين.\n'
                                '4. الالتزام بقواعد النزاهة الأكاديمية.\n'
                                '5. قبول سياسة الخصوصية الخاصة بالمنصة.\n\n'
                                'للاستفسار: support@adaptive-mastery.com',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(height: 1.6),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                child: const Text('موافق'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'الشروط والأحكام',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: ' وسياسة الخصوصية الخاصة بالمنصة.',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Checkbox(
          value: _termsAccepted,
          onChanged: (v) => setState(() => _termsAccepted = v ?? false),
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ],
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.app_registration_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'إنشاء الحساب',
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── Login Link ───────────────────────────────────────────────────────────

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => context.go(AppRoutes.login),
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ─── Decorative Divider ───────────────────────────────────────────────────

  Widget _buildDecorativeDivider() {
    return Opacity(
      opacity: 0.6,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.onSurfaceVariant,
                    AppColors.onSurfaceVariant.withValues(alpha: 0),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
