
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../data/repositories/home_repository.dart';
import '../../logic/cubit/home_cubit.dart';
import '../../../admin/data/models/doctor.dart';
import '../../../admin/data/repositories/favorites_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FavoritesRepository _favoritesRepository = FavoritesRepository();

  StreamSubscription<Set<String>>? _favoritesSubscription;
  Set<String> _favoriteDoctors = <String>{};

  @override
  void initState() {
    super.initState();

    _favoritesSubscription = _favoritesRepository
        .watchFavoriteDoctorIds()
        .listen(
      (favoriteIds) {
        if (!mounted) return;
        setState(() => _favoriteDoctors = favoriteIds);
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(HomeRepository()),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, state.userName),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      context,
                      'Specialties',
                      showSeeAll: false,
                    ),
                    const SizedBox(height: 12),
                    _buildSpecialties(context),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      'Popular Doctors',
                      sortBy: 'popular',
                    ),
                    const SizedBox(height: 12),
                    _buildPopularDoctors(context, cubit.popularDoctors),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      'Top Rated Doctors',
                      sortBy: 'topRated',
                    ),
                    const SizedBox(height: 12),
                    _buildTopRatedDoctors(context, cubit.topRatedDoctors),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi $userName,', style: context.regular14White),
          const SizedBox(height: 5),
          Text('Find Your Doctor', style: context.bold22White),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => context.push('/find-doctors'),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.textSub,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search doctors...',
                      style: context.regular14TextSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool showSeeAll = true,
    String? sortBy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: context.bold16TextMain),
          if (showSeeAll)
            GestureDetector(
              onTap: () {
                final sort = sortBy ?? 'all';
                context.push('/find-doctors?sort=$sort');
              },
              child: Text(
                'See all',
                style: context.regular12Primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecialties(BuildContext context) {
    final specialties = <Map<String, dynamic>>[
      {'name': 'Cardiology', 'icon': Icons.favorite_outline},
      {'name': 'Pediatrics', 'icon': Icons.child_care_outlined},
      {'name': 'Dentist', 'icon': Icons.medical_services_outlined},
      {'name': 'Neurology', 'icon': Icons.psychology_outlined},
      {'name': 'Ophthalmology', 'icon': Icons.visibility_outlined},
    ];

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: specialties.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final specialty = specialties[index];

          return GestureDetector(
            onTap: () {
              final name = Uri.encodeComponent(
                specialty['name'] as String,
              );
              context.push('/find-doctors?specialty=$name');
            },
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      specialty['icon'] as IconData,
                      color: AppColors.primary,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    specialty['name'] as String,
                    style: context.regular11TextSub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularDoctors(
    BuildContext context,
    List<Doctor> doctors,
  ) {
    if (doctors.isEmpty) return _buildEmptyDoctors();
    return _buildDoctorList(context, doctors);
  }

  Widget _buildTopRatedDoctors(
    BuildContext context,
    List<Doctor> doctors,
  ) {
    if (doctors.isEmpty) return _buildEmptyDoctors();
    return _buildDoctorList(context, doctors);
  }

  Widget _buildDoctorList(
    BuildContext context,
    List<Doctor> doctors,
  ) {
    return SizedBox(
      height: 225,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: doctors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _buildDoctorCard(context, doctors[index]);
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    final isFavorite = _favoriteDoctors.contains(doctor.id);

    return GestureDetector(
      onTap: () {
        context.push(
          '/doctor-details?doctorId=${Uri.encodeComponent(doctor.id)}',
        );
      },
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textBorders),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(child: _buildDoctorImage(doctor.imageUrl)),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: AppColors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        try {
                          await _favoritesRepository.toggleFavorite(
                            doctor.id,
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not update favorite. Please try again.',
                              ),
                            ),
                          );
                        }
                      },
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 17,
                          color: isFavorite
                              ? AppColors.danger
                              : AppColors.textSub,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              doctor.name,
              style: context.semiBold12TextMain,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              doctor.specialty,
              style: context.regular11TextSub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: context.semiBold12TextMain,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    '(${doctor.reviewsCount})',
                    style: context.regular11TextSub,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  '\$${doctor.fee.toStringAsFixed(0)}',
                  style: context.semiBold12TextMain,
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 13,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage(String imageUrl) {
    if (imageUrl.isEmpty) return _doctorPlaceholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _doctorPlaceholder();
        },
      ),
    );
  }

  Widget _doctorPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.textSub,
        size: 42,
      ),
    );
  }

  Widget _buildEmptyDoctors() {
    return const SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'No doctors available yet',
          style: TextStyle(color: AppColors.textSub),
        ),
      ),
    );
  }
}