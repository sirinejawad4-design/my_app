

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';


import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class EditAdminProfileScreen extends StatefulWidget {
  const EditAdminProfileScreen({super.key});

  @override
  State<EditAdminProfileScreen> createState() => _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState extends State<EditAdminProfileScreen> {
  final _nameController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _photoUrlController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  
  String _photoUrl = '';
  bool _loading = true;
  bool _saving = false;

  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _firestore.collection('app_settings').doc('clinic');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await _settingsRef.get();
      final data = doc.data() ?? {};
      final user = _auth.currentUser;

      _nameController.text =
          data['adminName'] as String? ?? user?.displayName ?? '';

      _clinicNameController.text =
          data['clinicName'] as String? ?? 'Central Clinic';

      _locationController.text = data['clinicLocation'] as String? ?? '';

      _photoUrl = data['adminPhotoUrl'] as String? ?? user?.photoURL ?? '';
      _photoUrlController.text = _photoUrl;
    } catch (e) {
      _showMessage('Could not load settings: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  
        

  Future<void> _saveSettings() async {
    final user = _auth.currentUser;

    if (user == null) {
      _showMessage('Please log in again.');
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _clinicNameController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    setState(() => _saving = true);

    try {
      final photoUrl = _photoUrlController.text.trim();

      await _settingsRef.set({
        'adminName': _nameController.text.trim(),
        'adminEmail': user.email ?? '',
        'adminPhotoUrl': photoUrl,
        'clinicName': _clinicNameController.text.trim(),
        'clinicLocation': _locationController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(_nameController.text.trim());

      if (photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }

      if (!mounted) return;

      setState(() {
        _photoUrl = photoUrl;
        
      });

      _showMessage('Profile updated successfully.');
    } catch (e) {
      _showMessage('Could not save settings: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clinicNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Edit Profile', style: context.bold16TextMain),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
             Center(
  child: Column(
    children: [
      CircleAvatar(
        radius: 48,
        backgroundColor: AppColors.grey100,
        backgroundImage: _photoUrl.isNotEmpty
            ? NetworkImage(_photoUrl)
            : null,
        child: _photoUrl.isEmpty
            ? const Icon(
                Icons.person,
                size: 48,
                color: AppColors.textSub,
              )
            : null,
      ),
      const SizedBox(height: 8),
      Text(
        'Profile image from URL',
        style: context.regular12TextSub,
      ),
    ],
  ),
),
                     
                  const SizedBox(height: 28),
                  Text('Admin Profile', style: context.bold16TextMain),
                  const SizedBox(height: 16),
_field(
  label: 'Profile Image URL',
  controller: _photoUrlController,
  hint: 'https://example.com/profile.jpg',
),
                  const SizedBox(height: 16),
                  _field(
                    label: 'Full Name',
                    controller: _nameController,
                    hint: 'Enter admin name',
                  ),
                  const SizedBox(height: 16),
                  Text('Email Address', style: context.semiBold14TextMain),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    readOnly: true,
                    decoration: _decoration(
                      'Admin email',
                    ).copyWith(suffixIcon: const Icon(Icons.lock_outline)),
                  ),
                  const SizedBox(height: 28),
                  Text('Clinic Information', style: context.bold16TextMain),
                  const SizedBox(height: 16),
                  _field(
                    label: 'Clinic Name',
                    controller: _clinicNameController,
                    hint: 'Enter clinic name',
                  ),
                  const SizedBox(height: 16),
                  _field(
                    label: 'Clinic Location',
                    controller: _locationController,
                    hint: 'Enter full clinic address',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.semiBold14TextMain),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: _decoration(hint),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
