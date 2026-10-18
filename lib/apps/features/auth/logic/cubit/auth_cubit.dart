import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import '../../domain/usecases/google_sign_in_use_case.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;

  AuthCubit({
    required this._loginUseCase,
    required this._signUpUseCase,
    required this._googleSignInUseCase,
  }) : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthState(isLoading: true));

    try {
      await _loginUseCase(email: email, password: password);

      emit(const AuthState(isSuccess: true));
    } on AuthRepositoryException catch (e) {
      emit(AuthState(errorMessage: e.message));
    } on FirebaseAuthException catch (e) {
      emit(AuthState(errorMessage: _messageForAuthError(e)));
    } catch (_) {
      emit(
        const AuthState(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthState(isLoading: true));

    try {
      await _signUpUseCase(name: name, email: email, password: password);

      emit(const AuthState(isSuccess: true));
    } on AuthRepositoryException catch (e) {
      emit(AuthState(errorMessage: e.message));
    } on FirebaseAuthException catch (e) {
      emit(AuthState(errorMessage: _messageForAuthError(e)));
    } catch (_) {
      emit(
        const AuthState(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState(isLoading: true));

    try {
      await _googleSignInUseCase();

      emit(const AuthState(isSuccess: true));
    } on AuthRepositoryException catch (e) {
      emit(AuthState(errorMessage: e.message));
    } on FirebaseAuthException catch (e) {
      emit(AuthState(errorMessage: 'Firebase: ${e.code} - ${e.message}'));
    } catch (e) {
      emit(AuthState(errorMessage: 'Google Sign-In: $e'));
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

      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';

      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google sign-in was cancelled.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
