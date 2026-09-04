import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'flow_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  bool _submitting = false;

  @override
  void dispose() {
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final flow = GoRouterState.of(c).uri.queryParameters['flow'] ?? 'worker';
    final identifier =
        GoRouterState.of(c).uri.queryParameters['identifier'] ?? '';
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
                  controller: _codeControllers[i],
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty && i < 5) FocusScope.of(c).nextFocus();
                  },
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          primaryAction(
            _submitting ? 'Verifying...' : 'Verify',
            _submitting ? null : () => _verify(flow, identifier),
          ),
          TextButton(
            onPressed: _submitting || identifier.isEmpty
                ? null
                : () => _resend(identifier),
            child: const Text('Resend code'),
          ),
        ],
      ),
    );
  }

  Future<void> _verify(String flow, String identifier) async {
    if (identifier.isEmpty) {
      _showError(
        'Your phone number is missing. Please create the account again.',
      );
      return;
    }
    final otp = _codeControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _showError('Enter all six digits.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final verified = await AuthService.instance.verifyOtp(
        identifier: identifier,
        otp: otp,
      );
      if (!verified) {
        throw const ApiException('The verification code was not accepted.');
      }
      if (mounted) {
        context.push('/terms-confirm?flow=$flow');
      }
    } on ApiException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _resend(String identifier) async {
    try {
      await AuthService.instance.sendOtp(identifier: identifier);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A new code has been sent. For local testing, use 123456.',
            ),
          ),
        );
      }
    } on ApiException catch (error) {
      _showError(error.message);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
