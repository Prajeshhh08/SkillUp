import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/language_selection_screen.dart';
import '../screens/onboarding_screen_1.dart';
import '../screens/onboarding_screen_2.dart';
import '../screens/onboarding_screen_3.dart';
import '../screens/location_permission_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/address_setup_screen.dart';
import '../screens/login_screen.dart';
import '../screens/terms_and_privacy_screen.dart';
import '../screens/home_screen.dart';
import '../screens/worker_onboarding_screen.dart';
import '../screens/worker_details_screen.dart';
import '../screens/worker_join_screen.dart';
import '../screens/verification_pending_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/customer_signup_screen.dart';
import '../screens/worker_signup_screen.dart';
import '../screens/worker_status_screen.dart';
import '../screens/worker_form_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/customer_home_screen.dart';
import '../screens/terms_confirm_screen.dart';

CustomTransitionPage<void> _buildCustomTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Centralized GoRouter setup for SkillUp 8-screen onboarding flow.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/language',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const LanguageSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding-1',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const OnboardingScreen1(),
      ),
    ),
    GoRoute(
      path: '/onboarding-2',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const OnboardingScreen2(),
      ),
    ),
    GoRoute(
      path: '/onboarding-3',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const OnboardingScreen3(),
      ),
    ),
    GoRoute(
      path: '/location',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const LocationPermissionScreen(),
      ),
    ),
    GoRoute(
      path: '/role',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const RoleSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/address',
      pageBuilder: (context, state) => _buildCustomTransitionPage(
        context: context,
        state: state,
        child: const AddressSetupScreen(),
      ),
    ),
    GoRoute(path: '/login', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const LoginScreen())),
    GoRoute(path: '/terms', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const TermsAndPrivacyScreen())),
    GoRoute(path: '/home', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const HomeScreen())),
    GoRoute(path: '/worker-onboarding', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerOnboardingScreen())),
    GoRoute(path: '/worker-details', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerDetailsScreen())),
    GoRoute(path: '/worker-join', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerJoinScreen())),
    GoRoute(path: '/verification-pending', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const VerificationPendingScreen())),
    GoRoute(path: '/otp', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const OtpScreen())),
    GoRoute(path: '/customer-signup', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const CustomerSignupScreen())),
    GoRoute(path: '/worker-signup', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerSignupScreen())),
    GoRoute(path: '/worker-status', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerStatusScreen())),
    GoRoute(path: '/worker-form', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerFormScreen())),
    GoRoute(path: '/forgot-password', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const ForgotPasswordScreen())),
    GoRoute(path: '/customer-home', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const CustomerHomeScreen())),
    GoRoute(path: '/terms-confirm', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const TermsConfirmScreen())),
  ],
);
