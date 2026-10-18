import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Appointments', style: context.bold16TextMain),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Could not load appointments.'));
          }

          final appointments = snapshot.data?.docs ?? [];

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSub,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:TabBarView(
  children: [
    _AppointmentsList(
      appointments: appointments,
    ),
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

// ============================================================
// APPOINTMENTS LIST
// ============================================================

class _AppointmentsList extends StatelessWidget {
  final List<QueryDocumentSnapshot> appointments;
  final String? status;

  const _AppointmentsList({required this.appointments, this.status});

  @override
  Widget build(BuildContext context) {
    final filtered = status == null
        ? appointments
        : appointments.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == status;
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            status == null
                ? 'No appointments yet.'
                : 'No ${status!} appointments.',
            style: context.regular14TextSub,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final doc = filtered[index];

        return _AdminAppointmentCard(
          appointmentId: doc.id,
          data: doc.data() as Map<String, dynamic>,
        );
      },
    );
  }
}

// ============================================================
// APPOINTMENT CARD
// ============================================================

class _AdminAppointmentCard extends StatelessWidget {
  final String appointmentId;
  final Map<String, dynamic> data;

  const _AdminAppointmentCard({
    required this.appointmentId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final doctorName = data['doctorName'] as String? ?? 'Unknown Doctor';
    final patientName = data['patientName'] as String? ?? 'Patient';
    final patientEmail = data['patientEmail'] as String? ?? '';
    final patientPhone = data['patientPhone'] as String? ?? '';
    final specialty = data['specialty'] as String? ?? '';
    final date = data['date'] as String? ?? '';
    final time = data['time'] as String? ?? '';
    final fee = data['fee']?.toString() ?? '';

    final status = data['status'] as String? ?? 'upcoming';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        AdminAppointmentDetailsRoute(
          appointmentId: appointmentId,
        ).push(context);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName, style: context.semiBold14TextMain),
                      const SizedBox(height: 3),
                      Text(specialty, style: context.regular12TextSub),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.calendar_today_outlined, text: date),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.access_time_outlined, text: time),
            const SizedBox(height: 8),

            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('app_settings')
                  .doc('clinic')
                  .snapshots(),
              builder: (context, clinicSnapshot) {
                final clinicData = clinicSnapshot.data?.data();

                final location =
                    clinicData?['clinicLocation'] as String? ??
                    'Location not set';

                return _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: location,
                );
              },
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.payments_outlined, text: '\$$fee'),
            const SizedBox(height: 14),
            Text('Patient', style: context.semiBold14TextMain),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName, style: context.semiBold14TextMain),
                  if (patientEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(patientEmail, style: context.regular12TextSub),
                  ],
                  if (patientPhone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(patientPhone, style: context.regular12TextSub),
                  ],
                ],
              ),
            ),
            if (status == 'upcoming') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelAppointment(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _markCompleted(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mark Completed',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL APPOINTMENT AND RELEASE ITS SLOT
  // ============================================================

  Future<void> _cancelAppointment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final appointmentRef = firestore
          .collection('appointments')
          .doc(appointmentId);

      await firestore.runTransaction((transaction) async {
        final appointmentSnapshot = await transaction.get(appointmentRef);

        if (!appointmentSnapshot.exists) {
          throw Exception('Appointment not found.');
        }

        final appointment = appointmentSnapshot.data() as Map<String, dynamic>;

        if (appointment['status'] != 'upcoming') {
          throw Exception('This appointment is no longer upcoming.');
        }

        final slotId = appointment['slotId'] as String?;

        DocumentReference<Map<String, dynamic>>? slotRef;
        DocumentSnapshot<Map<String, dynamic>>? slotSnapshot;

        if (slotId != null && slotId.isNotEmpty) {
          slotRef = firestore.collection('appointment_slots').doc(slotId);
          slotSnapshot = await transaction.get(slotRef);
        }

        final shouldReleaseSlot =
            slotSnapshot != null &&
            slotSnapshot.exists &&
            slotSnapshot.data()?['status'] == 'booked' &&
            slotSnapshot.data()?['appointmentId'] == appointmentId;

        transaction.update(appointmentRef, {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        if (shouldReleaseSlot) {
          transaction.update(slotRef!, {
            'status': 'available',
            'appointmentId': FieldValue.delete(),
            'userId': FieldValue.delete(),
          });
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

  // ============================================================
  // MARK APPOINTMENT COMPLETED
  // ============================================================

  Future<void> _markCompleted(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete Appointment'),
        content: const Text('Mark this appointment as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final appointmentRef = FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(appointmentRef);

        if (!snapshot.exists) {
          throw Exception('Appointment not found.');
        }

        final appointment = snapshot.data() as Map<String, dynamic>;

        if (appointment['status'] != 'upcoming') {
          throw Exception('This appointment is no longer upcoming.');
        }

        transaction.update(appointmentRef, {
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment marked as completed.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not complete appointment: $e')),
      );
    }
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: context.regular12TextMain)),
      ],
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final String label;

    switch (status) {
      case 'completed':
        label = 'Completed';
        break;
      case 'cancelled':
        label = 'Cancelled';
        break;
      default:
        label = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: context.regular11TextSub),
    );
  }
}
