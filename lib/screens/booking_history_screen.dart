import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key, this.bookingService});

  final BookingService? bookingService;

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _bookingService.getCustomerBookings();
      if (!mounted) return;
      setState(() {
        _bookings = list;
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
    final activeBookings = _bookings.where((b) => b.isActive).toList();
    final completedBookings = _bookings.where((b) => b.isCompleted).toList();
    final cancelledBookings = _bookings.where((b) => b.isCancelled).toList();

    return DefaultTabController(
      length: 3,
      child: FlowScaffold(
        title: 'Booking history',
        bottomNavigationBar: customerDashboardNav(context, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            flowTitle(
              'Your bookings',
              'Review active, completed, and cancelled services.',
            ),
            const TabBar(
              labelColor: AppTheme.primaryEmerald,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryEmerald,
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
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
                            onPressed: _loadBookings,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      children: [
                        _buildBookingList(
                          bookings: activeBookings,
                          emptyTitle: 'No active bookings',
                          emptySubtitle:
                              'Book a service to track your active orders here.',
                          icon: Icons.directions_run_rounded,
                          onTap: (b) => context
                              .push('/active-booking?bookingId=${b.id}')
                              .then((_) => _loadBookings()),
                        ),
                        _buildBookingList(
                          bookings: completedBookings,
                          emptyTitle: 'No completed bookings',
                          emptySubtitle:
                              'Completed jobs with invoices will be listed here.',
                          icon: Icons.check_circle_rounded,
                          showRebook: true,
                          onTap: (b) => context
                              .push('/order-summary?bookingId=${b.id}')
                              .then((_) => _loadBookings()),
                        ),
                        _buildBookingList(
                          bookings: cancelledBookings,
                          emptyTitle: 'No cancelled bookings',
                          emptySubtitle: 'Cancelled services will appear here.',
                          icon: Icons.event_busy_rounded,
                          onTap: (b) => context
                              .push('/order-summary?bookingId=${b.id}')
                              .then((_) => _loadBookings()),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList({
    required List<BookingModel> bookings,
    required String emptyTitle,
    required String emptySubtitle,
    required IconData icon,
    required void Function(BookingModel) onTap,
    bool showRebook = false,
  }) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56, color: AppTheme.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    emptyTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emptySubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final b = bookings[i];
          final title = b.serviceTitle ?? 'Home Service';
          final dateStr =
              '${b.scheduledAt.day}/${b.scheduledAt.month}/${b.scheduledAt.year}';
          final workerStr = b.workerName ?? 'Professional';
          final priceStr = '₹${b.quotedPrice.toStringAsFixed(0)}';

          return AppCard(
            onTap: () => onTap(b),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(icon, color: AppTheme.primaryEmerald),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('$dateStr · $workerStr · $priceStr'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        b.status,
                        style: const TextStyle(
                          color: AppTheme.primaryEmerald,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                if (showRebook) ...[
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => context
                            .push('/rebook?bookingId=${b.id}')
                            .then((_) => _loadBookings()),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Rebook'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
