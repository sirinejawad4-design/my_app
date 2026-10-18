import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/apps/features/admin/data/models/doctor.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  late Future<Doctor?> _doctorFuture;

  @override
  void initState() {
    super.initState();
    _doctorFuture = _loadDoctor();
  }

  Future<Doctor?> _loadDoctor() async {
    final doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return Doctor.fromMap(doc.id, doc.data()!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: Text('Doctor Details', style: context.bold16TextMain),
        centerTitle: true,
      ),
      body: FutureBuilder<Doctor?>(
        future: _doctorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return _buildError();
          }

          final doctor = snapshot.data;

          if (doctor == null) {
            return _buildNotFound();
          }

          return _buildDoctorDetails(context, doctor);
        },
      ),
    );
  }

  Widget _buildDoctorDetails(BuildContext context, Doctor doctor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DOCTOR CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildDoctorImage(doctor.imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: context.semiBold16TextMain,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(doctor.specialty, style: context.regular12TextSub),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.rating.toStringAsFixed(1),
                            style: context.semiBold12TextMain,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '(${doctor.reviewsCount} reviews)',
                            style: context.regular11TextSub,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${doctor.fee.toStringAsFixed(0)} / visit',
                        style: context.semiBold12TextMain,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ABOUT DOCTOR
          Text('About Doctor', style: context.bold16TextMain),
          const SizedBox(height: 8),
          Text(
            'Book an appointment with ${doctor.name} '
            'and get trusted medical care at our clinic.',
            style: context.regular12TextSub,
          ),

          const SizedBox(height: 24),

          // CENTRAL CLINIC LOCATION
          Text('Clinic Location', style: context.bold16TextMain),
          const SizedBox(height: 10),

          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('app_settings')
                .doc('clinic')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildClinicLocationCard(
                  clinicName: 'Central Clinic',
                  clinicLocation: 'Could not load clinic location.',
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              final data = snapshot.data?.data() ?? {};

              final clinicName = (data['clinicName'] as String?)?.trim();

              final clinicLocation = (data['clinicLocation'] as String?)
                  ?.trim();

              return _buildClinicLocationCard(
                clinicName: clinicName == null || clinicName.isEmpty
                    ? 'Central Clinic'
                    : clinicName,
                clinicLocation: clinicLocation == null || clinicLocation.isEmpty
                    ? 'Location not set'
                    : clinicLocation,
              );
            },
          ),

          const SizedBox(height: 24),

          // REVIEWS
          Text('Reviews', style: context.bold16TextMain),
          const SizedBox(height: 10),

          // RATING SUMMARY
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 22),
                const SizedBox(width: 8),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: context.bold18TextMain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${doctor.reviewsCount} patient reviews',
                    style: context.regular12TextSub,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // REAL REVIEWS FROM FIRESTORE
          _ReviewsList(doctorId: doctor.id),

          const SizedBox(height: 28),

          // BOOK NOW
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/select-time?doctorId=${Uri.encodeComponent(doctor.id)}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Book Now', style: context.semiBold16White),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'Consultation fee: '
              '\$${doctor.fee.toStringAsFixed(0)}',
              style: context.regular12TextSub,
            ),
          ),
        ],
      ),
    );
  }

  // CLINIC LOCATION CARD
  Widget _buildClinicLocationCard({
    required String clinicName,
    required String clinicLocation,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clinicName, style: context.semiBold14TextMain),
                const SizedBox(height: 4),
                Text(clinicLocation, style: context.regular12TextSub),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DOCTOR IMAGE
  Widget _buildDoctorImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.person, color: AppColors.textSub, size: 42),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: AppColors.textSub, size: 42),
          );
        },
      ),
    );
  }

  // ERROR
  Widget _buildError() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Something went wrong.\nPlease try again.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // DOCTOR NOT FOUND
  Widget _buildNotFound() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Doctor not found.', textAlign: TextAlign.center),
      ),
    );
  }
}

// REVIEWS LIST
class _ReviewsList extends StatelessWidget {
  final String doctorId;

  const _ReviewsList({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('doctorId', isEqualTo: doctorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('Could not load reviews.'),
          );
        }

        final reviews = snapshot.data?.docs.toList() ?? [];

        if (reviews.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'No patient reviews yet.',
              style: context.regular12TextSub,
            ),
          );
        }

        // Sort newest first.
        reviews.sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;

          if (aTime == null && bTime == null) {
            return 0;
          }

          if (aTime == null) {
            return 1;
          }

          if (bTime == null) {
            return -1;
          }

          return bTime.compareTo(aTime);
        });

        return Column(
          children: reviews.map((reviewDoc) {
            final review = reviewDoc.data();

            final rating = (review['rating'] as num?)?.toInt() ?? 0;

            final comment = review['comment'] as String? ?? '';

            final createdAt = review['createdAt'] as Timestamp?;

            return _ReviewCard(
              rating: rating,
              comment: comment,
              createdAt: createdAt,
            );
          }).toList(),
        );
      },
    );
  }
}

// REVIEW CARD
class _ReviewCard extends StatelessWidget {
  final int rating;
  final String comment;
  final Timestamp? createdAt;

  const _ReviewCard({
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  String _formatDate() {
    if (createdAt == null) {
      return '';
    }

    final date = createdAt!.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STARS + DATE
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 18,
                  );
                }),
              ),
              const Spacer(),
              if (createdAt != null)
                Text(_formatDate(), style: context.regular11TextSub),
            ],
          ),

          // COMMENT
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: context.regular12TextMain.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
