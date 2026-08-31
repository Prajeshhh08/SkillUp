import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class TermsConfirmScreen extends StatefulWidget {
  const TermsConfirmScreen({super.key});

  @override
  State<TermsConfirmScreen> createState() => _TermsConfirmScreenState();
}

class _TermsConfirmScreenState extends State<TermsConfirmScreen> {
  bool ok = false;

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
        primaryAction('Confirm & Finish', () => c.go('/customer-home')),
      ],
    ),
  );
}
