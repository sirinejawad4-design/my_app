import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/auth_cubit.dart';
import '../../logic/cubit/auth_state.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<void> _onLoginPressed() async {
    final authCubit = context.read<AuthCubit>();

    await authCubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    final state = authCubit.state;

    if (state.isSuccess) {
      context.go('/home');
      return;
    }

    if (state.errorMessage != null) {
      _showError(state.errorMessage!);
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _onGooglePressed() async {
    final authCubit = context.read<AuthCubit>();

    await authCubit.signInWithGoogle();

    if (!mounted) return;

    final state = authCubit.state;

    if (state.isSuccess) {
      context.go('/home');
      return;
    }

    if (state.errorMessage != null) {
      _showError(state.errorMessage!);
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: context.regular12White),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ======================================================
              // TITLE
              // ======================================================
              Text('Welcome back', style: context.bold24TextMain),

              const SizedBox(height: 8),

              Text(
                'Login to continue finding trusted doctors and booking appointments',
                style: context.regular12TextSub,
              ),

              const SizedBox(height: 24),

              // ======================================================
              // AUTH STATE
              // ======================================================
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  // ==================================================
                  // GOOGLE BUTTON
                  // ==================================================

                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoading ? null : _onGooglePressed,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.textBorders),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ======================================================
              // EMAIL
              // ======================================================
              Text('Email', style: context.semiBold14TextMain),

              const SizedBox(height: 8),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !context.watch<AuthCubit>().state.isLoading,
                decoration: _inputDecoration('Enter your email'),
              ),

              const SizedBox(height: 16),

              // ======================================================
              // PASSWORD
              // ======================================================
              Text('Password', style: context.semiBold14TextMain),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !context.watch<AuthCubit>().state.isLoading,
                onSubmitted: (_) {
                  if (!context.read<AuthCubit>().state.isLoading) {
                    _onLoginPressed();
                  }
                },
                decoration: _inputDecoration('Enter your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSub,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // LOGIN BUTTON / LOADING
              // ======================================================
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }

                  return CustomButton(
                    text: 'Login',
                    onPressed: _onLoginPressed,
                  );
                },
              ),

              const SizedBox(height: 12),

              // ======================================================
              // FORGOT PASSWORD
              // ======================================================
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  child: Text(
                    'Forgot password?',
                    style: context.semiBold14Primary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ======================================================
              // SIGN UP
              // ======================================================
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/sign-up');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: context.regular12TextSub,
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(text: 'Join us', style: context.bold12Primary),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
