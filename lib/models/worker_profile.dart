import 'package:flutter/material.dart';

class WorkerSkillItem {
  const WorkerSkillItem({
    required this.skillCategoryId,
    this.skillName,
    this.experienceYears = 1,
  });

  final String skillCategoryId;
  final String? skillName;
  final int experienceYears;

  factory WorkerSkillItem.fromJson(Map<String, dynamic> json) {
    return WorkerSkillItem(
      skillCategoryId: json['skill_category_id']?.toString() ?? '',
      skillName: json['skill_name']?.toString(),
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'skill_category_id': skillCategoryId,
    if (skillName != null) 'skill_name': skillName,
    'experience_years': experienceYears,
  };
}

class WorkerProfile {
  const WorkerProfile({
    required this.userId,
    required this.fullName,
    required this.phone,
    this.email,
    this.bio,
    this.hourlyRate,
    this.isAvailable = false,
    this.setupProgress = 0,
    this.verificationStatus = 'UNVERIFIED',
    this.payoutPreference = 'UPI',
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.skills = const [],
  });

  final String userId;
  final String fullName;
  final String phone;
  final String? email;
  final String? bio;
  final double? hourlyRate;
  final bool isAvailable;
  final int setupProgress;
  final String verificationStatus;
  final String payoutPreference;
  final double averageRating;
  final int totalReviews;
  final List<WorkerSkillItem> skills;

  String get initial {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'W';
    return trimmed.characters.first.toUpperCase();
  }

  bool get isVerified => verificationStatus.toUpperCase() == 'VERIFIED';

  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    return WorkerProfile(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      bio: json['bio']?.toString(),
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      isAvailable: json['is_available'] == true,
      setupProgress: (json['setup_progress'] as num?)?.toInt() ?? 0,
      verificationStatus:
          json['verification_status']?.toString() ?? 'UNVERIFIED',
      payoutPreference: json['payout_preference']?.toString() ?? 'UPI',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(WorkerSkillItem.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'full_name': fullName,
    'phone': phone,
    if (email != null) 'email': email,
    if (bio != null) 'bio': bio,
    if (hourlyRate != null) 'hourly_rate': hourlyRate,
    'is_available': isAvailable,
    'setup_progress': setupProgress,
    'verification_status': verificationStatus,
    'payout_preference': payoutPreference,
    'average_rating': averageRating,
    'total_reviews': totalReviews,
    'skills': skills.map((s) => s.toJson()).toList(),
  };
}

class WorkerProfileUpdatePayload {
  const WorkerProfileUpdatePayload({
    this.bio,
    this.skills,
    this.hourlyRate,
    this.isAvailable,
    this.payoutPreference,
  });

  final String? bio;
  final List<WorkerSkillItem>? skills;
  final double? hourlyRate;
  final bool? isAvailable;
  final String? payoutPreference;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (bio != null) map['bio'] = bio;
    if (skills != null) map['skills'] = skills!.map((s) => s.toJson()).toList();
    if (hourlyRate != null) map['hourly_rate'] = hourlyRate;
    if (isAvailable != null) map['is_available'] = isAvailable;
    if (payoutPreference != null) map['payout_preference'] = payoutPreference;
    return map;
  }
}

class WorkerMetrics {
  const WorkerMetrics({
    required this.acceptanceRate,
    required this.completedJobs,
    required this.totalEarnings,
    required this.averageRating,
  });

  final double acceptanceRate;
  final int completedJobs;
  final double totalEarnings;
  final double averageRating;

  factory WorkerMetrics.fromJson(Map<String, dynamic> json) {
    return WorkerMetrics(
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 0.0,
      completedJobs: (json['completed_jobs'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'acceptance_rate': acceptanceRate,
    'completed_jobs': completedJobs,
    'total_earnings': totalEarnings,
    'average_rating': averageRating,
  };
}

