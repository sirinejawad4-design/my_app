import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/doctor.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../logic/cubit/doctor_cubit.dart';
import '../../logic/cubit/doctor_state.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final DoctorCubit _doctorCubit;

  @override
  void initState() {
    super.initState();
    _doctorCubit = DoctorCubit(DoctorRepository());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => setState(() {});

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _doctorCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _doctorCubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text('Doctors', style: context.bold16White),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, state) {
            final query = _searchController.text.trim().toLowerCase();
            final doctors = state.doctors.where((doctor) {
              return doctor.name.toLowerCase().contains(query) ||
                  doctor.specialty.toLowerCase().contains(query);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.textSub),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search doctors...',
                                  hintStyle: context.regular14TextSub,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildStatCard(context, 'Total Doctors', '${state.doctors.length}'),
                          const SizedBox(width: 16),
                          _buildStatCard(context, 'Active', '${state.doctors.length}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildDoctorsBody(context, state, doctors),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/create-doctor'),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: AppColors.white),
          label: Text('Add Doctor', style: context.semiBold14White),
        ),
      ),
    );
  }

  Widget _buildDoctorsBody(
    BuildContext context,
    DoctorState state,
    List<Doctor> doctors,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.errorMessage != null && state.doctors.isEmpty) {
      return Center(
        child: Text(state.errorMessage!, style: context.regular14TextSub),
      );
    }

    if (doctors.isEmpty) {
      return Center(
        child: Text('No doctors added yet', style: context.regular14TextSub),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildDoctorTile(context, doctor);
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white,
              child: Icon(Icons.people_outline, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.regular11TextSub),
                Text(value, style: context.bold16TextMain),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorTile(BuildContext context, Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textBorders),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.grey100,
            backgroundImage: doctor.imageUrl.isNotEmpty
                ? NetworkImage(doctor.imageUrl)
                : null,
            child: doctor.imageUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.textSub)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: context.semiBold14TextMain),
                Text(doctor.specialty, style: context.regular12TextSub),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Active', style: context.regular11Success),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textSub),
        ],
      ),
    );
  }
}
