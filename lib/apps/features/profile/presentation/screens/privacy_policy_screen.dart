import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/generated/app_colors.dart';
import 'package:my_app/generated/style_atoms.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF263238),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: context.bold16TextMain,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Privacy Policy',
                  style: context.bold16TextMain.copyWith(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Doctor Hunt',
                  style: context.regular12TextSub,
                ),
              ),

              const SizedBox(height: 24),

              _buildSection(
                title: '1. Introduction',
                content:
                    'Doctor Hunt helps users discover doctors and manage appointments. '
                    'This page explains the general types of information that may be '
                    'used when you use the application.',
              ),

              _buildSection(
                title: '2. Personal Information',
                content:
                    'Your account may contain information such as your name, email '
                    'address, phone number, date of birth, gender, and profile photo.',
              ),

              _buildSection(
                title: '3. Appointments',
                content:
                    'Information related to your appointments may be used to help '
                    'you view and manage your bookings.',
              ),

              _buildSection(
                title: '4. Account Security',
                content:
                    'Keep your account credentials private. If you need to change '
                    'your password, use the password reset option available in Settings.',
              ),

              _buildSection(
                title: '5. Your Choices',
                content:
                    'You can review and update the personal information available '
                    'in your profile and manage the settings provided by the application.',
              ),

              _buildSection(
                title: '6. Contact',
                content:
                    'For questions about this policy, please contact the application '
                    'administrator through the official contact method provided by Doctor Hunt.',
              ),

              const SizedBox(height: 8),

              Text(
                'Note: This is placeholder policy text for the application interface. '
                'It must be reviewed and replaced with the project’s approved privacy '
                'policy before publication.',
                style: context.regular12TextSub.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}