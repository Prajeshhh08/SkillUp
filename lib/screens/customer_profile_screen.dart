import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/customer_account.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initial = CustomerAccount.fullName.isEmpty
        ? 'S'
        : CustomerAccount.fullName.characters.first.toUpperCase();
    return FlowScaffold(
      title: 'Your profile',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: AppTheme.primaryContainer,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              CustomerAccount.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Customer account',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),
            const AppCard(
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: AppTheme.primaryEmerald),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order acceptance', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Your bookings accepted by professionals', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('96%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primaryEmerald)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            sectionLabel('Account details'),
            AppCard(
              child: Column(
                children: [
                  _DetailRow(icon: Icons.person_outline_rounded, label: 'Full name', value: CustomerAccount.fullName),
                  const Divider(height: 24),
                  _DetailRow(icon: Icons.email_outlined, label: 'Email', value: CustomerAccount.email),
                  const Divider(height: 24),
                  _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: CustomerAccount.phone),
                ],
              ),
            ),
            const SizedBox(height: 18),
            sectionLabel('Jobs known'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                Chip(
                  avatar: Icon(
                    Icons.plumbing_rounded,
                    size: 18,
                    color: AppTheme.primaryEmerald,
                  ),
                  label: Text('Plumbing'),
                ),
                Chip(
                  avatar: Icon(
                    Icons.carpenter_rounded,
                    size: 18,
                    color: AppTheme.primaryEmerald,
                  ),
                  label: Text('Carpentry'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.push('/booking-history'),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('View booking history'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))])),
        ],
      );
}
