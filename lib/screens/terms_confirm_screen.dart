import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'flow_widgets.dart';

class TermsConfirmScreen extends StatefulWidget {
  const TermsConfirmScreen({super.key});

  @override
  State<TermsConfirmScreen> createState() => _TermsConfirmScreenState();
}

class _TermsConfirmScreenState extends State<TermsConfirmScreen> {
  bool ok = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Confirm account',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Almost finished',
          'Please confirm that you understand the account terms and service standards.',
        ),
        const AppCard(
          child: Text(
            'You have agreed to the SkillUp Terms of Service and Privacy Policy.',
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: ok,
          onChanged: (v) => setState(() => ok = v ?? false),
          contentPadding: EdgeInsets.zero,
          title: const Text('I confirm my agreement'),
        ),
        const Spacer(),
        primaryAction(
          _submitting ? 'Saving...' : 'Confirm & Finish',
          _submitting ? null : _confirm,
        ),
      ],
    ),
  );

  Future<void> _confirm() async {
    if (!ok) {
      _showError('Please confirm your agreement before continuing.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await AuthService.instance.acceptTerms();
      if (!mounted) return;
      final flow = GoRouterState.of(context).uri.queryParameters['flow'] ?? 'customer';
      context.go(flow == 'worker' ? '/worker-form' : '/customer-home');
    } on ApiException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
