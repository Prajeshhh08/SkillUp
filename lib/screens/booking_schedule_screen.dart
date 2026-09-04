import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class BookingScheduleScreen extends StatefulWidget {
  const BookingScheduleScreen({
    super.key,
    this.initialDate,
    this.initialTimeWindow,
  });

  final DateTime? initialDate;
  final String? initialTimeWindow;

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  late DateTime _selectedDate;
  late String _timeWindow;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        widget.initialDate ??
        BookingFlowState.instance.selectedDateTime ??
        DateTime.now().add(const Duration(days: 1));
    _timeWindow =
        widget.initialTimeWindow ?? BookingFlowState.instance.timeWindow;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final isTomorrow =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1;

    final prefix = isTomorrow ? 'Tomorrow, ' : '';
    return '$prefix${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now)
          ? now.add(const Duration(days: 1))
          : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceTitle =
        BookingFlowState.instance.selectedService?.title ?? 'your service';

    return FlowScaffold(
      title: 'Choose a time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Schedule $serviceTitle',
            'Pick a date and a time window that works for you.',
          ),
          AppCard(
            onTap: _pickDate,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month_rounded,
                color: AppTheme.primaryEmerald,
              ),
              title: Text(
                _formatDate(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Tap to change date'),
              trailing: const Icon(Icons.edit_calendar_rounded),
            ),
          ),
          const SizedBox(height: 24),
          sectionLabel('Time window'),
          Wrap(
            spacing: 8,
            children: ['Morning', 'Afternoon', 'Evening'].map((x) {
              final isSelected = _timeWindow == x;
              return ChoiceChip(
                label: Text(x),
                selected: isSelected,
                selectedColor: AppTheme.primaryEmerald.withAlpha(40),
                onSelected: (_) {
                  setState(() => _timeWindow = x);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            _timeWindow == 'Morning'
                ? '9:00 AM – 12:00 PM'
                : _timeWindow == 'Afternoon'
                ? '12:00 PM – 4:00 PM'
                : '4:00 PM – 8:00 PM',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          primaryAction('Review booking', () {
            BookingFlowState.instance.selectedDateTime = _selectedDate;
            BookingFlowState.instance.timeWindow = _timeWindow;
            context.push('/booking-review');
          }),
        ],
      ),
    );
  }
}
