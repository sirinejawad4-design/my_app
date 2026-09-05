import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class AppointmentSuccessScreen extends StatelessWidget {
  const AppointmentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [  
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.thumb_up,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              Text('Thank You!', style: context.bold24TextMain),

              const SizedBox(height: 12),

              Text(
                'Your Appointment Successful',
                style: context.semiBold14TextMain,
              ),

              const SizedBox(height: 8),

              Text(
                'You booked an appointment with Dr. Pediatrician Purpleson on February 21, at 02:00 PM',
                textAlign: TextAlign.center,
                style: context.regular12TextSub,
              ),

              const SizedBox(height: 40),

              CustomButton(
                text: 'Done',
                onPressed: () {
                  // بعد التأكيد، بترجعي للـ Home مباشرة (بدون رجوع لكل الشاشات القديمة)
                  context.go('/home');
                },
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text(
                  'Edit your appointment',
                  style: context.semiBold14Primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}