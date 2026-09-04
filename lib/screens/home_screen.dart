import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_model.dart';
import '../models/worker_profile.dart';
import '../services/worker_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.service});

  final WorkerService? service;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WorkerService _service;
  bool _isLoading = true;
  String? _error;
  WorkerMetrics? _metrics;
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WorkerService.instance;
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.getMetrics(),
        _service.getWorkerBookings(),
      ]);

      if (!mounted) return;
      setState(() {
        _metrics = results[0] as WorkerMetrics;
        _bookings = results[1] as List<BookingModel>;
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

  BookingModel? get _activeBooking {
    try {
      return _bookings.firstWhere(
        (b) =>
            b.status == 'CONFIRMED' ||
            b.status == 'ON_THE_WAY' ||
            b.status == 'IN_PROGRESS',
      );
    } catch (_) {
      try {
        return _bookings.firstWhere(
          (b) => b.status == 'PENDING' || b.status == 'OFFERED',
        );
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) context.go('/role');
        },
        child: Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadDashboard,
              color: AppTheme.primaryEmerald,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    flowTitle(
                      'Hello, professional',
                      'Here is what is happening with your SkillUp account.',
                    ),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                      )
                    else if (_error != null)
                      _buildErrorCard()
                    else ...[
                      _buildMetricsGrid(),
                      const SizedBox(height: 24),
                      sectionLabel('Active bookings'),
                      _buildActiveBookingCard(),
                      const SizedBox(height: 24),
                    ],
                    primaryAction(
                      'View verification status',
                      () => context.push('/worker-status'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/worker-bookings'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Duration(milliseconds: 100) == Duration.zero
                            ? null
                            : const Size.fromHeight(48),
                        side: const BorderSide(color: AppTheme.primaryEmerald),
                        foregroundColor: AppTheme.primaryEmerald,
                      ),
                      child: const Text('View all bookings & requests'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: workerDashboardNav(context, 0),
        ),
      );

  Widget _buildErrorCard() {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Failed to load dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryEmerald,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = _metrics ??
        const WorkerMetrics(
          acceptanceRate: 1.0,
          completedJobs: 0,
          totalEarnings: 0,
          averageRating: 5.0,
        );

    final ratingDisplay = metrics.averageRating > 0
        ? metrics.averageRating.toStringAsFixed(1)
        : '5.0';
    final acceptancePercent =
        '${(metrics.acceptanceRate * 100).clamp(0, 100).toStringAsFixed(0)}%';

    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            '₹${metrics.totalEarnings.toStringAsFixed(0)}',
            'Earnings',
            Icons.account_balance_wallet_rounded,
            AppTheme.primaryEmerald,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            '${metrics.completedJobs}',
            'Jobs done',
            Icons.task_alt_rounded,
            Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            '$ratingDisplay ★',
            'Rating',
            Icons.star_rounded,
            Colors.amber.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            acceptancePercent,
            'Acceptance',
            Icons.trending_up_rounded,
            Colors.purple.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingCard() {
    final booking = _activeBooking;
    if (booking == null) {
      return AppCard(
        onTap: () => context.push('/worker-bookings'),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryContainer,
                child: Icon(
                  Icons.inbox_outlined,
                  color: AppTheme.primaryEmerald,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No active bookings',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap to check new customer job requests.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            ],
          ),
        ),
      );
    }

    return AppCard(
      onTap: () => context.push('/worker-bookings'),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primaryContainer,
          child: Icon(
            Icons.home_repair_service_rounded,
            color: AppTheme.primaryEmerald,
          ),
        ),
        title: Text(
          booking.serviceTitle ?? 'Home service',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${_formatDate(booking.scheduledAt)} · ${booking.status.replaceAll('_', ' ')}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    if (isToday) return 'Today · $hour:$minute';
    return '${dt.day}/${dt.month} · $hour:$minute';
  }
}

