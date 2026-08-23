import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/choose_role_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/home/presentation/screens/main_navigation_screen.dart';
import '../../features/home/presentation/screens/find_doctors_screen.dart';
import '../../features/home/presentation/screens/doctor_details_screen.dart';
part 'app_router.g.dart';


// كل route هون عبارة عن كلاس، بدل نص (string) - هيك ما فيه مجال لخطأ إملائي

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
}

@TypedGoRoute<ChooseRoleRoute>(path: '/choose-role')
class ChooseRoleRoute extends GoRouteData {
  const ChooseRoleRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChooseRoleScreen();
}

@TypedGoRoute<SignUpRoute>(path: '/sign-up')
class SignUpRoute extends GoRouteData {
  const SignUpRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignUpScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData {
  const ForgotPasswordRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ForgotPasswordScreen();
}

@TypedGoRoute<OtpRoute>(path: '/otp')
class OtpRoute extends GoRouteData {
  const OtpRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OtpScreen();
}

@TypedGoRoute<ResetPasswordRoute>(path: '/reset-password')
class ResetPasswordRoute extends GoRouteData {
  const ResetPasswordRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ResetPasswordScreen();
}
@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData {
  const HomeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MainNavigationScreen();
}

@TypedGoRoute<FindDoctorsRoute>(path: '/find-doctors')
class FindDoctorsRoute extends GoRouteData {
  const FindDoctorsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FindDoctorsScreen();
}
@TypedGoRoute<DoctorDetailsRoute>(path: '/doctor-details')
class DoctorDetailsRoute extends GoRouteData {
  const DoctorDetailsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DoctorDetailsScreen();
}
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
  );
}