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
import '../screens/categories_screen.dart';
import '../screens/service_listing_screen.dart';
import '../screens/service_details_screen.dart';
import '../screens/search_filter_screen.dart';
import '../screens/nearby_workers_screen.dart';
import '../screens/map_matching_screen.dart';
import '../screens/worker_profile_screen.dart';
import '../screens/emergency_booking_screen.dart';
import '../screens/booking_schedule_screen.dart';
import '../screens/booking_review_screen.dart';
import '../screens/booking_address_screen.dart';
import '../screens/booking_confirmation_screen.dart';
import '../screens/active_booking_screen.dart';
import '../screens/cancel_reschedule_screen.dart';
import '../screens/payment_checkout_screen.dart';
import '../screens/invoice_success_screen.dart';
import '../screens/rating_review_screen.dart';
import '../screens/booking_history_screen.dart';
import '../screens/rebook_screen.dart';
import '../screens/service_address_screen.dart';
import '../screens/order_summary_screen.dart';
import '../screens/customer_profile_screen.dart';
import '../screens/worker_bookings_screen.dart';
import '../screens/worker_account_profile_screen.dart';

CustomTransitionPage<void> _buildCustomTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incomingAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final outgoingAnimation = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.18, 0),
        ).animate(outgoingAnimation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(incomingAnimation),
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
    GoRoute(path: '/categories', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const CategoriesScreen())),
    GoRoute(path: '/services', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const ServiceListingScreen())),
    GoRoute(path: '/service-details', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const ServiceDetailsScreen())),
    GoRoute(path: '/search', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const SearchFilterScreen())),
    GoRoute(path: '/nearby-workers', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const NearbyWorkersScreen())),
    GoRoute(path: '/map-matching', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const MapMatchingScreen())),
    GoRoute(path: '/worker-profile', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerProfileScreen())),
    GoRoute(path: '/emergency-booking', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const EmergencyBookingScreen())),
    GoRoute(path: '/booking-schedule', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const BookingScheduleScreen())),
    GoRoute(path: '/booking-review', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const BookingReviewScreen())),
    GoRoute(path: '/booking-address', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const BookingAddressScreen())),
    GoRoute(path: '/booking-confirmation', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const BookingConfirmationScreen())),
    GoRoute(path: '/active-booking', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const ActiveBookingScreen())),
    GoRoute(path: '/cancel-reschedule', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const CancelRescheduleScreen())),
    GoRoute(path: '/payment-checkout', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const PaymentCheckoutScreen())),
    GoRoute(path: '/invoice', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const InvoiceSuccessScreen())),
    GoRoute(path: '/rating-review', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const RatingReviewScreen())),
    GoRoute(path: '/booking-history', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const BookingHistoryScreen())),
    GoRoute(path: '/rebook', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const RebookScreen())),
    GoRoute(path: '/service-address', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const ServiceAddressScreen())),
    GoRoute(path: '/order-summary', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const OrderSummaryScreen())),
    GoRoute(path: '/customer-profile', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const CustomerProfileScreen())),
    GoRoute(path: '/worker-bookings', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerBookingsScreen())),
    GoRoute(path: '/worker-profile-account', pageBuilder: (context, state) => _buildCustomTransitionPage(context: context, state: state, child: const WorkerAccountProfileScreen())),
  ],
);
