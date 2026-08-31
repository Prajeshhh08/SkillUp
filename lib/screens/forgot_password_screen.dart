import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => FlowScaffold(
    title: 'Reset password',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flowTitle(
          'Reset your password',
          'Enter your email address or phone number and we’ll send reset instructions.',
        ),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email or phone number',
            prefixIcon: Icon(Icons.alternate_email),
          ),
        ),
        const SizedBox(height: 20),
        primaryAction(
          'Send Reset Link',
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reset instructions sent.')),
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Back to sign in'),
        ),
      ],
    ),
  );
}
