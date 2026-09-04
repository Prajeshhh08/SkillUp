import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skillup/models/booking_flow_state.dart';
import 'package:skillup/models/booking_model.dart';
import 'package:skillup/models/customer_address.dart';
import 'package:skillup/models/service_model.dart';
import 'package:skillup/screens/active_booking_screen.dart';
import 'package:skillup/screens/booking_confirmation_screen.dart';
import 'package:skillup/screens/booking_history_screen.dart';
import 'package:skillup/screens/booking_review_screen.dart';
import 'package:skillup/screens/booking_schedule_screen.dart';
import 'package:skillup/screens/cancel_reschedule_screen.dart';
import 'package:skillup/screens/invoice_success_screen.dart';
import 'package:skillup/screens/order_summary_screen.dart';
import 'package:skillup/screens/payment_checkout_screen.dart';
import 'package:skillup/screens/rating_review_screen.dart';
import 'package:skillup/screens/rebook_screen.dart';
import 'package:skillup/services/booking_service.dart';
import 'package:skillup/services/customer_service.dart';

class _FakeCustomerService extends CustomerService {
  @override
  Future<List<CustomerAddress>> getAddresses() async {
    return [
      CustomerAddress(
        id: 'addr-test-1',
        customerId: 'cust-1',
        label: 'Home',
        streetAddress: '100 Indiranagar',
        apartmentUnit: 'Flat 202',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560038',
        latitude: 12.9716,
        longitude: 77.5946,
        isDefault: true,
      ),
    ];
  }
}

class _FakeBookingService extends BookingService {
  _FakeBookingService();

  final BookingModel mockBooking = BookingModel(
    id: 'bk-test-1',
    bookingReference: 'SK-2026-55555',
    customerId: 'cust-1',
    workerId: 'wrk-1',
    serviceId: 'svc-1',
    addressId: 'addr-test-1',
    status: 'CONFIRMED',
    scheduledAt: DateTime.utc(2026, 9, 5, 9, 0),
    quotedPrice: 349.0,
    createdAt: DateTime.utc(2026, 9, 4, 10, 0),
    updatedAt: DateTime.utc(2026, 9, 4, 10, 0),
    serviceTitle: 'Tap & Leak Repair',
    workerName: 'Ravi Kumar',
    addressText: '100 Indiranagar, Bengaluru',
  );

  @override
  Future<QuoteModel> calculateQuote(QuoteRequestPayload payload) async {
    return const QuoteModel(
      serviceId: 'svc-1',
      serviceTitle: 'Tap & Leak Repair',
      basePrice: 299.0,
      distanceKm: 2.0,
      distanceFee: 40.0,
      emergencyFee: 0.0,
      taxAmount: 61.02,
      totalQuotedPrice: 400.02,
      estimatedDurationMins: 45,
    );
  }

  @override
  Future<BookingModel> createBooking(BookingCreatePayload payload) async {
    return mockBooking;
  }

  @override
  Future<List<BookingModel>> getCustomerBookings({String? status}) async {
    return [
      mockBooking,
      BookingModel(
        id: 'bk-comp-1',
        bookingReference: 'SK-2026-99999',
        customerId: 'cust-1',
        workerId: 'wrk-1',
        serviceId: 'svc-1',
        addressId: 'addr-test-1',
        status: 'COMPLETED',
        scheduledAt: DateTime.utc(2026, 9, 1, 10, 0),
        quotedPrice: 299.0,
        finalPrice: 299.0,
        createdAt: DateTime.utc(2026, 9, 1, 8, 0),
        updatedAt: DateTime.utc(2026, 9, 1, 12, 0),
        serviceTitle: 'Drain Cleaning',
        workerName: 'Ravi Kumar',
      ),
      BookingModel(
        id: 'bk-canc-1',
        bookingReference: 'SK-2026-88888',
        customerId: 'cust-1',
        serviceId: 'svc-1',
        addressId: 'addr-test-1',
        status: 'CANCELLED',
        cancellationReason: 'Schedule conflict',
        scheduledAt: DateTime.utc(2026, 8, 20, 14, 0),
        quotedPrice: 199.0,
        createdAt: DateTime.utc(2026, 8, 20, 9, 0),
        updatedAt: DateTime.utc(2026, 8, 20, 10, 0),
        serviceTitle: 'Fan Repair',
      ),
    ];
  }

  @override
  Future<BookingModel> getBookingDetails(String bookingId) async {
    return mockBooking;
  }

