import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skillup/screens/home_screen.dart';
import 'package:skillup/screens/worker_bookings_screen.dart';
import 'package:skillup/screens/worker_status_screen.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/worker_service.dart';

Widget _wrapRouter(Widget screen) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (context, state) => screen),
      GoRoute(path: '/role', builder: (context, state) => const Scaffold(body: Text('Role Screen'))),
      GoRoute(path: '/worker-status', builder: (context, state) => const Scaffold(body: Text('Status Route'))),
      GoRoute(path: '/worker-bookings', builder: (context, state) => const Scaffold(body: Text('Bookings Route'))),
      GoRoute(path: '/worker-form', builder: (context, state) => const Scaffold(body: Text('Form Route'))),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Home Route'))),
      GoRoute(path: '/worker-profile-account', builder: (context, state) => const Scaffold(body: Text('Profile Route'))),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

WorkerService _createMockWorkerService({
  List<Map<String, dynamic>>? bookings,
  Map<String, dynamic>? metrics,
  Map<String, dynamic>? profile,
  bool fail = false,
}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (fail) {
          return handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 500,
                data: {'detail': 'Internal server error'},
              ),
            ),
          );
        }

        if (options.path.endsWith('/metrics')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: metrics ?? {
                'acceptance_rate': 0.96,
                'completed_jobs': 24,
                'total_earnings': 11500.0,
                'average_rating': 4.9,
              },
            ),
          );
        }

        if (options.path.endsWith('/workers/me/profile')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: profile ?? {
                'user_id': 'wrk-1',
                'full_name': 'Ramesh Kumar',
                'phone': '+919876543210',
                'bio': 'Experienced plumber and electrician',
                'hourly_rate': 450.0,
                'is_available': true,
                'setup_progress': 85,
                'verification_status': 'VERIFIED',
                'payout_preference': 'UPI',
                'skills': [
                  {'skill_category_id': 'sk-1', 'skill_name': 'Plumbing', 'experience_years': 5},
                ],
              },
            ),
          );
        }

        if (options.path.contains('/accept')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': 'bk-req-1',
                'booking_reference': 'BK-2026-00001',
                'customer_id': 'c-1',
                'worker_id': 'wrk-1',
                'service_id': 's-1',
                'address_id': 'a-1',
                'status': 'CONFIRMED',
                'is_emergency': false,
                'scheduled_at': '2026-09-05T10:00:00Z',
                'quoted_price': 499.0,
                'created_at': '2026-09-04T12:00:00Z',
                'updated_at': '2026-09-04T12:05:00Z',
                'service_title': 'Sink Leak Repair',
              },
            ),
          );
        }

        if (options.path.contains('/decline')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': 'bk-req-1',
                'booking_reference': 'BK-2026-00001',
                'customer_id': 'c-1',
                'service_id': 's-1',
                'address_id': 'a-1',
                'status': 'REJECTED',
                'is_emergency': false,
                'scheduled_at': '2026-09-05T10:00:00Z',
                'quoted_price': 499.0,
                'created_at': '2026-09-04T12:00:00Z',
                'updated_at': '2026-09-04T12:05:00Z',
              },
            ),
          );
        }

        if (options.path.contains('/status')) {
          final nextStatus = (options.data as Map)['status'];
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': 'bk-act-1',
                'booking_reference': 'BK-2026-00002',
                'customer_id': 'c-1',
                'worker_id': 'wrk-1',
                'service_id': 's-1',
                'address_id': 'a-1',
                'status': nextStatus,
                'is_emergency': false,
                'scheduled_at': '2026-09-05T14:00:00Z',
                'quoted_price': 650.0,
                'created_at': '2026-09-04T12:00:00Z',
                'updated_at': '2026-09-04T12:10:00Z',
                'service_title': 'Electrical Wiring',
              },
            ),
          );
        }

        if (options.path.endsWith('/worker/bookings')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: bookings ?? [
                {
                  'id': 'bk-req-1',
                  'booking_reference': 'BK-2026-00001',
                  'customer_id': 'c-1',
                  'service_id': 's-1',
                  'address_id': 'a-1',
                  'status': 'OFFERED',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-05T10:00:00Z',
                  'quoted_price': 499.0,
                  'notes': 'Tap leaking in the bathroom',
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:00:00Z',
                  'service_title': 'Sink Leak Repair',
                  'address_text': 'Flat 402, Green Glen Layout, Bengaluru',
                },
                {
                  'id': 'bk-act-1',
                  'booking_reference': 'BK-2026-00002',
                  'customer_id': 'c-2',
                  'worker_id': 'wrk-1',
                  'service_id': 's-2',
                  'address_id': 'a-2',
                  'status': 'CONFIRMED',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-05T14:00:00Z',
                  'quoted_price': 650.0,
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:00:00Z',
                  'service_title': 'Electrical Wiring',
                  'address_text': 'Villa 12, Indiranagar, Bengaluru',
                },
                {
                  'id': 'bk-hist-1',
                  'booking_reference': 'BK-2026-00003',
                  'customer_id': 'c-3',
                  'worker_id': 'wrk-1',
                  'service_id': 's-3',
                  'address_id': 'a-3',
                  'status': 'COMPLETED',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-03T11:00:00Z',
                  'quoted_price': 800.0,
                  'final_price': 800.0,
                  'created_at': '2026-09-03T10:00:00Z',
                  'updated_at': '2026-09-03T12:00:00Z',
                  'service_title': 'Switchboard Installation',
                },
              ],
            ),
          );
        }

        return handler.next(options);
      },
    ),
  );

  return WorkerService(client: ApiClient.custom(dio));
}

