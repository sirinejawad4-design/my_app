import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/app_colors.dart';
import '../../../../../generated/style_atoms.dart';
import '../../../../core/widgets/custom_button.dart';

class ReviewAppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String fee;

  const ReviewAppointmentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.fee,
  });

  @override
  State<ReviewAppointmentScreen> createState() =>
      _ReviewAppointmentScreenState();
}

class _ReviewAppointmentScreenState extends State<ReviewAppointmentScreen> {
  bool _isSaving = false;

  final DocumentReference<Map<String, dynamic>> _clinicRef =
      FirebaseFirestore.instance.collection('app_settings').doc('clinic');

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String _normalizeDate(String value) {
    final input = value.trim();

    final iso =
        RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(input);

    if (iso != null) {
      final year = int.parse(iso.group(1)!);
      final month = int.parse(iso.group(2)!);
      final day = int.parse(iso.group(3)!);

      final date = DateTime(year, month, day);

      if (date.year != year ||
          date.month != month ||
          date.day != day) {
        throw const FormatException('Invalid appointment date.');
      }

      return _dateKey(date);
    }

    final old =
        RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(input);

    if (old != null) {
      final day = int.parse(old.group(1)!);
      final month = int.parse(old.group(2)!);
      final year = int.parse(old.group(3)!);

      final date = DateTime(year, month, day);

      if (date.year != year ||
          date.month != month ||
          date.day != day) {
        throw const FormatException('Invalid appointment date.');
      }

      return _dateKey(date);
    }

    throw const FormatException('Invalid appointment date.');
  }

  String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _displayDate(String dateKey) {
    final parts = dateKey.split('-');

    if (parts.length != 3) return dateKey;

    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  // ============================================================
  // TIME HELPERS
  // ============================================================

  int _timeToMinutes(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());

    if (match == null) {
      throw const FormatException(
        'Invalid appointment time. Please select a valid time.',
      );
    }

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (hour < 1 || hour > 12 || minute > 59) {
      throw const FormatException('Invalid appointment time.');
    }

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return hour * 60 + minute;
  }

  String _slotId(String date, String time) {
    final minutes = _timeToMinutes(time);
    final hour = minutes ~/ 60;
    final minute = minutes % 60;

    return '${widget.doctorId}_${date}_'
        '${hour.toString().padLeft(2, '0')}'
        '${minute.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // CONFIRM APPOINTMENT
  // ============================================================

  Future<void> _confirmAppointment() async {
    if (_isSaving) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login before booking an appointment.'),
        ),
      );

