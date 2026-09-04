import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skillup/models/booking_flow_state.dart';
import 'package:skillup/models/service_model.dart';
import 'package:skillup/models/skill_category.dart';
import 'package:skillup/screens/categories_screen.dart';
import 'package:skillup/screens/nearby_workers_screen.dart';
import 'package:skillup/screens/search_filter_screen.dart';
import 'package:skillup/screens/service_details_screen.dart';
import 'package:skillup/screens/service_listing_screen.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/discovery_service.dart';

class _FakeDiscoveryService extends DiscoveryService {
  _FakeDiscoveryService({this.throwError = false, this.emptyServices = false});

  final bool throwError;
  final bool emptyServices;

  @override
  Future<List<SkillCategory>> getCategories() async {
    if (throwError) throw const ApiException('Failed to load categories');
    return const [
      SkillCategory(
        id: 'cat-plumb',
        name: 'Plumbing',
        slug: 'plumbing',
        description: 'Pipes and fixtures',
      ),
      SkillCategory(
        id: 'cat-elec',
        name: 'Electrical',
        slug: 'electrical',
        description: 'Wiring and appliances',
      ),
    ];
  }

  @override
  Future<List<ServiceModel>> getServices({String? categoryId}) async {
    if (throwError) throw const ApiException('Failed to load services');
    if (emptyServices) return [];
    return const [
      ServiceModel(
        id: 'svc-1',
        categoryId: 'cat-plumb',
        title: 'Tap & Leak Repair',
        description: 'Fix dripping taps and leaky pipes.',
        basePrice: 299.0,
        estimatedDurationMins: 45,
        inclusions: ['Leak diagnosis', 'Washer replacement'],
      ),
      ServiceModel(
        id: 'svc-2',
        categoryId: 'cat-plumb',
        title: 'Drain Cleaning',
        description: 'Clear clogged drains.',
        basePrice: 499.0,
        estimatedDurationMins: 60,
        inclusions: ['Drain snaking', 'Chemical flushing'],
      ),
    ];
  }

  @override
  Future<ServiceModel> getServiceDetails(String serviceId) async {
    if (throwError) throw const ApiException('Failed to load service details');
    return const ServiceModel(
      id: 'svc-1',
      categoryId: 'cat-plumb',
      title: 'Tap & Leak Repair',
      description: 'Fix dripping taps and leaky pipes.',
      basePrice: 299.0,
      estimatedDurationMins: 45,
      inclusions: ['Leak diagnosis', 'Washer replacement', 'Pressure check'],
    );
  }

  @override
  Future<SearchResult> search({
    String? query,
    double? minRating,
    double? maxDistance,
    bool? availableNow,
    double? maxPrice,
  }) async {
    if (throwError) throw const ApiException('Search failed');
    return const SearchResult(
      services: [
        ServiceModel(
          id: 'svc-search-1',
          categoryId: 'cat-plumb',
          title: 'Pipe Replacement',
          basePrice: 599.0,
          estimatedDurationMins: 90,
        ),
      ],
      workers: [
        WorkerSearchItem(
          workerId: 'wrk-1',
          fullName: 'Ravi Kumar',
          bio: 'Plumbing expert',
          hourlyRate: 350.0,
          averageRating: 4.8,
          totalReviews: 20,
        ),
      ],
      totalResults: 2,
    );
  }

  @override
  Future<List<NearbyWorkerItem>> getNearbyWorkers({
    required double latitude,
    required double longitude,
    String? serviceId,
  }) async {
    if (throwError) throw const ApiException('Failed to load nearby workers');
    return const [
      NearbyWorkerItem(
        workerId: 'wrk-nearby-1',
        fullName: 'Anita Sharma',
        bio: 'Certified electrician',
        hourlyRate: 400.0,
        averageRating: 4.9,
        totalReviews: 32,
        distanceKm: 2.1,
        latitude: 12.972,
        longitude: 77.595,
      ),
    ];
  }
}

