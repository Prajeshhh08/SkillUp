import '../models/skill_category.dart';
import '../models/worker_profile.dart';
import 'api_client.dart';

class WorkerService {
  WorkerService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  static WorkerService instance = WorkerService();

  final ApiClient _client;

  Future<List<SkillCategory>> getSkillCategories() async {
    final response = await _client.getList('/skill-categories');
    return response
        .whereType<Map<String, dynamic>>()
        .map(SkillCategory.fromJson)
        .toList();
  }

  Future<WorkerProfile> getProfile() async {
    final response = await _client.get('/workers/me/profile');
    return WorkerProfile.fromJson(response);
  }

  Future<WorkerProfile> updateProfile(
    WorkerProfileUpdatePayload payload,
  ) async {
    final response = await _client.patch(
      '/workers/me/profile',
      data: payload.toJson(),
    );
    return WorkerProfile.fromJson(response);
  }

  Future<void> devVerify(String workerId) async {
    await _client.post('/workers/$workerId/dev-verify');
  }
}
