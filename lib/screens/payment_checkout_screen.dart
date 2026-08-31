import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({super.key});

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  String method = 'UPI';

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Payment',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Complete your booking',
          'Choose a payment method. You will only be charged after confirmation.',
        ),
        ...['UPI', 'Card', 'NetBanking'].map(
          (x) => RadioListTile<String>(
            value: x,
            groupValue: method,
            onChanged: (v) => setState(() => method = v!),
            title: Text(x),
          ),
        ),
        const AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total payable',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '₹299',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppTheme.primaryEmerald,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        primaryAction('Pay ₹299', () => c.push('/booking-confirmation')),
      ],
    ),
  );
}