Widget _wrapWithRouter(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(
        path: '/services',
        builder: (context, state) =>
            const Scaffold(body: Text('Services page')),
      ),
      GoRoute(
        path: '/service-details',
        builder: (context, state) =>
            const Scaffold(body: Text('Service details page')),
      ),
      GoRoute(
        path: '/booking-schedule',
        builder: (context, state) =>
            const Scaffold(body: Text('Booking schedule page')),
      ),
      GoRoute(
        path: '/nearby-workers',
        builder: (context, state) =>
            const Scaffold(body: Text('Nearby workers page')),
      ),
      GoRoute(
        path: '/worker-profile',
        builder: (context, state) =>
            const Scaffold(body: Text('Worker profile page')),
      ),
      GoRoute(
        path: '/map-matching',
        builder: (context, state) =>
            const Scaffold(body: Text('Map matching page')),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUp(() {
    BookingFlowState.instance.reset();
  });

  group('CategoriesScreen', () {
    testWidgets('renders categories and stores selection in BookingFlowState', (
      tester,
    ) async {
      final fake = _FakeDiscoveryService();
      await tester.pumpWidget(
        _wrapWithRouter(CategoriesScreen(discoveryService: fake)),
      );

      // Loading spinner first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Categories rendered
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('Electrical'), findsOneWidget);

      // Tap Plumbing
      await tester.tap(find.text('Plumbing'));
      await tester.pumpAndSettle();

      expect(BookingFlowState.instance.selectedCategory?.name, 'Plumbing');
    });

    testWidgets('shows error and retries successfully', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(
          CategoriesScreen(
            discoveryService: _FakeDiscoveryService(throwError: true),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Failed to load categories'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('ServiceListingScreen', () {
    testWidgets('renders services for category with price and duration', (
      tester,
    ) async {
      final fake = _FakeDiscoveryService();
      await tester.pumpWidget(
        _wrapWithRouter(
          ServiceListingScreen(
            categoryId: 'cat-plumb',
            categoryName: 'Plumbing',
            discoveryService: fake,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tap & Leak Repair'), findsOneWidget);
      expect(find.text('Drain Cleaning'), findsOneWidget);
      expect(find.text('From ₹299 · 45 min'), findsOneWidget);
      expect(find.text('From ₹499 · 60 min'), findsOneWidget);

      // Tap service
      await tester.tap(find.text('Tap & Leak Repair'));
      await tester.pumpAndSettle();

      expect(
        BookingFlowState.instance.selectedService?.title,
        'Tap & Leak Repair',
      );
    });

    testWidgets('shows empty state when category has no services', (
      tester,
    ) async {
      final fake = _FakeDiscoveryService(emptyServices: true);
      await tester.pumpWidget(
        _wrapWithRouter(
          ServiceListingScreen(
            categoryId: 'cat-empty',
            categoryName: 'Empty Category',
            discoveryService: fake,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(
        find.text('No services available in this category yet.'),
        findsOneWidget,
      );
    });
  });

  group('ServiceDetailsScreen', () {
    testWidgets('renders title, price, duration, and dynamic inclusions', (
      tester,
    ) async {
      const service = ServiceModel(
        id: 'svc-1',
        categoryId: 'cat-plumb',
        title: 'Tap & Leak Repair',
        description: 'Fix dripping taps and leaky pipes.',
        basePrice: 299.0,
        estimatedDurationMins: 45,
        inclusions: ['Leak diagnosis', 'Washer replacement', 'Pressure check'],
      );

      await tester.pumpWidget(
        _wrapWithRouter(const ServiceDetailsScreen(initialService: service)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tap & Leak Repair'), findsOneWidget);
      expect(find.text('From ₹299'), findsOneWidget);
      expect(find.text('Estimated duration: 45 mins'), findsOneWidget);
      expect(find.text('Leak diagnosis'), findsOneWidget);
      expect(find.text('Washer replacement'), findsOneWidget);
      expect(find.text('Pressure check'), findsOneWidget);
      expect(find.text('Book now'), findsOneWidget);

      // Tap Book now
      await tester.tap(find.text('Book now'));
      await tester.pumpAndSettle();

      expect(BookingFlowState.instance.selectedService?.id, 'svc-1');
    });
  });

  group('SearchFilterScreen', () {
    testWidgets('searches and displays matching services and professionals', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fake = _FakeDiscoveryService();
      await tester.pumpWidget(
        _wrapWithRouter(SearchFilterScreen(discoveryService: fake)),
      );

      await tester.pumpAndSettle();

      // Verify prompt before search
      expect(
        find.text(
          'Enter keywords or apply filters above to find services and verified professionals.',
        ),
        findsOneWidget,
      );

      // Enter search term and tap search icon
      await tester.enterText(find.byType(TextField), 'pipe');
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      // Results displayed
      expect(find.text('Pipe Replacement'), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('4.8 ★'), findsOneWidget);

      // Toggle filter chip
      await tester.tap(find.text('4.5+ rating'));
      await tester.pumpAndSettle();
    });
  });

  group('NearbyWorkersScreen', () {
    testWidgets('renders nearby workers with distance and rating', (
      tester,
    ) async {
      final fake = _FakeDiscoveryService();
      await tester.pumpWidget(
        _wrapWithRouter(NearbyWorkersScreen(discoveryService: fake)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Anita Sharma'), findsOneWidget);
      expect(find.text('Certified electrician · 2.1 km away'), findsOneWidget);
      expect(find.text('₹400/hr'), findsOneWidget);
      expect(find.text('4.9 ★'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);

      // Tap worker
      await tester.tap(find.text('Anita Sharma'));
      await tester.pumpAndSettle();

      expect(
        BookingFlowState.instance.selectedWorker?.fullName,
        'Anita Sharma',
      );
    });
  });
}
