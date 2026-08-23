import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  void _onLoginPressed() {
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');
    context.go('/home');
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
              Text(
                'Welcome back',
                style: context.bold24TextMain,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to continue finding trusted doctors and booking appointments',
                style: context.regular12TextSub,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildSocialButton('Google', Icons.g_mobiledata)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSocialButton('Facebook', Icons.facebook)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Email', style: context.semiBold14TextMain),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Enter your email'),
              ),
              const SizedBox(height: 16),
              Text('Password', style: context.semiBold14TextMain),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Enter your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
              CustomButton(
                text: 'Login',
                onPressed: _onLoginPressed,
              ),
              const SizedBox(height: 12),
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
                        TextSpan(
                          text: 'Join us',
                          style: context.bold12Primary,
                        ),
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

  Widget _buildSocialButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.textBorders),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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