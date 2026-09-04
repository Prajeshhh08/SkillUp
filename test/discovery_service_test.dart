import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/discovery_service.dart';

void main() {
  group('DiscoveryService tests', () {
    test(
      'getCategories calls /categories and returns parsed categories',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/categories');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': '11111111-1111-1111-1111-111111111111',
                      'name': 'Plumbing',
                      'slug': 'plumbing',
                      'description': 'Pipe repair',
                      'is_active': true,
                    },
                    {
                      'id': '22222222-2222-2222-2222-222222222222',
                      'name': 'Electrical',
                      'slug': 'electrical',
                      'is_active': true,
                    },
                  ],
                ),
              );
            },
          ),
        );

        final service = DiscoveryService(client: ApiClient.custom(dio));
        final categories = await service.getCategories();

        expect(categories.length, 2);
        expect(categories[0].name, 'Plumbing');
        expect(categories[1].name, 'Electrical');
      },
    );

    test(
      'getServices passes categoryId query parameter and parses services',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/services');
              expect(
                options.queryParameters['categoryId'],
                '11111111-1111-1111-1111-111111111111',
              );
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 'a1111111-1111-1111-1111-111111111111',
                      'category_id': '11111111-1111-1111-1111-111111111111',
                      'title': 'Tap & Leak Repair',
                      'base_price': 299.0,
                      'price_unit': 'FLAT',
                      'estimated_duration_mins': 45,
                      'inclusions': ['Inspection', 'Washer replacement'],
                    },
                  ],
                ),
              );
            },
          ),
        );

        final service = DiscoveryService(client: ApiClient.custom(dio));
        final services = await service.getServices(
          categoryId: '11111111-1111-1111-1111-111111111111',
        );

        expect(services.length, 1);
        expect(services[0].title, 'Tap & Leak Repair');
        expect(services[0].basePrice, 299.0);
        expect(services[0].inclusions.length, 2);
      },
    );

    test(
      'getServiceDetails calls /services/{id} and returns service',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.path, '/services/service-abc');
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'id': 'service-abc',
                    'category_id': 'cat-1',
                    'title': 'Water Heater Install',
                    'base_price': 799.0,
                    'price_unit': 'FLAT',
                    'estimated_duration_mins': 90,
                    'inclusions': ['Safety wiring', 'Mounting bracket'],
                  },
                ),
              );
            },
          ),
        );

        final service = DiscoveryService(client: ApiClient.custom(dio));
        final details = await service.getServiceDetails('service-abc');

        expect(details.id, 'service-abc');
        expect(details.title, 'Water Heater Install');
        expect(details.basePrice, 799.0);
      },
    );

    test('search passes query and filters to /search', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/search');
            expect(options.queryParameters['q'], 'plumber');
            expect(options.queryParameters['rating'], 4.5);
            expect(options.queryParameters['distance'], 5.0);
            expect(options.queryParameters['availableNow'], true);
            expect(options.queryParameters['maxPrice'], 500.0);

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'services': [
                    {
                      'id': 's1',
                      'category_id': 'c1',
                      'title': 'Emergency Plumbing',
                      'base_price': 499.0,
                    },
                  ],
                  'workers': [
                    {
                      'worker_id': 'w1',
                      'full_name': 'Ravi Kumar',
                      'average_rating': 4.8,
                      'total_reviews': 30,
                    },
                  ],
                  'total_results': 2,
                },
              ),
            );
          },
        ),
      );

      final service = DiscoveryService(client: ApiClient.custom(dio));
      final result = await service.search(
        query: 'plumber',
        minRating: 4.5,
        maxDistance: 5.0,
        availableNow: true,
        maxPrice: 500.0,
      );

      expect(result.totalResults, 2);
      expect(result.services.first.title, 'Emergency Plumbing');
      expect(result.workers.first.fullName, 'Ravi Kumar');
    });

    test('getNearbyWorkers passes coordinates to /workers/nearby', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/workers/nearby');
            expect(options.queryParameters['lat'], 12.9716);
            expect(options.queryParameters['lng'], 77.5946);
            expect(options.queryParameters['serviceId'], 'svc-999');

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'workers': [
                    {
                      'worker_id': 'w-1',
                      'full_name': 'Anita Sharma',
                      'hourly_rate': 400.0,
                      'average_rating': 4.9,
                      'distance_km': 1.8,
                      'latitude': 12.98,
                      'longitude': 77.60,
                      'is_available': true,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final service = DiscoveryService(client: ApiClient.custom(dio));
      final workers = await service.getNearbyWorkers(
        latitude: 12.9716,
        longitude: 77.5946,
        serviceId: 'svc-999',
      );

      expect(workers.length, 1);
      expect(workers[0].fullName, 'Anita Sharma');
      expect(workers[0].distanceKm, 1.8);
      expect(workers[0].hourlyRate, 400.0);
    });
  });
}