  @override
  Future<BookingTrackingModel> getBookingTracking(String bookingId) async {
    return BookingTrackingModel(
      bookingId: 'bk-test-1',
      bookingReference: 'SK-2026-55555',
      status: 'ON_THE_WAY',
      scheduledAt: DateTime.utc(2026, 9, 5, 9, 0),
      workerId: 'wrk-1',
      workerName: 'Ravi Kumar',
      workerPhone: '+919876543210',
      etaMinutes: 12,
      timeline: [
        BookingTimelineItem(
          status: 'CONFIRMED',
          timestamp: DateTime.utc(2026, 9, 5, 8, 30),
        ),
        BookingTimelineItem(
          status: 'ON_THE_WAY',
          timestamp: DateTime.utc(2026, 9, 5, 8, 45),
        ),
      ],
    );
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, String reason) async {
    return BookingModel(
      id: bookingId,
      bookingReference: 'SK-2026-55555',
      customerId: 'cust-1',
      serviceId: 'svc-1',
      addressId: 'addr-test-1',
      status: 'CANCELLED',
      cancellationReason: reason,
      scheduledAt: DateTime.utc(2026, 9, 5, 9, 0),
      quotedPrice: 349.0,
      createdAt: DateTime.utc(2026, 9, 4, 10, 0),
      updatedAt: DateTime.utc(2026, 9, 4, 11, 0),
    );
  }

  @override
  Future<BookingModel> rescheduleBooking(
    String bookingId,
    DateTime newScheduledAt,
  ) async {
    return BookingModel(
      id: bookingId,
      bookingReference: 'SK-2026-55555',
      customerId: 'cust-1',
      serviceId: 'svc-1',
      addressId: 'addr-test-1',
      status: 'CONFIRMED',
      scheduledAt: newScheduledAt,
      quotedPrice: 349.0,
      createdAt: DateTime.utc(2026, 9, 4, 10, 0),
      updatedAt: DateTime.utc(2026, 9, 4, 11, 0),
    );
  }

  @override
  Future<BookingModel> rebookBooking(
    String bookingId,
    DateTime newScheduledAt,
  ) async {
    return BookingModel(
      id: 'bk-rebooked-1',
      bookingReference: 'SK-2026-77777',
      customerId: 'cust-1',
      serviceId: 'svc-1',
      addressId: 'addr-test-1',
      status: 'PENDING',
      scheduledAt: newScheduledAt,
      quotedPrice: 349.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceTitle: 'Tap & Leak Repair',
    );
  }

  @override
  Future<ReviewModel> createReview(
    String bookingId,
    ReviewCreatePayload payload,
  ) async {
    return ReviewModel(
      id: 'rev-1',
      bookingId: bookingId,
      customerId: 'cust-1',
      workerId: 'wrk-1',
      rating: payload.rating,
      comment: payload.comment,
      badges: payload.badges,
    );
  }

  @override
  Future<InvoiceModel> getInvoice(String bookingId) async {
    return InvoiceModel(
      invoiceNumber: 'INV-SK-2026-55555',
      bookingReference: 'SK-2026-55555',
      issuedAt: DateTime.utc(2026, 9, 5, 12, 0),
      customerName: 'Aarav Sharma',
      workerName: 'Ravi Kumar',
      serviceTitle: 'Tap & Leak Repair',
      items: const [
        InvoiceLineItem(description: 'Tap Service', amount: 299.0),
        InvoiceLineItem(description: 'GST (18%)', amount: 50.0),
      ],
      subtotal: 299.0,
      taxAmount: 50.0,
      totalAmount: 349.0,
      downloadUrl: 'https://api.skillup.com/invoices/inv.pdf',
    );
  }
}

