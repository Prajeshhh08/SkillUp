import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'flow_widgets.dart';

class WorkerSignupScreen extends StatefulWidget {
  const WorkerSignupScreen({super.key});

  @override
  State<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          ...[
            ('Full name', _nameController, false),
            ('Phone number', _phoneController, false),
            ('Email address', _emailController, false),
            ('Password', _passwordController, true),
          ].map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: field.$2,
                obscureText: field.$3,
                keyboardType: field.$1 == 'Phone number'
                    ? TextInputType.phone
                    : TextInputType.text,
                decoration: InputDecoration(labelText: field.$1),
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
            onChanged: (_) {},
          ),
          const SizedBox(height: 22),
          primaryAction(
            _submitting ? 'Creating account...' : 'Create Account',
            _submitting ? null : _createAccount,
          ),
          TextButton(
            onPressed: _submitting ? null : () => c.push('/login'),
            child: const Text('Already have an account? Sign in'),
          ),
        ],
      ),
    ),
  );

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.length < 6) {
      _showError(
        'Enter your name, email, phone number, and a password of at least 6 characters.',
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await AuthService.instance.registerWorker(
        fullName: name,
        email: email,
        phone: phone,
        password: password,
      );
      await AuthService.instance.sendOtp(identifier: phone);
      if (mounted) {
        context.push(
          '/otp?flow=worker&identifier=${Uri.encodeComponent(phone)}',
        );
      }
    } on ApiException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
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
