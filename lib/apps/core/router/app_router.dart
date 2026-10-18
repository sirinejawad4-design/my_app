import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/choose_role_screen.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/sign_up_use_case.dart';
import '../../features/auth/domain/usecases/google_sign_in_use_case.dart';
import '../../features/auth/logic/cubit/auth_cubit.dart';

import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';


import '../../features/admin/presentation/screens/admin_login_screen.dart';
import '../../features/admin/presentation/screens/admin_navigation_screen.dart';
import '../../features/admin/presentation/screens/create_doctor_screen.dart';
import '../../features/admin/presentation/screens/admin_doctor_details_screen.dart';
import '../../features/admin/presentation/screens/admin_appointment_details_screen.dart';

import '../navigation/main_navigation_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';

import '../../features/find_doctors/presentation/screens/find_doctors_screen.dart';
import '../../features/doctor_details/presentation/screens/doctor_details_screen.dart';

import '../../features/appointment/presentation/screens/select_time_screen.dart';
import '../../features/appointment/presentation/screens/review_appointment_screen.dart';
import '../../features/appointment/presentation/screens/appointment_success_screen.dart';
import '../../features/appointment/presentation/screens/appointments_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'app_router.g.dart';

// ============================================================
// SPLASH
// ============================================================

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}

// ============================================================
// ONBOARDING
// ============================================================

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OnboardingScreen();
  }
}

// ============================================================
// CHOOSE ROLE
// ============================================================

@TypedGoRoute<ChooseRoleRoute>(path: '/choose-role')
class ChooseRoleRoute extends GoRouteData with $ChooseRoleRoute {
  const ChooseRoleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChooseRoleScreen();
  }
}

// ============================================================
// SIGN UP
// ============================================================

@TypedGoRoute<SignUpRoute>(path: '/sign-up')
class SignUpRoute extends GoRouteData with $SignUpRoute {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) {
        final repository = AuthRepositoryImpl();

        return AuthCubit(
          loginUseCase: LoginUseCase(repository),
          signUpUseCase: SignUpUseCase(repository),
          googleSignInUseCase: GoogleSignInUseCase(repository),
        );
      },
      child: const SignUpScreen(),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) {
        final repository = AuthRepositoryImpl();

        return AuthCubit(
          loginUseCase: LoginUseCase(repository),
          signUpUseCase: SignUpUseCase(repository),
          googleSignInUseCase: GoogleSignInUseCase(repository),
        );
      },
      child: const LoginScreen(),
    );
  }
}

// ============================================================
// FORGOT PASSWORD
// ============================================================

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForgotPasswordScreen();
  }
}




// ============================================================
// HOME
// ============================================================

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MainNavigationScreen();
  }
}

// ============================================================
// FIND DOCTORS
// ============================================================

@TypedGoRoute<FindDoctorsRoute>(path: '/find-doctors')
class FindDoctorsRoute extends GoRouteData with $FindDoctorsRoute {
  const FindDoctorsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FindDoctorsScreen();
  }
}

// ============================================================
// DOCTOR DETAILS
// ============================================================

@TypedGoRoute<DoctorDetailsRoute>(path: '/doctor-details')
class DoctorDetailsRoute extends GoRouteData with $DoctorDetailsRoute {
  const DoctorDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final doctorId = state.uri.queryParameters['doctorId'];

    if (doctorId == null || doctorId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Doctor not found.')));
    }

    return DoctorDetailsScreen(doctorId: doctorId);
  }
}

// ============================================================
// SELECT TIME
// ============================================================

@TypedGoRoute<SelectTimeRoute>(path: '/select-time')
class SelectTimeRoute extends GoRouteData with $SelectTimeRoute {
  const SelectTimeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final doctorId = state.uri.queryParameters['doctorId'];

    if (doctorId == null || doctorId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Doctor not found.')));
    }

    return SelectTimeScreen(doctorId: doctorId);
  }
}

// ============================================================
// REVIEW APPOINTMENT
// ============================================================

@TypedGoRoute<ReviewAppointmentRoute>(path: '/review-appointment')
class ReviewAppointmentRoute extends GoRouteData with $ReviewAppointmentRoute {
  const ReviewAppointmentRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final doctorId = state.uri.queryParameters['doctorId'] ?? '';

