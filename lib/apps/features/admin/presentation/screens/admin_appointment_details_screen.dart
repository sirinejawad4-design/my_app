import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';

class AdminAppointmentDetailsScreen extends StatelessWidget {
  final String appointmentId;

  const AdminAppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF263238),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Appointment Details', style: context.bold16TextMain),
        centerTitle: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load appointment details.'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Appointment not found.'));
          }

          final data = snapshot.data!.data()!;

          final doctorName = data['doctorName'] as String? ?? 'Unknown Doctor';
          final patientName = data['patientName'] as String? ?? 'Patient';
          final email = data['patientEmail'] as String? ?? '';
          final phone = data['patientPhone'] as String? ?? '';
          final specialty = data['specialty'] as String? ?? '';
          final date = data['date']?.toString() ?? '';
          final time = data['time']?.toString() ?? '';
          final fee = data['fee']?.toString() ?? '0';

          final status = data['status'] as String? ?? 'upcoming';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    Text('Patient', style: context.bold16TextMain),
                    const SizedBox(height: 12),
                    _personCard(
                      context: context,
                      name: patientName,
                      subtitle: email.isNotEmpty ? email : phone,
                      icon: Icons.person_outline,
                      imageUrl: data['patientImageUrl'] as String?,
                    ),
                    const SizedBox(height: 20),
                    Text('Doctor', style: context.bold16TextMain),
                    const SizedBox(height: 12),
                    _personCard(
                      context: context,
                      name: doctorName,
                      subtitle: specialty,
                      icon: Icons.medical_services_outlined,
                      imageUrl: data['doctorImageUrl'] as String?,
                      verified: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Appointment',
                            style: context.bold16TextMain,
                          ),
                        ),
                        _statusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _appointmentInfo(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'DATE',
                                  value: date,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _appointmentInfo(
                                  icon: Icons.access_time_rounded,
                                  label: 'TIME',
                                  value: time,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _appointmentInfo(
                            icon: Icons.payments_outlined,
                            label: 'CONSULTATION FEE',
                            value: '\$$fee',
                          ),
                          const SizedBox(height: 22),
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

                              return _appointmentInfo(
                                icon: Icons.location_on_outlined,
                                label: 'PLACE / LOCATION',
                                value: location,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (status == 'upcoming')
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    color: const Color(0xFFF4F8F7),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => _updateStatus(
                                context,
                                newStatus: 'cancelled',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade300,
                                side: BorderSide(color: Colors.red.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const FittedBox(
                                child: Text('Cancel Appointment'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => _updateStatus(
                                context,
                                newStatus: 'completed',
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const FittedBox(
                                child: Text('Mark as Completed'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // PATIENT AND DOCTOR CARDS

  Widget _personCard({
    required BuildContext context,
    required String name,
    required String subtitle,
    required IconData icon,
    String? imageUrl,
    bool verified = false,
  }) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
            child: hasImage
                ? null
                : Icon(icon, color: AppColors.primary, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.semiBold14TextMain,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (subtitle.contains('@')) ...[
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.regular12TextSub,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (verified) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 13,
              backgroundColor: Color(0xFFE2F5F2),
              child: Icon(Icons.verified, color: AppColors.primary, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  // APPOINTMENT INFORMATION ROW

  Widget _appointmentInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF829395),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(
                  color: Color(0xFF263238),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // APPOINTMENT STATUS BADGE

  Widget _statusBadge(String status) {
    final Color color;
    final String label;

    switch (status) {
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = AppColors.primary;
        label = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // CANCEL OR COMPLETE APPOINTMENT

  Future<void> _updateStatus(
    BuildContext context, {
    required String newStatus,
  }) async {
    final isCancelling = newStatus == 'cancelled';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isCancelling ? 'Cancel Appointment' : 'Complete Appointment',
        ),
        content: Text(
          isCancelling
              ? 'Are you sure you want to cancel this appointment?'
              : 'Mark this appointment as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isCancelling ? 'Yes, Cancel' : 'Confirm'),
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

        DocumentReference<Map<String, dynamic>>? slotRef;
        DocumentSnapshot<Map<String, dynamic>>? slotSnapshot;

        if (isCancelling) {
          final slotId = appointment['slotId'] as String?;

          if (slotId != null && slotId.isNotEmpty) {
            slotRef = firestore.collection('appointment_slots').doc(slotId);
            slotSnapshot = await transaction.get(slotRef);
          }
        }

        final shouldReleaseSlot =
            isCancelling &&
            slotSnapshot != null &&
            slotSnapshot.exists &&
            slotSnapshot.data()?['status'] == 'booked' &&
            slotSnapshot.data()?['appointmentId'] == appointmentId;

        transaction.update(appointmentRef, {
          'status': newStatus,
          if (isCancelling) 'cancelledAt': FieldValue.serverTimestamp(),
          if (!isCancelling) 'completedAt': FieldValue.serverTimestamp(),
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
        SnackBar(
          content: Text(
            isCancelling
                ? 'Appointment cancelled successfully.'
                : 'Appointment marked as completed.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update appointment: $e')),
      );
    }
  }
}
