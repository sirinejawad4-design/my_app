import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_app/generated/app_colors.dart';
import 'package:my_app/generated/style_atoms.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _dateOfBirth;
  String? _gender;
  File? _selectedImage;
  bool _saving = false;
  bool _initialized = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _user;
    if (user == null) return;

    _nameController.text = user.displayName ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (!mounted) return;

      if (data != null) {
        _nameController.text =
            (data['name'] as String?) ?? _nameController.text;
        _phoneController.text = (data['phone'] as String?) ?? '';
        _dateOfBirth = data['dateOfBirth'] as String?;
        _gender = data['gender'] as String?;
      }

      setState(() => _initialized = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image == null || !mounted) return;

      setState(() => _selectedImage = File(image.path));
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not select image.');
    }
  }

  Future<String?> _uploadImage(User user) async {
    if (_selectedImage == null) return user.photoURL;

    final reference = FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/profile.jpg');

    final snapshot = await reference.putFile(
      _selectedImage!,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return snapshot.ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    final user = _user;

    if (user == null) {
      _showMessage('Please sign in again.');
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name.');
      return;
    }

    setState(() => _saving = true);

    try {
      final photoUrl = await _uploadImage(user);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'id': user.uid,
        'name': name,
        'phone': phone,
        'dateOfBirth': _dateOfBirth,
        'gender': _gender,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(name);

      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();

      if (!mounted) return;

      setState(() {
        _selectedImage = null;
        _saving = false;
      });

      _showMessage('Profile updated successfully.');
    } catch (error) {
      if (!mounted) return;

      setState(() => _saving = false);
      _showMessage(
        'Could not save profile. Check your Firebase rules and try again.',
      );
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    DateTime initialDate = now.subtract(
      const Duration(days: 365 * 20),
    );

    if (_dateOfBirth != null) {
      final parsed = DateTime.tryParse(_dateOfBirth!);
      if (parsed != null) initialDate = parsed;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );

    if (date == null || !mounted) return;

    setState(() {
      _dateOfBirth =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openPersonalInformation() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Personal Information',
                      style: context.bold16TextMain,
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration('Full name'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Phone number'),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await _selectDate();
                        setSheetState(() {});
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration('Date of birth'),
                        child: Text(
                          _dateOfBirth ?? 'Select date',
                          style: context.regular12TextSub,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
  initialValue: _gender,
                      decoration: _inputDecoration('Gender'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(
                          value: 'Male',
                          child: Text('Male'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                        DropdownMenuItem(
                          value: 'Prefer not to say',
                          child: Text('Prefer not to say'),
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() => _gender = value);
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                Navigator.of(sheetContext).pop();
                                await _saveProfile();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE3E9EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!.trim()
            : 'User');

    final email = user?.email ?? '';

    ImageProvider? imageProvider;

    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (user?.photoURL != null &&
        user!.photoURL!.isNotEmpty) {
      imageProvider = NetworkImage(user.photoURL!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: context.bold16TextMain),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF263238),
            ),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(
                                Icons.person_outline,
                                size: 48,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickImage,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: context.bold16TextMain.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(email, style: context.regular12TextSub),
                  const SizedBox(height: 30),
                  _buildProfileOption(
                    context,
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    onTap: _openPersonalInformation,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileOption(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedImage != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveProfile,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          _saving ? 'Saving...' : 'Save Profile Photo',
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: context.semiBold14TextMain,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
