import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class InvoiceSuccessScreen extends StatefulWidget {
  const InvoiceSuccessScreen({super.key, this.bookingId, this.bookingService});

  final String? bookingId;
  final BookingService? bookingService;

  @override
  State<InvoiceSuccessScreen> createState() => _InvoiceSuccessScreenState();
}

class _InvoiceSuccessScreenState extends State<InvoiceSuccessScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;

  String? _resolvedBookingId;
  bool _isLoading = true;
  String? _errorMessage;
  InvoiceModel? _invoice;

  @override
  void initState() {
    super.initState();
    _resolvedBookingId =
        widget.bookingId ?? BookingFlowState.instance.activeBooking?.id;
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
      final queryId = GoRouterState.of(
        context,
      ).uri.queryParameters['bookingId'];
      if (queryId != null && queryId.isNotEmpty) {
        _resolvedBookingId = queryId;
      }
    } catch (_) {}

    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? idToFetch = _resolvedBookingId;
      if (idToFetch == null || idToFetch.isEmpty) {
        final list = await _bookingService.getCustomerBookings();
        if (list.isNotEmpty) {
          idToFetch = list.first.id;
          _resolvedBookingId = idToFetch;
        } else {
          throw Exception('No booking found for invoice.');
        }
      }

      final invoice = await _bookingService.getInvoice(idToFetch);
      if (!mounted) return;
      setState(() {
        _invoice = invoice;
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
    return FlowScaffold(title: 'Invoice', child: _buildBody());
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
              onPressed: _loadInvoice,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final invoice = _invoice;
    if (invoice == null) {
      return const Center(
        child: Text(
          'Invoice details unavailable.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          invoice.serviceTitle,
          'Invoice ${invoice.invoiceNumber} · Ref: #${invoice.bookingReference}',
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer: ${invoice.customerName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (invoice.workerName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Professional: ${invoice.workerName!}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
              const Divider(height: 20),
              ...invoice.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.description),
                      Text('₹${item.amount.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('₹${invoice.subtotal.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Taxes & GST'),
                  Text('₹${invoice.taxAmount.toStringAsFixed(0)}'),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total paid',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    '₹${invoice.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        primaryAction('Rate your experience', () {
          final id = _resolvedBookingId ?? invoice.bookingReference;
          context.push('/rating-review?bookingId=$id');
        }),
      ],
    );
  }
}
