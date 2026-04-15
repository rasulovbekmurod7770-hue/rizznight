import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/providers.dart';

// ── Login Page ─────────────────────────────────────────────────
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      await ref.read(authServiceProvider).signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) context.go(AppRoutes.landing);
    } catch (e) {
      setState(() => _error = 'Invalid email or password.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.landing),
                    child: const RzLogo(),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  _RzField(
                    label: 'EMAIL',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  _RzField(
                    label: 'PASSWORD',
                    controller: _passCtrl,
                    obscure: true,
                    validator: (v) => v!.length >= 6 ? null : 'Min 6 characters',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 28),
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1))
                      : RzButton(label: 'LOGIN', onTap: _login, fullWidth: true),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.signup),
                      child: const Text(
                        "Don't have an account? Request an invite →",
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Signup Page ────────────────────────────────────────────────
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  // final _inviteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    // _inviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      await ref.read(authServiceProvider).signUp(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        // inviteCode: _inviteCtrl.text.trim(),
      );
      if (mounted) context.go(AppRoutes.landing);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.landing),
                    child: const RzLogo(),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'JOIN THE CREW',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'You need an invite code to join.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  _RzField(
                    label: 'FULL NAME',
                    controller: _nameCtrl,
                    validator: (v) => v!.trim().length >= 2 ? null : 'Enter your name',
                  ),
                  const SizedBox(height: 16),
                  _RzField(
                    label: 'EMAIL',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  _RzField(
                    label: 'PASSWORD',
                    controller: _passCtrl,
                    obscure: true,
                    validator: (v) => v!.length >= 6 ? null : 'Min 6 characters',
                  ),
                  const SizedBox(height: 16),
                  
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 28),
                  _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1))
                      : RzButton(label: 'CREATE ACCOUNT', onTap: _signup, fullWidth: true),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Already have an account? Login →',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared Field Widget ────────────────────────────────────────
class _RzField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _RzField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
