import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../logic/cubit/doctor_cubit.dart';
import '../../logic/cubit/doctor_state.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../../../../generated/app_colors.dart';

import '../../../../core/widgets/custom_button.dart';

class CreateDoctorScreen extends StatefulWidget {
  const CreateDoctorScreen({super.key});

  @override
  State<CreateDoctorScreen> createState() => _CreateDoctorScreenState();
}

class _CreateDoctorScreenState extends State<CreateDoctorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

final TextEditingController _imageUrlController = TextEditingController();
  final List<String> _specialties = const [
    'Cardiologist',
    'Orthopedic',
    'Dentist',
    'Pediatrician',
    'Dermatologist',
  ];

  late final DoctorCubit _doctorCubit;

  static const Color _background = Color(0xFFFFFCF5);
  static const Color _fieldColor = Color(0xFFFFF4E7);
  static const Color _green = Color(0xFF19B58A);
  static const Color _darkText = Color(0xFF263238);
  static const Color _subText = Color(0xFF8A9297);
  static const Color _borderColor = Color(0xFFECE5DA);
  static const Color _danger = Color(0xFFD96B70);

  String? _doctorId;
  String? _selectedSpecialty;
  String? _existingImageUrl;

  File? _selectedImage;

  bool _doctorLoaded = false;
  bool _isActive = true;
  bool _originalIsActive = true;
  bool _closeAfterSuccess = false;
  bool _isDeleting = false;

  bool get _isEditing => _doctorId != null && _doctorId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _doctorCubit = DoctorCubit(DoctorRepository());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _doctorId ??= GoRouterState.of(context).uri.queryParameters['doctorId'];

    _loadDoctorIfAvailable(_doctorCubit.state);
  }

  void _loadDoctorIfAvailable(DoctorState state) {
    if (!_isEditing || _doctorLoaded) return;

    for (final doctor in state.doctors) {
      if (doctor.id == _doctorId) {
        _nameController.text = doctor.name;
        _feeController.text = doctor.fee.toString();
        _selectedSpecialty = doctor.specialty;
        _existingImageUrl = doctor.imageUrl;
        _imageUrlController.text = doctor.imageUrl;
        _isActive = doctor.isActive;
        _originalIsActive = doctor.isActive;
        _doctorLoaded = true;
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feeController.dispose();
    _doctorCubit.close();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : _green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSavePressed() async {
    final name = _nameController.text.trim();
    final feeText = _feeController.text.trim();

    if (name.isEmpty || _selectedSpecialty == null || feeText.isEmpty) {
      _showMessage(
        'Please fill in doctor name, specialty and fee',
        isError: true,
      );
      return;
    }

    final fee = double.tryParse(feeText);

    if (fee == null || fee < 0) {
      _showMessage('Please enter a valid fee', isError: true);
      return;
    }

    if (_isEditing && !_doctorLoaded) {
      _showMessage(
        'Doctor information is still loading. Please try again.',
        isError: true,
      );
      return;
    }

    if (_isEditing && _isActive != _originalIsActive) {
      await _doctorCubit.updateDoctorStatus(
        doctorId: _doctorId!,
        isActive: _isActive,
      );

      if (!mounted) return;

      if (_doctorCubit.state.errorMessage != null) {
        return;
      }

      _originalIsActive = _isActive;
    }

    _closeAfterSuccess = true;

   final imageUrl = _imageUrlController.text.trim();

if (_isEditing) {
  await _doctorCubit.updateDoctor(
    doctorId: _doctorId!,
    name: name,
    specialty: _selectedSpecialty!,
    fee: fee,
    imageUrl: imageUrl,
  );
} else {
  await _doctorCubit.addDoctor(
    name: name,
    specialty: _selectedSpecialty!,
    fee: fee,
    imageUrl: imageUrl,
  );
}
   
  }

  Future<void> _onDeletePressed() async {
    if (!_isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Deactivate Doctor?',
          style: TextStyle(color: _darkText, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will deactivate the doctor instead of permanently '
          'deleting the record, so booking history can be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deactivate', style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    await _doctorCubit.updateDoctorStatus(
      doctorId: _doctorId!,
      isActive: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorCubit,
      child: BlocListener<DoctorCubit, DoctorState>(
        listener: (context, state) {
          _loadDoctorIfAvailable(state);

          if (state.errorMessage != null) {
            _closeAfterSuccess = false;

            if (mounted) {
              setState(() {
                _isDeleting = false;
              });
            }

            _showMessage(state.errorMessage!, isError: true);
            return;
          }

          if (!state.saveSuccess) return;

          if (_isDeleting) {
            setState(() {
              _isDeleting = false;
            });

            _showMessage('Doctor deactivated successfully');
            context.pop();
            return;
          }

          if (_closeAfterSuccess) {
            _closeAfterSuccess = false;

            _showMessage(
              _isEditing
                  ? 'Doctor updated successfully'
                  : 'Doctor added successfully',
            );

            context.pop();
          }
        },
        child: BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, state) {
            _loadDoctorIfAvailable(state);

            final isLoadingDoctor =
                _isEditing && !_doctorLoaded && state.isLoading;

            return Scaffold(
              backgroundColor: _background,
              appBar: AppBar(
                backgroundColor: _background,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: _darkText,
                    size: 23,
                  ),
                ),
                title: Text(
                  _isEditing ? 'Edit Doctor' : 'Create Doctor',
                  style: const TextStyle(
                    color: _darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
                actions: [
                  if (_isEditing)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: _darkText),
                      onSelected: (value) {
                        if (value == 'deactivate') {
                          _onDeletePressed();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'deactivate',
                          child: Text('Deactivate Doctor'),
                        ),
                      ],
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
              body: isLoadingDoctor
                  ? const Center(
                      child: CircularProgressIndicator(color: _green),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPhotoSection(),
const SizedBox(height: 26),

_buildLabel('DOCTOR IMAGE URL'),
const SizedBox(height: 9),
TextField(
  controller: _imageUrlController,
  keyboardType: TextInputType.url,
  onChanged: (value) {
    setState(() {
      _existingImageUrl = value.trim();
    });
  },
  decoration: _inputDecoration(
    hint: 'https://example.com/doctor.jpg',
    icon: Icons.link,
  ),
),

const SizedBox(height: 23),

_buildLabel('DOCTOR NAME'),
                          const SizedBox(height: 9),
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'e.g. Dr. Ahmed Ali',
                              icon: Icons.person_outline,
                            ),
                          ),

                          const SizedBox(height: 23),

                          _buildLabel('SPECIALTY'),
                          const SizedBox(height: 9),
                          _buildSpecialtyDropdown(),

                          const SizedBox(height: 23),

                          _buildLabel('CONSULTATION FEE'),
                          const SizedBox(height: 9),
                          TextField(
                            controller: _feeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration(
                              hint: 'e.g. 50.00',
                              icon: Icons.payments_outlined,
                              prefixText: '\$ ',
                            ),
                          ),

                          if (_isEditing) ...[
                            const SizedBox(height: 27),
                            _buildStatusCard(),
                          ],

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: state.isSaving
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: _green,
                                    ),
                                  )
                                : CustomButton(
                                    text: _isEditing
                                        ? 'Save Changes'
                                        : 'Create Doctor',
                                    onPressed: _onSavePressed,
                                  ),
                          ),

                          if (_isEditing) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: state.isSaving
                                    ? null
                                    : _onDeletePressed,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFF8F5),
                                  foregroundColor: _danger,
                                  side: const BorderSide(
                                    color: Color(0xFFF4DEDA),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: const Text(
                                  'Delete Doctor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: SizedBox(
              width: 112,
              height: 112,
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _fieldColor,
                      border: Border.all(color: _borderColor, width: 1.2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildDoctorImage(),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 4,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: _background, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _isEditing ? 'Tap photo to change' : 'Add photo',
            style: const TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 104,
        height: 104,
      );
    }

    if (_existingImageUrl != null && _existingImageUrl!.trim().isNotEmpty) {
      return Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        width: 104,
        height: 104,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(
        _isEditing ? Icons.person_outline : Icons.camera_alt_outlined,
        size: 34,
        color: _green,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _darkText,
        fontSize: 11,
        letterSpacing: 0.35,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSpecialtyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: _fieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _specialties.contains(_selectedSpecialty)
              ? _selectedSpecialty
              : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _subText),
          hint: const Text(
            'Select specialty',
            style: TextStyle(color: _subText, fontSize: 13),
          ),
          items: _specialties
              .map(
                (specialty) => DropdownMenuItem<String>(
                  value: specialty,
                  child: Text(
                    specialty,
                    style: const TextStyle(color: _darkText, fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedSpecialty = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _fieldColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: _green,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doctor Status',
                  style: TextStyle(
                    color: _darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isActive ? 'Active & Available' : 'Inactive',
                  style: const TextStyle(color: _subText, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isActive,
            activeTrackColor: _green.withValues(alpha: 0.45),
            activeThumbColor: _green,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _subText, fontSize: 13),
      prefixIcon: Icon(icon, color: _subText, size: 20),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: _darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: _fieldColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _green, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _danger),
      ),
    );
  }
}
