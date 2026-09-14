import 'package:firebase_auth/firebase_auth.dart';

class HomeRepository {
  final FirebaseAuth _firebaseAuth;

  HomeRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String getUserDisplayName() {
    final email = _firebaseAuth.currentUser?.email;
    if (email == null || email.isEmpty) return 'there';
    return email.split('@').first;
  }
}
