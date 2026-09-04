import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/customer_address.dart';
import 'package:skillup/models/customer_profile.dart';

void main() {
  group('CustomerProfile model tests', () {
    test('parses json correctly with all fields', () {
      final json = {
        'user_id': '11111111-2222-3333-4444-555555555555',
        'full_name': 'Ravi Kumar',
        'email': 'ravi@example.com',
        'phone': '+919876543210',
        'avatar_url': 'https://example.com/avatar.jpg',
        'known_jobs': ['Plumbing', 'Carpentry'],
      };

      final profile = CustomerProfile.fromJson(json);

      expect(profile.userId, '11111111-2222-3333-4444-555555555555');
      expect(profile.fullName, 'Ravi Kumar');
      expect(profile.email, 'ravi@example.com');
      expect(profile.phone, '+919876543210');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.knownJobs, ['Plumbing', 'Carpentry']);
      expect(profile.initial, 'R');
    });

    test('handles null optional fields and computes initial fallback', () {
      final json = {
        'user_id': '22222222-3333-4444-5555-666666666666',
        'full_name': '',
        'phone': '+919876543211',
      };

      final profile = CustomerProfile.fromJson(json);

      expect(profile.fullName, '');
      expect(profile.email, isNull);
      expect(profile.avatarUrl, isNull);
      expect(profile.knownJobs, isEmpty);
      expect(profile.initial, 'S');
    });

    test('serializes to json', () {
      const profile = CustomerProfile(
        userId: 'abc',
        fullName: 'Anita Roy',
        phone: '+919999999999',
        email: 'anita@example.com',
      );

      final json = profile.toJson();
      expect(json['user_id'], 'abc');
      expect(json['full_name'], 'Anita Roy');
      expect(json['email'], 'anita@example.com');
      expect(json['phone'], '+919999999999');
      expect(json.containsKey('avatar_url'), isFalse);
    });
  });

  group('CustomerMetrics model tests', () {
    test('parses metrics json correctly', () {
      final json = {'order_acceptance_percentage': 95.5, 'booking_totals': 12};

      final metrics = CustomerMetrics.fromJson(json);
      expect(metrics.orderAcceptancePercentage, 95.5);
      expect(metrics.bookingTotals, 12);
    });

    test('handles missing or default values', () {
      final metrics = CustomerMetrics.fromJson({});
      expect(metrics.orderAcceptancePercentage, 100.0);
      expect(metrics.bookingTotals, 0);
    });
  });

  group('CustomerAddress model tests', () {
    test('parses address json correctly and computes formatted strings', () {
      final json = {
        'id': 'addr-123',
        'customer_id': 'cust-456',
        'label': 'Home',
        'street_address': '123 MG Road',
        'apartment_unit': 'Apt 4B',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'postal_code': '560001',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'is_default': true,
        'created_at': '2026-09-04T10:00:00Z',
      };

      final address = CustomerAddress.fromJson(json);

      expect(address.id, 'addr-123');
      expect(address.customerId, 'cust-456');
      expect(address.label, 'Home');
      expect(address.streetAddress, '123 MG Road');
      expect(address.apartmentUnit, 'Apt 4B');
      expect(address.city, 'Bengaluru');
      expect(address.state, 'Karnataka');
      expect(address.postalCode, '560001');
      expect(address.latitude, 12.9716);
      expect(address.longitude, 77.5946);
      expect(address.isDefault, isTrue);
      expect(address.createdAt, isNotNull);

      expect(address.shortLine, 'Apt 4B, 123 MG Road');
      expect(
        address.fullDisplayLine,
        'Apt 4B, 123 MG Road, Bengaluru, Karnataka, 560001',
      );
    });

    test('shortLine when apartment_unit is null or empty', () {
      final address = CustomerAddress.fromJson({
        'id': '1',
        'customer_id': '2',
        'label': 'Work',
        'street_address': '742 Evergreen Terrace',
        'city': 'Bengaluru',
        'state': 'Karnataka',
        'postal_code': '560001',
        'latitude': 12.0,
        'longitude': 77.0,
        'is_default': false,
      });

      expect(address.shortLine, '742 Evergreen Terrace');
      expect(
        address.fullDisplayLine,
        '742 Evergreen Terrace, Bengaluru, Karnataka, 560001',
      );
    });

    test('AddressCreatePayload serializes correctly', () {
      const payload = AddressCreatePayload(
        label: 'Work',
        streetAddress: 'Outer Ring Road',
        apartmentUnit: 'Tower 2, Floor 5',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560103',
        latitude: 12.9352,
        longitude: 77.6946,
        isDefault: false,
      );

      final map = payload.toJson();
      expect(map['label'], 'Work');
      expect(map['street_address'], 'Outer Ring Road');
      expect(map['apartment_unit'], 'Tower 2, Floor 5');
      expect(map['city'], 'Bengaluru');
      expect(map['state'], 'Karnataka');
      expect(map['postal_code'], '560103');
      expect(map['latitude'], 12.9352);
      expect(map['longitude'], 77.6946);
      expect(map['is_default'], isFalse);
    });

    test('AddressUpdatePayload serializes only provided fields', () {
      const payload = AddressUpdatePayload(label: 'Office', isDefault: true);

      final map = payload.toJson();
      expect(map['label'], 'Office');
      expect(map['is_default'], isTrue);
      expect(map.containsKey('street_address'), isFalse);
      expect(map.containsKey('city'), isFalse);
    });
  });
}
