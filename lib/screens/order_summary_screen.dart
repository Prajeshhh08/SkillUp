import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});
  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Order summary',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Standard plumbing visit',
          'A summary of your booking, payment, and support options.',
        ),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #SK-2048',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('Status: Completed'),
              SizedBox(height: 8),
              Text('Total paid: ₹299'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => c.push('/invoice'),
          child: const Text('View invoice'),
        ),
        const Spacer(),
        primaryAction('Rebook this service', () => c.push('/rebook')),
      ],
    ),
  );
}
