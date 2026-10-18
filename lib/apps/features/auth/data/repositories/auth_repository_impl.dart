import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AuthUser> login({
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

    final credential = await _firebaseAuth.signInWithEmailAndPassword(
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
      throw const AuthRepositoryException('Please enter your name.');
    }

    if (cleanEmail.isEmpty) {
      throw const AuthRepositoryException('Please enter your email.');
    }

    if (cleanPassword.isEmpty) {
      throw const AuthRepositoryException('Please enter your password.');
    }

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );

    final user = credential.user;

    if (user == null) {
      throw const AuthRepositoryException('Unable to create user.');
    }

    await user.updateDisplayName(cleanName);
    await user.reload();

    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw const AuthRepositoryException(
        'Unable to get user information.',
      );
    }

    await _createPatientProfileIfMissing(
      user: currentUser,
      name: cleanName,
    );

    return _mapUser(currentUser);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthRepositoryException(
          'Google sign-in did not return an ID token. Please try again.',
        );
      }

      final oauthCredential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const AuthRepositoryException(
          'Unable to get your Google account information.',
        );
      }

      // Create a patient profile only if this user has no profile yet.
      // Existing profiles and roles, including admin, remain unchanged.
      await _createPatientProfileIfMissing(
        user: user,
        name: user.displayName ?? googleUser.displayName ??'',
      );

      return _mapUser(user);
    } on AuthRepositoryException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthRepositoryException(_messageForAuthError(e));
    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled') {
        throw const AuthRepositoryException(
          'Google sign-in was cancelled.',
        );
      }

      throw AuthRepositoryException(
        'Google sign-in failed. Please try again. (${e.code.name})',
      );
    } catch (e) {
      throw AuthRepositoryException(
        'Google sign-in failed. Please try again. Details: $e',
      );
    }
  }

  Future<void> _createPatientProfileIfMissing({
    required User user,
    required String name,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      // Never overwrite an existing profile or its role.
      if (snapshot.exists) return;

      transaction.set(userRef, {
        'id': user.uid,
        'name': name,
        'email': user.email ?? '',
        'role': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  String _messageForAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';

      case 'invalid-credential':
        return 'Google could not verify your credentials. Please try again.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'operation-not-allowed':
        return 'Google sign-in is not enabled in Firebase Authentication.';

      default:
        return 'Firebase sign-in failed (${e.code}). Please try again.';
    }
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

  @override
  String toString() => message;
}