import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class SearchFilterScreen extends StatelessWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Search',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Find a professional',
          'Search by service, skill, or provider name.',
        ),
        const TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Try “electrician”',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ['4.5+ rating', 'Within 5 km', 'Available today', 'Under ₹500']
                  .map(
                    (x) => FilterChip(
                      label: Text(x),
                      selected: false,
                      onSelected: (_) => {},
                    ),
                  )
                  .toList(),
        ),
        const Spacer(),
        primaryAction('Show nearby workers', () => c.push('/nearby-workers')),
      ],
    ),
  );
}