Widget _wrapRouter(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(
        path: '/booking-review',
        builder: (context, state) =>
            const Scaffold(body: Text('Review booking page')),
      ),
      GoRoute(
        path: '/payment-checkout',
        builder: (context, state) =>
            const Scaffold(body: Text('Payment checkout page')),
      ),
      GoRoute(
        path: '/booking-confirmation',
        builder: (context, state) =>
            const Scaffold(body: Text('Confirmation page')),
      ),
      GoRoute(
        path: '/active-booking',
        builder: (context, state) =>
            const Scaffold(body: Text('Active booking page')),
      ),
      GoRoute(
        path: '/booking-history',
        builder: (context, state) =>
            const Scaffold(body: Text('Booking history page')),
      ),
      GoRoute(
        path: '/cancel-reschedule',
        builder: (context, state) =>
            const Scaffold(body: Text('Cancel reschedule page')),
      ),
      GoRoute(
        path: '/order-summary',
        builder: (context, state) =>
            const Scaffold(body: Text('Order summary page')),
      ),
      GoRoute(
        path: '/invoice',
        builder: (context, state) => const Scaffold(body: Text('Invoice page')),
      ),
      GoRoute(
        path: '/rating-review',
        builder: (context, state) =>
            const Scaffold(body: Text('Rating review page')),
      ),
      GoRoute(
        path: '/rebook',
        builder: (context, state) => const Scaffold(body: Text('Rebook page')),
      ),
      GoRoute(
        path: '/customer-home',
        builder: (context, state) =>
            const Scaffold(body: Text('Customer home page')),
      ),
      GoRoute(
        path: '/address',
        builder: (context, state) =>
            const Scaffold(body: Text('Address setup page')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUp(() {
    BookingFlowState.instance.reset();
  });

  group('BookingScheduleScreen', () {
    testWidgets('selects time window and navigates to review', (tester) async {
      BookingFlowState.instance.selectedService = const ServiceModel(
        id: 'svc-1',
        categoryId: 'cat-1',
        title: 'Tap & Leak Repair',
        basePrice: 299,
      );

      await tester.pumpWidget(_wrapRouter(const BookingScheduleScreen()));

      await tester.pumpAndSettle();

      expect(find.text('Schedule Tap & Leak Repair'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Afternoon'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);

      // Select Afternoon
      await tester.tap(find.text('Afternoon'));
      await tester.pumpAndSettle();

      expect(BookingFlowState.instance.timeWindow, 'Morning'); // Before submit

      // Tap Review booking
      await tester.tap(find.text('Review booking'));
      await tester.pumpAndSettle();

      expect(BookingFlowState.instance.timeWindow, 'Afternoon');
      expect(find.text('Review booking page'), findsOneWidget);
    });
  });

  group('BookingReviewScreen', () {
    testWidgets('loads address, calculates live quote, and confirms booking', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      BookingFlowState.instance.selectedService = const ServiceModel(
        id: 'svc-1',
        categoryId: 'cat-1',
        title: 'Tap & Leak Repair',
        basePrice: 299,
      );

      final fakeBookingService = _FakeBookingService();
      final fakeCustService = _FakeCustomerService();

      await tester.pumpWidget(
        _wrapRouter(
          BookingReviewScreen(
            bookingService: fakeBookingService,
            customerService: fakeCustService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify loaded address
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Flat 202, 100 Indiranagar'), findsOneWidget);

      // Verify calculated quote breakdown
      expect(find.text('Base service charge'), findsOneWidget);
      expect(find.text('₹299'), findsOneWidget);
      expect(find.text('Distance fee'), findsOneWidget);
      expect(find.text('₹40'), findsOneWidget);
      expect(find.text('Taxes & GST (18%)'), findsOneWidget);
      expect(find.text('₹61'), findsOneWidget);
      expect(find.text('₹400'), findsOneWidget); // Total rounded

      // Tap Confirm booking
      await tester.tap(find.text('Confirm booking'));
      await tester.pumpAndSettle();

      expect(BookingFlowState.instance.activeBooking?.id, 'bk-test-1');
      expect(find.text('Payment checkout page'), findsOneWidget);
    });
  });

  group('PaymentCheckoutScreen', () {
    testWidgets('renders payment options and mock confirms to confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapRouter(
          const PaymentCheckoutScreen(
            bookingId: 'bk-test-1',
            totalAmount: 400.0,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Credit/Debit Card'), findsOneWidget);
      expect(find.text('₹400'), findsOneWidget);

      await tester.tap(find.text('Pay ₹400'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmation page'), findsOneWidget);
    });
  });

  group('BookingConfirmationScreen', () {
    testWidgets('renders reference and navigates to active tracking', (
      tester,
    ) async {
      BookingFlowState.instance.activeBooking = BookingModel(
        id: 'bk-test-1',
        bookingReference: 'SK-2026-55555',
        customerId: 'cust-1',
        serviceId: 'svc-1',
        addressId: 'addr-1',
        status: 'CONFIRMED',
        scheduledAt: DateTime.utc(2026, 9, 5, 9, 0),
        quotedPrice: 400.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        serviceTitle: 'Tap & Leak Repair',
      );

      await tester.pumpWidget(
        _wrapRouter(const BookingConfirmationScreen(bookingId: 'bk-test-1')),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          'Booking Reference #SK-2026-55555. We are assigning a verified professional for your service.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Track booking'));
      await tester.pumpAndSettle();

      expect(find.text('Active booking page'), findsOneWidget);
    });
  });

  group('ActiveBookingScreen', () {
    testWidgets('loads tracking details and timeline steps', (tester) async {
      final fake = _FakeBookingService();

      await tester.pumpWidget(
        _wrapRouter(
          ActiveBookingScreen(bookingId: 'bk-test-1', bookingService: fake),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('Estimated arrival in 12 mins'), findsOneWidget);
      expect(find.text('Booking confirmed'), findsOneWidget);
      expect(find.text('Professional assigned'), findsOneWidget);
      expect(find.text('On the way'), findsOneWidget);

      // Tap order summary
      await tester.tap(find.text('View order summary'));
      await tester.pumpAndSettle();

      expect(find.text('Order summary page'), findsOneWidget);
    });
  });

  group('BookingHistoryScreen', () {
    testWidgets('renders tabs with active and completed bookings', (
      tester,
    ) async {
      final fake = _FakeBookingService();

      await tester.pumpWidget(
        _wrapRouter(BookingHistoryScreen(bookingService: fake)),
      );

      await tester.pumpAndSettle();

      // Active tab
      expect(find.text('Tap & Leak Repair'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);

      // Switch to Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(find.text('Drain Cleaning'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('Rebook'), findsOneWidget);

      // Switch to Cancelled tab
      await tester.tap(find.text('Cancelled'));
      await tester.pumpAndSettle();

      expect(find.text('Fan Repair'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);
    });
  });

  group('CancelRescheduleScreen', () {
    testWidgets('reschedules booking and cancels booking', (tester) async {
      final fake = _FakeBookingService();

      await tester.pumpWidget(
        _wrapRouter(
          CancelRescheduleScreen(bookingId: 'bk-test-1', bookingService: fake),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Reschedule booking'), findsOneWidget);
      expect(find.text('Confirm reschedule'), findsOneWidget);

      // Switch to Cancel
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('Cancel booking'), findsNWidgets(2)); // Title & button
      await tester.enterText(
        find.byType(TextField),
        'Found alternative plumber',
      );

      await tester.tap(find.text('Cancel booking').last);
      await tester.pumpAndSettle();

      expect(find.text('Booking history page'), findsOneWidget);
    });
  });

  group('RatingReviewScreen', () {
    testWidgets('selects star rating and submits review', (tester) async {
      final fake = _FakeBookingService();

      await tester.pumpWidget(
        _wrapRouter(
          RatingReviewScreen(bookingId: 'bk-test-1', bookingService: fake),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('How was your experience?'), findsOneWidget);
      expect(find.text('Punctual'), findsOneWidget);
      expect(find.text('Clean Work'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'Excellent work done on time!',
      );

      await tester.tap(find.text('Submit review'));
      await tester.pumpAndSettle();

      expect(find.text('Customer home page'), findsOneWidget);
    });
  });

  group('OrderSummaryScreen and InvoiceSuccessScreen', () {
    testWidgets('loads order summary and invoice breakdown', (tester) async {
      final fake = _FakeBookingService();

      await tester.pumpWidget(
        _wrapRouter(
          OrderSummaryScreen(bookingId: 'bk-test-1', bookingService: fake),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order #SK-2026-55555'), findsOneWidget);
      expect(find.text('Tap & Leak Repair'), findsOneWidget);
      expect(find.text('₹349'), findsOneWidget);
      expect(find.text('View invoice & receipt'), findsOneWidget);

      // Now test Invoice screen
      await tester.pumpWidget(
        _wrapRouter(
          InvoiceSuccessScreen(bookingId: 'bk-test-1', bookingService: fake),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tap Service'), findsOneWidget);
      expect(find.text('GST (18%)'), findsOneWidget);
      expect(find.text('₹349'), findsOneWidget);
    });
  });

  group('RebookScreen', () {
    testWidgets('loads previous booking and submits rebooking', (tester) async {
      final fake = _FakeBookingService();

      await tester.pumpWidget(
        _wrapRouter(RebookScreen(bookingId: 'bk-test-1', bookingService: fake)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tap & Leak Repair'), findsOneWidget);
      expect(find.text('Previous order: #SK-2026-55555'), findsOneWidget);

      await tester.tap(find.text('Confirm rebooking'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmation page'), findsOneWidget);
    });
  });
}
