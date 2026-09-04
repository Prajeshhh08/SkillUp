import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/booking_model.dart';

void main() {
  group('QuoteModel tests', () {
    test('parses QuoteModel from JSON', () {
      final json = {
        'service_id': 'svc-1',
        'service_title': 'Tap & Leak Repair',
        'base_price': 299.0,
        'distance_km': 2.4,
        'distance_fee': 48.0,
        'emergency_fee': 0.0,
        'tax_amount': 62.46,
        'total_quoted_price': 409.46,
        'estimated_duration_mins': 45,
      };

      final quote = QuoteModel.fromJson(json);

      expect(quote.serviceId, 'svc-1');
      expect(quote.serviceTitle, 'Tap & Leak Repair');
      expect(quote.basePrice, 299.0);
      expect(quote.distanceKm, 2.4);
      expect(quote.distanceFee, 48.0);
      expect(quote.emergencyFee, 0.0);
      expect(quote.taxAmount, 62.46);
      expect(quote.totalQuotedPrice, 409.46);
      expect(quote.estimatedDurationMins, 45);
    });

    test('QuoteRequestPayload serializes correctly', () {
      const payload = QuoteRequestPayload(
        serviceId: 's1',
        addressId: 'a1',
        isEmergency: true,
      );

      final json = payload.toJson();
      expect(json['service_id'], 's1');
      expect(json['address_id'], 'a1');
      expect(json['is_emergency'], true);
    });
  });

  group('BookingModel tests', () {
    test('parses BookingModel from JSON and calculates status helpers', () {
      final json = {
        'id': 'bk-uuid-1',
        'booking_reference': 'SK-2026-98765',
        'customer_id': 'cust-1',
        'worker_id': 'wrk-1',
        'service_id': 'svc-1',
        'address_id': 'addr-1',
        'status': 'CONFIRMED',
        'is_emergency': false,
        'scheduled_at': '2026-09-05T10:00:00Z',
        'notes': 'Ring doorbell',
        'quoted_price': 350.0,
        'final_price': 350.0,
        'created_at': '2026-09-04T12:00:00Z',
        'updated_at': '2026-09-04T12:05:00Z',
        'service_title': 'Tap & Leak Repair',
        'worker_name': 'Ravi Kumar',
        'address_text': 'Flat 4B, 100 MG Road',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.id, 'bk-uuid-1');
      expect(booking.bookingReference, 'SK-2026-98765');
      expect(booking.status, 'CONFIRMED');
      expect(booking.isActive, isTrue);
      expect(booking.isCompleted, isFalse);
      expect(booking.isCancelled, isFalse);
      expect(booking.serviceTitle, 'Tap & Leak Repair');
      expect(booking.workerName, 'Ravi Kumar');
      expect(booking.quotedPrice, 350.0);
      expect(booking.notes, 'Ring doorbell');
    });

    test('BookingCreatePayload serializes correctly', () {
      final payload = BookingCreatePayload(
        serviceId: 's1',
        addressId: 'a1',
        workerId: 'w1',
        scheduledAt: DateTime.utc(2026, 9, 5, 14, 30),
        notes: 'Ground floor',
        isEmergency: false,
      );

      final json = payload.toJson();
      expect(json['service_id'], 's1');
      expect(json['address_id'], 'a1');
      expect(json['worker_id'], 'w1');
      expect(json['scheduled_at'], '2026-09-05T14:30:00.000Z');
      expect(json['notes'], 'Ground floor');
      expect(json['is_emergency'], false);
    });
  });

  group('BookingTrackingModel tests', () {
    test('parses tracking model and timeline items', () {
      final json = {
        'booking_id': 'bk-1',
        'booking_reference': 'SK-2026-11111',
        'status': 'ON_THE_WAY',
        'scheduled_at': '2026-09-05T09:00:00Z',
        'worker_id': 'wrk-1',
        'worker_name': 'Ravi Kumar',
        'worker_phone': '+919876543210',
        'worker_latitude': 12.9716,
        'worker_longitude': 77.5946,
        'eta_minutes': 15,
        'timeline': [
          {'status': 'CONFIRMED', 'timestamp': '2026-09-04T12:00:00Z'},
          {'status': 'ON_THE_WAY', 'timestamp': '2026-09-04T12:15:00Z'},
        ],
      };

      final tracking = BookingTrackingModel.fromJson(json);

      expect(tracking.bookingId, 'bk-1');
      expect(tracking.bookingReference, 'SK-2026-11111');
      expect(tracking.status, 'ON_THE_WAY');
      expect(tracking.workerName, 'Ravi Kumar');
      expect(tracking.workerPhone, '+919876543210');
      expect(tracking.etaMinutes, 15);
      expect(tracking.timeline.length, 2);
      expect(tracking.timeline[0].status, 'CONFIRMED');
      expect(tracking.timeline[1].status, 'ON_THE_WAY');
    });
  });

  group('Review and Invoice models', () {
    test('parses ReviewModel correctly', () {
      final json = {
        'id': 'rev-1',
        'booking_id': 'bk-1',
        'customer_id': 'cust-1',
        'worker_id': 'wrk-1',
        'rating': 5,
        'comment': 'Prompt and professional!',
        'badges': ['Punctual', 'Clean Work'],
        'customer_name': 'Aarav Sharma',
      };

      final review = ReviewModel.fromJson(json);

      expect(review.id, 'rev-1');
      expect(review.rating, 5);
      expect(review.comment, 'Prompt and professional!');
      expect(review.badges, ['Punctual', 'Clean Work']);
      expect(review.customerName, 'Aarav Sharma');
    });

    test('parses InvoiceModel correctly', () {
      final json = {
        'invoice_number': 'INV-SK-2026-1234',
        'booking_reference': 'SK-2026-1234',
        'issued_at': '2026-09-04T12:30:00Z',
        'customer_name': 'Aarav Sharma',
        'worker_name': 'Ravi Kumar',
        'service_title': 'Tap & Leak Repair',
        'items': [
          {'description': 'Service Charge', 'amount': 299.0},
          {'description': 'GST (18%)', 'amount': 53.82},
        ],
        'subtotal': 299.0,
        'tax_amount': 53.82,
        'total_amount': 352.82,
        'download_url': 'https://api.skillup.com/invoices/inv-1.pdf',
      };

      final invoice = InvoiceModel.fromJson(json);

      expect(invoice.invoiceNumber, 'INV-SK-2026-1234');
      expect(invoice.customerName, 'Aarav Sharma');
      expect(invoice.items.length, 2);
      expect(invoice.subtotal, 299.0);
      expect(invoice.taxAmount, 53.82);
      expect(invoice.totalAmount, 352.82);
    });
  });
}
