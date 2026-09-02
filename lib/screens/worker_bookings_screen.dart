import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class WorkerBookingsScreen extends StatefulWidget {
  const WorkerBookingsScreen({super.key});

  @override
  State<WorkerBookingsScreen> createState() => _WorkerBookingsScreenState();
}

class _WorkerBookingsScreenState extends State<WorkerBookingsScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) => FlowScaffold(
        title: 'My bookings',
        bottomNavigationBar: workerDashboardNav(context, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            flowTitle(
              'Jobs for you',
              'Review new requests and keep track of your active work.',
            ),
            sectionLabel('New request'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryContainer,
                        child: Icon(
                          Icons.plumbing_rounded,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kitchen plumbing repair',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Ananya S. · 2.1 km away',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹499',
                        style: TextStyle(
                          color: AppTheme.primaryEmerald,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Today · 2:30 PM · Home visit'),
                  const SizedBox(height: 14),
                  if (_accepted)
                    const Chip(
                      avatar: Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.success,
                        size: 18,
                      ),
                      label: Text('Accepted — customer notified'),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Booking declined.'))),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _accepted = true),
                            child: const Text('Accept job'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            sectionLabel('Active booking'),
            const AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Icon(Icons.home_repair_service_rounded),
                ),
                title: Text('Bathroom fixture installation'),
                subtitle: Text('Tomorrow · 10:00 AM · In progress'),
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ),
          ],
        ),
      );
}
