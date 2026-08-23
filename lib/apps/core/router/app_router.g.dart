// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $onboardingRoute,
  $chooseRoleRoute,
  $signUpRoute,
  $loginRoute,
  $forgotPasswordRoute,
  $otpRoute,
  $resetPasswordRoute,
  $homeRoute,
  $findDoctorsRoute,
  $doctorDetailsRoute,
];

RouteBase get $splashRoute =>
    GoRouteData.$route(path: '/', factory: $SplashRouteExtension._fromState);

extension $SplashRouteExtension on SplashRoute {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  String get location => GoRouteData.$location('/');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingRoute => GoRouteData.$route(
  path: '/onboarding',

  factory: $OnboardingRouteExtension._fromState,
);

extension $OnboardingRouteExtension on OnboardingRoute {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  String get location => GoRouteData.$location('/onboarding');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chooseRoleRoute => GoRouteData.$route(
  path: '/choose-role',

  factory: $ChooseRoleRouteExtension._fromState,
);

extension $ChooseRoleRouteExtension on ChooseRoleRoute {
  static ChooseRoleRoute _fromState(GoRouterState state) =>
      const ChooseRoleRoute();

  String get location => GoRouteData.$location('/choose-role');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoute => GoRouteData.$route(
  path: '/sign-up',

  factory: $SignUpRouteExtension._fromState,
);

extension $SignUpRouteExtension on SignUpRoute {
  static SignUpRoute _fromState(GoRouterState state) => const SignUpRoute();

  String get location => GoRouteData.$location('/sign-up');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',

  factory: $LoginRouteExtension._fromState,
);

extension $LoginRouteExtension on LoginRoute {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  String get location => GoRouteData.$location('/login');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $forgotPasswordRoute => GoRouteData.$route(
  path: '/forgot-password',

  factory: $ForgotPasswordRouteExtension._fromState,
);

extension $ForgotPasswordRouteExtension on ForgotPasswordRoute {
  static ForgotPasswordRoute _fromState(GoRouterState state) =>
      const ForgotPasswordRoute();

  String get location => GoRouteData.$location('/forgot-password');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $otpRoute =>
    GoRouteData.$route(path: '/otp', factory: $OtpRouteExtension._fromState);

extension $OtpRouteExtension on OtpRoute {
  static OtpRoute _fromState(GoRouterState state) => const OtpRoute();

  String get location => GoRouteData.$location('/otp');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resetPasswordRoute => GoRouteData.$route(
  path: '/reset-password',

  factory: $ResetPasswordRouteExtension._fromState,
);

extension $ResetPasswordRouteExtension on ResetPasswordRoute {
  static ResetPasswordRoute _fromState(GoRouterState state) =>
      const ResetPasswordRoute();

  String get location => GoRouteData.$location('/reset-password');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute =>
    GoRouteData.$route(path: '/home', factory: $HomeRouteExtension._fromState);

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location('/home');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $findDoctorsRoute => GoRouteData.$route(
  path: '/find-doctors',

  factory: $FindDoctorsRouteExtension._fromState,
);

extension $FindDoctorsRouteExtension on FindDoctorsRoute {
  static FindDoctorsRoute _fromState(GoRouterState state) =>
      const FindDoctorsRoute();

  String get location => GoRouteData.$location('/find-doctors');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doctorDetailsRoute => GoRouteData.$route(
  path: '/doctor-details',

  factory: $DoctorDetailsRouteExtension._fromState,
);

extension $DoctorDetailsRouteExtension on DoctorDetailsRoute {
  static DoctorDetailsRoute _fromState(GoRouterState state) =>
      const DoctorDetailsRoute();

  String get location => GoRouteData.$location('/doctor-details');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
