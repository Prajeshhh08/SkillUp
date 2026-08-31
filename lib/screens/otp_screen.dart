import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final flow = GoRouterState.of(c).uri.queryParameters['flow'] ?? 'worker';
    return FlowScaffold(
      title: 'Verify phone',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Enter verification code',
            'We sent a six-digit code to your phone number.',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (i) => SizedBox(
                width: 44,
                child: TextField(
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          primaryAction('Verify', () => c.push('/terms?flow=$flow')),
          TextButton(
            onPressed: () {},
            child: const Text('Resend code in 00:30'),
          ),
        ],
      ),
    );
  }
}
