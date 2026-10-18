import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../admin/data/repositories/favorites_repository.dart';
import '../../../admin/data/models/doctor.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();

  StreamSubscription<Set<String>>? _favoritesSubscription;
  Set<String> _favoriteIds = {};
  bool _favoritesLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _search = _searchController.text.trim().toLowerCase();
      });
    });

    _favoritesSubscription = _favoritesRepository
        .watchFavoriteDoctorIds()
        .listen(
      (ids) {
        if (!mounted) return;

        setState(() {
          _favoriteIds = ids;
          _favoritesLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _favoritesLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Favourite Doctors',
          style: context.bold16TextMain,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: context.regular12TextSub,
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSub,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 19),
                        onPressed: _searchController.clear,
                      ),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
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
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _favoritesLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _favoriteIds.isEmpty
                      ? _emptyState('No favourite doctors yet')
                      : StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('doctors')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _emptyState(
                                'Could not load doctors. Please try again.',
                              );
                            }

                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final doctors = (snapshot.data?.docs ?? [])
                                .where(
                                  (doc) =>
                                      _favoriteIds.contains(doc.id) &&
                                      doc.data()['isActive'] != false,
                                )
                                .map(
                                  (doc) => Doctor.fromMap(
                                    doc.id,
                                    doc.data(),
                                  ),
                                )
                                .where(
                                  (doctor) =>
                                      doctor.name
                                          .toLowerCase()
                                          .contains(_search) ||
                                      doctor.specialty
                                          .toLowerCase()
                                          .contains(_search),
                                )
                                .toList();

                            if (doctors.isEmpty) {
                              return _emptyState(
                                _search.isEmpty
                                    ? 'Your favourite doctors are unavailable.'
                                    : 'No matching favourite doctors found.',
                              );
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 12,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: doctors.length,
                              itemBuilder: (context, index) {
                                final doctor = doctors[index];

                                return _buildFavouriteCard(
                                  context,
                                  doctor,
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

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 48,
            color: AppColors.textSub,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavouriteCard(
    BuildContext context,
    Doctor doctor,
  ) {
    final accent = AppColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        context.push(
          '/doctor-details?doctorId=${Uri.encodeComponent(doctor.id)}',
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // FAVORITE HEART
            Align(
              alignment: Alignment.topRight,
              heightFactor: 1,
              child: SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Remove from favourites',
                  onPressed: () async {
                    try {
                      await _favoritesRepository.toggleFavorite(
                        doctor.id,
                      );
                    } catch (error) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not update favourites. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.favorite,
                    color: AppColors.danger,
                    size: 21,
                  ),
                ),
              ),
            ),

            // CIRCULAR DOCTOR IMAGE
            CircleAvatar(
              radius: 39,
              backgroundColor: accent.withValues(alpha: 0.10),
              backgroundImage: doctor.imageUrl.isNotEmpty
                  ? NetworkImage(doctor.imageUrl)
                  : null,
              onBackgroundImageError: doctor.imageUrl.isNotEmpty
                  ? (exception, stackTrace) {}
                  : null,
              child: doctor.imageUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 42,
                      color: accent,
                    )
                  : null,
            ),

            const SizedBox(height: 13),

            // DOCTOR NAME
            Text(
              doctor.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.semiBold12TextMain,
            ),

            const SizedBox(height: 5),

            // SPECIALTY
            Text(
              'Specialist ${doctor.specialty}',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.regular11TextSub.copyWith(
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}