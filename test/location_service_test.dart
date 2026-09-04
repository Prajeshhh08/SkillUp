import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:skillup/models/customer_address.dart';
import 'package:skillup/models/location_models.dart';
import 'package:skillup/screens/address_setup_screen.dart';
import 'package:skillup/screens/location_permission_screen.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/customer_service.dart';
import 'package:skillup/services/location_service.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient({this.throwError = false}) : super.custom(Dio());
  bool throwError;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (throwError) throw const ApiException('Reverse geocode failure');
    return {
      'formatted_address':
          '10th Main Rd, Indiranagar, Bengaluru, Karnataka 560038',
      'street_address': '10th Main Rd',
      'city': 'Bengaluru',
      'state': 'Karnataka',
      'postal_code': '560038',
      'latitude': queryParameters?['lat'] ?? 12.9716,
      'longitude': queryParameters?['lng'] ?? 77.5946,
    };
  }
}

class _FakeLocationService extends LocationService {
  _FakeLocationService({
    super.apiClient,
    this.permissionToReturn = LocationPermission.whileInUse,
    this.positionToReturn = const AppCoordinates(
      latitude: 12.9352,
      longitude: 77.6245,
    ),
    this.throwOnRequest = false,
  });

  LocationPermission permissionToReturn;
  AppCoordinates? positionToReturn;
  bool throwOnRequest;
  bool requestPermissionCalled = false;
  bool getCurrentPositionCalled = false;

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCalled = true;
    if (throwOnRequest) throw Exception('Simulated permission exception');
    return permissionToReturn;
  }

  @override
  Future<AppCoordinates?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    getCurrentPositionCalled = true;
    if (positionToReturn != null) {
      setKnownPosition(
        positionToReturn!.latitude,
        positionToReturn!.longitude,
      );
    }
    return positionToReturn;
  }
}

class _FakeCustomerService extends CustomerService {
  _FakeCustomerService() : super(client: _FakeApiClient());

  @override
  Future<List<CustomerAddress>> getAddresses() async => [];
}

