import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({super.key, this.bookingId, this.totalAmount});

  final String? bookingId;
  final double? totalAmount;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  String _method = 'UPI';
  String? _resolvedBookingId;
  late double _amount;

  @override
  void initState() {
    super.initState();
    _resolvedBookingId =
        widget.bookingId ?? BookingFlowState.instance.activeBooking?.id;
    _amount =
        widget.totalAmount ??
        BookingFlowState.instance.activeQuote?.totalQuotedPrice ??
        BookingFlowState.instance.activeBooking?.quotedPrice ??
        299.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final queryId = GoRouterState.of(
        context,
      ).uri.queryParameters['bookingId'];
      if (queryId != null && queryId.isNotEmpty) {
        _resolvedBookingId = queryId;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext c) {
    final amountText = '₹${_amount.toStringAsFixed(0)}';

    return FlowScaffold(
      title: 'Payment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Complete your booking',
            'Choose a payment method. Payments are currently in sandbox mode.',
          ),
          ...[
            'UPI',
            'Credit/Debit Card',
            'NetBanking',
            'Cash after service',
          ].map(
            (x) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                x == 'UPI'
                    ? Icons.qr_code_rounded
                    : x == 'Credit/Debit Card'
                    ? Icons.credit_card_rounded
                    : x == 'NetBanking'
                    ? Icons.account_balance_rounded
                    : Icons.payments_rounded,
                color: _method == x
                    ? AppTheme.primaryEmerald
                    : AppTheme.textSecondary,
              ),
              title: Text(x),
              trailing: _method == x
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primaryEmerald,
                    )
                  : const Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: AppTheme.textSecondary,
                    ),
              onTap: () => setState(() => _method = x),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total payable',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  amountText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          primaryAction('Pay $amountText', () {
            final targetId =
                _resolvedBookingId ??
                BookingFlowState.instance.activeBooking?.id;
            final path = targetId != null && targetId.isNotEmpty
                ? '/booking-confirmation?bookingId=$targetId'
                : '/booking-confirmation';
            c.push(path);
          }),
        ],
      ),
    );
  }
}
