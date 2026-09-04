import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/service_model.dart';
import '../services/discovery_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class NearbyWorkersScreen extends StatefulWidget {
  const NearbyWorkersScreen({
    super.key,
    this.discoveryService,
    this.latitude,
    this.longitude,
    this.serviceId,
  });

  final DiscoveryService? discoveryService;
  final double? latitude;
  final double? longitude;
  final String? serviceId;

  @override
  State<NearbyWorkersScreen> createState() => _NearbyWorkersScreenState();
}

class _NearbyWorkersScreenState extends State<NearbyWorkersScreen> {
  late final DiscoveryService _discoveryService =
      widget.discoveryService ?? DiscoveryService.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<NearbyWorkerItem> _workers = [];

  late final double _lat =
      widget.latitude ??
      LocationService.instance.lastKnownPosition?.latitude ??
      12.9716;
  late final double _lng =
      widget.longitude ??
      LocationService.instance.lastKnownPosition?.longitude ??
      77.5946;
  String? _serviceId;

  @override
  void initState() {
    super.initState();
    _serviceId =
        widget.serviceId ?? BookingFlowState.instance.selectedService?.id;
    _loadNearbyWorkers();
  }

  Future<void> _loadNearbyWorkers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workers = await _discoveryService.getNearbyWorkers(
        latitude: _lat,
        longitude: _lng,
        serviceId: _serviceId,
      );
      if (!mounted) return;
      setState(() {
        _workers = workers;
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
      title: 'Nearby professionals',
      action: IconButton(
        icon: const Icon(Icons.map_outlined),
        onPressed: () => context.push('/map-matching'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Available near you',
            'Verified professionals ready to help with your request.',
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadNearbyWorkers,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No active professionals found nearby.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadNearbyWorkers,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNearbyWorkers,
      child: ListView.separated(
        itemCount: _workers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final worker = _workers[i];
          final distanceStr = '${worker.distanceKm.toStringAsFixed(1)} km away';
          final bioOrRole = (worker.bio != null && worker.bio!.isNotEmpty)
              ? worker.bio!
              : 'Verified professional';

          return AppCard(
            onTap: () {
              BookingFlowState.instance.selectedWorker = worker;
              context.push('/worker-profile');
            },
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 25,
                child: Icon(Icons.person_rounded),
              ),
              title: Text(
                worker.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    '$bioOrRole · $distanceStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (worker.hourlyRate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '₹${worker.hourlyRate!.toStringAsFixed(0)}/hr',
                      style: const TextStyle(
                        color: AppTheme.primaryEmerald,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${worker.averageRating.toStringAsFixed(1)} ★',
                    style: const TextStyle(
                      color: AppTheme.primaryEmerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Verified', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
