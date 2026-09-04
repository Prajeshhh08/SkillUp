import 'package:flutter/material.dart';

class CustomerProfile {
  const CustomerProfile({
    required this.userId,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.knownJobs = const [],
  });

  final String userId;
  final String fullName;
  final String? email;
  final String phone;
  final String? avatarUrl;
  final List<String> knownJobs;

  String get initial {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'S';
    return trimmed.characters.first.toUpperCase();
  }

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      knownJobs:
          (json['known_jobs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'full_name': fullName,
    if (email != null) 'email': email,
    'phone': phone,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    'known_jobs': knownJobs,
  };
}

class CustomerMetrics {
  const CustomerMetrics({
    this.orderAcceptancePercentage = 100.0,
    this.bookingTotals = 0,
  });

  final double orderAcceptancePercentage;
  final int bookingTotals;

  factory CustomerMetrics.fromJson(Map<String, dynamic> json) {
    return CustomerMetrics(
      orderAcceptancePercentage:
          (json['order_acceptance_percentage'] as num?)?.toDouble() ?? 100.0,
      bookingTotals: (json['booking_totals'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'order_acceptance_percentage': orderAcceptancePercentage,
    'booking_totals': bookingTotals,
  };
}
