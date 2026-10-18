import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../admin/data/models/doctor.dart';

class HomeRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  HomeRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  String getUserDisplayName() {
    final email = _firebaseAuth.currentUser?.email;

    if (email == null || email.isEmpty) {
      return 'there';
    }

    return email.split('@').first;
  }

  Stream<List<Doctor>> watchActiveDoctors() {
    return _firestore.collection('doctors').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data()['isActive'] != false)
          .map((doc) => Doctor.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  List<Doctor> getPopularDoctors(List<Doctor> doctors) {
    final result = [...doctors];

    result.sort((a, b) {
      final reviewsComparison = b.reviewsCount.compareTo(a.reviewsCount);

      if (reviewsComparison != 0) {
        return reviewsComparison;
      }

      return b.rating.compareTo(a.rating);
    });

    return result;
  }

  List<Doctor> getTopRatedDoctors(List<Doctor> doctors) {
    final result = [...doctors];

    result.sort((a, b) {
      final ratingComparison = b.rating.compareTo(a.rating);

      if (ratingComparison != 0) {
        return ratingComparison;
      }

      return b.reviewsCount.compareTo(a.reviewsCount);
    });

    return result;
  }
}
