import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/app_colors.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your appointments.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load appointments.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final appointments = snapshot.data?.docs ?? [];

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSub,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AppointmentsList(
                        appointments: appointments,
                        status: 'upcoming',
                      ),
                      _AppointmentsList(
                        appointments: appointments,
                        status: 'completed',
                      ),
                      _AppointmentsList(
                        appointments: appointments,
                        status: 'cancelled',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> appointments;
  final String status;

  const _AppointmentsList({required this.appointments, required this.status});

  @override
  Widget build(BuildContext context) {
    final filtered = appointments.where((doc) {
      return doc.data()['status'] == status;
    }).toList();

    if (filtered.isEmpty) {
      return _EmptyAppointments(status: status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final doc = filtered[index];

        return _AppointmentCard(appointmentId: doc.id, data: doc.data());
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String appointmentId;
  final Map<String, dynamic> data;

  const _AppointmentCard({required this.appointmentId, required this.data});

  Future<void> _cancelAppointment(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please login first.');
      }

      final db = FirebaseFirestore.instance;
      final appointmentRef = db.collection('appointments').doc(appointmentId);

      await db.runTransaction((transaction) async {
        final appointmentSnapshot = await transaction.get(appointmentRef);

        if (!appointmentSnapshot.exists) {
          throw Exception('Appointment not found.');
        }

        final appointment = appointmentSnapshot.data()!;

        if (appointment['userId'] != user.uid) {
          throw Exception('You cannot cancel this appointment.');
        }

        if (appointment['status'] != 'upcoming') {
          throw Exception('Only upcoming appointments can be cancelled.');
        }

        final slotId = appointment['slotId'] as String?;

        DocumentReference<Map<String, dynamic>>? slotRef;
        DocumentSnapshot<Map<String, dynamic>>? slotSnapshot;

        if (slotId != null && slotId.isNotEmpty) {
          slotRef = db.collection('appointment_slots').doc(slotId);
          slotSnapshot = await transaction.get(slotRef);
        }

        transaction.update(appointmentRef, {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        if (slotRef != null && slotSnapshot != null && slotSnapshot.exists) {
          final slot = slotSnapshot.data()!;

          if (slot['appointmentId'] == appointmentId &&
              slot['userId'] == user.uid &&
              slot['status'] == 'booked') {
            transaction.update(slotRef, {
              'status': 'available',
              'appointmentId': FieldValue.delete(),
              'userId': FieldValue.delete(),
            });
          }
        }
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not cancel appointment: $e')),
      );
    }
  }

  Future<void> _rateDoctor(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _RateDoctorDialog(),
    );

    if (result == null) return;

    final int rating = result['rating'] as int;
    final String comment = result['comment'] as String;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please login first.');
      }

      final doctorId = data['doctorId'] as String? ?? '';
      if (doctorId.isEmpty) {
        throw Exception('Doctor ID is missing.');
      }

      final db = FirebaseFirestore.instance;
      final appointmentRef = db.collection('appointments').doc(appointmentId);
      final doctorRef = db.collection('doctors').doc(doctorId);
      final reviewRef = db.collection('reviews').doc(appointmentId);

      await db.runTransaction((transaction) async {
        final appointmentSnapshot = await transaction.get(appointmentRef);
        final doctorSnapshot = await transaction.get(doctorRef);

        if (!appointmentSnapshot.exists || !doctorSnapshot.exists) {
          throw Exception('Appointment or doctor not found.');
        }

        final appointment = appointmentSnapshot.data()!;

        if (appointment['userId'] != user.uid) {
          throw Exception('You cannot rate this appointment.');
        }

        if (appointment['status'] != 'completed') {
          throw Exception('Only completed appointments can be rated.');
        }

        if (appointment['rated'] == true) {
          throw Exception('This appointment has already been rated.');
        }

        final doctor = doctorSnapshot.data()!;

        final currentRating = (doctor['rating'] as num?)?.toDouble() ?? 0.0;
        final currentReviews = (doctor['reviewsCount'] as num?)?.toInt() ?? 0;

        final newReviews = currentReviews + 1;
        final newRating =
            ((currentRating * currentReviews) + rating) / newReviews;

        transaction.set(reviewRef, {
          'appointmentId': appointmentId,
          'patientId': user.uid,
          'doctorId': doctorId,
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(doctorRef, {
  'rating': newRating,
  'reviewsCount': newReviews,
  'lastReviewId': appointmentId,
});

        transaction.update(appointmentRef, {
          'rated': true,
          'rating': rating,
          'ratedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not submit review: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = data['doctorName'] as String? ?? '';
    final specialty = data['specialty'] as String? ?? '';
    final date = data['date'] as String? ?? '';
    final time = data['time'] as String? ?? '';
    final fee = data['fee']?.toString() ?? '0';
    final status = data['status'] as String? ?? 'upcoming';
    final isRated = data['rated'] == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: AppColors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: const TextStyle(color: AppColors.textSub),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          _AppointmentInfo(icon: Icons.calendar_today, text: date),
          const SizedBox(height: 10),
          _AppointmentInfo(icon: Icons.access_time, text: time),
          const SizedBox(height: 10),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('app_settings')
                .doc('clinic')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _AppointmentInfo(
                  icon: Icons.location_on,
                  text: 'Could not load clinic location.',
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const _AppointmentInfo(
                  icon: Icons.location_on,
                  text: 'Loading clinic location...',
                );
              }

              final clinic = snapshot.data?.data() ?? {};
              final name = (clinic['clinicName'] as String?)?.trim() ?? '';
              final location =
                  (clinic['clinicLocation'] as String?)?.trim() ?? '';

              final text = [
                if (name.isNotEmpty) name,
                if (location.isNotEmpty) location,
              ].join('\n');

              return _AppointmentInfo(
                icon: Icons.location_on,
                text: text.isEmpty ? 'Location not set' : text,
              );
            },
          ),
          const SizedBox(height: 10),
          _AppointmentInfo(icon: Icons.payments, text: '\$$fee'),
          if (status == 'upcoming') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelAppointment(context),
                child: const Text('Cancel Appointment'),
              ),
            ),
          ],
          if (status == 'completed') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isRated ? null : () => _rateDoctor(context),
                icon: Icon(isRated ? Icons.check : Icons.star_outline),
                label: Text(isRated ? 'Rated' : 'Rate Doctor'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RateDoctorDialog extends StatefulWidget {
  const _RateDoctorDialog();

  @override
  State<_RateDoctorDialog> createState() => _RateDoctorDialogState();
}

class _RateDoctorDialogState extends State<_RateDoctorDialog> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (selectedRating == 0) return;

    Navigator.of(
      context,
    ).pop({'rating': selectedRating, 'comment': commentController.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Doctor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your experience?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final number = index + 1;

                return IconButton(
                  onPressed: () {
                    setState(() => selectedRating = number);
                  },
                  icon: Icon(
                    number <= selectedRating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 34,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Comment (Optional)',
                hintText: 'Write your experience...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedRating == 0 ? null : _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final String text;

    switch (status) {
      case 'completed':
        text = 'Completed';
        break;
      case 'cancelled':
        text = 'Cancelled';
        break;
      default:
        text = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  final String status;

  const _EmptyAppointments({required this.status});

  @override
  Widget build(BuildContext context) {
    final String title;
    final String description;

    switch (status) {
      case 'completed':
        title = 'No completed appointments';
        description = 'Your completed appointments will appear here.';
        break;
      case 'cancelled':
        title = 'No cancelled appointments';
        description = 'Your cancelled appointments will appear here.';
        break;
      default:
        title = 'No upcoming appointments';
        description = 'Your upcoming appointments will appear here.';
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(description, style: const TextStyle(color: AppColors.textSub)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AppointmentInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
