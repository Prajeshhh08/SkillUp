import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class NearbyWorkersScreen extends StatelessWidget {
  const NearbyWorkersScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final names = ['Ravi Kumar', 'Anita Sharma', 'Mohammed Ali'];
    final skills = [
      'Plumber · 1.2 km',
      'Electrician · 2.4 km',
      'Home services · 3.1 km',
    ];

    return FlowScaffold(
      title: 'Nearby professionals',
      action: IconButton(
        icon: const Icon(Icons.map_outlined),
        onPressed: () => c.push('/map-matching'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Available near you',
            'Verified professionals ready to help with your request.',
          ),
          Expanded(
            child: ListView.separated(
              itemCount: names.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => AppCard(
                onTap: () => c.push('/worker-profile'),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(names[i]),
                  subtitle: Text(skills[i]),
                  trailing: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '4.8 ★',
                        style: TextStyle(color: AppTheme.primaryEmerald),
                      ),
                      Text('Verified', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
