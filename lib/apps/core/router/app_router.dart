import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/choose_role_screen.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/logic/cubit/auth_cubit.dart';

import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';

import '../../features/admin/presentation/screens/admin_login_screen.dart';
import '../../features/admin/presentation/screens/admin_navigation_screen.dart';
import '../../features/admin/presentation/screens/create_doctor_screen.dart';

import '../navigation/main_navigation_screen.dart';

import '../../features/find_doctors/presentation/screens/find_doctors_screen.dart';
import '../../features/doctor_details/presentation/screens/doctor_details_screen.dart';

import '../../features/appointment/presentation/screens/select_time_screen.dart';
import '../../features/appointment/presentation/screens/appointment_success_screen.dart';

part 'app_router.g.dart';

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OnboardingScreen();
  }
}

@TypedGoRoute<ChooseRoleRoute>(path: '/choose-role')
class ChooseRoleRoute extends GoRouteData with $ChooseRoleRoute {
  const ChooseRoleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChooseRoleScreen();
  }
}

@TypedGoRoute<SignUpRoute>(path: '/sign-up')
class SignUpRoute extends GoRouteData with $SignUpRoute {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRepository()),
      child: const SignUpScreen(),
    );
  }
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRepository()),
      child: const LoginScreen(),
    );
  }
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData
    with $ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForgotPasswordScreen();
  }
}

@TypedGoRoute<OtpRoute>(path: '/otp')
class OtpRoute extends GoRouteData with $OtpRoute {
  const OtpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OtpScreen();
  }
}

@TypedGoRoute<ResetPasswordRoute>(path: '/reset-password')
class ResetPasswordRoute extends GoRouteData
    with $ResetPasswordRoute {
  const ResetPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ResetPasswordScreen();
  }
}


@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MainNavigationScreen();
  }
}

@TypedGoRoute<FindDoctorsRoute>(path: '/find-doctors')
class FindDoctorsRoute extends GoRouteData with $FindDoctorsRoute {
  const FindDoctorsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FindDoctorsScreen();
  }
}

@TypedGoRoute<DoctorDetailsRoute>(path: '/doctor-details')
class DoctorDetailsRoute extends GoRouteData
    with $DoctorDetailsRoute {
  const DoctorDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DoctorDetailsScreen();
  }
}

@TypedGoRoute<SelectTimeRoute>(path: '/select-time')
class SelectTimeRoute extends GoRouteData with $SelectTimeRoute {
  const SelectTimeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SelectTimeScreen();
  }
}

@TypedGoRoute<AppointmentSuccessRoute>(
  path: '/appointment-success',
)
class AppointmentSuccessRoute extends GoRouteData
    with $AppointmentSuccessRoute {
  const AppointmentSuccessRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppointmentSuccessScreen();
  }
}

@TypedGoRoute<DoctorsListRoute>(path: '/doctors-list')
class DoctorsListRoute extends GoRouteData with $DoctorsListRoute {
  const DoctorsListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdminNavigationScreen();
  }
}

@TypedGoRoute<CreateDoctorRoute>(path: '/create-doctor')
class CreateDoctorRoute extends GoRouteData with $CreateDoctorRoute {
  const CreateDoctorRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CreateDoctorScreen();
  }
}
@TypedGoRoute<AdminLoginRoute>(path: '/admin-login')
class AdminLoginRoute extends GoRouteData with $AdminLoginRoute {
  const AdminLoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => AuthCubit(AuthRepository()),
      child: const AdminLoginScreen(),
    );
  }
}
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
  );
}