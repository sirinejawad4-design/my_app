import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              
              const Icon(
                Icons.local_hospital_rounded,
                size: 40,
                color: Color(0xFF1F9E6E),
              ),
              const SizedBox(height: 8),
              const Text(
                'Doctor Hunt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Choose your role',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This selected role determines the experience and available features',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
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

              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onContinuePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F9E6E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
            color: isSelected ? const Color(0xFF1F9E6E) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFF1F9E6E).withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1F9E6E), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF1F9E6E)),
          ],
        ),
      ),
    );
  }
}