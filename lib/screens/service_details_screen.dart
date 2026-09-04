import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/service_model.dart';
import '../services/discovery_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({
    super.key,
    this.serviceId,
    this.initialService,
    this.discoveryService,
  });

  final String? serviceId;
  final ServiceModel? initialService;
  final DiscoveryService? discoveryService;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late final DiscoveryService _discoveryService =
      widget.discoveryService ?? DiscoveryService.instance;

  bool _isLoading = false;
  String? _errorMessage;
  ServiceModel? _service;
  String? _resolvedServiceId;

  @override
  void initState() {
    super.initState();
    _service =
        widget.initialService ?? BookingFlowState.instance.selectedService;
    _resolvedServiceId = widget.serviceId ?? _service?.id;
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
      final queryServiceId = GoRouterState.of(
        context,
      ).uri.queryParameters['serviceId'];
      if (queryServiceId != null && queryServiceId.isNotEmpty) {
        _resolvedServiceId = queryServiceId;
      }
    } catch (_) {
      // In tests without GoRouterState
    }

    if (_service != null &&
        (_resolvedServiceId == null || _service!.id == _resolvedServiceId)) {
      return;
    }

    if (_resolvedServiceId != null && _resolvedServiceId!.isNotEmpty) {
      _loadServiceDetails(_resolvedServiceId!);
    }
  }

  Future<void> _loadServiceDetails(String serviceId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await _discoveryService.getServiceDetails(serviceId);
      if (!mounted) return;
      setState(() {
        _service = service;
        BookingFlowState.instance.selectedService = service;
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
    return FlowScaffold(title: 'Service details', child: _buildBody());
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
              onPressed: () {
                if (_resolvedServiceId != null) {
                  _loadServiceDetails(_resolvedServiceId!);
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final service = _service;
    if (service == null) {
      return const Center(
        child: Text(
          'Service not found.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final inclusions = service.inclusions.isNotEmpty
        ? service.inclusions
        : const [
            'Verified local professional',
            'Upfront pricing with no hidden charges',
            '30-day service support',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                flowTitle(
                  service.title,
                  service.description ??
                      'A verified professional assesses and resolves your service request.',
                ),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From ₹${service.basePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Estimated duration: ${service.estimatedDurationMins} mins',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                sectionLabel('What is included'),
                ...inclusions.map(
                  (x) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.success,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(x, style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        primaryAction('Book now', () {
          BookingFlowState.instance.selectedService = service;
          context.push('/booking-schedule?serviceId=${service.id}');
        }),
      ],
    );
  }
}
