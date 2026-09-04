import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/booking_model.dart';
import '../models/customer_address.dart';
import '../services/booking_service.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class BookingReviewScreen extends StatefulWidget {
  const BookingReviewScreen({
    super.key,
    this.bookingService,
    this.customerService,
  });

  final BookingService? bookingService;
  final CustomerService? customerService;

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;
  late final CustomerService _customerService =
      widget.customerService ?? CustomerService.instance;

  final TextEditingController _notesController = TextEditingController();

  bool _isLoadingAddresses = true;
  bool _isCalculatingQuote = false;
  bool _isSubmitting = false;

  String? _errorMessage;
  List<CustomerAddress> _addresses = [];
  CustomerAddress? _selectedAddress;
  QuoteModel? _quote;

  @override
  void initState() {
    super.initState();
    _notesController.text = BookingFlowState.instance.notes ?? '';
    _loadAddressesAndQuote();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressesAndQuote() async {
    setState(() {
      _isLoadingAddresses = true;
      _errorMessage = null;
    });

    try {
      final addresses = await _customerService.getAddresses();
      if (!mounted) return;

      CustomerAddress? chosen = BookingFlowState.instance.selectedAddress;
      if (chosen == null && addresses.isNotEmpty) {
        chosen = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }

      setState(() {
        _addresses = addresses;
        _selectedAddress = chosen;
        BookingFlowState.instance.selectedAddress = chosen;
        _isLoadingAddresses = false;
      });

      if (chosen != null) {
        await _fetchQuote(chosen);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _fetchQuote(CustomerAddress address) async {
    final service = BookingFlowState.instance.selectedService;
    if (service == null) return;

    setState(() {
      _isCalculatingQuote = true;
      _errorMessage = null;
    });

    try {
      final quote = await _bookingService.calculateQuote(
        QuoteRequestPayload(serviceId: service.id, addressId: address.id),
      );
      if (!mounted) return;
      setState(() {
        _quote = quote;
        BookingFlowState.instance.activeQuote = quote;
        _isCalculatingQuote = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isCalculatingQuote = false;
      });
    }
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select service address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._addresses.map(
                (addr) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    addr.label.toLowerCase() == 'home'
                        ? Icons.home_rounded
                        : Icons.location_on_rounded,
                    color: AppTheme.primaryEmerald,
                  ),
                  title: Text(addr.label),
                  subtitle: Text(addr.shortLine),
                  trailing: _selectedAddress?.id == addr.id
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.success,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedAddress = addr;
                      BookingFlowState.instance.selectedAddress = addr;
                    });
                    _fetchQuote(addr);
                  },
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context
                      .push('/address')
                      .then((_) => _loadAddressesAndQuote());
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add new address'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitBooking() async {
    final service = BookingFlowState.instance.selectedService;
    final address = _selectedAddress;

    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a service first.')),
      );
      return;
    }

    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a delivery address.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final scheduledAt = BookingFlowState.instance.resolvedScheduledAt;
      final worker = BookingFlowState.instance.selectedWorker;
      final notes = _notesController.text.trim();

      final booking = await _bookingService.createBooking(
        BookingCreatePayload(
          serviceId: service.id,
          addressId: address.id,
          workerId: worker?.workerId,
          scheduledAt: scheduledAt,
          notes: notes.isNotEmpty ? notes : null,
        ),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      BookingFlowState.instance.activeBooking = booking;

      // Navigate to payment checkout (mocked payment per Phase 1 scope)
      context.push('/payment-checkout?bookingId=${booking.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = BookingFlowState.instance.selectedService;
    final date =
        BookingFlowState.instance.selectedDateTime ??
        DateTime.now().add(const Duration(days: 1));
    final window = BookingFlowState.instance.timeWindow;
    final worker = BookingFlowState.instance.selectedWorker;

    return FlowScaffold(
      title: 'Review booking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Almost there',
            'Please confirm your service details before placing the booking.',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service?.title ?? 'Selected Service',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${date.day}/${date.month}/${date.year} · $window',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (worker != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Professional: ${worker.fullName}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  sectionLabel('Service address'),
                  if (_isLoadingAddresses)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_selectedAddress != null)
                    AppCard(
                      onTap: _showAddressSelector,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.primaryEmerald,
                        ),
                        title: Text(_selectedAddress!.label),
                        subtitle: Text(_selectedAddress!.shortLine),
                        trailing: const Text(
                          'Change',
                          style: TextStyle(
                            color: AppTheme.primaryEmerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    AppCard(
                      onTap: () => context
                          .push('/address')
                          .then((_) => _loadAddressesAndQuote()),
                      child: const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.add_location_alt_rounded,
                          color: AppTheme.primaryEmerald,
                        ),
                        title: Text('Add delivery address'),
                        subtitle: Text('Tap to set up your service location'),
                        trailing: Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  const SizedBox(height: 16),
                  sectionLabel('Price details'),
                  _buildPriceCard(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Special instructions / notes (optional)',
                      hintText: 'e.g. Ring bell twice, ground floor unit',
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          primaryAction(
            _isSubmitting ? 'Placing booking...' : 'Confirm booking',
            _isSubmitting ? () {} : _submitBooking,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    if (_isCalculatingQuote) {
      return const AppCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final quote = _quote;
    final basePrice =
        quote?.basePrice ??
        BookingFlowState.instance.selectedService?.basePrice ??
        299.0;
    final total = quote?.totalQuotedPrice ?? basePrice;

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Base service charge'),
              Text('₹${basePrice.toStringAsFixed(0)}'),
            ],
          ),
          if (quote != null && quote.distanceFee > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Distance fee'),
                Text('₹${quote.distanceFee.toStringAsFixed(0)}'),
              ],
            ),
          ],
          if (quote != null && quote.taxAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Taxes & GST (18%)'),
                Text('₹${quote.taxAmount.toStringAsFixed(0)}'),
              ],
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated total',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
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
    );
  }
}