    final doctorName = state.uri.queryParameters['doctorName'] ?? '';

    final specialty = state.uri.queryParameters['specialty'] ?? '';

    final date = state.uri.queryParameters['date'] ?? '';

    final time = state.uri.queryParameters['time'] ?? '';

    final fee = state.uri.queryParameters['fee'] ?? '';

    return ReviewAppointmentScreen(
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      date: date,
      time: time,
      fee: fee,
    );
  }
}

// ============================================================
// APPOINTMENTS
// ============================================================

@TypedGoRoute<AppointmentsRoute>(path: '/appointments')
class AppointmentsRoute extends GoRouteData with $AppointmentsRoute {
  const AppointmentsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppointmentsScreen();
  }
}

// ============================================================
// APPOINTMENT SUCCESS
// ============================================================

@TypedGoRoute<AppointmentSuccessRoute>(path: '/appointment-success')
class AppointmentSuccessRoute extends GoRouteData
    with $AppointmentSuccessRoute {
  const AppointmentSuccessRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppointmentSuccessScreen();
  }
}

// ============================================================
// ADMIN DOCTORS
// ============================================================

@TypedGoRoute<DoctorsListRoute>(path: '/doctors-list')
class DoctorsListRoute extends GoRouteData with $DoctorsListRoute {
  const DoctorsListRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AdminNavigationScreen();
  }
}

// ============================================================
// ADMIN DOCTOR DETAILS
// ============================================================

@TypedGoRoute<AdminDoctorDetailsRoute>(path: '/admin-doctor-details')
class AdminDoctorDetailsRoute extends GoRouteData
    with $AdminDoctorDetailsRoute {
  const AdminDoctorDetailsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final doctorId = state.uri.queryParameters['doctorId'];

    if (doctorId == null || doctorId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Doctor not found.')));
    }

    return AdminDoctorDetailsScreen(doctorId: doctorId);
  }
}

// ============================================================
// CREATE DOCTOR
// ============================================================

@TypedGoRoute<CreateDoctorRoute>(path: '/create-doctor')
class CreateDoctorRoute extends GoRouteData with $CreateDoctorRoute {
  const CreateDoctorRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CreateDoctorScreen();
  }
}

// ============================================================
// ADMIN LOGIN
// ============================================================

@TypedGoRoute<AdminLoginRoute>(path: '/admin-login')
class AdminLoginRoute extends GoRouteData with $AdminLoginRoute {
  const AdminLoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final repository = AuthRepositoryImpl();

    return BlocProvider(
      create: (_) => AuthCubit(
        loginUseCase: LoginUseCase(repository),
        signUpUseCase: SignUpUseCase(repository),
        googleSignInUseCase: GoogleSignInUseCase(repository),
      ),
      child: const AdminLoginScreen(),
    );
  }
}
// ============================================================
// ADMIN APPOINTMENT DETAILS
// ============================================================

@TypedGoRoute<AdminAppointmentDetailsRoute>(path: '/admin-appointment-details')
class AdminAppointmentDetailsRoute extends GoRouteData
    with $AdminAppointmentDetailsRoute {
  const AdminAppointmentDetailsRoute({required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AdminAppointmentDetailsScreen(appointmentId: appointmentId);
  }
}
// ============================================================
// PROFILE
// ============================================================

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}

// ============================================================
// SETTINGS
// ============================================================

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

// ============================================================
// PRIVACY POLICY
// ============================================================

@TypedGoRoute<PrivacyPolicyRoute>(path: '/privacy-policy')
class PrivacyPolicyRoute extends GoRouteData
    with $PrivacyPolicyRoute {
  const PrivacyPolicyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PrivacyPolicyScreen();
  }
}

// ============================================================
// APP ROUTER
// ============================================================

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: $appRoutes,
    redirect: (context, state) async {
      const adminPaths = {
        '/doctors-list',
        '/admin-doctor-details',
        '/create-doctor',
        '/admin-appointment-details',
      };

      final path = state.uri.path;

      if (!adminPaths.contains(path)) {
        return null;
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return '/admin-login';
      }

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final role = userDoc.data()?['role'];

        if (userDoc.exists && role == 'admin') {
          return null;
        }

        return '/admin-login';
      } on FirebaseException {
        return '/admin-login';
      }
    },
  );
}
