import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState(isLoading: true));

    try {
      debugPrint('EMAIL = "${email.trim()}"');
      debugPrint('PASSWORD EMPTY = ${password.trim().isEmpty}');
      await _repository.login(email: email, password: password);
      emit(const AuthState(isSuccess: true));
    } on AuthRepositoryException catch (e) {
      emit(AuthState(errorMessage: e.message));
    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE ERROR CODE: ${e.code}');
      debugPrint('FIREBASE ERROR MESSAGE: ${e.message}');
      emit(AuthState(errorMessage: _messageForAuthError(e)));
    } catch (e) {
      debugPrint('AUTH ERROR: $e');
      emit(const AuthState(
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(const AuthState(isLoading: true));

    try {
      await _repository.signUp(email: email, password: password);
      emit(const AuthState(isSuccess: true));
    } on AuthRepositoryException catch (e) {
      emit(AuthState(errorMessage: e.message));
    } on FirebaseAuthException catch (e) {
      emit(AuthState(errorMessage: _messageForAuthError(e)));
    } catch (e) {
      debugPrint('AUTH ERROR: $e');
      emit(const AuthState(
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  String _messageForAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
