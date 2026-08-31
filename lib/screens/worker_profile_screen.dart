import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Professional profile',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: CircleAvatar(
            radius: 42,
            child: Icon(Icons.person_rounded, size: 48),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Ravi Kumar',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
          ),
        ),
        const Center(child: Text('Verified plumber · 4.8 ★')),
        const SizedBox(height: 24),
        const AppCard(
          child: Text(
            'Experienced residential plumber specialising in repairs, installations, and urgent leaks.',
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          children: ['Verified', '5 years experience', 'Hindi · English']
              .map(
                (x) => Chip(
                  label: Text(x),
                  avatar: const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppTheme.success,
                  ),
                ),
              )
              .toList(),
        ),
        const Spacer(),
        primaryAction('Book Ravi', () => c.push('/booking-schedule')),
      ],
    ),
  );
}
