import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/doctor.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../logic/cubit/doctor_cubit.dart';
import '../../logic/cubit/doctor_state.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import 'admin_doctor_availability_screen.dart';

class AdminDoctorDetailsScreen extends StatefulWidget {
  final String doctorId;

  const AdminDoctorDetailsScreen({super.key, required this.doctorId});

  @override
  State<AdminDoctorDetailsScreen> createState() =>
      _AdminDoctorDetailsScreenState();
}

class _AdminDoctorDetailsScreenState extends State<AdminDoctorDetailsScreen> {
  late final DoctorCubit _doctorCubit;

  @override
  void initState() {
    super.initState();
    _doctorCubit = DoctorCubit(DoctorRepository());
  }

  @override
  void dispose() {
    _doctorCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorCubit,
      child: Scaffold(
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
          title: Text('Doctor Details', style: context.bold16TextMain),
          centerTitle: true,
        ),
        body: BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            Doctor? doctor;

            for (final item in state.doctors) {
              if (item.id == widget.doctorId) {
                doctor = item;
                break;
              }
            }

            if (doctor == null) {
              return const Center(child: Text('Doctor not found.'));
            }

            return _buildDetails(context, doctor);
          },
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, Doctor doctor) {
    final accent = AppColors.primary;
    const muted = Color(0xFF7B858C);
    const cardColor = Color(0xFFFFF9F3);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // DOCTOR PROFILE
          const SizedBox(height: 8),

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 53,
                backgroundColor: accent.withValues(alpha: 0.12),
                backgroundImage: doctor.imageUrl.isNotEmpty
                    ? NetworkImage(doctor.imageUrl)
                    : null,
                child: doctor.imageUrl.isEmpty
                    ? Icon(
                        Icons.person_outline_rounded,
                        size: 54,
                        color: accent,
                      )
                    : null,
              ),
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: doctor.isActive ? accent : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(
                  doctor.isActive ? Icons.check_rounded : Icons.close_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: context.bold16TextMain.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              doctor.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: doctor.isActive ? accent : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // DOCTOR INFORMATION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildDetailInfoRow(
                  icon: Icons.medical_services_outlined,
                  title: 'Specialty',
                  value: doctor.specialty,
                  accent: accent,
                  muted: muted,
                ),

                const SizedBox(height: 22),

                _buildDetailInfoRow(
                  icon: Icons.star_outline_rounded,
                  title: 'Rating',
                  value:
                      '${doctor.rating.toStringAsFixed(1)}  ·  ${doctor.reviewsCount} reviews',
                  accent: accent,
                  muted: muted,
                ),

                const SizedBox(height: 22),

                _buildDetailInfoRow(
                  icon: Icons.payments_outlined,
                  title: 'Consultation Fee',
                  value: '\$${doctor.fee.toStringAsFixed(2)}',
                  accent: accent,
                  muted: muted,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // EDIT DOCTOR
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/create-doctor?doctorId='
                  '${Uri.encodeComponent(doctor.id)}',
                );
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 19,
                color: Colors.white,
              ),
              label: const Text(
                'Edit Doctor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // MANAGE AVAILABILITY
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminDoctorAvailabilityScreen(doctor: doctor),
                  ),
                );
              },
              icon: Icon(
                Icons.calendar_month_outlined,
                color: accent,
                size: 19,
              ),
              label: Text(
                'Manage Availability',
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DETAIL INFORMATION ROW

  Widget _buildDetailInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
    required Color muted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 21),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF263238),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
