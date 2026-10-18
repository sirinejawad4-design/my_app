import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubit/auth_cubit.dart';
import '../../logic/cubit/auth_state.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUpPressed() async {
    final authCubit = context.read<AuthCubit>();

    await authCubit.signUp(
      name: _nameController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!, style: context.regular12White),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _onGoogleSignInPressed() async {
    final authCubit = context.read<AuthCubit>();

    await authCubit.signInWithGoogle();

    if (!mounted) return;

    final state = authCubit.state;

    if (state.isSuccess) {
      context.go('/home');
      return;
    }

    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!, style: context.regular12White),
          backgroundColor: AppColors.danger,
        ),
      );
    }
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
              const SizedBox(height: 40),

              Text('Join us to start searching', style: context.bold24TextMain),

              const SizedBox(height: 8),

              Text(
                'You can search doctors, book appointments and find trusted care',
                style: context.regular12TextSub,
              ),

              const SizedBox(height: 24),

              // GOOGLE
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : _onGoogleSignInPressed,
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

              // NAME
              Text('Name', style: context.semiBold14TextMain),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Enter your name'),
              ),

              const SizedBox(height: 16),

              // EMAIL
              Text('Email', style: context.semiBold14TextMain),

              const SizedBox(height: 8),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Enter your email'),
              ),

              const SizedBox(height: 16),

              // PASSWORD
              Text('Password', style: context.semiBold14TextMain),

              const SizedBox(height: 8),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
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

              // SIGN UP
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  return CustomButton(
                    text: 'Sign up',
                    onPressed: _onSignUpPressed,
                  );
                },
              ),

              const SizedBox(height: 16),

              // LOGIN
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: context.regular12TextSub,
                      children: [
                        const TextSpan(text: 'Have an account? '),
                        TextSpan(text: 'Login', style: context.bold12Primary),
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
