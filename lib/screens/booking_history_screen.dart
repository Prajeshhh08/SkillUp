import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: FlowScaffold(
          title: 'Booking history',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              flowTitle(
                'Your bookings',
                'Review active, completed, and cancelled services.',
              ),
              const TabBar(
                labelColor: AppTheme.primaryEmerald,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryEmerald,
                tabs: [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _BookingList(
                      title: 'Standard plumbing visit',
                      subtitle: 'Tomorrow · Morning · Ravi Kumar',
                      icon: Icons.directions_run_rounded,
                      status: 'On the way',
                      onTap: () => context.push('/active-booking'),
                    ),
                    _BookingList(
                      title: 'Standard plumbing visit',
                      subtitle: 'Completed · 28 August',
                      icon: Icons.check_circle_rounded,
                      status: 'Completed',
                      onTap: () => context.push('/order-summary'),
                    ),
                    _BookingList(
                      title: 'No cancelled bookings',
                      subtitle: 'Cancelled services will appear here.',
                      icon: Icons.event_busy_rounded,
                      status: '',
                      onTap: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          AppCard(
            onTap: onTap,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: AppTheme.primaryEmerald),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: status.isEmpty
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          status,
                          style: const TextStyle(
                            color: AppTheme.primaryEmerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
            ),
          ),
          if (status == 'Completed') ...[
            const SizedBox(height: 12),
            AppCard(
              onTap: () => context.push('/rebook'),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.refresh_rounded),
                title: Text('Rebook this service'),
                subtitle: Text('Use your previous booking details'),
              ),
            ),
          ],
        ],
      );
}
