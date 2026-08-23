import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_hospital_rounded,
              size: 60,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Doctor Hunt',
              style: context.bold22TextMain,
            ),
          ],
        ),
      ),
    );
  }
}