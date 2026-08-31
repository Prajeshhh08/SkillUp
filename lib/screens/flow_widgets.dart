import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

class FlowScaffold extends StatelessWidget {
  const FlowScaffold({super.key, required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              }
            },
          ),
          title: const BrandLogo(size: 36, showShadow: false),
          actions: action == null ? null : [action!],
        ),
        body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 24), child: child)),
      );
}

Widget flowTitle(String title, String subtitle) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(title, style: GoogleFonts.inter(fontSize: 27, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
  const SizedBox(height: 8),
  Text(subtitle, style: GoogleFonts.inter(fontSize: 14, height: 1.45, color: AppTheme.textSecondary)),
  const SizedBox(height: 28),
]);

Widget primaryAction(String label, VoidCallback onPressed) => ElevatedButton(onPressed: onPressed, child: Text(label));

Widget sectionLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: .8)));

class DashboardNav extends StatelessWidget {
  const DashboardNav({super.key, required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index, onDestinationSelected: onTap,
    destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'), NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Bookings'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profile')],
  );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap});
  final Widget child; final VoidCallback? onTap;
  @override Widget build(BuildContext context) => Material(color: AppTheme.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppTheme.radiusMd), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: AppTheme.borderColor), borderRadius: BorderRadius.circular(AppTheme.radiusMd), boxShadow: AppTheme.cardShadow), child: child)));
}
