import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty) {
      throw const AuthRepositoryException(
        'Please enter your email.',
      );
    }

    if (cleanPassword.isEmpty) {
      throw const AuthRepositoryException(
        'Please enter your password.',
      );
    }

    final credential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );

    return _mapUser(credential.user);
  }

  @override
  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      throw const AuthRepositoryException(
        'Please enter your name.',
      );
    }

    if (cleanEmail.isEmpty) {
      throw const AuthRepositoryException(
        'Please enter your email.',
      );
    }

    if (cleanPassword.isEmpty) {
      throw const AuthRepositoryException(
        'Please enter your password.',
      );
    }

    final credential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );

    final user = credential.user;

    if (user == null) {
      throw const AuthRepositoryException(
        'Unable to create user.',
      );
    }

    await user.updateDisplayName(cleanName);
    await user.reload();

    return _mapUser(_firebaseAuth.currentUser);
  }

  AuthUser _mapUser(User? user) {
    if (user == null) {
      throw const AuthRepositoryException(
        'Unable to get user information.',
      );
    }

    return AuthUser(
      id: user.uid,
      email: user.email,
      name: user.displayName,
    );
  }
}

class AuthRepositoryException implements Exception {
  final String message;

  const AuthRepositoryException(this.message);
}