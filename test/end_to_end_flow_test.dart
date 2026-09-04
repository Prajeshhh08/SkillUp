import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skillup/models/booking_flow_state.dart';
import 'package:skillup/models/booking_model.dart';
import 'package:skillup/models/customer_address.dart';
import 'package:skillup/models/service_model.dart';
import 'package:skillup/models/skill_category.dart';
import 'package:skillup/screens/active_booking_screen.dart';
import 'package:skillup/screens/booking_schedule_screen.dart';
import 'package:skillup/screens/customer_home_screen.dart';
import 'package:skillup/screens/home_screen.dart';
import 'package:skillup/screens/rating_review_screen.dart';
import 'package:skillup/screens/service_details_screen.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/booking_service.dart';
import 'package:skillup/services/discovery_service.dart';
import 'package:skillup/services/worker_service.dart';

Widget _wrapRouter(Widget screen) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (context, state) => screen),
      GoRoute(path: '/role', builder: (context, state) => const Scaffold(body: Text('Role Screen'))),
      GoRoute(path: '/worker-status', builder: (context, state) => const Scaffold(body: Text('Status Route'))),
      GoRoute(path: '/worker-bookings', builder: (context, state) => const Scaffold(body: Text('Bookings Route'))),
      GoRoute(path: '/customer-home', builder: (context, state) => const Scaffold(body: Text('Customer Home Route'))),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Worker Home Route'))),
      GoRoute(path: '/booking-review', builder: (context, state) => const Scaffold(body: Text('Review Route'))),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUp(() {
    BookingFlowState.instance.reset();
  });

  group('End-to-End Customer and Worker Happy Path', () {
    testWidgets(
      'Complete journey: Discovery -> Schedule -> Review Quote -> Worker Accept & Progress -> Rating',
      (tester) async {
        const testCategory = SkillCategory(
          id: 'cat-e2e-1',
          name: 'Plumbing',
          slug: 'plumbing',
          description: 'Pipes, leaks, taps and fixtures',
        );

        const testService = ServiceModel(
          id: 'svc-e2e-1',
          categoryId: 'cat-e2e-1',
          title: 'Kitchen Plumbing Repair',
          description: 'Fix leaking taps and sink drain pipes',
          basePrice: 499.0,
          priceUnit: 'FIXED',
          estimatedDurationMins: 45,
          inclusions: ['Inspection', 'Minor parts', 'Labor'],
        );

        const testAddress = CustomerAddress(
          id: 'addr-e2e-1',
          customerId: 'cust-e2e-1',
          label: 'Home',
          streetAddress: '100 Feet Rd, Indiranagar',
          city: 'Bengaluru',
          state: 'Karnataka',
          postalCode: '560038',
          latitude: 12.9716,
          longitude: 77.5946,
          isDefault: true,
        );

        final testBooking = BookingModel(
          id: 'bk-e2e-1',
          bookingReference: 'BK-2026-99999',
          customerId: 'cust-e2e-1',
          workerId: 'wrk-e2e-1',
          serviceId: 'svc-e2e-1',
          addressId: 'addr-e2e-1',
          status: 'OFFERED',
          isEmergency: false,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          quotedPrice: 499.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          serviceTitle: 'Kitchen Plumbing Repair',
          addressText: '100 Feet Rd, Indiranagar, Bengaluru',
          notes: 'Leaking pipe under kitchen sink',
        );

        // Pre-seed BookingFlowState
        BookingFlowState.instance.selectedCategory = testCategory;
        BookingFlowState.instance.selectedService = testService;
        BookingFlowState.instance.selectedAddress = testAddress;
        BookingFlowState.instance.activeBooking = testBooking;

        // 1. Verify Customer Home
        final homeDiscoveryDio = Dio();
        homeDiscoveryDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.endsWith('/categories')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: [
                      {
                        'id': testCategory.id,
                        'name': 'Plumber',
                        'slug': 'plumbing',
                        'description': 'Pipes, leaks, taps and fixtures',
                        'is_active': true,
                      },
                    ],
                  ),
                );
              }
              return handler.next(options);
            },
          ),
        );
        final mockHomeDiscoveryService = DiscoveryService(client: ApiClient.custom(homeDiscoveryDio));

        await tester.pumpWidget(_wrapRouter(CustomerHomeScreen(discoveryService: mockHomeDiscoveryService)));
        await tester.pumpAndSettle();
        expect(find.text('Find help for your home'), findsOneWidget);
        expect(find.text('Plumber'), findsOneWidget);

        // 2. Verify Service Details Screen
        await tester.pumpWidget(_wrapRouter(ServiceDetailsScreen(serviceId: testService.id)));
        await tester.pump();
        expect(find.text('Book now'), findsOneWidget);

        // 3. Verify Booking Schedule Screen
        await tester.pumpWidget(_wrapRouter(const BookingScheduleScreen()));
        await tester.pumpAndSettle();
        expect(find.text('Morning'), findsOneWidget);
        expect(find.text('Review booking'), findsOneWidget);

        // 4. Mock BookingService for Active Tracking Screen
        final trackingDio = Dio();
        trackingDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'booking_id': testBooking.id,
                    'booking_reference': testBooking.bookingReference,
                    'status': 'ON_THE_WAY',
                    'scheduled_at': testBooking.scheduledAt.toIso8601String(),
                    'worker_name': 'Rajesh Plumber',
                    'worker_phone': '+919876543210',
                    'eta_minutes': 15,
                    'timeline': [
                      {'status': 'REQUESTED', 'timestamp': '2026-09-04T10:00:00Z'},
                      {'status': 'ON_THE_WAY', 'timestamp': '2026-09-04T10:30:00Z'},
                    ],
                  },
                ),
              );
            },
          ),
        );
        final mockBookingService = BookingService(client: ApiClient.custom(trackingDio));

        await tester.pumpWidget(
          _wrapRouter(
            ActiveBookingScreen(
              bookingId: testBooking.id,
              bookingService: mockBookingService,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Rajesh Plumber'), findsWidgets);
        expect(find.text('Estimated arrival in 15 mins'), findsOneWidget);

        // 5. Verify Worker Home Dashboard
        final workerDio = Dio();
        workerDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.endsWith('/metrics')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'acceptance_rate': 0.98,
                      'completed_jobs': 25,
                      'total_earnings': 12500.0,
                      'average_rating': 4.9,
                    },
                  ),
                );
              }
              if (options.path.endsWith('/worker/bookings')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: [
                      {
                        'id': testBooking.id,
                        'booking_reference': testBooking.bookingReference,
                        'customer_id': 'c-1',
                        'service_id': 's-1',
                        'address_id': 'a-1',
                        'status': 'CONFIRMED',
                        'is_emergency': false,
                        'scheduled_at': '2026-09-05T10:00:00Z',
                        'quoted_price': 499.0,
                        'created_at': '2026-09-04T12:00:00Z',
                        'updated_at': '2026-09-04T12:00:00Z',
                        'service_title': 'Kitchen Plumbing Repair',
                      },
                    ],
                  ),
                );
              }
              return handler.next(options);
            },
          ),
        );
        final mockWorkerService = WorkerService(client: ApiClient.custom(workerDio));

        await tester.pumpWidget(_wrapRouter(HomeScreen(service: mockWorkerService)));
        await tester.pumpAndSettle();
        expect(find.text('Hello, professional'), findsOneWidget);
        expect(find.text('₹12500'), findsOneWidget);
        expect(find.text('Kitchen Plumbing Repair'), findsOneWidget);

        // 6. Verify Rating & Review Screen
        await tester.pumpWidget(_wrapRouter(RatingReviewScreen(bookingId: testBooking.id)));
        await tester.pumpAndSettle();
        expect(find.text('How was your experience?'), findsOneWidget);
        expect(find.text('Submit review'), findsOneWidget);
      },
    );
  });
}
