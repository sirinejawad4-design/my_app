import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:my_app/apps/features/auth/logic/cubit/auth_cubit.dart';
import 'package:my_app/apps/features/auth/logic/cubit/auth_state.dart';
import 'package:my_app/apps/features/auth/presentation/screens/login_screen.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();

    when(() => authCubit.state).thenReturn(
      const AuthState(),
    );

    when(() => authCubit.stream).thenAnswer(
      (_) => const Stream<AuthState>.empty(),
    );
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets(
    'displays login screen fields and button',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText() ==
                  "Don't have an account? Join us",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows loading indicator when auth state is loading',
    (tester) async {
      when(() => authCubit.state).thenReturn(
        const AuthState(isLoading: true),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );

      expect(find.text('Login'), findsNothing);
    },
  );

  testWidgets(
    'calls login with entered email and password',
    (tester) async {
      when(
        () => authCubit.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Enter your email',
        ),
        'test@example.com',
      );

      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Enter your password',
        ),
        '123456',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      verify(
        () => authCubit.login(
          email: 'test@example.com',
          password: '123456',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'shows error SnackBar when login fails',
    (tester) async {
      when(
        () => authCubit.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});

      when(() => authCubit.state).thenReturn(
        const AuthState(
          errorMessage: 'Incorrect email or password.',
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Enter your email',
        ),
        'test@example.com',
      );

      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Enter your password',
        ),
        'wrong',
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(
        find.text('Incorrect email or password.'),
        findsOneWidget,
      );
    },
  );
}