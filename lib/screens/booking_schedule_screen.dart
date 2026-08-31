import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class BookingScheduleScreen extends StatefulWidget {
  const BookingScheduleScreen({super.key});

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  String time = 'Morning';

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Choose a time',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Schedule your service',
          'Pick a date and a time window that works for you.',
        ),
        const AppCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.calendar_month_rounded,
              color: AppTheme.primaryEmerald,
            ),
            title: Text('Tomorrow, 1 September'),
            trailing: Icon(Icons.edit_calendar_rounded),
          ),
        ),
        const SizedBox(height: 24),
        sectionLabel('Time window'),
        Wrap(
          spacing: 8,
          children: ['Morning', 'Afternoon', 'Evening']
              .map(
                (x) => ChoiceChip(
                  label: Text(x),
                  selected: time == x,
                  onSelected: (_) => setState(() => time = x),
                ),
              )
              .toList(),
        ),
        const Spacer(),
        primaryAction('Review booking', () => c.push('/booking-review')),
      ],
    ),
  );
}
