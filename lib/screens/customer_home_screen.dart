import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                flowTitle(
                  'Find help for your home',
                  'Book trusted professionals near you.',
                ),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'What do you need help with?',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 24),
                sectionLabel('Popular services'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['Plumber', 'Electrician', 'Painter', 'Cleaner']
                      .map(
                        (x) => Chip(
                          avatar: const Icon(
                            Icons.handyman_rounded,
                            size: 17,
                            color: AppTheme.primaryEmerald,
                          ),
                          label: Text(x),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 26),
                sectionLabel('Quick actions'),
                AppCard(
                  onTap: () => c.go('/terms-confirm'),
                  child: const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.add_home_work_rounded,
                      color: AppTheme.primaryEmerald,
                    ),
                    title: Text('Book a professional'),
                    subtitle: Text('Tell us what you need help with'),
                  ),
                ),
                const SizedBox(height: 16),
                sectionLabel('Recently viewed'),
                const AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Icon(Icons.person_rounded)),
                    title: Text('Ravi Kumar'),
                    subtitle: Text('Electrician · 4.8 ★'),
                    trailing: Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DashboardNav(index: 0, onTap: (_) => {}),
    );
  }
}
