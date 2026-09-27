import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/apps/features/auth/domain/entities/auth_user.dart';
import 'package:my_app/apps/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_app/apps/features/auth/domain/usecases/login_use_case.dart';
import 'package:my_app/apps/features/auth/domain/usecases/sign_up_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase loginUseCase;
  late SignUpUseCase signUpUseCase;

  const testUser = AuthUser(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
  );

  setUp(() {
    repository = MockAuthRepository();
    loginUseCase = LoginUseCase(repository);
    signUpUseCase = SignUpUseCase(repository);
  });

  group('LoginUseCase', () {
    test('should return user when repository login succeeds', () async {
      // Arrange
      when(
        () => repository.login(
          email: 'test@example.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => testUser);

      // Act
      final result = await loginUseCase(
        email: 'test@example.com',
        password: '123456',
      );

      // Assert
      expect(result.id, 'user-123');
      expect(result.email, 'test@example.com');
      expect(result.name, 'Test User');

      verify(
        () => repository.login(
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);
    });

    test('should throw when repository login fails', () async {
      // Arrange
      when(
        () => repository.login(
          email: 'test@example.com',
          password: 'wrong',
        ),
      ).thenThrow(Exception('Login failed'));

      // Act + Assert
      expect(
        () => loginUseCase(
          email: 'test@example.com',
          password: 'wrong',
        ),
        throwsException,
      );
    });
  });

  group('SignUpUseCase', () {
    test('should return user when repository sign up succeeds', () async {
      // Arrange
      when(
        () => repository.signUp(
          name: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => testUser);

      // Act
      final result = await signUpUseCase(
        name: 'Test User',
        email: 'test@example.com',
        password: '123456',
      );

      // Assert
      expect(result.id, 'user-123');
      expect(result.email, 'test@example.com');
      expect(result.name, 'Test User');

      verify(
        () => repository.signUp(
          name: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);
    });

    test('should throw when repository sign up fails', () async {
      // Arrange
      when(
        () => repository.signUp(
          name: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
      ).thenThrow(Exception('Sign up failed'));

      // Act + Assert
      expect(
        () => signUpUseCase(
          name: 'Test User',
          email: 'test@example.com',
          password: '123456',
        ),
        throwsException,
      );
    });
  });
}