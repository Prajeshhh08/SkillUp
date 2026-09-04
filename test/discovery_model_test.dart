import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/booking_flow_state.dart';
import 'package:skillup/models/service_model.dart';
import 'package:skillup/models/skill_category.dart';

void main() {
  group('ServiceModel', () {
    test('parses from JSON correctly', () {
      final json = {
        'id': 'a1111111-1111-1111-1111-111111111111',
        'category_id': '11111111-1111-1111-1111-111111111111',
        'title': 'Tap & Leak Repair',
        'description': 'Fix dripping faucets and pipe leaks.',
        'base_price': 299.0,
        'price_unit': 'FLAT',
        'estimated_duration_mins': 45,
        'inclusions': ['Inspection', 'Washer replacement'],
        'is_active': true,
      };

      final service = ServiceModel.fromJson(json);

      expect(service.id, 'a1111111-1111-1111-1111-111111111111');
      expect(service.categoryId, '11111111-1111-1111-1111-111111111111');
      expect(service.title, 'Tap & Leak Repair');
      expect(service.description, 'Fix dripping faucets and pipe leaks.');
      expect(service.basePrice, 299.0);
      expect(service.priceUnit, 'FLAT');
      expect(service.estimatedDurationMins, 45);
      expect(service.inclusions, ['Inspection', 'Washer replacement']);
      expect(service.isActive, isTrue);

      final outJson = service.toJson();
      expect(outJson['title'], 'Tap & Leak Repair');
      expect(outJson['base_price'], 299.0);
    });

    test('handles default values in JSON', () {
      final json = {
        'id': 'a111',
        'category_id': 'c111',
        'title': 'Basic visit',
        'base_price': 150,
      };

      final service = ServiceModel.fromJson(json);

      expect(service.priceUnit, 'FLAT');
      expect(service.estimatedDurationMins, 60);
      expect(service.inclusions, isEmpty);
      expect(service.isActive, isTrue);
    });
  });

  group('WorkerSearchItem and SearchResult', () {
    test('parses SearchResult with services and workers', () {
      final json = {
        'services': [
          {
            'id': 's1',
            'category_id': 'c1',
            'title': 'Fan Repair',
            'base_price': 349.0,
          },
        ],
        'workers': [
          {
            'worker_id': 'w1',
            'full_name': 'Ravi Kumar',
            'bio': 'Experienced plumber',
            'hourly_rate': 350.0,
            'average_rating': 4.8,
            'total_reviews': 24,
            'is_available': true,
          },
        ],
        'total_results': 2,
      };

      final result = SearchResult.fromJson(json);

      expect(result.totalResults, 2);
      expect(result.services.length, 1);
      expect(result.services.first.title, 'Fan Repair');
      expect(result.workers.length, 1);
      expect(result.workers.first.fullName, 'Ravi Kumar');
      expect(result.workers.first.hourlyRate, 350.0);
      expect(result.workers.first.averageRating, 4.8);
      expect(result.workers.first.totalReviews, 24);
    });
  });

  group('NearbyWorkerItem', () {
    test('parses from JSON correctly', () {
      final json = {
        'worker_id': 'w-100',
        'full_name': 'Anita Sharma',
        'bio': 'Master electrician',
        'hourly_rate': 400.0,
        'average_rating': 4.9,
        'total_reviews': 38,
        'distance_km': 1.45,
        'latitude': 12.9750,
        'longitude': 77.6000,
        'is_available': true,
      };

      final worker = NearbyWorkerItem.fromJson(json);

      expect(worker.workerId, 'w-100');
      expect(worker.fullName, 'Anita Sharma');
      expect(worker.distanceKm, 1.45);
      expect(worker.averageRating, 4.9);
      expect(worker.hourlyRate, 400.0);
    });
  });

  group('BookingFlowState', () {
    test('holds and clears discovery selection state', () {
      final state = BookingFlowState.instance;
      state.reset();

      expect(state.selectedCategory, isNull);
      expect(state.selectedService, isNull);
      expect(state.selectedWorker, isNull);

      const category = SkillCategory(
        id: 'cat-1',
        name: 'Plumbing',
        slug: 'plumbing',
      );
      const service = ServiceModel(
        id: 'svc-1',
        categoryId: 'cat-1',
        title: 'Tap Repair',
        basePrice: 299,
      );
      const worker = NearbyWorkerItem(
        workerId: 'wrk-1',
        fullName: 'Ravi Kumar',
      );

      state.selectedCategory = category;
      state.selectedService = service;
      state.selectedWorker = worker;

      expect(state.selectedCategory?.name, 'Plumbing');
      expect(state.selectedService?.title, 'Tap Repair');
      expect(state.selectedWorker?.fullName, 'Ravi Kumar');

      state.reset();
      expect(state.selectedCategory, isNull);
      expect(state.selectedService, isNull);
      expect(state.selectedWorker, isNull);
    });
  });
}
