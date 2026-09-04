import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/skill_category.dart';
import 'package:skillup/models/worker_profile.dart';

void main() {
  group('SkillCategory model tests', () {
    test('parses json correctly', () {
      final json = {
        'id': 'cat-123',
        'name': 'Plumbing',
        'slug': 'plumbing',
        'description': 'Plumbing repairs and installations',
        'icon_url': 'https://example.com/plumbing.png',
        'is_active': true,
      };

      final cat = SkillCategory.fromJson(json);
      expect(cat.id, 'cat-123');
      expect(cat.name, 'Plumbing');
      expect(cat.slug, 'plumbing');
      expect(cat.description, 'Plumbing repairs and installations');
      expect(cat.iconUrl, 'https://example.com/plumbing.png');
      expect(cat.isActive, isTrue);
    });

    test('serializes to json', () {
      const cat = SkillCategory(
        id: 'cat-456',
        name: 'Carpentry',
        slug: 'carpentry',
      );

      final json = cat.toJson();
      expect(json['id'], 'cat-456');
      expect(json['name'], 'Carpentry');
      expect(json['slug'], 'carpentry');
      expect(json['is_active'], isTrue);
    });
  });

  group('WorkerProfile and WorkerSkillItem model tests', () {
    test('parses worker profile json with skills and stats', () {
      final json = {
        'user_id': 'usr-789',
        'full_name': 'Ramesh Patel',
        'phone': '+919123456780',
        'email': 'ramesh@example.com',
        'bio': 'Skilled electrician with over 8 years experience.',
        'hourly_rate': 450.0,
        'is_available': true,
        'setup_progress': 80,
        'verification_status': 'VERIFIED',
        'payout_preference': 'UPI',
        'average_rating': 4.9,
        'total_reviews': 35,
        'skills': [
          {
            'skill_category_id': 'cat-elec',
            'skill_name': 'Electrical',
            'experience_years': 8,
          },
        ],
      };

      final profile = WorkerProfile.fromJson(json);
      expect(profile.userId, 'usr-789');
      expect(profile.fullName, 'Ramesh Patel');
      expect(profile.phone, '+919123456780');
      expect(profile.email, 'ramesh@example.com');
      expect(profile.bio, 'Skilled electrician with over 8 years experience.');
      expect(profile.hourlyRate, 450.0);
      expect(profile.isAvailable, isTrue);
      expect(profile.setupProgress, 80);
      expect(profile.verificationStatus, 'VERIFIED');
      expect(profile.isVerified, isTrue);
      expect(profile.payoutPreference, 'UPI');
      expect(profile.averageRating, 4.9);
      expect(profile.totalReviews, 35);
      expect(profile.skills.length, 1);
      expect(profile.skills.first.skillName, 'Electrical');
      expect(profile.skills.first.experienceYears, 8);
      expect(profile.initial, 'R');
    });

    test('handles unverified worker with default and missing fields', () {
      final json = {
        'user_id': 'usr-000',
        'full_name': '',
        'phone': '+919000000000',
      };

      final profile = WorkerProfile.fromJson(json);
      expect(profile.initial, 'W');
      expect(profile.isVerified, isFalse);
      expect(profile.verificationStatus, 'UNVERIFIED');
      expect(profile.hourlyRate, isNull);
      expect(profile.bio, isNull);
      expect(profile.skills, isEmpty);
    });

    test('WorkerProfileUpdatePayload serializes correctly', () {
      const payload = WorkerProfileUpdatePayload(
        bio: 'Professional plumber',
        hourlyRate: 350.0,
        isAvailable: true,
        payoutPreference: 'BANK_TRANSFER',
        skills: [
          WorkerSkillItem(skillCategoryId: 'cat-plumb', experienceYears: 4),
        ],
      );

      final map = payload.toJson();
      expect(map['bio'], 'Professional plumber');
      expect(map['hourly_rate'], 350.0);
      expect(map['is_available'], isTrue);
      expect(map['payout_preference'], 'BANK_TRANSFER');
      expect(map['skills'], isA<List>());
      final skillsList = map['skills'] as List;
      expect(skillsList.length, 1);
      expect(skillsList.first['skill_category_id'], 'cat-plumb');
      expect(skillsList.first['experience_years'], 4);
    });
  });
}
