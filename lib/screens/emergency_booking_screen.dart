import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class EmergencyBookingScreen extends StatelessWidget {
  const EmergencyBookingScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Emergency booking',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Need help right away?',
          'Tell us what is urgent and we’ll prioritize an available professional.',
        ),
        const AppCard(
          child: Row(
            children: [
              Icon(Icons.emergency_rounded, color: AppTheme.error),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Emergency requests may include a priority dispatch charge.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const TextField(
          maxLines: 4,
          decoration: InputDecoration(labelText: 'Describe the emergency'),
        ),
        const SizedBox(height: 18),
        primaryAction(
          'Find available workers',
          () => c.push('/nearby-workers'),
        ),
      ],
    ),
  );
}
