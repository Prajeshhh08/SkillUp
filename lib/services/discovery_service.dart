import '../models/service_model.dart';
import '../models/skill_category.dart';
import 'api_client.dart';

class DiscoveryService {
  DiscoveryService({ApiClient? client})
    : _client = client ?? ApiClient.instance;
  static DiscoveryService instance = DiscoveryService();

  final ApiClient _client;

  Future<List<SkillCategory>> getCategories() async {
    final response = await _client.getList('/categories');
    return response
        .whereType<Map<String, dynamic>>()
        .map(SkillCategory.fromJson)
        .toList();
  }

  Future<List<ServiceModel>> getServices({String? categoryId}) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.trim().isNotEmpty) {
      queryParams['categoryId'] = categoryId.trim();
    }
    final response = await _client.getList(
      '/services',
      queryParameters: queryParams,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(ServiceModel.fromJson)
        .toList();
  }

  Future<ServiceModel> getServiceDetails(String serviceId) async {
    final response = await _client.get('/services/$serviceId');
    return ServiceModel.fromJson(response);
  }

  Future<SearchResult> search({
    String? query,
    double? minRating,
    double? maxDistance,
    bool? availableNow,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{};
    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }
    if (minRating != null) {
      queryParams['rating'] = minRating;
    }
    if (maxDistance != null) {
      queryParams['distance'] = maxDistance;
    }
    if (availableNow != null) {
      queryParams['availableNow'] = availableNow;
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice;
    }

    final response = await _client.get('/search', queryParameters: queryParams);
    return SearchResult.fromJson(response);
  }

  Future<List<NearbyWorkerItem>> getNearbyWorkers({
    required double latitude,
    required double longitude,
    String? serviceId,
  }) async {
    final queryParams = <String, dynamic>{'lat': latitude, 'lng': longitude};
    if (serviceId != null && serviceId.trim().isNotEmpty) {
      queryParams['serviceId'] = serviceId.trim();
    }

    final response = await _client.get(
      '/workers/nearby',
      queryParameters: queryParams,
    );
    final rawWorkers = response['workers'];
    if (rawWorkers is List) {
      return rawWorkers
          .whereType<Map<String, dynamic>>()
          .map(NearbyWorkerItem.fromJson)
          .toList();
    }
    return [];
  }
}
