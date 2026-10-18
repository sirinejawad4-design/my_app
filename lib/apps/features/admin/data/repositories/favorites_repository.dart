import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoritesRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _favoritesRef {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in to manage favorites.');
    }

    return _firestore.collection('users').doc(user.uid).collection('favorites');
  }

  Stream<Set<String>> watchFavoriteDoctorIds() {
    return _favoritesRef.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
    );
  }

  Future<void> toggleFavorite(String doctorId) async {
    final favoriteRef = _favoritesRef.doc(doctorId);
    final snapshot = await favoriteRef.get();

    if (snapshot.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'doctorId': doctorId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
