import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class RatingReviewScreen extends StatefulWidget {
  const RatingReviewScreen({super.key});

  @override
  State<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends State<RatingReviewScreen> {
  int stars = 5;

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Rate service',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'How was your experience?',
          'Your feedback helps customers choose confidently.',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => IconButton(
              onPressed: () => setState(() => stars = i + 1),
              icon: Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 34,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          maxLines: 4,
          decoration: InputDecoration(labelText: 'Write a review (optional)'),
        ),
        const Spacer(),
        primaryAction('Submit review', () => c.go('/customer-home')),
      ],
    ),
  );
}
