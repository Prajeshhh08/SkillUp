import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class TermsAndPrivacyScreen extends StatefulWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  State<TermsAndPrivacyScreen> createState() => _TermsAndPrivacyScreenState();
}

class _TermsAndPrivacyScreenState extends State<TermsAndPrivacyScreen> {
  bool terms = false, privacy = false;

  @override
  Widget build(BuildContext c) {
    final customer =
        GoRouterState.of(c).uri.queryParameters['flow'] == 'customer';

    return FlowScaffold(
      title: 'Terms & privacy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Before you continue',
            'Please review and accept the terms that keep SkillUp safe for everyone.',
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Text(
                'Terms of Service\n\n'
                'SkillUp connects customers with independent skilled professionals. '
                'Bookings, payments, cancellations and reviews must be made fairly and respectfully.\n\n'
                'Privacy Policy\n\n'
                'We use your contact and location details to provide services, communications and account support. '
                'We do not sell your personal information.',
              ),
            ),
          ),
          CheckboxListTile(
            value: terms,
            onChanged: (value) => setState(() => terms = value ?? false),
            title: const Text('I accept the Terms of Service'),
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: privacy,
            onChanged: (value) => setState(() => privacy = value ?? false),
            title: const Text('I accept the Privacy Policy'),
            contentPadding: EdgeInsets.zero,
          ),
          primaryAction(
            'Accept & Continue',
            () => c.push(
              customer ? '/address?flow=customer' : '/worker-onboarding',
            ),
          ),
        ],
      ),
    );
  }
}
