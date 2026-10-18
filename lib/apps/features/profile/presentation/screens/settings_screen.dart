import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/generated/app_colors.dart';
import 'package:my_app/generated/style_atoms.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _languageKey = 'app_language';

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _isLoadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled =
            prefs.getBool(_notificationsKey) ?? true;

        _selectedLanguage =
            prefs.getString(_languageKey) ?? 'English';

        _isLoadingPreferences = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingPreferences = false;
      });
    }
  }

  Future<void> _saveNotificationPreference(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, value);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save notification settings.');
    }
  }

  Future<void> _saveLanguagePreference(String language) async {
    final previousLanguage = _selectedLanguage;

    setState(() {
      _selectedLanguage = language;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);

      if (!mounted) return;

      _showMessage(
        'Language saved: $language. '
        'App translation is not connected yet.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedLanguage = previousLanguage;
      });

      _showMessage('Could not save language preference.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'User';

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
          'Settings',
          style: context.bold16TextMain,
        ),
        centerTitle: true,
      ),
      body: _isLoadingPreferences
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // PROFILE HEADER
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(
                                Icons.person_outline,
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
                            Text(
                              name,
                              style: context.semiBold14TextMain,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              user?.email ?? '',
                              style: context.regular12TextSub,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ACCOUNT
                Text(
                  'Account',
                  style: context.bold16TextMain,
                ),
                const SizedBox(height: 12),

                _buildSettingsCard(
                  children: [
                    _buildSettingsRow(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: _changePassword,
                    ),
                    _buildDivider(),
                    _buildNotificationRow(),
                  ],
                ),

                const SizedBox(height: 26),

                // PREFERENCES
                Text(
                  'Preferences',
                  style: context.bold16TextMain,
                ),
                const SizedBox(height: 12),

                _buildSettingsCard(
                  children: [
                    _buildSettingsRow(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        context.push('/privacy-policy');
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsRow(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      trailing: Text(
                        _selectedLanguage,
                        style: context.regular12TextSub,
                      ),
                      onTap: _showLanguageDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // LOGOUT
                _buildSettingsCard(
                  children: [
                    _buildSettingsRow(
                      icon: Icons.logout_rounded,
                      title: 'Log Out',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      showArrow: false,
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primary,
        size: 23,
      ),
      title: Text(
        title,
        style: context.semiBold14TextMain.copyWith(
          color: titleColor,
        ),
      ),
      trailing: trailing ??
          (showArrow
              ? const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Colors.grey,
                )
              : null),
    );
  }

  Widget _buildNotificationRow() {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      secondary: const Icon(
        Icons.notifications_none_outlined,
        color: AppColors.primary,
        size: 23,
      ),
      title: Text(
        'Notifications',
        style: context.semiBold14TextMain,
      ),
      value: _notificationsEnabled,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
      activeThumbColor: AppColors.primary,
      onChanged: _saveNotificationPreference,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  // CHANGE PASSWORD

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) {
      _showMessage('No email is associated with this account.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showMessage('Password reset email sent to $email.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ?? 'Could not send password reset email.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
    }
  }

  // LANGUAGE

  Future<void> _showLanguageDialog() async {
    final language = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, 'English');
              },
              child: const Text('English'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, 'Arabic');
              },
              child: const Text('العربية'),
            ),
          ],
        );
      },
    );

    if (language == null || !mounted) return;

    await _saveLanguagePreference(language);
  }

  // LOGOUT CONFIRMATION

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      context.go('/onboarding');
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not log out. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}