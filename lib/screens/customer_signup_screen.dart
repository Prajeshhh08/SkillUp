import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  bool terms = false;

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Create account',
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Create your customer account',
            'Find trusted local professionals for every task.',
          ),
          ...[
            'Full name',
            'Email address',
            'Phone number',
            'Password',
            'Confirm password',
          ].map(
            (x) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                obscureText: x.contains('Password'),
                decoration: InputDecoration(labelText: x),
              ),
            ),
          ),
          CheckboxListTile(
            value: terms,
            onChanged: (v) => setState(() => terms = v ?? false),
            contentPadding: EdgeInsets.zero,
            title: const Text('I agree to the Terms and Privacy Policy'),
          ),
          primaryAction('Create Account', () => c.push('/otp?flow=customer')),
        ],
      ),
    ),
  );
}
