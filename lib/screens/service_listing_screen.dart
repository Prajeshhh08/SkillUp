import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class ServiceListingScreen extends StatelessWidget {
  const ServiceListingScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final category =
        GoRouterState.of(c).uri.queryParameters['category'] ?? 'Home services';
    final services = [
      'Standard visit',
      'Repair & installation',
      'Deep service',
    ];
    final details = [
      'From ₹299 · 45 min',
      'From ₹499 · 90 min',
      'From ₹799 · 2 hours',
    ];

    return FlowScaffold(
      title: category,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            '$category services',
            'Choose a service and view transparent pricing before you book.',
          ),
          Expanded(
            child: ListView.separated(
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => AppCard(
                onTap: () => c.push('/service-details'),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.home_repair_service_rounded),
                  ),
                  title: Text(services[i]),
                  subtitle: Text(details[i]),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
