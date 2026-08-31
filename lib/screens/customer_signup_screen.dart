import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/customer_account.dart';
import 'flow_widgets.dart';

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  bool terms = false;
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
          primaryAction('Create Account', () {
            CustomerAccount.update(name: _nameController.text, emailAddress: _emailController.text, phoneNumber: _phoneController.text);
            c.push('/otp?flow=customer');
          }),
        ],
      ),
    ),
  );
}
