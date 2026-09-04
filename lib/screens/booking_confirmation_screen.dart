import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key, this.bookingId});

  final String? bookingId;

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  String? _resolvedBookingId;

  @override
  void initState() {
    super.initState();
    _resolvedBookingId =
        widget.bookingId ?? BookingFlowState.instance.activeBooking?.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final queryId = GoRouterState.of(
        context,
      ).uri.queryParameters['bookingId'];
      if (queryId != null && queryId.isNotEmpty) {
        _resolvedBookingId = queryId;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final activeBooking = BookingFlowState.instance.activeBooking;
    final reference = activeBooking?.bookingReference ?? 'BK-CONFIRMED';
    final serviceTitle =
        activeBooking?.serviceTitle ??
        BookingFlowState.instance.selectedService?.title ??
        'Home service';
    final window = BookingFlowState.instance.timeWindow;
    final date =
        activeBooking?.scheduledAt ??
        BookingFlowState.instance.selectedDateTime ??
        DateTime.now().add(const Duration(days: 1));

    return FlowScaffold(
      title: 'Booking confirmed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Center(
            child: Icon(
              Icons.check_circle_rounded,
              size: 88,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(height: 22),
          flowTitle(
            'Your booking is confirmed',
            'Booking Reference #$reference. We are assigning a verified professional for your service.',
          ),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.schedule_rounded,
                color: AppTheme.primaryEmerald,
              ),
              title: Text(
                '${date.day}/${date.month}/${date.year} · $window',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(serviceTitle),
            ),
          ),
          const Spacer(),
          primaryAction('Track booking', () {
            final targetId =
                _resolvedBookingId ??
                BookingFlowState.instance.activeBooking?.id;
            final path = (targetId != null && targetId.isNotEmpty)
                ? '/active-booking?bookingId=$targetId'
                : '/active-booking';
            context.push(path);
          }),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/customer-home'),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}
