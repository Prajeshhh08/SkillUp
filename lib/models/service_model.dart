class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    required this.basePrice,
    this.priceUnit = 'FLAT',
    this.estimatedDurationMins = 60,
    this.inclusions = const [],
    this.isActive = true,
  });

  final String id;
  final String categoryId;
  final String title;
  final String? description;
  final double basePrice;
  final String priceUnit;
  final int estimatedDurationMins;
  final List<String> inclusions;
  final bool isActive;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final rawInclusions = json['inclusions'];
    final inclusionsList = (rawInclusions is List)
        ? rawInclusions.map((e) => e.toString()).toList()
        : <String>[];

    return ServiceModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      priceUnit: json['price_unit']?.toString() ?? 'FLAT',
      estimatedDurationMins:
          (json['estimated_duration_mins'] as num?)?.toInt() ?? 60,
      inclusions: inclusionsList,
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'title': title,
    if (description != null) 'description': description,
    'base_price': basePrice,
    'price_unit': priceUnit,
    'estimated_duration_mins': estimatedDurationMins,
    'inclusions': inclusions,
    'is_active': isActive,
  };
}

class WorkerSearchItem {
  const WorkerSearchItem({
    required this.workerId,
    required this.fullName,
    this.bio,
    this.hourlyRate,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isAvailable = true,
  });

  final String workerId;
  final String fullName;
  final String? bio;
  final double? hourlyRate;
  final double averageRating;
  final int totalReviews;
  final bool isAvailable;

  factory WorkerSearchItem.fromJson(Map<String, dynamic> json) {
    return WorkerSearchItem(
      workerId: json['worker_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      bio: json['bio']?.toString(),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'worker_id': workerId,
    'full_name': fullName,
    if (bio != null) 'bio': bio,
    if (hourlyRate != null) 'hourly_rate': hourlyRate,
    'average_rating': averageRating,
    'total_reviews': totalReviews,
    'is_available': isAvailable,
  };
}

class SearchResult {
  const SearchResult({
    this.services = const [],
    this.workers = const [],
    this.totalResults = 0,
  });

  final List<ServiceModel> services;
  final List<WorkerSearchItem> workers;
  final int totalResults;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    final svcList = (rawServices is List)
        ? rawServices
              .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList()
        : <ServiceModel>[];

    final rawWorkers = json['workers'];
    final wrkList = (rawWorkers is List)
        ? rawWorkers
              .map((e) => WorkerSearchItem.fromJson(e as Map<String, dynamic>))
              .toList()
        : <WorkerSearchItem>[];

    return SearchResult(
      services: svcList,
      workers: wrkList,
      totalResults:
          (json['total_results'] as num?)?.toInt() ??
          (svcList.length + wrkList.length),
    );
  }

  Map<String, dynamic> toJson() => {
    'services': services.map((s) => s.toJson()).toList(),
    'workers': workers.map((w) => w.toJson()).toList(),
    'total_results': totalResults,
  };
}

class NearbyWorkerItem {
  const NearbyWorkerItem({
    required this.workerId,
    required this.fullName,
    this.bio,
    this.hourlyRate,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.distanceKm = 0.0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isAvailable = true,
  });

  final String workerId;
  final String fullName;
  final String? bio;
  final double? hourlyRate;
  final double averageRating;
  final int totalReviews;
  final double distanceKm;
  final double latitude;
  final double longitude;
  final bool isAvailable;

  factory NearbyWorkerItem.fromJson(Map<String, dynamic> json) {
    return NearbyWorkerItem(
      workerId: json['worker_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      bio: json['bio']?.toString(),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['is_available'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'worker_id': workerId,
    'full_name': fullName,
    if (bio != null) 'bio': bio,
    if (hourlyRate != null) 'hourly_rate': hourlyRate,
    'average_rating': averageRating,
    'total_reviews': totalReviews,
    'distance_km': distanceKm,
    'latitude': latitude,
    'longitude': longitude,
    'is_available': isAvailable,
  };
}
