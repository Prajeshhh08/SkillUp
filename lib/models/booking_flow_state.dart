import 'booking_model.dart';
import 'customer_address.dart';
import 'service_model.dart';
import 'skill_category.dart';

class BookingFlowState {
  BookingFlowState._();

  static final BookingFlowState instance = BookingFlowState._();

  SkillCategory? selectedCategory;
  ServiceModel? selectedService;
  NearbyWorkerItem? selectedWorker;

  CustomerAddress? selectedAddress;
  DateTime? selectedDateTime;
  String timeWindow = 'Morning';
  String? notes;
  QuoteModel? activeQuote;
  BookingModel? activeBooking;

  DateTime get resolvedScheduledAt {
    final baseDate =
        selectedDateTime ?? DateTime.now().add(const Duration(days: 1));
    int hour = 9;
    if (timeWindow == 'Afternoon') {
      hour = 14;
    } else if (timeWindow == 'Evening') {
      hour = 18;
    }
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, 0, 0);
  }

  void reset() {
    selectedCategory = null;
    selectedService = null;
    selectedWorker = null;
    selectedAddress = null;
    selectedDateTime = null;
    timeWindow = 'Morning';
    notes = null;
    activeQuote = null;
    activeBooking = null;
  }
}