void main() {
  group('WorkerBookingsScreen widget tests', () {
    testWidgets('Renders requests tab with job request, accept, and decline buttons', (tester) async {
      final service = _createMockWorkerService();

      await tester.pumpWidget(_wrapRouter(WorkerBookingsScreen(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Jobs for you'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      expect(find.text('Sink Leak Repair'), findsOneWidget);
      expect(find.text('₹499'), findsOneWidget);
      expect(find.text('Flat 402, Green Glen Layout, Bengaluru'), findsOneWidget);
      expect(find.text('Note: Tap leaking in the bathroom'), findsOneWidget);

      expect(find.text('Accept job'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('Tapping Accept job triggers accept and displays feedback', (tester) async {
      final service = _createMockWorkerService();

      await tester.pumpWidget(_wrapRouter(WorkerBookingsScreen(service: service)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accept job'));
      await tester.pumpAndSettle();

      expect(find.text('Job accepted! Moved to Active jobs.'), findsOneWidget);
    });

    testWidgets('Active tab displays confirmed job and status action button', (tester) async {
      final service = _createMockWorkerService();

      await tester.pumpWidget(_wrapRouter(WorkerBookingsScreen(service: service)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      expect(find.text('Electrical Wiring'), findsOneWidget);
      expect(find.text('Villa 12, Indiranagar, Bengaluru'), findsOneWidget);
      expect(find.text('Start travel (On the way)'), findsOneWidget);

      await tester.tap(find.text('Start travel (On the way)'));
      await tester.pumpAndSettle();

      expect(find.text('Status updated: On the way to customer!'), findsOneWidget);
    });

    testWidgets('History tab displays completed job with final earnings', (tester) async {
      final service = _createMockWorkerService();

      await tester.pumpWidget(_wrapRouter(WorkerBookingsScreen(service: service)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('Switchboard Installation'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('₹800'), findsOneWidget);
    });

    testWidgets('Renders empty state when no requests exist', (tester) async {
      final service = _createMockWorkerService(bookings: []);

      await tester.pumpWidget(_wrapRouter(WorkerBookingsScreen(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('No new job requests'), findsOneWidget);
    });

    testWidgets('Renders error view and retries on error', (tester) async {
      final service = _createMockWorkerService(fail: true);

      await tester.pumpWidget(_wrapRouter(WorkerBookingsScreen(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load jobs'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('HomeScreen (Worker Home) widget tests', () {
    testWidgets('Renders dashboard metrics and active booking card', (tester) async {
      final service = _createMockWorkerService();

      await tester.pumpWidget(_wrapRouter(HomeScreen(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Hello, professional'), findsOneWidget);

      expect(find.text('₹11500'), findsOneWidget);
      expect(find.text('Earnings'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('Jobs done'), findsOneWidget);
      expect(find.text('4.9 ★'), findsOneWidget);
      expect(find.text('96%'), findsOneWidget);

      expect(find.text('Electrical Wiring'), findsOneWidget);
      expect(find.text('View verification status'), findsOneWidget);
    });

    testWidgets('Navigates to verification status on button tap', (tester) async {
      final service = _createMockWorkerService();

      await tester.pumpWidget(_wrapRouter(HomeScreen(service: service)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View verification status'));
      await tester.pumpAndSettle();

      expect(find.text('Status Route'), findsOneWidget);
    });
  });

  group('WorkerStatusScreen widget tests', () {
    testWidgets('Renders verification status card and checklist items', (tester) async {
      final service = _createMockWorkerService();

      await tester.pumpWidget(_wrapRouter(WorkerStatusScreen(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Verification status'), findsOneWidget);
      expect(find.text('Status: Verified Professional'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);

      expect(find.text('Identity verification'), findsOneWidget);
      expect(find.text('Bank account details'), findsOneWidget);
      expect(find.text('Professional skills'), findsOneWidget);
      expect(find.text('1 skills listed'), findsOneWidget);
      expect(find.text('Hourly rate set'), findsOneWidget);
      expect(find.text('₹450/hr'), findsOneWidget);

      expect(find.text('Edit profile'), findsOneWidget);
    });

    testWidgets('Renders pending status when worker is unverified', (tester) async {
      final service = _createMockWorkerService(
        profile: {
          'user_id': 'wrk-2',
          'full_name': 'Pending Worker',
          'phone': '+919876543211',
          'setup_progress': 40,
          'verification_status': 'PENDING_REVIEW',
          'skills': [],
        },
      );

      await tester.pumpWidget(_wrapRouter(WorkerStatusScreen(service: service)));
      await tester.pumpAndSettle();

      expect(find.text('Status: Pending review'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
    });
  });
}
