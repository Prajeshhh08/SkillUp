import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/booking_model.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/booking_service.dart';

void main() {
  group('BookingService tests', () {
    test(
      'calculateQuote posts to /bookings/quote and parses QuoteModel',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/bookings/quote');
              expect(options.data['service_id'], 'svc-1');
              expect(options.data['address_id'], 'addr-1');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'service_id': 'svc-1',
                    'service_title': 'Ceiling Fan Installation',
                    'base_price': 349.0,
                    'distance_km': 1.5,
                    'distance_fee': 30.0,
                    'emergency_fee': 0.0,
                    'tax_amount': 68.22,
                    'total_quoted_price': 447.22,
                    'estimated_duration_mins': 60,
                  },
                ),
              );
            },
          ),
        );

        final service = BookingService(client: ApiClient.custom(dio));
        final quote = await service.calculateQuote(
          const QuoteRequestPayload(serviceId: 'svc-1', addressId: 'addr-1'),
        );

        expect(quote.serviceTitle, 'Ceiling Fan Installation');
        expect(quote.totalQuotedPrice, 447.22);
      },
    );

    test('createBooking posts to /bookings and returns BookingModel', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/bookings');
            expect(options.data['service_id'], 'svc-1');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'id': 'bk-new-1',
                  'booking_reference': 'SK-2026-12345',
                  'customer_id': 'cust-1',
                  'service_id': 'svc-1',
                  'address_id': 'addr-1',
                  'status': 'PENDING',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-05T10:00:00Z',
                  'quoted_price': 349.0,
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:00:00Z',
                  'service_title': 'Ceiling Fan Installation',
                },
              ),
            );
          },
        ),
      );

      final service = BookingService(client: ApiClient.custom(dio));
      final booking = await service.createBooking(
        BookingCreatePayload(
          serviceId: 'svc-1',
          addressId: 'addr-1',
          scheduledAt: DateTime.utc(2026, 9, 5, 10, 0),
        ),
      );

      expect(booking.id, 'bk-new-1');
      expect(booking.bookingReference, 'SK-2026-12345');
      expect(booking.status, 'PENDING');
      expect(booking.isActive, isTrue);
    });

    test(
      'getCustomerBookings fetches from /bookings with optional filter',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/bookings');
              expect(options.queryParameters['status'], 'COMPLETED');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 'bk-comp-1',
                      'booking_reference': 'SK-2026-00001',
                      'customer_id': 'cust-1',
                      'service_id': 'svc-1',
                      'address_id': 'addr-1',
                      'status': 'COMPLETED',
                      'is_emergency': false,
                      'scheduled_at': '2026-09-01T10:00:00Z',
                      'quoted_price': 299.0,
                      'created_at': '2026-09-01T08:00:00Z',
                      'updated_at': '2026-09-01T11:00:00Z',
                    },
                  ],
                ),
              );
            },
          ),
        );

        final service = BookingService(client: ApiClient.custom(dio));
        final bookings = await service.getCustomerBookings(status: 'COMPLETED');

        expect(bookings.length, 1);
        expect(bookings.first.id, 'bk-comp-1');
        expect(bookings.first.isCompleted, isTrue);
      },
    );

    test('cancelBooking posts to /bookings/{id}/cancel with reason', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/bookings/bk-1/cancel');
            expect(options.data['reason'], 'Need to reschedule');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'bk-1',
                  'booking_reference': 'SK-2026-12345',
                  'customer_id': 'cust-1',
                  'service_id': 'svc-1',
                  'address_id': 'addr-1',
                  'status': 'CANCELLED',
                  'cancellation_reason': 'Need to reschedule',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-05T10:00:00Z',
                  'quoted_price': 299.0,
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:10:00Z',
                },
              ),
            );
          },
        ),
      );

      final service = BookingService(client: ApiClient.custom(dio));
      final cancelled = await service.cancelBooking(
        'bk-1',
        'Need to reschedule',
      );

      expect(cancelled.status, 'CANCELLED');
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.cancellationReason, 'Need to reschedule');
    });

    test('rescheduleBooking posts to /bookings/{id}/reschedule', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/bookings/bk-1/reschedule');
            expect(options.data['new_scheduled_at'], isNotNull);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'bk-1',
                  'booking_reference': 'SK-2026-12345',
                  'customer_id': 'cust-1',
                  'service_id': 'svc-1',
                  'address_id': 'addr-1',
                  'status': 'CONFIRMED',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-08T14:00:00Z',
                  'quoted_price': 299.0,
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:15:00Z',
                },
              ),
            );
          },
        ),
      );

      final service = BookingService(client: ApiClient.custom(dio));
      final updated = await service.rescheduleBooking(
        'bk-1',
        DateTime.utc(2026, 9, 8, 14, 0),
      );

      expect(updated.scheduledAt, DateTime.utc(2026, 9, 8, 14, 0));
    });

    test(
      'getBookingTracking returns tracking timeline and worker info',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/bookings/bk-1/tracking');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'booking_id': 'bk-1',
                    'booking_reference': 'SK-2026-12345',
                    'status': 'ON_THE_WAY',
                    'scheduled_at': '2026-09-05T10:00:00Z',
                    'worker_name': 'Ravi Kumar',
                    'worker_phone': '+919876543210',
                    'eta_minutes': 15,
                    'timeline': [
                      {
                        'status': 'CONFIRMED',
                        'timestamp': '2026-09-05T09:30:00Z',
                      },
                      {
                        'status': 'ON_THE_WAY',
                        'timestamp': '2026-09-05T09:45:00Z',
                      },
                    ],
                  },
                ),
              );
            },
          ),
        );

        final service = BookingService(client: ApiClient.custom(dio));
        final tracking = await service.getBookingTracking('bk-1');

        expect(tracking.status, 'ON_THE_WAY');
        expect(tracking.workerName, 'Ravi Kumar');
        expect(tracking.etaMinutes, 15);
        expect(tracking.timeline.length, 2);
      },
    );

    test('createReview posts review to /bookings/{id}/review', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/bookings/bk-1/review');
            expect(options.data['rating'], 5);
            expect(options.data['badges'], ['Punctual', 'Clean Work']);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'id': 'rev-1',
                  'booking_id': 'bk-1',
                  'customer_id': 'cust-1',
                  'worker_id': 'wrk-1',
                  'rating': 5,
                  'comment': 'Great job!',
                  'badges': ['Punctual', 'Clean Work'],
                },
              ),
            );
          },
        ),
      );

      final service = BookingService(client: ApiClient.custom(dio));
      final review = await service.createReview(
        'bk-1',
        const ReviewCreatePayload(
          rating: 5,
          comment: 'Great job!',
          badges: ['Punctual', 'Clean Work'],
        ),
      );

      expect(review.rating, 5);
      expect(review.comment, 'Great job!');
    });

    test('getInvoice fetches invoice from /bookings/{id}/invoice', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/bookings/bk-1/invoice');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'invoice_number': 'INV-SK-2026-12345',
                  'booking_reference': 'SK-2026-12345',
                  'issued_at': '2026-09-05T11:00:00Z',
                  'customer_name': 'Aarav Sharma',
                  'worker_name': 'Ravi Kumar',
                  'service_title': 'Tap & Leak Repair',
                  'items': [
                    {'description': 'Service Charge', 'amount': 299.0},
                  ],
                  'subtotal': 299.0,
                  'tax_amount': 53.82,
                  'total_amount': 352.82,
                  'download_url': 'https://api.skillup.com/invoices/1.pdf',
                },
              ),
            );
          },
        ),
      );

      final service = BookingService(client: ApiClient.custom(dio));
      final invoice = await service.getInvoice('bk-1');

      expect(invoice.invoiceNumber, 'INV-SK-2026-12345');
      expect(invoice.totalAmount, 352.82);
    });
  });
}
