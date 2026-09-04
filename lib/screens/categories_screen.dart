import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/skill_category.dart';
import '../services/discovery_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.discoveryService});

  final DiscoveryService? discoveryService;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final DiscoveryService _discoveryService =
      widget.discoveryService ?? DiscoveryService.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<SkillCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _discoveryService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories.where((c) => c.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  IconData _iconForCategory(SkillCategory category) {
    final slug = category.slug.toLowerCase();
    final name = category.name.toLowerCase();

    if (slug.contains('plumb') || name.contains('plumb')) {
      return Icons.plumbing_rounded;
    }
    if (slug.contains('electr') || name.contains('electr')) {
      return Icons.electrical_services_rounded;
    }
    if (slug.contains('carpent') || name.contains('carpent')) {
      return Icons.carpenter_rounded;
    }
    if (slug.contains('appliance') || name.contains('appliance')) {
      return Icons.settings_suggest_rounded;
    }
    if (slug.contains('clean') || name.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    if (slug.contains('paint') || name.contains('paint')) {
      return Icons.format_paint_rounded;
    }
    return Icons.handyman_rounded;
  }

  @override
  Widget build(BuildContext context) => FlowScaffold(
    title: 'Services',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'What do you need help with?',
          'Browse trusted services available in your area.',
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody()),
      ],
    ),
  );

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.error),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No categories available right now.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadCategories,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return AppCard(
            onTap: () {
              BookingFlowState.instance.selectedCategory = category;
              final encodedName = Uri.encodeComponent(category.name);
              context.push(
                '/services?categoryId=${category.id}&category=$encodedName',
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconForCategory(category),
                  size: 30,
                  color: AppTheme.primaryEmerald,
                ),
                const SizedBox(height: 10),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
