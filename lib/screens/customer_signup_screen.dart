import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/customer_account.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'flow_widgets.dart';

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  bool terms = false;
  bool _submitting = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
            ('Full name', _nameController, false),
            ('Email address', _emailController, false),
            ('Phone number', _phoneController, false),
            ('Password', _passwordController, true),
            ('Confirm password', _confirmPasswordController, true),
          ].map((field) => Padding(padding: const EdgeInsets.only(bottom: 14), child: TextField(controller: field.$2, obscureText: field.$3, keyboardType: field.$1 == 'Phone number' ? TextInputType.phone : TextInputType.text, decoration: InputDecoration(labelText: field.$1)))),
          CheckboxListTile(
            value: terms,
            onChanged: (v) => setState(() => terms = v ?? false),
            contentPadding: EdgeInsets.zero,
            title: const Text('I agree to the Terms and Privacy Policy'),
          ),
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
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.length < 6) {
      _showError('Enter your name, email, phone number, and a password of at least 6 characters.');
      return;
    }
    if (password != _confirmPasswordController.text) {
      _showError('The passwords do not match.');
      return;
    }
    if (!terms) {
      _showError('Please agree to the Terms and Privacy Policy.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await AuthService.instance.registerCustomer(
        fullName: name,
        email: email,
        phone: phone,
        password: password,
      );
      await AuthService.instance.sendOtp(identifier: phone);
      CustomerAccount.update(name: name, emailAddress: email, phoneNumber: phone);
      if (mounted) {
        context.push('/otp?flow=customer&identifier=${Uri.encodeComponent(phone)}');
      }
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
