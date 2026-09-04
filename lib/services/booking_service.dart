import '../models/booking_model.dart';
import 'api_client.dart';

class BookingService {
  BookingService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  static BookingService instance = BookingService();

  final ApiClient _client;

  Future<QuoteModel> calculateQuote(QuoteRequestPayload payload) async {
    final response = await _client.post(
      '/bookings/quote',
      data: payload.toJson(),
    );
    return QuoteModel.fromJson(response);
  }

  Future<BookingModel> createBooking(BookingCreatePayload payload) async {
    final response = await _client.post('/bookings', data: payload.toJson());
    return BookingModel.fromJson(response);
  }

  Future<List<BookingModel>> getCustomerBookings({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    final response = await _client.getList(
      '/bookings',
      queryParameters: queryParams,
    );
    return response
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }

  Future<BookingModel> getBookingDetails(String bookingId) async {
    final response = await _client.get('/bookings/$bookingId');
    return BookingModel.fromJson(response);
  }

  Future<BookingModel> cancelBooking(String bookingId, String reason) async {
    final response = await _client.post(
      '/bookings/$bookingId/cancel',
      data: {'reason': reason},
    );
    return BookingModel.fromJson(response);
  }

  Future<BookingModel> rescheduleBooking(
    String bookingId,
    DateTime newScheduledAt,
  ) async {
    final response = await _client.post(
      '/bookings/$bookingId/reschedule',
      data: {'new_scheduled_at': newScheduledAt.toUtc().toIso8601String()},
    );
    return BookingModel.fromJson(response);
  }

  Future<BookingModel> rebookBooking(
    String bookingId,
    DateTime newScheduledAt,
  ) async {
    final response = await _client.post(
      '/bookings/$bookingId/rebook',
      data: {'new_scheduled_at': newScheduledAt.toUtc().toIso8601String()},
    );
    return BookingModel.fromJson(response);
  }

  Future<BookingTrackingModel> getBookingTracking(String bookingId) async {
    final response = await _client.get('/bookings/$bookingId/tracking');
    return BookingTrackingModel.fromJson(response);
  }

  Future<ReviewModel> createReview(
    String bookingId,
    ReviewCreatePayload payload,
  ) async {
    final response = await _client.post(
      '/bookings/$bookingId/review',
      data: payload.toJson(),
    );
    return ReviewModel.fromJson(response);
  }

  Future<InvoiceModel> getInvoice(String bookingId) async {
    final response = await _client.get('/bookings/$bookingId/invoice');
    return InvoiceModel.fromJson(response);
  }
}
