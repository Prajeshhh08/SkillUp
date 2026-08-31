import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class BookingReviewScreen extends StatelessWidget {
  const BookingReviewScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Review booking',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Almost there',
          'Please confirm your service details before placing the booking.',
        ),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Standard plumbing visit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('Tomorrow · Morning'),
              SizedBox(height: 8),
              Text('Home address on file'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated total',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '₹299',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryEmerald,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        primaryAction(
          'Confirm booking',
          () => showDialog(
            context: c,
            builder: (d) => AlertDialog(
              title: const Text('Booking confirmed'),
              content: const Text(
                'Your professional will contact you shortly.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(d).pop();
                    c.push('/booking-address');
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
