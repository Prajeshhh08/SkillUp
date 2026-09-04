import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class ActiveBookingScreen extends StatefulWidget {
  const ActiveBookingScreen({super.key, this.bookingId, this.bookingService});

  final String? bookingId;
  final BookingService? bookingService;

  @override
  State<ActiveBookingScreen> createState() => _ActiveBookingScreenState();
}

class _ActiveBookingScreenState extends State<ActiveBookingScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;

  String? _resolvedBookingId;
  bool _isLoading = true;
  String? _errorMessage;
  BookingTrackingModel? _tracking;

  @override
  void initState() {
    super.initState();
    _resolvedBookingId =
        widget.bookingId ?? BookingFlowState.instance.activeBooking?.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveParamsAndLoad();
  }

  bool _hasLoaded = false;

  void _resolveParamsAndLoad() {
    if (_hasLoaded) return;
    _hasLoaded = true;

    try {
      final queryId = GoRouterState.of(
        context,
      ).uri.queryParameters['bookingId'];
      if (queryId != null && queryId.isNotEmpty) {
        _resolvedBookingId = queryId;
      }
    } catch (_) {}

    _loadTracking();
  }

  Future<void> _loadTracking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? idToFetch = _resolvedBookingId;
      if (idToFetch == null || idToFetch.isEmpty) {
        final activeList = await _bookingService.getCustomerBookings();
        final firstActive = activeList.firstWhere(
          (b) => b.isActive,
          orElse: () => activeList.isNotEmpty
              ? activeList.first
              : throw Exception('No bookings found to track.'),
        );
        idToFetch = firstActive.id;
        _resolvedBookingId = idToFetch;
      }

      final tracking = await _bookingService.getBookingTracking(idToFetch);
      if (!mounted) return;
      setState(() {
        _tracking = tracking;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title: 'Track booking',
      action: IconButton(
        icon: const Icon(Icons.more_horiz_rounded),
        onPressed: () {
          final id =
              _resolvedBookingId ??
              _tracking?.bookingId ??
              BookingFlowState.instance.activeBooking?.id;
          final path = (id != null && id.isNotEmpty)
              ? '/cancel-reschedule?bookingId=$id'
              : '/cancel-reschedule';
          context.push(path).then((_) => _loadTracking());
        },
      ),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.error),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadTracking,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final tracking = _tracking;
    if (tracking == null) {
      return const Center(
        child: Text(
          'No booking tracking details found.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final status = tracking.status.toUpperCase();
    final workerName = tracking.workerName ?? 'Verified Professional';

    final steps = [
      ('Booking confirmed', status != 'CANCELLED' && status != 'REJECTED'),
      (
        'Professional assigned',
        tracking.workerId != null ||
            status == 'OFFERED' ||
            status == 'CONFIRMED' ||
            status == 'ON_THE_WAY' ||
            status == 'IN_PROGRESS' ||
            status == 'COMPLETED',
      ),
      (
        'On the way',
        status == 'ON_THE_WAY' ||
            status == 'IN_PROGRESS' ||
            status == 'COMPLETED',
      ),
      ('Service in progress', status == 'IN_PROGRESS' || status == 'COMPLETED'),
      ('Service completed', status == 'COMPLETED'),
    ];

    return RefreshIndicator(
      onRefresh: _loadTracking,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            '$workerName · $status',
            'Order #${tracking.bookingReference}. Updates refresh automatically.',
          ),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: Text(
                tracking.workerName ?? 'Assigning professional...',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                tracking.etaMinutes != null
                    ? 'Estimated arrival in ${tracking.etaMinutes} mins'
                    : 'Scheduled for ${tracking.scheduledAt.day}/${tracking.scheduledAt.month}',
              ),
              trailing: tracking.workerPhone != null
                  ? const Icon(
                      Icons.phone_rounded,
                      color: AppTheme.primaryEmerald,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 22),
          sectionLabel('Booking progress'),
          Expanded(
            child: ListView(
              children: steps.map((step) {
                final isDone = step.$2;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isDone
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        step.$1,
                        style: TextStyle(
                          fontWeight: isDone
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isDone
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          primaryAction('View order summary', () {
            final targetId = _resolvedBookingId ?? tracking.bookingId;
            context.push('/order-summary?bookingId=$targetId');
          }),
        ],
      ),
    );
  }
}
