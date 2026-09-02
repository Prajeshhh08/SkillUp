import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class WorkerAccountProfileScreen extends StatelessWidget {
  const WorkerAccountProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => FlowScaffold(
        title: 'My profile',
        bottomNavigationBar: workerDashboardNav(context, 2),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: AppTheme.primaryContainer,
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Ravi Kumar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Verified professional · 4.8 ★',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 26),
              const AppCard(
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppTheme.primaryEmerald),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Job acceptance rate', style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Based on your recent job offers', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Text('96%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primaryEmerald)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              sectionLabel('Professional details'),
              const AppCard(
                child: Column(
                  children: [
                    _WorkerDetail(icon: Icons.handyman_rounded, label: 'Primary service', value: 'Plumbing'),
                    Divider(height: 24),
                    _WorkerDetail(icon: Icons.workspace_premium_rounded, label: 'Experience', value: '5 years'),
                    Divider(height: 24),
                    _WorkerDetail(icon: Icons.currency_rupee_rounded, label: 'Hourly rate', value: '₹350'),
                    Divider(height: 24),
                    _WorkerDetail(icon: Icons.schedule_rounded, label: 'Availability', value: 'Weekdays · 9 AM–6 PM'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              sectionLabel('Skills'),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Chip(avatar: Icon(Icons.plumbing_rounded, size: 18, color: AppTheme.primaryEmerald), label: Text('Plumbing')),
                  Chip(avatar: Icon(Icons.carpenter_rounded, size: 18, color: AppTheme.primaryEmerald), label: Text('Carpentry')),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.push('/worker-form'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit professional profile'),
              ),
            ],
          ),
        ),
      );
}

class _WorkerDetail extends StatelessWidget {
  const _WorkerDetail({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppTheme.textSecondary),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))])),
  ]);
}
