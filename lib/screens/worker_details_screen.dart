import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'flow_widgets.dart';

class WorkerDetailsScreen extends StatelessWidget {
  const WorkerDetailsScreen({super.key});

  @override
  Widget build(BuildContext c) => FlowScaffold(
    title: 'Professional details',
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'Verify your professional profile',
            'These details help us review your account securely.',
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Years of experience'),
            items: const [
              '0–1 years',
              '2–5 years',
              '6–10 years',
              '10+ years',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 14),
          const AppCard(
            child: Row(
              children: [
                Icon(Icons.upload_file_rounded),
                SizedBox(width: 12),
                Expanded(child: Text('Upload ID verification document')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...['Aadhaar / PAN number', 'IFSC code', 'Bank account number'].map(
            (x) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(decoration: InputDecoration(labelText: x)),
            ),
          ),
          primaryAction('Submit details', () => c.push('/worker-form')),
        ],
      ),
    ),
  );
}
