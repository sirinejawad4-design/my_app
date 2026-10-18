import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import 'edit_admin_profile_screen.dart';

import 'package:go_router/go_router.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Administrator';
    final email = user?.email ?? 'No email available';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text('Settings', style: context.bold16TextMain),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Account',
            onPressed: () => _openEditProfile(context),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: user?.photoURL?.isNotEmpty == true
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL?.isNotEmpty != true
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: context.semiBold14TextMain),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        style: context.regular12TextSub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Admin Profile',
            subtitle: 'Edit your admin details and clinic information',
            onTap: () => _openEditProfile(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _showChangePassword(context),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Information',
            subtitle: 'Build version',
            trailing: const Text(
              'v1.0.0',
              style: TextStyle(color: AppColors.textSub),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'DoctorHunt',
                applicationVersion: '1.0.0',
                applicationLegalese: 'DoctorHunt appointment management',
              );
            },
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditAdminProfileScreen()),
    );
  }

  Future<void> _showChangePassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email address is linked to this account.'),
        ),
      );
      return;
    }

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Password'),
        content: Text('Send a password reset link to $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );

    if (shouldSend != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Could not send password reset email.'),
        ),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      context.go('/admin-login');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not log out.')),
      );
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
              if (trailing == null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSub,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
