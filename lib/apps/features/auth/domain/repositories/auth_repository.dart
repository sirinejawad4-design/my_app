import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String email, required String password});

  Future<AuthUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithGoogle();
}
