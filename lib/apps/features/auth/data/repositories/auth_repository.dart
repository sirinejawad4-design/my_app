import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty) {
      throw const AuthRepositoryException('Please enter your email.');
    }
    if (cleanPassword.isEmpty) {
      throw const AuthRepositoryException('Please enter your password.');
    }

    return _firebaseAuth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty) {
      throw const AuthRepositoryException('Please enter your email.');
    }
    if (cleanPassword.isEmpty) {
      throw const AuthRepositoryException('Please enter your password.');
    }

    return _firebaseAuth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );
  }
}

class AuthRepositoryException implements Exception {
  final String message;
  const AuthRepositoryException(this.message);
}