void main() {
  group('Location Models Tests', () {
    test('ReverseGeocodeResult parses from and converts to JSON', () {
      final json = {
        'formatted_address': '123 Main St, Bengaluru',
        'street_address': '123 Main St',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'postal_code': '560001',
        'latitude': 12.9716,
        'longitude': 77.5946,
      };

      final result = ReverseGeocodeResult.fromJson(json);

      expect(result.formattedAddress, '123 Main St, Bengaluru');
      expect(result.streetAddress, '123 Main St');
      expect(result.city, 'Bengaluru');
      expect(result.state, 'Karnataka');
      expect(result.postalCode, '560001');
      expect(result.latitude, 12.9716);
      expect(result.longitude, 77.5946);

      final converted = result.toJson();
      expect(converted['formatted_address'], json['formatted_address']);
      expect(converted['street_address'], json['street_address']);
      expect(converted['city'], json['city']);
      expect(converted['latitude'], 12.9716);
    });

    test('AppCoordinates supports default Bengaluru and toString', () {
      const coords = AppCoordinates.defaultBengaluru;
      expect(coords.latitude, 12.9716);
      expect(coords.longitude, 77.5946);
      expect(coords.toString(), contains('12.9716'));
    });
  });

  group('LocationService Unit Tests', () {
    test('reverseGeocode parses successful response from API client', () async {
      final fakeApi = _FakeApiClient();
      final service = LocationService(apiClient: fakeApi);

      final result = await service.reverseGeocode(12.9716, 77.5946);

      expect(result, isNotNull);
      expect(result!.city, 'Bengaluru');
      expect(result.state, 'Karnataka');
      expect(result.postalCode, '560038');
      expect(result.streetAddress, '10th Main Rd');
    });

    test('reverseGeocode handles API error gracefully and returns null', () async {
      final fakeApi = _FakeApiClient(throwError: true);
      final service = LocationService(apiClient: fakeApi);

      final result = await service.reverseGeocode(12.9716, 77.5946);

      expect(result, isNull);
    });

    test('setKnownPosition caches coordinates in lastKnownPosition', () {
      final service = LocationService(apiClient: _FakeApiClient());
      expect(service.lastKnownPosition, isNull);

      service.setKnownPosition(13.0827, 80.2707); // Chennai
      expect(service.lastKnownPosition?.latitude, 13.0827);
      expect(service.lastKnownPosition?.longitude, 80.2707);
    });

    test('fallbackLocation returns default Bengaluru coordinates', () {
      final service = LocationService(apiClient: _FakeApiClient());
      expect(service.fallbackLocation.latitude, 12.9716);
      expect(service.fallbackLocation.longitude, 77.5946);
    });
  });

  group('LocationPermissionScreen Widget Tests', () {
    late _FakeLocationService fakeLocationService;

    setUp(() {
      fakeLocationService = _FakeLocationService();
      LocationService.instance = fakeLocationService;
      CustomerService.instance = _FakeCustomerService();
    });

    testWidgets('renders location graphic, description, allow, and skip buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LocationPermissionScreen(),
        ),
      );

      expect(find.text('Enable Location Services'), findsOneWidget);
      expect(find.text('Allow Location Access'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    });

    testWidgets('tapping Allow Location Access requests permission and navigates', (
      tester,
    ) async {
      var navigatedToRole = false;

      final testRouter = GoRouter(
        initialLocation: '/location-permission',
        routes: [
          GoRoute(
            path: '/location-permission',
            builder: (context, state) => const LocationPermissionScreen(),
          ),
          GoRoute(
            path: '/role',
            builder: (context, state) {
              navigatedToRole = true;
              return const Scaffold(body: Text('Role Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );

      await tester.tap(find.text('Allow Location Access'));
      await tester.pump(); // Start async request
      await tester.pumpAndSettle(); // Resolve navigation

      expect(fakeLocationService.requestPermissionCalled, isTrue);
      expect(navigatedToRole, isTrue);
      expect(find.text('Role Screen'), findsOneWidget);
    });

    testWidgets('tapping Skip for now navigates directly to role screen', (
      tester,
    ) async {
      var navigatedToRole = false;

      final testRouter = GoRouter(
        initialLocation: '/location-permission',
        routes: [
          GoRoute(
            path: '/location-permission',
            builder: (context, state) => const LocationPermissionScreen(),
          ),
          GoRoute(
            path: '/role',
            builder: (context, state) {
              navigatedToRole = true;
              return const Scaffold(body: Text('Role Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );

      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      expect(fakeLocationService.requestPermissionCalled, isFalse);
      expect(navigatedToRole, isTrue);
    });

    testWidgets('gracefully handles denied permission and still navigates', (
      tester,
    ) async {
      LocationService.instance = _FakeLocationService(
        permissionToReturn: LocationPermission.denied,
      );
      var navigatedToRole = false;

      final testRouter = GoRouter(
        initialLocation: '/location-permission',
        routes: [
          GoRoute(
            path: '/location-permission',
            builder: (context, state) => const LocationPermissionScreen(),
          ),
          GoRoute(
            path: '/role',
            builder: (context, state) {
              navigatedToRole = true;
              return const Scaffold(body: Text('Role Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: testRouter),
      );

      await tester.tap(find.text('Allow Location Access'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(navigatedToRole, isTrue);
    });

    testWidgets('gracefully handles permission exception and navigates', (
      tester,
    ) async {
      LocationService.instance = _FakeLocationService(
        throwOnRequest: true,
      );
      var navigatedToRole = false;

      final testRouter = GoRouter(
        initialLocation: '/location-permission',
        routes: [
          GoRoute(
            path: '/location-permission',
            builder: (context, state) => const LocationPermissionScreen(),
          ),
          GoRoute(
            path: '/role',
            builder: (context, state) {
              navigatedToRole = true;
              return const Scaffold(body: Text('Role Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: testRouter),
      );

      await tester.tap(find.text('Allow Location Access'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(navigatedToRole, isTrue);
    });
  });

  group('AddressSetupScreen Location Integration Tests', () {
    late _FakeLocationService fakeLocationService;

    setUp(() {
      final fakeApi = _FakeApiClient();
      fakeLocationService = _FakeLocationService(
        apiClient: fakeApi,
        positionToReturn: const AppCoordinates(
          latitude: 12.9352,
          longitude: 77.6245,
        ),
      );
      LocationService.instance = fakeLocationService;
      CustomerService.instance = _FakeCustomerService();
    });

    testWidgets('tapping Use current GPS location updates coordinates and fills address', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddressSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Use current GPS location'), findsOneWidget);

      await tester.tap(find.text('Use current GPS location'));
      await tester.pump(); // Starts locating
      await tester.pumpAndSettle(); // Finishes reverse geocoding and updates state

      expect(fakeLocationService.getCurrentPositionCalled, isTrue);
      // Coordinates text updated in UI
      expect(find.text('12.9352, 77.6245'), findsOneWidget);
      // Reverse geocoded street address populated
      expect(find.text('10th Main Rd'), findsOneWidget);
    });
  });
}
