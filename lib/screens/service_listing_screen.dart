import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/service_model.dart';
import '../services/discovery_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class ServiceListingScreen extends StatefulWidget {
  const ServiceListingScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.discoveryService,
  });

  final String? categoryId;
  final String? categoryName;
  final DiscoveryService? discoveryService;

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  late final DiscoveryService _discoveryService =
      widget.discoveryService ?? DiscoveryService.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<ServiceModel> _services = [];

  String? _resolvedCategoryId;
  String _resolvedCategoryName = 'Home services';

  @override
  void initState() {
    super.initState();
    _resolvedCategoryId = widget.categoryId;
    if (widget.categoryName != null) {
      _resolvedCategoryName = widget.categoryName!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveParamsAndLoad();
  }

  bool _hasLoaded = false;

  void _resolveParamsAndLoad() {
    if (_hasLoaded) return;
    _hasLoaded = true;

    try {
      final state = GoRouterState.of(context);
      final queryCatId = state.uri.queryParameters['categoryId'];
      final queryCatName = state.uri.queryParameters['category'];

      if (_resolvedCategoryId == null &&
          queryCatId != null &&
          queryCatId.isNotEmpty) {
        _resolvedCategoryId = queryCatId;
      }
      if (queryCatName != null && queryCatName.isNotEmpty) {
        _resolvedCategoryName = queryCatName;
      }
    } catch (_) {
      // In tests without GoRouterState
    }

    if (_resolvedCategoryId == null &&
        BookingFlowState.instance.selectedCategory != null) {
      _resolvedCategoryId = BookingFlowState.instance.selectedCategory!.id;
      _resolvedCategoryName = BookingFlowState.instance.selectedCategory!.name;
    }

    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final services = await _discoveryService.getServices(
        categoryId: _resolvedCategoryId,
      );
      if (!mounted) return;
      setState(() {
        _services = services.where((s) => s.isActive).toList();
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

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title: _resolvedCategoryName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            '$_resolvedCategoryName services',
            'Choose a service and view transparent pricing before you book.',
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

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
              onPressed: _loadServices,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No services available in this category yet.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadServices,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.separated(
        itemCount: _services.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (c, i) {
          final service = _services[i];
          final priceText = 'From ₹${service.basePrice.toStringAsFixed(0)}';
          final durationText = '${service.estimatedDurationMins} min';

          return AppCard(
            onTap: () {
              BookingFlowState.instance.selectedService = service;
              c.push('/service-details?serviceId=${service.id}');
            },
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryLight,
                child: Icon(
                  Icons.home_repair_service_rounded,
                  color: AppTheme.primaryEmerald,
                ),
              ),
              title: Text(
                service.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '$priceText · $durationText',
                    style: const TextStyle(
                      color: AppTheme.primaryEmerald,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (service.description != null &&
                      service.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      service.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
      ),
    );
  }
}
