import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<AuthUser> call() {
    return repository.signInWithGoogle();
  }
}
