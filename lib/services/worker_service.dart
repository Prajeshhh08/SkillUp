import '../models/booking_model.dart';
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

  Future<List<BookingModel>> getWorkerBookings({String? status}) async {
    final query = status != null ? {'status': status} : null;
    final response = await _client.getList(
      '/worker/bookings',
      queryParameters: query,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }

  Future<BookingModel> acceptBooking(String bookingId) async {
    final response = await _client.post('/worker/bookings/$bookingId/accept');
    return BookingModel.fromJson(response);
  }

  Future<BookingModel> declineBooking(String bookingId) async {
    final response = await _client.post('/worker/bookings/$bookingId/decline');
    return BookingModel.fromJson(response);
  }

  Future<BookingModel> updateJobStatus(String bookingId, String status) async {
    final response = await _client.patch(
      '/worker/bookings/$bookingId/status',
      data: {'status': status},
    );
    return BookingModel.fromJson(response);
  }

  Future<WorkerMetrics> getMetrics() async {
    final response = await _client.get('/worker/metrics');
    return WorkerMetrics.fromJson(response);
  }
}

