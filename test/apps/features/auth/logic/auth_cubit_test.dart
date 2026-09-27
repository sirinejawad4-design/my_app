import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/apps/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:my_app/apps/features/auth/domain/entities/auth_user.dart';
import 'package:my_app/apps/features/auth/domain/usecases/login_use_case.dart';
import 'package:my_app/apps/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:my_app/apps/features/auth/logic/cubit/auth_cubit.dart';
import 'package:my_app/apps/features/auth/logic/cubit/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockSignUpUseCase signUpUseCase;

  const user = AuthUser(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
  );

  setUp(() {
    loginUseCase = MockLoginUseCase();
    signUpUseCase = MockSignUpUseCase();
  });

  AuthCubit buildCubit() {
    return AuthCubit(
      loginUseCase: loginUseCase,
      signUpUseCase: signUpUseCase,
    );
  }

  group('AuthCubit login', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then success when login succeeds',
      build: () {
        when(
          () => loginUseCase(
            email: 'test@example.com',
            password: '123456',
          ),
        ).thenAnswer((_) async => user);

        return buildCubit();
      },
      act: (cubit) => cubit.login(
        email: 'test@example.com',
        password: '123456',
      ),
      expect: () => const [
        AuthState(isLoading: true),
        AuthState(isSuccess: true),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits loading then error when repository throws',
      build: () {
        when(
          () => loginUseCase(
            email: 'test@example.com',
            password: '123456',
          ),
        ).thenThrow(
          const AuthRepositoryException(
            'Please enter your password.',
          ),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.login(
        email: 'test@example.com',
        password: '123456',
      ),
      expect: () => const [
        AuthState(isLoading: true),
        AuthState(
          errorMessage: 'Please enter your password.',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits loading then Firebase error message',
      build: () {
        when(
          () => loginUseCase(
            email: 'test@example.com',
            password: '123456',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
          ),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.login(
        email: 'test@example.com',
        password: '123456',
      ),
      expect: () => const [
        AuthState(isLoading: true),
        AuthState(
          errorMessage: 'Incorrect email or password.',
        ),
      ],
    );
  });

  group('AuthCubit signUp', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then success when sign up succeeds',
      build: () {
        when(
          () => signUpUseCase(
            name: 'Test User',
            email: 'test@example.com',
            password: '123456',
          ),
        ).thenAnswer((_) async => user);

        return buildCubit();
      },
      act: (cubit) => cubit.signUp(
        name: 'Test User',
        email: 'test@example.com',
        password: '123456',
      ),
      expect: () => const [
        AuthState(isLoading: true),
        AuthState(isSuccess: true),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits loading then error when sign up fails',
      build: () {
        when(
          () => signUpUseCase(
            name: 'Test User',
            email: 'test@example.com',
            password: '123456',
          ),
        ).thenThrow(
          const AuthRepositoryException(
            'This email is already registered.',
          ),
        );

        return buildCubit();
      },
      act: (cubit) => cubit.signUp(
        name: 'Test User',
        email: 'test@example.com',
        password: '123456',
      ),
      expect: () => const [
        AuthState(isLoading: true),
        AuthState(
          errorMessage: 'This email is already registered.',
        ),
      ],
    );
  });
}