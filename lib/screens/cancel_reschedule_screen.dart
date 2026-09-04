import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class CancelRescheduleScreen extends StatefulWidget {
  const CancelRescheduleScreen({
    super.key,
    this.bookingId,
    this.bookingService,
  });

  final String? bookingId;
  final BookingService? bookingService;

  @override
  State<CancelRescheduleScreen> createState() => _CancelRescheduleScreenState();
}

class _CancelRescheduleScreenState extends State<CancelRescheduleScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;

  String? _resolvedBookingId;
  bool _isReschedule = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  final TextEditingController _reasonController = TextEditingController();
  DateTime _newDate = DateTime.now().add(const Duration(days: 2));
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
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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

  Future<void> _handleAction() async {
    final id =
        _resolvedBookingId ?? BookingFlowState.instance.activeBooking?.id;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active booking specified.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (_isReschedule) {
        final newTime = _computeNewScheduledAt();
        final updated = await _bookingService.rescheduleBooking(id, newTime);
        if (!mounted) return;
        BookingFlowState.instance.activeBooking = updated;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking rescheduled successfully.')),
        );
        Navigator.pop(context);
      } else {
        final reason = _reasonController.text.trim().isNotEmpty
            ? _reasonController.text.trim()
            : 'Customer requested cancellation';
        final updated = await _bookingService.cancelBooking(id, reason);
        if (!mounted) return;
        BookingFlowState.instance.activeBooking = updated;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully.')),
        );
        context.go('/booking-history');
      }
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
    return FlowScaffold(
      title: 'Manage booking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Cancel or reschedule',
            'Changes may be subject to the booking cancellation policy.',
          ),
          SwitchListTile(
            value: _isReschedule,
            activeThumbColor: AppTheme.primaryEmerald,
            activeTrackColor: AppTheme.primaryEmerald.withAlpha(100),
            onChanged: (v) => setState(() => _isReschedule = v),
            title: Text(
              _isReschedule ? 'Reschedule booking' : 'Cancel booking',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _isReschedule
                  ? 'Select a new date and time window'
                  : 'Permanently cancel your service request',
            ),
          ),
          const SizedBox(height: 16),
          if (_isReschedule) ...[
            AppCard(
              onTap: _pickDate,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.edit_calendar_rounded,
                  color: AppTheme.primaryEmerald,
                ),
                title: Text(
                  '${_newDate.day}/${_newDate.month}/${_newDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Tap to pick new date'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: 16),
            sectionLabel('New time window'),
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
          ] else ...[
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'e.g. Schedule conflict, problem resolved, etc.',
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(_errorMessage!, style: const TextStyle(color: AppTheme.error)),
          ],
          const Spacer(),
          primaryAction(
            _isSubmitting
                ? 'Processing...'
                : _isReschedule
                ? 'Confirm reschedule'
                : 'Cancel booking',
            _isSubmitting ? () {} : _handleAction,
          ),
        ],
      ),
    );
  }
}
