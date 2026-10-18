import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _navigateFromSplash();
  }

  Future<void> _navigateFromSplash() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Always show onboarding when the app starts.
      await prefs.setBool('onboarding_completed', false);

      if (!mounted) return;

      context.go('/onboarding');
    } catch (error, stackTrace) {
      debugPrint('Splash navigation error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      context.go('/onboarding');
    }
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