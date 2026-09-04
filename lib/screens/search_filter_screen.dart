import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/service_model.dart';
import '../services/discovery_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key, this.discoveryService});

  final DiscoveryService? discoveryService;

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late final DiscoveryService _discoveryService =
      widget.discoveryService ?? DiscoveryService.instance;

  final TextEditingController _searchController = TextEditingController();

  bool _filterRating45 = false;
  bool _filterWithin5km = false;
  bool _filterAvailableToday = false;
  bool _filterUnder500 = false;

  bool _isLoading = false;
  String? _errorMessage;
  SearchResult? _searchResult;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final result = await _discoveryService.search(
        query: query.isNotEmpty ? query : null,
        minRating: _filterRating45 ? 4.5 : null,
        maxDistance: _filterWithin5km ? 5.0 : null,
        availableNow: _filterAvailableToday ? true : null,
        maxPrice: _filterUnder500 ? 500.0 : null,
      );

      if (!mounted) return;
      setState(() {
        _searchResult = result;
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
      title: 'Search',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Find a professional',
            'Search by service, skill, or provider name.',
          ),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'Try “plumbing”, “fan”, or “repair”',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: _performSearch,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('4.5+ rating'),
                selected: _filterRating45,
                selectedColor: AppTheme.primaryEmerald.withAlpha(50),
                checkmarkColor: AppTheme.primaryEmerald,
                onSelected: (val) {
                  setState(() => _filterRating45 = val);
                  _performSearch();
                },
              ),
              FilterChip(
                label: const Text('Within 5 km'),
                selected: _filterWithin5km,
                selectedColor: AppTheme.primaryEmerald.withAlpha(50),
                checkmarkColor: AppTheme.primaryEmerald,
                onSelected: (val) {
                  setState(() => _filterWithin5km = val);
                  _performSearch();
                },
              ),
              FilterChip(
                label: const Text('Available today'),
                selected: _filterAvailableToday,
                selectedColor: AppTheme.primaryEmerald.withAlpha(50),
                checkmarkColor: AppTheme.primaryEmerald,
                onSelected: (val) {
                  setState(() => _filterAvailableToday = val);
                  _performSearch();
                },
              ),
              FilterChip(
                label: const Text('Under ₹500'),
                selected: _filterUnder500,
                selectedColor: AppTheme.primaryEmerald.withAlpha(50),
                checkmarkColor: AppTheme.primaryEmerald,
                onSelected: (val) {
                  setState(() => _filterUnder500 = val);
                  _performSearch();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildResultsArea()),
          const SizedBox(height: 12),
          primaryAction(
            'Show nearby workers',
            () => context.push('/nearby-workers'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea() {
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
              onPressed: _performSearch,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry search'),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return const Center(
        child: Text(
          'Enter keywords or apply filters above to find services and verified professionals.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final result = _searchResult;
    if (result == null || result.totalResults == 0) {
      return const Center(
        child: Text(
          'No matching services or professionals found.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView(
      children: [
        if (result.services.isNotEmpty) ...[
          sectionLabel('Services (${result.services.length})'),
          ...result.services.map(
            (svc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () {
                  BookingFlowState.instance.selectedService = svc;
                  context.push('/service-details?serviceId=${svc.id}');
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
                    svc.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'From ₹${svc.basePrice.toStringAsFixed(0)} · ${svc.estimatedDurationMins} min',
                    style: const TextStyle(color: AppTheme.primaryEmerald),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (result.workers.isNotEmpty) ...[
          sectionLabel('Professionals (${result.workers.length})'),
          ...result.workers.map(
            (wrk) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () {
                  context.push('/nearby-workers');
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(
                    wrk.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    wrk.bio ?? 'Verified professional',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${wrk.averageRating.toStringAsFixed(1)} ★',
                        style: const TextStyle(
                          color: AppTheme.primaryEmerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (wrk.hourlyRate != null)
                        Text(
                          '₹${wrk.hourlyRate!.toStringAsFixed(0)}/hr',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
