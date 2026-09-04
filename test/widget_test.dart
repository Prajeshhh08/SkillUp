import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/main.dart';
import 'package:skillup/models/customer_address.dart';
import 'package:skillup/models/customer_profile.dart';
import 'package:skillup/screens/address_setup_screen.dart';
import 'package:skillup/services/customer_service.dart';

class _FakeCustomerService extends CustomerService {
  @override
  Future<List<CustomerAddress>> getAddresses() async => [];

  @override
  Future<CustomerAddress> createAddress(AddressCreatePayload payload) async {
    return CustomerAddress(
      id: 'mock-addr-id',
      customerId: 'mock-cust-id',
      label: payload.label,
      streetAddress: payload.streetAddress,
      apartmentUnit: payload.apartmentUnit,
      city: payload.city,
      state: payload.state,
      postalCode: payload.postalCode,
      latitude: payload.latitude,
      longitude: payload.longitude,
      isDefault: payload.isDefault,
    );
  }

  @override
  Future<CustomerProfile> getProfile() async {
    return const CustomerProfile(
      userId: 'mock-id',
      fullName: 'Test User',
      phone: '+919876543210',
      email: 'test@example.com',
    );
  }

  @override
  Future<CustomerMetrics> getMetrics() async {
    return const CustomerMetrics();
  }
}

void main() {
  setUp(() {
    CustomerService.instance = _FakeCustomerService();
  });

  testWidgets('SkillUpApp 8-screen onboarding flow test', (
    WidgetTester tester,
  ) async {
    // 1. Launch App & verify Splash Screen
    await tester.pumpWidget(const SkillUpApp());
    expect(find.text('SkillUp'), findsOneWidget);
    expect(find.text('Empowering cooperative work.'), findsOneWidget);

    // 2. Advance past splash screen timer to Language Selection
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('Tamil'), findsOneWidget);
    expect(find.text('Hindi'), findsOneWidget);

    // Tap Continue on Language Selection -> Screen 3 (Onboarding 1)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Verified Workers'), findsOneWidget);
    expect(find.text('100% Vetted'), findsOneWidget);

    // Tap Next -> Screen 4 (Onboarding 2)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Fair Wages'), findsOneWidget);
    expect(find.text('Direct Payouts'), findsOneWidget);

    // Tap Next -> Screen 5 (Onboarding 3)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('SkillUp Welfare'), findsOneWidget);
    expect(find.text('Member Benefits'), findsOneWidget);

    // Tap Get Started -> Screen 6 (Location Permission)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Enable Location Services'), findsOneWidget);
    expect(find.text('Allow Location Access'), findsOneWidget);

    // Tap Allow Location Access -> Screen 7 (Role Selection)
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Allow Location Access'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('How will you use SkillUp?'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Worker'), findsOneWidget);

    // Select Role -> Continue to Worker Signup
    await tester.tap(find.text('Worker'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pumpAndSettle();
    // Verify Worker Signup Screen is reached
    expect(find.text('Start your professional journey'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('AddressSetupScreen renders, validates, and saves address', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddressSetupScreen()));
    await tester.pumpAndSettle();

    // Verify Address Setup Screen
    expect(find.text('Set Your Location'), findsOneWidget);
    expect(find.text('Save & Finish Setup'), findsOneWidget);

    // Tap Save & Finish Setup -> Displays Setup Complete modal
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Save & Finish Setup'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Setup Complete!'), findsOneWidget);
    expect(find.text('Start Exploring'), findsOneWidget);
  });
}
