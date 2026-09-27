import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/apps/features/auth/data/repositories/auth_repository_impl.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockUserCredential userCredential;
  late MockUser user;
  late AuthRepositoryImpl repository;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    userCredential = MockUserCredential();
    user = MockUser();

    repository = AuthRepositoryImpl(
      firebaseAuth: firebaseAuth,
    );
  });

  group('AuthRepositoryImpl - login', () {
    test('should login successfully and return AuthUser', () async {
      // Arrange
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => userCredential);

      when(() => userCredential.user).thenReturn(user);

      when(() => user.uid).thenReturn('user-123');
      when(() => user.email).thenReturn('test@example.com');
      when(() => user.displayName).thenReturn('Test User');

      // Act
      final result = await repository.login(
        email: '  test@example.com  ',
        password: '123456',
      );

      // Assert
      expect(result.id, 'user-123');
      expect(result.email, 'test@example.com');
      expect(result.name, 'Test User');

      verify(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);
    });

    test('should throw when email is empty', () async {
      // Act
      final call = repository.login(
        email: '   ',
        password: '123456',
      );

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Please enter your email.',
          ),
        ),
      );

      verifyNever(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('should throw when password is empty', () async {
      // Act
      final call = repository.login(
        email: 'test@example.com',
        password: '   ',
      );

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Please enter your password.',
          ),
        ),
      );

      verifyNever(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('should throw when Firebase returns null user', () async {
      // Arrange
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => userCredential);

      when(() => userCredential.user).thenReturn(null);

      // Act
      final call = repository.login(
        email: 'test@example.com',
        password: '123456',
      );

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Unable to get user information.',
          ),
        ),
      );
    });
  });

  group('AuthRepositoryImpl - signUp', () {
    test('should sign up successfully and update display name', () async {
      // Arrange
      when(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => userCredential);

      when(() => userCredential.user).thenReturn(user);

      when(() => firebaseAuth.currentUser).thenReturn(user);

      when(() => user.uid).thenReturn('user-123');
      when(() => user.email).thenReturn('test@example.com');
      when(() => user.displayName).thenReturn('Test User');

      when(
        () => user.updateDisplayName('Test User'),
      ).thenAnswer((_) async {});

      when(
        () => user.reload(),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.signUp(
        name: '  Test User  ',
        email: '  test@example.com  ',
        password: '123456',
      );

      // Assert
      expect(result.id, 'user-123');
      expect(result.email, 'test@example.com');
      expect(result.name, 'Test User');

      verify(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);

      verify(
        () => user.updateDisplayName('Test User'),
      ).called(1);

      verify(
        () => user.reload(),
      ).called(1);
    });

    test('should throw when name is empty', () async {
      // Act
      final call = repository.signUp(
        name: '   ',
        email: 'test@example.com',
        password: '123456',
      );

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Please enter your name.',
          ),
        ),
      );

      verifyNever(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('should throw when email is empty', () async {
      // Act
      final call = repository.signUp(
        name: 'Test User',
        email: '   ',
        password: '123456',
      );

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Please enter your email.',
          ),
        ),
      );
    });

    test('should throw when password is empty', () async {
      // Act
      final call = repository.signUp(
        name: 'Test User',
        email: 'test@example.com',
        password: '   ',
      );

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Please enter your password.',
          ),
        ),
      );
    });

    test('should throw when created user is null', () async {
      // Arrange
      when(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: '123456',
        ),
      ).thenAnswer((_) async => userCredential);

      when(() => userCredential.user).thenReturn(null);

      // Act
      final call = repository.signUp(
        name: 'Test User',
        email: 'test@example.com',
        password: '123456',
      );

      // Assert
      await expectLater(
        call,
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Unable to create user.',
          ),
        ),
      );
    });
  });
}