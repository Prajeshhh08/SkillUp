import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/worker_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class WorkerBookingsScreen extends StatefulWidget {
  const WorkerBookingsScreen({super.key, this.service});

  final WorkerService? service;

  @override
  State<WorkerBookingsScreen> createState() => _WorkerBookingsScreenState();
}

class _WorkerBookingsScreenState extends State<WorkerBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final WorkerService _service;
  late final TabController _tabController;

  bool _isLoading = true;
  String? _error;
  List<BookingModel> _bookings = [];
  String? _processingBookingId;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WorkerService.instance;
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobs = await _service.getWorkerBookings();
      if (!mounted) return;
      setState(() {
        _bookings = jobs;
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

  Future<void> _acceptJob(BookingModel booking) async {
    setState(() => _processingBookingId = booking.id);
    try {
      await _service.acceptBooking(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job accepted! Moved to Active jobs.'),
          backgroundColor: AppTheme.primaryEmerald,
        ),
      );
      await _loadJobs();
      if (mounted) {
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept job: $e')),
      );
    } finally {
      if (mounted) setState(() => _processingBookingId = null);
    }
  }

  Future<void> _declineJob(BookingModel booking) async {
    setState(() => _processingBookingId = booking.id);
    try {
      await _service.declineBooking(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job request declined.')),
      );
      await _loadJobs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline job: $e')),
      );
    } finally {
      if (mounted) setState(() => _processingBookingId = null);
    }
  }

  Future<void> _updateStatus(BookingModel booking, String nextStatus) async {
    setState(() => _processingBookingId = booking.id);
    try {
      await _service.updateJobStatus(booking.id, nextStatus);
      if (!mounted) return;

      String message;
      if (nextStatus == 'ON_THE_WAY') {
        message = 'Status updated: On the way to customer!';
      } else if (nextStatus == 'IN_PROGRESS') {
        message = 'Status updated: Job in progress!';
      } else if (nextStatus == 'COMPLETED') {
        message =
            'Job completed! ₹${booking.quotedPrice.toStringAsFixed(0)} added to earnings.';
      } else {
        message = 'Status updated: $nextStatus';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.primaryEmerald,
        ),
      );

      await _loadJobs();
      if (nextStatus == 'COMPLETED' && mounted) {
        _tabController.animateTo(2);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      if (mounted) setState(() => _processingBookingId = null);
    }
  }

  List<BookingModel> get _newRequests =>
      _bookings
          .where((b) => b.status == 'PENDING' || b.status == 'OFFERED')
          .toList();

  List<BookingModel> get _activeJobs =>
      _bookings
          .where(
            (b) =>
                b.status == 'CONFIRMED' ||
                b.status == 'ON_THE_WAY' ||
                b.status == 'IN_PROGRESS',
          )
          .toList();

  List<BookingModel> get _historyJobs =>
      _bookings
          .where(
            (b) =>
                b.status == 'COMPLETED' ||
                b.status == 'CANCELLED' ||
                b.status == 'REJECTED',
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title: 'My bookings',
      bottomNavigationBar: workerDashboardNav(context, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Jobs for you',
            'Review new requests and keep track of your active work.',
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryEmerald,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.primaryEmerald,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Requests'),
                      if (_newRequests.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_newRequests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Active'),
                      if (_activeJobs.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryEmerald,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_activeJobs.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'History'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryEmerald,
                    ),
                  )
                : _error != null
                    ? _buildErrorView()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRequestsTab(),
                          _buildActiveTab(),
                          _buildHistoryTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
            const SizedBox(height: 8),
            const Text(
              'Failed to load jobs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _error ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    final requests = _newRequests;
    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadJobs,
        color: AppTheme.primaryEmerald,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No new job requests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'New customer bookings will appear here.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      color: AppTheme.primaryEmerald,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = requests[index];
          final isProcessing = _processingBookingId == booking.id;

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.primaryContainer,
                      child: Icon(
                        Icons.handyman_rounded,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceTitle ?? 'Home Service',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.addressText ?? 'Customer address provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${booking.quotedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primaryEmerald,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(booking.scheduledAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (booking.isEmergency) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'EMERGENCY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      'Note: ${booking.notes}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (isProcessing)
                  const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _declineJob(booking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptJob(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryEmerald,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Accept job'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTab() {
    final active = _activeJobs;
    if (active.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadJobs,
        color: AppTheme.primaryEmerald,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No active jobs right now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Accepted jobs will appear here for status tracking.',
                    style: TextStyle(
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
      onRefresh: _loadJobs,
      color: AppTheme.primaryEmerald,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: active.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = active[index];
          final isProcessing = _processingBookingId == booking.id;

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.primaryContainer,
                      child: Icon(
                        Icons.construction_rounded,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceTitle ?? 'Home Service',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ref: ${booking.bookingReference}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  booking.addressText ?? 'Address provided by customer',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(booking.scheduledAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${booking.quotedPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primaryEmerald,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      'Note: ${booking.notes}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (isProcessing)
                  const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  _buildStatusAction(booking),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusAction(BookingModel booking) {
    if (booking.status == 'CONFIRMED') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _updateStatus(booking, 'ON_THE_WAY'),
          icon: const Icon(Icons.navigation_rounded, size: 18),
          label: const Text('Start travel (On the way)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryEmerald,
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else if (booking.status == 'ON_THE_WAY') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _updateStatus(booking, 'IN_PROGRESS'),
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('Arrived & Start work'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade800,
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else if (booking.status == 'IN_PROGRESS') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _updateStatus(booking, 'COMPLETED'),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text('Complete job'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHistoryTab() {
    final history = _historyJobs;
    if (history.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadJobs,
        color: AppTheme.primaryEmerald,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No job history',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Completed and past jobs will appear here.',
                    style: TextStyle(
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
      onRefresh: _loadJobs,
      color: AppTheme.primaryEmerald,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: history.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = history[index];
          final price = booking.finalPrice ?? booking.quotedPrice;

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: booking.status == 'COMPLETED'
                          ? AppTheme.primaryContainer
                          : Colors.grey.shade200,
                      child: Icon(
                        booking.status == 'COMPLETED'
                            ? Icons.task_alt_rounded
                            : Icons.cancel_outlined,
                        color: booking.status == 'COMPLETED'
                            ? AppTheme.primaryEmerald
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceTitle ?? 'Home Service',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Ref: ${booking.bookingReference}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(booking.scheduledAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: booking.status == 'COMPLETED'
                            ? AppTheme.primaryEmerald
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (booking.cancellationReason != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Reason: ${booking.cancellationReason}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'OFFERED':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        label = 'Pending';
        break;
      case 'CONFIRMED':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        label = 'Confirmed';
        break;
      case 'ON_THE_WAY':
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        label = 'On the way';
        break;
      case 'IN_PROGRESS':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        label = 'In progress';
        break;
      case 'COMPLETED':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        label = 'Completed';
        break;
      case 'CANCELLED':
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = 'Cancelled';
        break;
      case 'REJECTED':
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        label = 'Declined';
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
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
    return '${dt.day}/${dt.month}/${dt.year} · $hour:$minute';
  }
}
