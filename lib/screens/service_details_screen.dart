import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Service details',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Standard plumbing visit',
          'A verified professional assesses and resolves common home plumbing issues.',
        ),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From ₹299',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryEmerald,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Includes diagnosis, basic repair work, and service warranty. Parts are charged separately.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        sectionLabel('What is included'),
        ...[
          'Verified local professional',
          'Upfront pricing',
          '30-day service support',
        ].map(
          (x) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppTheme.success),
                const SizedBox(width: 10),
                Text(x),
              ],
            ),
          ),
        ),
        const Spacer(),
        primaryAction('Book now', () => c.push('/booking-schedule')),
      ],
    ),
  );
}
