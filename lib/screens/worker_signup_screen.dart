import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class WorkerSignupScreen extends StatelessWidget {
  const WorkerSignupScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Join SkillUp',
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Start your professional journey',
            'Create a profile and connect with customers nearby.',
          ),
          ...['Full name', 'Phone number', 'Email address', 'Password'].map(
            (x) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                obscureText: x == 'Password',
                decoration: InputDecoration(labelText: x),
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Primary skill category',
            ),
            items: const [
              'Plumbing',
              'Electrical',
              'Painting',
              'Carpentry',
              'Cleaning',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (_) => null,
          ),
          const SizedBox(height: 22),
          primaryAction('Create Account', () => c.push('/otp?flow=worker')),
        ],
      ),
    ),
  );
}
