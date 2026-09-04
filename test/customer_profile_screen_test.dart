import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/customer_address.dart';
import 'package:skillup/models/customer_profile.dart';
import 'package:skillup/screens/customer_profile_screen.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/customer_service.dart';

class _MockCustomerService extends CustomerService {
  _MockCustomerService({this.throwError = false});
  final bool throwError;

  @override
  Future<CustomerProfile> getProfile() async {
    if (throwError) {
      throw const ApiException('Network timeout while loading profile.');
    }
    return const CustomerProfile(
      userId: 'test-user-id',
      fullName: 'Aarav Sharma',
      phone: '+919876543210',
      email: 'aarav@example.com',
    );
  }

  @override
  Future<CustomerMetrics> getMetrics() async {
    if (throwError) {
      throw const ApiException('Network timeout while loading metrics.');
    }
    return const CustomerMetrics(
      bookingTotals: 5,
      orderAcceptancePercentage: 98.0,
    );
  }

  @override
  Future<List<CustomerAddress>> getAddresses() async {
    if (throwError) {
      throw const ApiException('Network timeout while loading addresses.');
    }
    return [
      CustomerAddress(
        id: 'addr-1',
        customerId: 'test-user-id',
        label: 'Home',
        streetAddress: '100 MG Road',
        apartmentUnit: 'Flat 3A',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560001',
        latitude: 12.9716,
        longitude: 77.5946,
        isDefault: true,
      ),
    ];
  }
}

void main() {
  testWidgets(
    'CustomerProfileScreen loads and displays profile, metrics, and address',
    (tester) async {
      CustomerService.instance = _MockCustomerService();

      await tester.pumpWidget(const MaterialApp(home: CustomerProfileScreen()));

      // Initial loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify loaded content
      expect(find.text('Aarav Sharma'), findsNWidgets(2)); // Title & detail row
      expect(find.text('aarav@example.com'), findsOneWidget);
      expect(find.text('+919876543210'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // Total bookings
      expect(find.text('98%'), findsOneWidget); // Acceptance rate
      expect(
        find.text('Home'),
        findsNWidgets(2),
      ); // Address label & dashboard navigation tab
      expect(find.text('Flat 3A, 100 MG Road'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('View booking history'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    },
  );

  testWidgets(
    'CustomerProfileScreen shows error message and retry button on failure',
    (tester) async {
      CustomerService.instance = _MockCustomerService(throwError: true);

      await tester.pumpWidget(const MaterialApp(home: CustomerProfileScreen()));

      await tester.pumpAndSettle();

      expect(
        find.text('Network timeout while loading profile.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    },
  );
}
