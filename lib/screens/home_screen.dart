import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext c) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            flowTitle(
              'Hello, professional',
              'Here is what is happening with your SkillUp account.',
            ),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search bookings',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 24),
            sectionLabel('Active bookings'),
            const AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Icon(Icons.home_repair_service_rounded),
                ),
                title: Text('Kitchen plumbing repair'),
                subtitle: Text('Today · 2:30 PM'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ),
            const Spacer(),
            primaryAction(
              'View verification status',
              () => c.push('/worker-status'),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: workerDashboardNav(c, 0),
  );
}
