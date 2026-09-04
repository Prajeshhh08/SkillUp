import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class RebookScreen extends StatefulWidget {
  const RebookScreen({super.key, this.bookingId, this.bookingService});

  final String? bookingId;
  final BookingService? bookingService;

  @override
  State<RebookScreen> createState() => _RebookScreenState();
}

class _RebookScreenState extends State<RebookScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;

  String? _resolvedBookingId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  BookingModel? _previousBooking;

  DateTime _newDate = DateTime.now().add(const Duration(days: 1));
  String _timeWindow = 'Morning';

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

    _loadPreviousBooking();
  }

  Future<void> _loadPreviousBooking() async {
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
          throw Exception('No previous booking found to rebook.');
        }
      }

      final booking = await _bookingService.getBookingDetails(idToFetch);
      if (!mounted) return;
      setState(() {
        _previousBooking = booking;
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _newDate.isBefore(now)
          ? now.add(const Duration(days: 1))
          : _newDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _newDate = picked);
    }
  }

  DateTime _computeNewScheduledAt() {
    int hour = 9;
    if (_timeWindow == 'Afternoon') {
      hour = 14;
    } else if (_timeWindow == 'Evening') {
      hour = 18;
    }
    return DateTime(_newDate.year, _newDate.month, _newDate.day, hour, 0, 0);
  }

  Future<void> _submitRebook() async {
    final id = _resolvedBookingId ?? _previousBooking?.id;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous booking selected.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final scheduledAt = _computeNewScheduledAt();
      final newBooking = await _bookingService.rebookBooking(id, scheduledAt);

      if (!mounted) return;
      BookingFlowState.instance.activeBooking = newBooking;
      context.push('/booking-confirmation?bookingId=${newBooking.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(title: 'Rebook service', child: _buildBody());
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
              onPressed: _loadPreviousBooking,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final prev = _previousBooking;
    final title = prev?.serviceTitle ?? 'Home Service';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Book again in seconds',
          'We have pre-filled your previous preferences for $title.',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Previous order: #${prev?.bookingReference ?? ''}',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              if (prev?.addressText != null) ...[
                const SizedBox(height: 4),
                Text(
                  prev!.addressText!,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        sectionLabel('Select new date'),
        AppCard(
          onTap: _pickDate,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.calendar_month_rounded,
              color: AppTheme.primaryEmerald,
            ),
            title: Text(
              '${_newDate.day}/${_newDate.month}/${_newDate.year}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Tap to change date'),
            trailing: const Icon(Icons.edit_calendar_rounded),
          ),
        ),
        const SizedBox(height: 18),
        sectionLabel('Time window'),
        Wrap(
          spacing: 8,
          children: ['Morning', 'Afternoon', 'Evening'].map((x) {
            final isSelected = _timeWindow == x;
            return ChoiceChip(
              label: Text(x),
              selected: isSelected,
              selectedColor: AppTheme.primaryEmerald.withAlpha(40),
              onSelected: (_) => setState(() => _timeWindow = x),
            );
          }).toList(),
        ),
        const Spacer(),
        primaryAction(
          _isSubmitting ? 'Confirming rebook...' : 'Confirm rebooking',
          _isSubmitting ? () {} : _submitRebook,
        ),
      ],
    );
  }
}
