import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/doctor.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DoctorRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

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

  Future<void> addDoctor({
    required String name,
    required String specialty,
    File? image,
  }) async {
    String imageUrl = '';

    if (image != null) {
      final fileName = 'doctors/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(fileName);
      await storageRef.putFile(image);
      imageUrl = await storageRef.getDownloadURL();
    }

    await _firestore.collection('doctors').add({
      'name': name.trim(),
      'specialty': specialty,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
