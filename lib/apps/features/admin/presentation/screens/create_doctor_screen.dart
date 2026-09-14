import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/doctor_cubit.dart';
import '../../logic/cubit/doctor_state.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class CreateDoctorScreen extends StatefulWidget {
  const CreateDoctorScreen({super.key});

  @override
  State<CreateDoctorScreen> createState() => _CreateDoctorScreenState();
}

class _CreateDoctorScreenState extends State<CreateDoctorScreen> {
  final TextEditingController _nameController = TextEditingController();

  
  final List<String> _specialties = const [
    'Cardiologist',
    'Orthopedic',
    'Dentist',
    'Pediatrician',
    'Dermatologist',
  ];
  String? _selectedSpecialty;

  File? _selectedImage;
  late final DoctorCubit _doctorCubit;

  @override
  void initState() {
    super.initState();
    _doctorCubit = DoctorCubit(DoctorRepository());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doctorCubit.close();
    super.dispose();
  }

  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _onCreateDoctorPressed() async {
    if (_nameController.text.trim().isEmpty || _selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in doctor name and specialty',
            style: context.regular12White,
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    await _doctorCubit.addDoctor(
      name: _nameController.text,
      specialty: _selectedSpecialty!,
      image: _selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorCubit,
      child: BlocListener<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Doctor added successfully',
                  style: context.regular12White,
                ),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: context.regular12White,
                ),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: AppColors.white),
        title: Text('Create Doctor', style: context.bold16White),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor Name', style: context.semiBold14TextMain),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter doctor name',
                hintStyle: context.regular14TextSub,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSub),
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 20),

            Text('Specialty', style: context.semiBold14TextMain),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSpecialty,
                  isExpanded: true,
                  hint: Text('Select specialty', style: context.regular14TextSub),
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(specialty, style: context.regular14TextMain),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialty = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text('Doctor Image', style: context.semiBold14TextMain),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textBorders,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.textSub,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload doctor image',
                            style: context.regular12TextSub,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to pick an image',
                            style: context.regular11TextSub,
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            BlocBuilder<DoctorCubit, DoctorState>(
              builder: (context, state) {
                return state.isSaving
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : CustomButton(
                        text: 'Create Doctor',
                        onPressed: _onCreateDoctorPressed,
                      );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
        ),
      ),
    );
  }
}