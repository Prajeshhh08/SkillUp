import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class MapMatchingScreen extends StatelessWidget {
  const MapMatchingScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Map view',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Professionals around you',
          'Choose a nearby professional directly from the map.',
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.map_rounded,
                    size: 100,
                    color: AppTheme.primaryLight,
                  ),
                ),
                ...const [
                  Alignment(-.4, -.2),
                  Alignment(.35, .15),
                  Alignment(.1, -.5),
                ].map(
                  (a) => Align(
                    alignment: a,
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.primaryEmerald,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          onTap: () => c.push('/worker-profile'),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Ravi Kumar'),
            subtitle: Text('Plumber · 1.2 km away'),
            trailing: Icon(Icons.arrow_forward_rounded),
          ),
        ),
      ],
    ),
  );
}
