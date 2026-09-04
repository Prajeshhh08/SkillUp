import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/worker_profile.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/worker_service.dart';

void main() {
  group('WorkerMetrics model tests', () {
    test('WorkerMetrics parses from JSON correctly', () {
      final json = {
        'acceptance_rate': 0.95,
        'completed_jobs': 42,
        'total_earnings': 15800.5,
        'average_rating': 4.85,
      };

      final metrics = WorkerMetrics.fromJson(json);

      expect(metrics.acceptanceRate, 0.95);
      expect(metrics.completedJobs, 42);
      expect(metrics.totalEarnings, 15800.5);
      expect(metrics.averageRating, 4.85);
    });

    test('WorkerMetrics serializes to JSON correctly', () {
      const metrics = WorkerMetrics(
        acceptanceRate: 0.88,
        completedJobs: 15,
        totalEarnings: 6200.0,
        averageRating: 4.7,
      );

      final json = metrics.toJson();

      expect(json['acceptance_rate'], 0.88);
      expect(json['completed_jobs'], 15);
      expect(json['total_earnings'], 6200.0);
      expect(json['average_rating'], 4.7);
    });

    test('WorkerMetrics handles default/null fields gracefully', () {
      final metrics = WorkerMetrics.fromJson({});

      expect(metrics.acceptanceRate, 0.0);
      expect(metrics.completedJobs, 0);
      expect(metrics.totalEarnings, 0.0);
      expect(metrics.averageRating, 0.0);
    });
  });

  group('WorkerService job operations tests', () {
    test('getWorkerBookings fetches and parses bookings list', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/worker/bookings');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'id': 'bk-1',
                    'booking_reference': 'BK-2026-00001',
                    'customer_id': 'cust-1',
                    'service_id': 'svc-1',
                    'address_id': 'addr-1',
                    'status': 'PENDING',
                    'is_emergency': false,
                    'scheduled_at': '2026-09-05T10:00:00Z',
                    'quoted_price': 499.0,
                    'created_at': '2026-09-04T12:00:00Z',
                    'updated_at': '2026-09-04T12:00:00Z',
                    'service_title': 'Plumbing Repair',
                  },
                ],
              ),
            );
          },
        ),
      );

      final service = WorkerService(client: ApiClient.custom(dio));
      final jobs = await service.getWorkerBookings();

      expect(jobs.length, 1);
      expect(jobs.first.id, 'bk-1');
      expect(jobs.first.bookingReference, 'BK-2026-00001');
      expect(jobs.first.status, 'PENDING');
      expect(jobs.first.serviceTitle, 'Plumbing Repair');
    });

    test('getWorkerBookings passes status query parameter', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/worker/bookings');
            expect(options.queryParameters['status'], 'CONFIRMED');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [],
              ),
            );
          },
        ),
      );

      final service = WorkerService(client: ApiClient.custom(dio));
      final jobs = await service.getWorkerBookings(status: 'CONFIRMED');
      expect(jobs, isEmpty);
    });

    test('acceptBooking posts to /worker/bookings/{id}/accept', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/worker/bookings/bk-1/accept');
            expect(options.method, 'POST');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'bk-1',
                  'booking_reference': 'BK-2026-00001',
                  'customer_id': 'cust-1',
                  'worker_id': 'wrk-1',
                  'service_id': 'svc-1',
                  'address_id': 'addr-1',
                  'status': 'CONFIRMED',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-05T10:00:00Z',
                  'quoted_price': 499.0,
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:05:00Z',
                  'service_title': 'Plumbing Repair',
                },
              ),
            );
          },
        ),
      );

      final service = WorkerService(client: ApiClient.custom(dio));
      final booking = await service.acceptBooking('bk-1');

      expect(booking.status, 'CONFIRMED');
      expect(booking.workerId, 'wrk-1');
    });

    test('declineBooking posts to /worker/bookings/{id}/decline', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/worker/bookings/bk-1/decline');
            expect(options.method, 'POST');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'bk-1',
                  'booking_reference': 'BK-2026-00001',
                  'customer_id': 'cust-1',
                  'service_id': 'svc-1',
                  'address_id': 'addr-1',
                  'status': 'REJECTED',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-05T10:00:00Z',
                  'quoted_price': 499.0,
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:05:00Z',
                },
              ),
            );
          },
        ),
      );

      final service = WorkerService(client: ApiClient.custom(dio));
      final booking = await service.declineBooking('bk-1');

      expect(booking.status, 'REJECTED');
    });

    test('updateJobStatus patches /worker/bookings/{id}/status', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/worker/bookings/bk-1/status');
            expect(options.method, 'PATCH');
            expect(options.data['status'], 'ON_THE_WAY');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'bk-1',
                  'booking_reference': 'BK-2026-00001',
                  'customer_id': 'cust-1',
                  'worker_id': 'wrk-1',
                  'service_id': 'svc-1',
                  'address_id': 'addr-1',
                  'status': 'ON_THE_WAY',
                  'is_emergency': false,
                  'scheduled_at': '2026-09-05T10:00:00Z',
                  'quoted_price': 499.0,
                  'created_at': '2026-09-04T12:00:00Z',
                  'updated_at': '2026-09-04T12:10:00Z',
                },
              ),
            );
          },
        ),
      );

      final service = WorkerService(client: ApiClient.custom(dio));
      final booking = await service.updateJobStatus('bk-1', 'ON_THE_WAY');

      expect(booking.status, 'ON_THE_WAY');
    });

    test('getMetrics calls /worker/metrics and parses WorkerMetrics', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/worker/metrics');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'acceptance_rate': 0.92,
                  'completed_jobs': 28,
                  'total_earnings': 12400.0,
                  'average_rating': 4.9,
                },
              ),
            );
          },
        ),
      );

      final service = WorkerService(client: ApiClient.custom(dio));
      final metrics = await service.getMetrics();

      expect(metrics.acceptanceRate, 0.92);
      expect(metrics.completedJobs, 28);
      expect(metrics.totalEarnings, 12400.0);
      expect(metrics.averageRating, 4.9);
    });
  });
}
