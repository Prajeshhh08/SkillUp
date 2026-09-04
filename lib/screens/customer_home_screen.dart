import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/skill_category.dart';
import '../services/discovery_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key, this.discoveryService});

  final DiscoveryService? discoveryService;

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late final DiscoveryService _discoveryService;
  bool _isLoading = true;
  String? _error;
  List<SkillCategory> _categories = [];

  static const _defaultCategories = [
    ('Plumber', 'plumbing'),
    ('Electrician', 'electrical'),
    ('Painter', 'painting'),
    ('Cleaner', 'cleaning'),
  ];

  @override
  void initState() {
    super.initState();
    _discoveryService = widget.discoveryService ?? DiscoveryService.instance;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _discoveryService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = list.where((c) => c.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  IconData _iconForCategory(String nameOrSlug) {
    final lower = nameOrSlug.toLowerCase();
    if (lower.contains('plumb')) return Icons.plumbing_rounded;
    if (lower.contains('electr')) return Icons.electrical_services_rounded;
    if (lower.contains('carpent')) return Icons.carpenter_rounded;
    if (lower.contains('appliance')) return Icons.settings_suggest_rounded;
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    if (lower.contains('paint')) return Icons.format_paint_rounded;
    return Icons.handyman_rounded;
  }

  Widget _buildPopularServices(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primaryEmerald,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 36),
            const SizedBox(height: 8),
            const Text(
              'Unable to load services',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_categories.isNotEmpty) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _categories.map((category) {
          return ActionChip(
            avatar: Icon(
              _iconForCategory(category.slug),
              size: 17,
              color: AppTheme.primaryEmerald,
            ),
            label: Text(category.name),
            onPressed: () {
              BookingFlowState.instance.selectedCategory = category;
              context.push('/services?category=${category.slug}');
            },
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _defaultCategories.map((pair) {
        return ActionChip(
          avatar: Icon(
            _iconForCategory(pair.$2),
            size: 17,
            color: AppTheme.primaryEmerald,
          ),
          label: Text(pair.$1),
          onPressed: () => context.push('/services?category=${pair.$2}'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext c) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) c.go('/role');
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadCategories,
            color: AppTheme.primaryEmerald,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  flowTitle(
                    'Find help for your home',
                    'Book trusted professionals near you.',
                  ),
                  TextField(
                    onTap: () => c.push('/search'),
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'What do you need help with?',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 24),
                  sectionLabel('Popular services'),
                  _buildPopularServices(c),
                  const SizedBox(height: 26),
                  sectionLabel('Quick actions'),
                  AppCard(
                    onTap: () => c.push('/categories'),
                    child: const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.add_home_work_rounded,
                        color: AppTheme.primaryEmerald,
                      ),
                      title: Text('Browse services'),
                      subtitle: Text('Tell us what you need help with'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    onTap: () => c.push('/emergency-booking'),
                    child: const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.emergency_rounded,
                        color: AppTheme.error,
                      ),
                      title: Text('Emergency booking'),
                      subtitle: Text('Request urgent help now'),
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
        bottomNavigationBar: customerDashboardNav(c, 0),
      ),
    );
  }
}
