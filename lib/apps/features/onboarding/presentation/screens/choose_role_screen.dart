import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  String _selectedRole = 'Patient';

  void _onContinuePressed() {
    context.go('/sign-up');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.local_hospital_rounded,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Doctor Hunt',
                style: context.bold18TextMain,
              ),
              const SizedBox(height: 32),
              Text(
                'Choose your role',
                style: context.bold22TextMain,
              ),
              const SizedBox(height: 8),
              Text(
                'This selected role determines the experience and available features',
                textAlign: TextAlign.center,
                style: context.regular12TextSub,
              ),
              const SizedBox(height: 32),
              _buildRoleCard(
                icon: Icons.person_outline,
                title: 'Patient',
                description:
                    'Find doctors, book appointments, and manage your medical records',
                roleValue: 'Patient',
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin',
                description:
                    'Manage doctors, appointments, users, and the platform',
                roleValue: 'Admin',
              ),
              const Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: _onContinuePressed,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required String roleValue,
  }) {
    final bool isSelected = _selectedRole == roleValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textBorders,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bold14TextMain,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: context.regular12TextSub,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}