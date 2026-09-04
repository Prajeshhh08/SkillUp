class QuoteRequestPayload {
  const QuoteRequestPayload({
    required this.serviceId,
    required this.addressId,
    this.isEmergency = false,
  });

  final String serviceId;
  final String addressId;
  final bool isEmergency;

  Map<String, dynamic> toJson() => {
    'service_id': serviceId,
    'address_id': addressId,
    'is_emergency': isEmergency,
  };
}

class QuoteModel {
  const QuoteModel({
    required this.serviceId,
    required this.serviceTitle,
    required this.basePrice,
    required this.distanceKm,
    required this.distanceFee,
    required this.emergencyFee,
    required this.taxAmount,
    required this.totalQuotedPrice,
    required this.estimatedDurationMins,
  });

  final String serviceId;
  final String serviceTitle;
  final double basePrice;
  final double distanceKm;
  final double distanceFee;
  final double emergencyFee;
  final double taxAmount;
  final double totalQuotedPrice;
  final int estimatedDurationMins;

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      serviceId: json['service_id']?.toString() ?? '',
      serviceTitle: json['service_title']?.toString() ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      distanceFee: (json['distance_fee'] as num?)?.toDouble() ?? 0.0,
      emergencyFee: (json['emergency_fee'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalQuotedPrice: (json['total_quoted_price'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMins:
          (json['estimated_duration_mins'] as num?)?.toInt() ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
    'service_id': serviceId,
    'service_title': serviceTitle,
    'base_price': basePrice,
    'distance_km': distanceKm,
    'distance_fee': distanceFee,
    'emergency_fee': emergencyFee,
    'tax_amount': taxAmount,
    'total_quoted_price': totalQuotedPrice,
    'estimated_duration_mins': estimatedDurationMins,
  };
}

class BookingCreatePayload {
  const BookingCreatePayload({
    required this.serviceId,
    required this.addressId,
    this.workerId,
    required this.scheduledAt,
    this.notes,
    this.isEmergency = false,
  });

  final String serviceId;
  final String addressId;
  final String? workerId;
  final DateTime scheduledAt;
  final String? notes;
  final bool isEmergency;

  Map<String, dynamic> toJson() => {
    'service_id': serviceId,
    'address_id': addressId,
    if (workerId != null && workerId!.isNotEmpty) 'worker_id': workerId,
    'scheduled_at': scheduledAt.toUtc().toIso8601String(),
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'is_emergency': isEmergency,
  };
}

class BookingModel {
  const BookingModel({
    required this.id,
    required this.bookingReference,
    required this.customerId,
    this.workerId,
    required this.serviceId,
    required this.addressId,
    required this.status,
    this.isEmergency = false,
    required this.scheduledAt,
    this.notes,
    required this.quotedPrice,
    this.finalPrice,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.serviceTitle,
    this.workerName,
    this.addressText,
  });

  final String id;
  final String bookingReference;
  final String customerId;
  final String? workerId;
  final String serviceId;
  final String addressId;
  final String status;
  final bool isEmergency;
  final DateTime scheduledAt;
  final String? notes;
  final double quotedPrice;
  final double? finalPrice;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? serviceTitle;
  final String? workerName;
  final String? addressText;

  bool get isActive =>
      status != 'COMPLETED' && status != 'CANCELLED' && status != 'REJECTED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      bookingReference: json['booking_reference']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      workerId: json['worker_id']?.toString(),
      serviceId: json['service_id']?.toString() ?? '',
      addressId: json['address_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      isEmergency: json['is_emergency'] == true,
      scheduledAt:
          DateTime.tryParse(json['scheduled_at']?.toString() ?? '') ??
          DateTime.now(),
      notes: json['notes']?.toString(),
      quotedPrice: (json['quoted_price'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      cancellationReason: json['cancellation_reason']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      serviceTitle: json['service_title']?.toString(),
      workerName: json['worker_name']?.toString(),
      addressText: json['address_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_reference': bookingReference,
    'customer_id': customerId,
    if (workerId != null) 'worker_id': workerId,
    'service_id': serviceId,
    'address_id': addressId,
    'status': status,
    'is_emergency': isEmergency,
    'scheduled_at': scheduledAt.toIso8601String(),
    if (notes != null) 'notes': notes,
    'quoted_price': quotedPrice,
    if (finalPrice != null) 'final_price': finalPrice,
    if (cancellationReason != null) 'cancellation_reason': cancellationReason,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    if (serviceTitle != null) 'service_title': serviceTitle,
    if (workerName != null) 'worker_name': workerName,
    if (addressText != null) 'address_text': addressText,
  };
}

class BookingTimelineItem {
  const BookingTimelineItem({
    required this.status,
    required this.timestamp,
    this.metadataJson,
  });

  final String status;
  final DateTime timestamp;
  final Map<String, dynamic>? metadataJson;

  factory BookingTimelineItem.fromJson(Map<String, dynamic> json) {
    return BookingTimelineItem(
      status: json['status']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      metadataJson: json['metadata_json'] is Map<String, dynamic>
          ? json['metadata_json'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    if (metadataJson != null) 'metadata_json': metadataJson,
  };
}

class BookingTrackingModel {
  const BookingTrackingModel({
    required this.bookingId,
    required this.bookingReference,
    required this.status,
    required this.scheduledAt,
    this.workerId,
    this.workerName,
    this.workerPhone,
    this.workerLatitude,
    this.workerLongitude,
    this.etaMinutes,
    this.timeline = const [],
  });

  final String bookingId;
  final String bookingReference;
  final String status;
  final DateTime scheduledAt;
  final String? workerId;
  final String? workerName;
  final String? workerPhone;
  final double? workerLatitude;
  final double? workerLongitude;
  final int? etaMinutes;
  final List<BookingTimelineItem> timeline;

  factory BookingTrackingModel.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'];
    final items = (rawTimeline is List)
        ? rawTimeline
              .whereType<Map<String, dynamic>>()
              .map(BookingTimelineItem.fromJson)
              .toList()
        : <BookingTimelineItem>[];

    return BookingTrackingModel(
      bookingId: json['booking_id']?.toString() ?? '',
      bookingReference: json['booking_reference']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduled_at']?.toString() ?? '') ??
          DateTime.now(),
      workerId: json['worker_id']?.toString(),
      workerName: json['worker_name']?.toString(),
      workerPhone: json['worker_phone']?.toString(),
      workerLatitude: (json['worker_latitude'] as num?)?.toDouble(),
      workerLongitude: (json['worker_longitude'] as num?)?.toDouble(),
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      timeline: items,
    );
  }

  Map<String, dynamic> toJson() => {
    'booking_id': bookingId,
    'booking_reference': bookingReference,
    'status': status,
    'scheduled_at': scheduledAt.toIso8601String(),
    if (workerId != null) 'worker_id': workerId,
    if (workerName != null) 'worker_name': workerName,
    if (workerPhone != null) 'worker_phone': workerPhone,
    if (workerLatitude != null) 'worker_latitude': workerLatitude,
    if (workerLongitude != null) 'worker_longitude': workerLongitude,
    if (etaMinutes != null) 'eta_minutes': etaMinutes,
    'timeline': timeline.map((t) => t.toJson()).toList(),
  };
}

class ReviewCreatePayload {
  const ReviewCreatePayload({
    required this.rating,
    this.comment,
    this.badges = const [],
  });

  final int rating;
  final String? comment;
  final List<String> badges;

  Map<String, dynamic> toJson() => {
    'rating': rating,
    if (comment != null && comment!.isNotEmpty) 'comment': comment,
    'badges': badges,
  };
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.workerId,
    required this.rating,
    this.comment,
    this.badges = const [],
    this.createdAt,
    this.customerName,
  });

  final String id;
  final String bookingId;
  final String customerId;
  final String workerId;
  final int rating;
  final String? comment;
  final List<String> badges;
  final DateTime? createdAt;
  final String? customerName;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final rawBadges = json['badges'];
    final badgeList = (rawBadges is List)
        ? rawBadges.map((e) => e.toString()).toList()
        : <String>[];

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      workerId: json['worker_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment']?.toString(),
      badges: badgeList,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      customerName: json['customer_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'customer_id': customerId,
    'worker_id': workerId,
    'rating': rating,
    if (comment != null) 'comment': comment,
    'badges': badges,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (customerName != null) 'customer_name': customerName,
  };
}

class InvoiceLineItem {
  const InvoiceLineItem({required this.description, required this.amount});

  final String description;
  final double amount;

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      description: json['description']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'amount': amount,
  };
}

class InvoiceModel {
  const InvoiceModel({
    required this.invoiceNumber,
    required this.bookingReference,
    required this.issuedAt,
    required this.customerName,
    this.workerName,
    required this.serviceTitle,
    this.items = const [],
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.downloadUrl,
  });

  final String invoiceNumber;
  final String bookingReference;
  final DateTime issuedAt;
  final String customerName;
  final String? workerName;
  final String serviceTitle;
  final List<InvoiceLineItem> items;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String downloadUrl;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = (rawItems is List)
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(InvoiceLineItem.fromJson)
              .toList()
        : <InvoiceLineItem>[];

    return InvoiceModel(
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      bookingReference: json['booking_reference']?.toString() ?? '',
      issuedAt:
          DateTime.tryParse(json['issued_at']?.toString() ?? '') ??
          DateTime.now(),
      customerName: json['customer_name']?.toString() ?? 'Customer',
      workerName: json['worker_name']?.toString(),
      serviceTitle: json['service_title']?.toString() ?? 'Service',
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      downloadUrl: json['download_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'invoice_number': invoiceNumber,
    'booking_reference': bookingReference,
    'issued_at': issuedAt.toIso8601String(),
    'customer_name': customerName,
    if (workerName != null) 'worker_name': workerName,
    'service_title': serviceTitle,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'tax_amount': taxAmount,
    'total_amount': totalAmount,
    'download_url': downloadUrl,
  };
}
