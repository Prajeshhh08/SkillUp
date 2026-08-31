import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class WorkerFormScreen extends StatelessWidget {
  const WorkerFormScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Complete profile',
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Tell customers about your work',
            'Complete the final details for a stronger profile.',
          ),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Professional bio'),
          ),
          const SizedBox(height: 14),
          const TextField(
            key: Key('hourly-rate'),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Hourly rate',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Availability'),
            items: const [
              'Weekdays',
              'Weekends',
              'Every day',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (_) => null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Payout method'),
            items: const [
              'Bank transfer',
              'UPI',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (_) => null,
          ),
          const SizedBox(height: 22),
          primaryAction('Save profile', () => c.push('/verification-pending')),
        ],
      ),
    ),
  );
}
