import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key, this.bookingId, this.bookingService});

  final String? bookingId;
  final BookingService? bookingService;

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;

  String? _resolvedBookingId;
  bool _isLoading = true;
  String? _errorMessage;
  BookingModel? _booking;

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

    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? idToFetch = _resolvedBookingId;
      if (idToFetch == null || idToFetch.isEmpty) {
        final list = await _bookingService.getCustomerBookings();
        if (list.isNotEmpty) {
          idToFetch = list.first.id;
          _resolvedBookingId = idToFetch;
        } else {
          throw Exception('No booking found for summary.');
        }
      }

      final booking = await _bookingService.getBookingDetails(idToFetch);
      if (!mounted) return;
      setState(() {
        _booking = booking;
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
    return FlowScaffold(title: 'Order summary', child: _buildBody());
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
              onPressed: _loadBooking,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final booking = _booking;
    if (booking == null) {
      return const Center(
        child: Text(
          'Booking details unavailable.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final title = booking.serviceTitle ?? 'Home Service';
    final price = booking.finalPrice ?? booking.quotedPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          title,
          'A summary of your booking, payment, and support options.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${booking.bookingReference}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status'),
                  Text(
                    booking.status,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Scheduled date'),
                  Text(
                    '${booking.scheduledAt.day}/${booking.scheduledAt.month}/${booking.scheduledAt.year}',
                  ),
                ],
              ),
              if (booking.workerName != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Assigned worker'),
                    Text(
                      booking.workerName!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
              if (booking.addressText != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Address'),
                    Text(
                      booking.addressText!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total amount',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            context.push('/invoice?bookingId=${booking.id}');
          },
          icon: const Icon(Icons.receipt_long_rounded),
          label: const Text('View invoice & receipt'),
        ),
        const Spacer(),
        primaryAction('Rebook this service', () {
          context.push('/rebook?bookingId=${booking.id}');
        }),
      ],
    );
  }
}
