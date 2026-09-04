import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/worker_profile.dart';
import '../services/worker_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class WorkerStatusScreen extends StatefulWidget {
  const WorkerStatusScreen({super.key, this.service});

  final WorkerService? service;

  @override
  State<WorkerStatusScreen> createState() => _WorkerStatusScreenState();
}

class _WorkerStatusScreenState extends State<WorkerStatusScreen> {
  late final WorkerService _service;
  bool _isLoading = true;
  String? _error;
  WorkerProfile? _profile;
  WorkerMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WorkerService.instance;
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.getProfile(),
        _service.getMetrics(),
      ]);

      if (!mounted) return;
      setState(() {
        _profile = results[0] as WorkerProfile;
        _metrics = results[1] as WorkerMetrics;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => FlowScaffold(
        title: 'Account status',
        child: RefreshIndicator(
          onRefresh: _loadStatus,
          color: AppTheme.primaryEmerald,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                flowTitle(
                  'Verification status',
                  'Keep track of your account review and document checklist.',
                ),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                  )
                else if (_error != null)
                  _buildErrorView()
                else ...[
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildProgressSection(),
                  const SizedBox(height: 20),
                  sectionLabel('Verification checklist'),
                  _buildChecklistSection(),
                  const SizedBox(height: 20),
                  sectionLabel('Account performance'),
                  _buildMetricsSummary(),
                  const SizedBox(height: 24),
                  primaryAction(
                    'Edit profile',
                    () => context.push('/worker-form'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  Widget _buildErrorView() {
    return Center(
      child: AppCard(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
            const SizedBox(height: 8),
            const Text(
              'Failed to load verification status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final profile = _profile;
    final isVerified = profile?.isVerified ?? false;
    final statusText = isVerified
        ? 'Status: Verified Professional'
        : 'Status: Pending review';

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
            color: isVerified ? AppTheme.success : Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isVerified
                      ? 'Your account is active and verified to accept customer jobs.'
                      : 'SkillUp team is reviewing your details. You can accept jobs once approved.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = _profile?.setupProgress ?? 0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile completion',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: AppTheme.primaryEmerald,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.primaryEmerald,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection() {
    final profile = _profile;
    final hasSkills = profile != null && profile.skills.isNotEmpty;
    final hasRate = profile != null && profile.hourlyRate != null;

    final items = [
      (
        'Identity verification',
        'Submitted',
        true,
        Icons.badge_rounded,
      ),
      (
        'Bank account details',
        '${profile?.payoutPreference ?? 'UPI'} linked',
        true,
        Icons.account_balance_rounded,
      ),
      (
        'Professional skills',
        hasSkills ? '${profile.skills.length} skills listed' : 'Pending',
        hasSkills,
        Icons.handyman_rounded,
      ),
      (
        'Hourly rate set',
        hasRate ? '₹${profile.hourlyRate!.toStringAsFixed(0)}/hr' : 'Pending',
        hasRate,
        Icons.payments_rounded,
      ),
    ];

    return Column(
      children: items.map((item) {
        final title = item.$1;
        final status = item.$2;
        final isDone = item.$3;
        final icon = item.$4;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: isDone
                ? AppTheme.primaryContainer
                : Colors.grey.shade100,
            child: Icon(
              icon,
              size: 18,
              color: isDone ? AppTheme.primaryEmerald : Colors.grey,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: isDone ? AppTheme.success : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.access_time_rounded,
                size: 16,
                color: isDone ? AppTheme.success : Colors.orange,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsSummary() {
    final metrics = _metrics ??
        const WorkerMetrics(
          acceptanceRate: 1.0,
          completedJobs: 0,
          totalEarnings: 0,
          averageRating: 5.0,
        );

    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            '${metrics.completedJobs}',
            'Completed',
            AppTheme.primaryEmerald,
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          _buildSummaryItem(
            '₹${metrics.totalEarnings.toStringAsFixed(0)}',
            'Total earned',
            Colors.blue.shade700,
          ),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          _buildSummaryItem(
            '${(metrics.acceptanceRate * 100).toStringAsFixed(0)}%',
            'Acceptance',
            Colors.purple.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