      return;
    }

    setState(() => _isSaving = true);

    try {
      final firestore = FirebaseFirestore.instance;

      final date = _normalizeDate(widget.date);
      final time = widget.time.trim();

      final minutes = _timeToMinutes(time);
      final dateParts = date.split('-');

      final appointmentDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      ).add(Duration(minutes: minutes));

      if (!appointmentDateTime.isAfter(DateTime.now())) {
        throw Exception(
          'This time has passed. Please choose another time.',
        );
      }

      final doctorRef =
          firestore.collection('doctors').doc(widget.doctorId);

      final slotId = _slotId(date, time);

      final slotRef =
          firestore.collection('appointment_slots').doc(slotId);

      final appointmentRef =
          firestore.collection('appointments').doc();

      final userProfileSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final userData =
          userProfileSnapshot.data() ?? <String, dynamic>{};

      final patientName =
          (userData['name'] as String?)?.trim().isNotEmpty == true
              ? (userData['name'] as String).trim()
              : (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!.trim()
                  : (user.email?.split('@').first ?? 'Patient'));

      final patientEmail =
          (userData['email'] as String?)?.trim().isNotEmpty == true
              ? (userData['email'] as String).trim()
              : (user.email ?? '');

      final patientPhone =
          (userData['phone'] as String?)?.trim().isNotEmpty == true
              ? (userData['phone'] as String).trim()
              : (user.phoneNumber ?? '');

      await firestore.runTransaction((transaction) async {
        // All reads must happen before writes.
        final doctorSnapshot = await transaction.get(doctorRef);
        final slotSnapshot = await transaction.get(slotRef);
        final clinicSnapshot = await transaction.get(_clinicRef);

        if (!doctorSnapshot.exists) {
          throw Exception('This doctor is no longer available.');
        }

        final doctorData = doctorSnapshot.data()!;

        if (doctorData['isActive'] != true) {
          throw Exception('This doctor is currently unavailable.');
        }

        // CLINIC INFORMATION

        final clinicData =
            clinicSnapshot.data() ?? <String, dynamic>{};

        final clinicName =
            (clinicData['clinicName'] as String?)?.trim() ?? '';

        final clinicLocation =
            (clinicData['clinicLocation'] as String?)?.trim() ?? '';

        // CHECK SLOT AVAILABILITY

        if (slotSnapshot.exists) {
          final slotData = slotSnapshot.data()!;

          if (slotData['status'] != 'available') {
            throw Exception(
              'This slot is already booked. '
              'Please refresh available times and choose another.',
            );
          }

          transaction.update(slotRef, {
            'status': 'booked',
            'appointmentId': appointmentRef.id,
            'userId': user.uid,
          });
        } else {
          transaction.set(slotRef, {
            'doctorId': widget.doctorId,
            'date': date,
            'time': time,
            'status': 'booked',
            'appointmentId': appointmentRef.id,
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // CREATE APPOINTMENT

        transaction.set(appointmentRef, {
          'userId': user.uid,
          'patientName': patientName,
          'patientEmail': patientEmail,
          'patientPhone': patientPhone,
          'doctorId': widget.doctorId,
          'doctorName': widget.doctorName,
          'specialty': widget.specialty,
          'date': date,
          'time': time,
          'fee': widget.fee,
          'clinicName':
              clinicName.isEmpty ? 'Central Clinic' : clinicName,
          'location':
              clinicLocation.isEmpty ? 'Location not set' : clinicLocation,
          'status': 'upcoming',
          'slotId': slotRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully.'),
          backgroundColor: AppColors.primary,
        ),
      );

      context.push('/appointment-success');
    } catch (e) {
      if (!mounted) return;

      String message;

      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          message =
              'Permission denied. Please check Firestore Security Rules.';
        } else if (e.code == 'unavailable') {
          message = 'Service temporarily unavailable. Please try again.';
        } else if (e.code == 'aborted') {
          message =
              'The slot changed while booking. Please refresh and try again.';
        } else {
          message = e.message ?? 'Unable to book appointment.';
        }
      } else {
        message = e.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: Text(
          'Review Appointment',
          style: context.bold16TextMain,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Details',
              style: context.bold16TextMain,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    title: 'Doctor Name',
                    value: widget.doctorName,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    title: 'Specialty',
                    value: widget.specialty,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    title: 'Date & Time',
                    value:
                        '${_displayDate(_normalizeDate(widget.date))}'
                        ' • ${widget.time}',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    title: 'Fee',
                    value: '\$${widget.fee}',
                  ),
                  const Divider(height: 24),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _clinicRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const _InfoRow(
                          title: 'Location',
                          value: 'Unable to load clinic location',
                        );
                      }

                      final data = snapshot.data?.data() ?? {};

                      final name =
                          (data['clinicName'] as String?)?.trim() ?? '';

                      final location =
                          (data['clinicLocation'] as String?)?.trim() ?? '';

                      final text = [
                        if (name.isNotEmpty) name,
                        if (location.isNotEmpty) location,
                      ].join('\n');

                      return _InfoRow(
                        title: 'Location',
                        value: text.isEmpty ? 'Location not set' : text,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _isSaving ? 'Confirming...' : 'Confirm Appointment',
              onPressed: _isSaving ? null : _confirmAppointment,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: context.regular12TextSub,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: context.semiBold14TextMain,
          ),
        ),
      ],
    );
  }
}
