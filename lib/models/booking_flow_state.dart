import 'service_model.dart';
import 'skill_category.dart';

class BookingFlowState {
  BookingFlowState._();

  static final BookingFlowState instance = BookingFlowState._();

  SkillCategory? selectedCategory;
  ServiceModel? selectedService;
  NearbyWorkerItem? selectedWorker;

  void reset() {
    selectedCategory = null;
    selectedService = null;
    selectedWorker = null;
  }
}
