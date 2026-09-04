import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class CancelRescheduleScreen extends StatefulWidget {
  const CancelRescheduleScreen({super.key});

  @override
  State<CancelRescheduleScreen> createState() => _CancelRescheduleScreenState();
}

class _CancelRescheduleScreenState extends State<CancelRescheduleScreen> {
  bool reschedule = true;

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Manage booking',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Cancel or reschedule',
          'Changes may be subject to the cancellation policy.',
        ),
        SwitchListTile(
          value: reschedule,
          onChanged: (v) => setState(() => reschedule = v),
          title: Text(reschedule ? 'Reschedule booking' : 'Cancel booking'),
        ),
        const SizedBox(height: 12),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(labelText: 'Tell us why (optional)'),
        ),
        const Spacer(),
        primaryAction(
          reschedule ? 'Choose a new time' : 'Cancel booking',
          () => reschedule
              ? c.push('/booking-schedule')
              : c.push('/booking-history'),
        ),
      ],
    ),
  );
}
