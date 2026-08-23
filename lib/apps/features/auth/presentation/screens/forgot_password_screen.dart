import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    context.go('/otp');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Forgot password',
                style: context.bold24TextMain,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email for the verification process, we will send a 4 digits code to your email',
                style: context.regular12TextSub,
              ),
              const SizedBox(height: 24),
              Text('Email', style: context.semiBold14TextMain),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  filled: true,
                  fillColor: AppColors.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue',
                onPressed: _onContinuePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}