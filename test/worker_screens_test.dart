import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillup/models/skill_category.dart';
import 'package:skillup/models/worker_profile.dart';
import 'package:skillup/screens/worker_account_profile_screen.dart';
import 'package:skillup/screens/worker_form_screen.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/worker_service.dart';

class _MockWorkerService extends WorkerService {
  _MockWorkerService({this.throwError = false});
  final bool throwError;

  WorkerProfile currentProfile = const WorkerProfile(
    userId: 'worker-1',
    fullName: 'Suresh Kumar',
    phone: '+919876543210',
    email: 'suresh@example.com',
    bio: 'Professional plumber with 6 years experience.',
    hourlyRate: 400.0,
    isAvailable: true,
    setupProgress: 75,
    verificationStatus: 'VERIFIED',
    payoutPreference: 'UPI',
    averageRating: 4.8,
    totalReviews: 24,
    skills: [
      WorkerSkillItem(
        skillCategoryId: 'cat-1',
        skillName: 'Plumbing',
        experienceYears: 6,
      ),
    ],
  );

  @override
  Future<WorkerProfile> getProfile() async {
    if (throwError) {
      throw const ApiException('Failed to load worker profile from server.');
    }
    return currentProfile;
  }

  @override
  Future<List<SkillCategory>> getSkillCategories() async {
    if (throwError) {
      throw const ApiException('Failed to load categories.');
    }
    return const [
      SkillCategory(id: 'cat-1', name: 'Plumbing', slug: 'plumbing'),
      SkillCategory(id: 'cat-2', name: 'Electrical', slug: 'electrical'),
      SkillCategory(id: 'cat-3', name: 'Carpentry', slug: 'carpentry'),
    ];
  }

  @override
  Future<WorkerProfile> updateProfile(
    WorkerProfileUpdatePayload payload,
  ) async {
    currentProfile = WorkerProfile(
      userId: currentProfile.userId,
      fullName: currentProfile.fullName,
      phone: currentProfile.phone,
      email: currentProfile.email,
      bio: payload.bio ?? currentProfile.bio,
      hourlyRate: payload.hourlyRate ?? currentProfile.hourlyRate,
      isAvailable: payload.isAvailable ?? currentProfile.isAvailable,
      setupProgress: 90,
      verificationStatus: currentProfile.verificationStatus,
      payoutPreference:
          payload.payoutPreference ?? currentProfile.payoutPreference,
      averageRating: currentProfile.averageRating,
      totalReviews: currentProfile.totalReviews,
      skills: payload.skills ?? currentProfile.skills,
    );
    return currentProfile;
  }
}

void main() {
  group('WorkerAccountProfileScreen widget tests', () {
    testWidgets('renders worker profile details, skills, and progress', (
      tester,
    ) async {
      WorkerService.instance = _MockWorkerService();

      await tester.pumpWidget(
        const MaterialApp(home: WorkerAccountProfileScreen()),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Loaded state
      expect(find.text('Suresh Kumar'), findsOneWidget);
      expect(find.text('Professional bio'), findsOneWidget);
      expect(
        find.text('Professional plumber with 6 years experience.'),
        findsOneWidget,
      );
      expect(find.text('₹400/hr'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Available for jobs'), findsOneWidget);
      expect(find.text('Plumbing (6y)'), findsOneWidget);
      expect(find.text('Edit professional profile'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });

    testWidgets('shows error view and retry button on failure', (tester) async {
      WorkerService.instance = _MockWorkerService(throwError: true);

      await tester.pumpWidget(
        const MaterialApp(home: WorkerAccountProfileScreen()),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Failed to load worker profile from server.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('WorkerFormScreen widget tests', () {
    testWidgets('loads form, selects skills, and saves profile', (
      tester,
    ) async {
      final mock = _MockWorkerService();
      WorkerService.instance = mock;

      await tester.pumpWidget(const MaterialApp(home: WorkerFormScreen()));

      await tester.pumpAndSettle();

      // Verify categories are rendered as FilterChips
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('Electrical'), findsOneWidget);
      expect(find.text('Carpentry'), findsOneWidget);

      // Verify prefilled data
      expect(
        find.text('Professional plumber with 6 years experience.'),
        findsOneWidget,
      );
      expect(find.text('400'), findsOneWidget);

      // Scroll to and tap an additional skill: Electrical
      await tester.ensureVisible(find.text('Electrical'));
      await tester.tap(find.text('Electrical'));
      await tester.pumpAndSettle();

      // Scroll to and tap Save profile
      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save profile');
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Check that profile was updated with the new skill
      expect(mock.currentProfile.skills.length, 2);
    });
  });
}
