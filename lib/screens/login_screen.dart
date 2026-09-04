import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'flow_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int role = 0;
  bool _submitting = false;
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FlowScaffold(
    title: 'Sign in',
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Welcome back',
            'Sign in to manage bookings or grow your service business.',
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Customer')),
              ButtonSegment(value: 1, label: Text('Worker')),
            ],
            selected: {role},
            onSelectionChanged: (v) => setState(() => role = v.first),
          ),
          const SizedBox(height: 24),
          TextField(
            key: Key('login-phone'),
            controller: _identifierController,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: 'Phone number or email',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 12),
          primaryAction(
            _submitting ? 'Signing in...' : 'Sign In',
            _submitting ? null : _signIn,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('New to SkillUp?'),
              TextButton(
                onPressed: () => context.push(
                  role == 0 ? '/customer-signup' : '/worker-signup',
                ),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _signIn() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    if (identifier.isEmpty || password.isEmpty) {
      _showError('Enter your phone number or email and password.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await AuthService.instance.login(
        identifier: identifier,
        password: password,
      );
      if (!mounted) return;
      final isCustomer = result.role.toUpperCase() == 'CUSTOMER';
      context.go(isCustomer ? '/customer-home' : '/home');
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
