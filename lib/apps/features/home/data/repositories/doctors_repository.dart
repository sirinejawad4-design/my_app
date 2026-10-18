import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../admin/data/models/doctor.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;

  DoctorRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================
  // WATCH DOCTORS
  // ============================================================

  Stream<List<Doctor>> watchDoctors() {
    return _firestore
        .collection('doctors')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Doctor.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ============================================================
  // ADD DOCTOR
  // ============================================================

  Future<void> addDoctor({
    required String name,
    required String specialty,
    required double fee,
    String? imageUrl,
  }) async {
    await _firestore.collection('doctors').add({
      'name': name.trim(),
      'specialty': specialty.trim(),
      'fee': fee,
      'imageUrl': imageUrl?.trim() ?? '',
      'isActive': true,
      'rating': 0,
      'reviewsCount': 0,
      'workingDays': {
        'monday': false,
        'tuesday': false,
        'wednesday': false,
        'thursday': false,
        'friday': false,
        'saturday': false,
        'sunday': false,
      },
      'startTime': '09:00 AM',
      'endTime': '05:00 PM',
      'slotDuration': 30,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE DOCTOR AVAILABILITY
  // ============================================================

  Future<void> updateAvailability({
    required String doctorId,
    required Map<String, bool> workingDays,
    required String startTime,
    required String endTime,
    required int slotDuration,
  }) async {
    await _firestore.collection('doctors').doc(doctorId).update({
      'workingDays': workingDays,
      'startTime': startTime,
      'endTime': endTime,
      'slotDuration': slotDuration,
    });
  }

  // ============================================================
  // UPDATE DOCTOR PROFILE
  // ============================================================

  Future<void> updateDoctor({
    required String doctorId,
    required String name,
    required String specialty,
    required double fee,
    String? imageUrl,
  }) async {
    final updateData = <String, dynamic>{
      'name': name.trim(),
      'specialty': specialty.trim(),
      'fee': fee,
    };

    if (imageUrl != null) {
      updateData['imageUrl'] = imageUrl.trim();
    }

    await _firestore.collection('doctors').doc(doctorId).update(updateData);
  }

  // ============================================================
  // ACTIVATE / DEACTIVATE DOCTOR
  // ============================================================

  Future<void> updateDoctorStatus({
    required String doctorId,
    required bool isActive,
  }) async {
    await _firestore.collection('doctors').doc(doctorId).update({
      'isActive': isActive,
    });
  }
}