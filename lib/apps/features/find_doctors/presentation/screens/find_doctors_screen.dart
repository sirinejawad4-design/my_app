
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../admin/data/models/doctor.dart';
import '../../../admin/data/repositories/favorites_repository.dart';

class FindDoctorsScreen extends StatefulWidget {
  const FindDoctorsScreen({super.key});

  @override
  State<FindDoctorsScreen> createState() => _FindDoctorsScreenState();
}

class _FindDoctorsScreenState extends State<FindDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();

  StreamSubscription<Set<String>>? _favoritesSubscription;

  Set<String> _favoriteIds = <String>{};
  String _search = '';
  String _selectedSpecialty = 'All';

  static const List<String> _specialties = [
    'All',
    'Cardiology',
    'Pediatrics',
    'Dentist',
    'Neurology',
    'Ophthalmology',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    _favoritesSubscription = _favoritesRepository
        .watchFavoriteDoctorIds()
        .listen(
      (ids) {
        if (!mounted) return;
        setState(() => _favoriteIds = ids);
      },
      onError: (_) {},
    );
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _search = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  Future<void> _toggleFavorite(Doctor doctor) async {
    try {
      await _favoritesRepository.toggleFavorite(doctor.id);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update favourites. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;
    final queryParameters =
        GoRouterState.of(context).uri.queryParameters;

    final sortBy = queryParameters['sort'];
    final specialtyFromRoute =
        queryParameters['specialty']?.trim();

    final initialSpecialty = _specialties.firstWhere(
      (specialty) =>
          specialty.toLowerCase() ==
          specialtyFromRoute?.toLowerCase(),
      orElse: () => 'All',
    );

    // Keep the specialty selected when opening this page
    // from a specialty shortcut on the home screen.
    if (_selectedSpecialty == 'All' &&
        initialSpecialty != 'All') {
      _selectedSpecialty = initialSpecialty;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Find Doctors',
          style: context.bold16TextMain,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors or specialties...',
                hintStyle: context.regular12TextSub,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSub,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 19,
                          color: AppColors.textSub,
                        ),
                        onPressed: _searchController.clear,
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Specialty filters
            Text(
              'Specialties',
              style: context.semiBold14TextMain,
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _specialties.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final specialty = _specialties[index];
                  final isSelected =
                      _selectedSpecialty == specialty;

                  return ChoiceChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedSpecialty = specialty;
                      });
                    },
                    selectedColor: accent,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSub,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? accent
                          : const Color(0xFFEAF0F0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // Results heading
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedSpecialty == 'All'
                        ? 'Available Doctors'
                        : _selectedSpecialty,
                    style: context.semiBold14TextMain,
                  ),
                ),
                if (sortBy == 'popular')
                  Text(
                    'Most Popular',
                    style: context.regular12TextSub,
                  )
                else if (sortBy == 'topRated')
                  Text(
                    'Top Rated',
                    style: context.regular12TextSub,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Doctors list
            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Could not load doctors. Please try again.',
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: accent,
                      ),
                    );
                  }

                  final doctors = (snapshot.data?.docs ?? [])
                      .where((doc) {
                        final data = doc.data();
                        return data['isActive'] != false;
                      })
                      .map(
                        (doc) => Doctor.fromMap(
                          doc.id,
                          doc.data(),
                        ),
                      )
                      .where((doctor) {
                        // Filter by specialty.
                        if (_selectedSpecialty != 'All' &&
                            doctor.specialty.toLowerCase() !=
                                _selectedSpecialty.toLowerCase()) {
                          return false;
                        }

                        // Filter by search text.
                        if (_search.isNotEmpty) {
                          final matchesName = doctor.name
                              .toLowerCase()
                              .contains(_search);

                          final matchesSpecialty = doctor
                              .specialty
                              .toLowerCase()
                              .contains(_search);

                          if (!matchesName && !matchesSpecialty) {
                            return false;
                          }
                        }

                        return true;
                      }).toList()
                    ..sort((a, b) {
                      if (sortBy == 'popular') {
                        final reviewsComparison =
                            b.reviewsCount.compareTo(a.reviewsCount);

                        if (reviewsComparison != 0) {
                          return reviewsComparison;
                        }

                        return b.rating.compareTo(a.rating);
                      }

                      if (sortBy == 'topRated') {
                        final ratingComparison =
                            b.rating.compareTo(a.rating);

                        if (ratingComparison != 0) {
                          return ratingComparison;
                        }

                        return b.reviewsCount
                            .compareTo(a.reviewsCount);
                      }

                      return a.name
                          .toLowerCase()
                          .compareTo(b.name.toLowerCase());
                    });

                  if (doctors.isEmpty) {
                    return Center(
                      child: Text(
                        _selectedSpecialty == 'All'
                            ? 'No doctors found.'
                            : 'No doctors found for $_selectedSpecialty.',
                        textAlign: TextAlign.center,
                        style: context.regular12TextSub,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: doctors.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      final isFavorite =
                          _favoriteIds.contains(doctor.id);

                      return _buildDoctorCard(
                        doctor: doctor,
                        isFavorite: isFavorite,
                        accent: accent,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard({
    required Doctor doctor,
    required bool isFavorite,
    required Color accent,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(
            '/doctor-details?doctorId=${Uri.encodeComponent(doctor.id)}',
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFEAF0F0),
            ),
          ),
          child: Row(
            children: [
              // Doctor image
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: doctor.imageUrl.isEmpty
                    ? Container(
                        width: 64,
                        height: 68,
                        color: accent.withValues(alpha: 0.10),
                        child: Icon(
                          Icons.person,
                          color: accent,
                          size: 34,
                        ),
                      )
                    : Image.network(
                        doctor.imageUrl,
                        width: 64,
                        height: 68,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 64,
                          height: 68,
                          color: accent.withValues(alpha: 0.10),
                          child: Icon(
                            Icons.person,
                            color: accent,
                            size: 34,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              // Doctor information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.semiBold14TextMain,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Specialist ${doctor.specialty}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.regular12TextSub.copyWith(
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${doctor.rating.toStringAsFixed(1)} '
                            '(${doctor.reviewsCount} reviews)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.regular11TextSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$${doctor.fee.toStringAsFixed(0)} / visit',
                      style: context.semiBold12TextMain,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 2),

              // Favorite button
              IconButton(
                tooltip: isFavorite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: () => _toggleFavorite(doctor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite
                      ? AppColors.danger
                      : Colors.grey,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}