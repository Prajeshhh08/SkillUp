import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/worker_profile.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/worker_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class WorkerAccountProfileScreen extends StatefulWidget {
  const WorkerAccountProfileScreen({super.key});

  @override
  State<WorkerAccountProfileScreen> createState() =>
      _WorkerAccountProfileScreenState();
}

class _WorkerAccountProfileScreenState
    extends State<WorkerAccountProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  WorkerProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await WorkerService.instance.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load profile. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    if (_profile == null) return;
    try {
      final updated = await WorkerService.instance.updateProfile(
        WorkerProfileUpdatePayload(isAvailable: value),
      );
      if (mounted) {
        setState(() => _profile = updated);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to sign out of your worker account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.logout();
      if (mounted) context.go('/role');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return FlowScaffold(
        title: 'My profile',
        bottomNavigationBar: workerDashboardNav(context, 2),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
        ),
      );
    }

    if (_errorMessage != null) {
      return FlowScaffold(
        title: 'My profile',
        bottomNavigationBar: workerDashboardNav(context, 2),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 54,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadProfile,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = _profile!;
    final isVerified = profile.isVerified;

    return FlowScaffold(
      title: 'My profile',
      bottomNavigationBar: workerDashboardNav(context, 2),
      child: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppTheme.primaryEmerald,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: AppTheme.primaryContainer,
                  child: Text(
                    profile.initial,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                    size: 16,
                    color: isVerified
                        ? AppTheme.primaryEmerald
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${profile.verificationStatus} · ${profile.averageRating.toStringAsFixed(1)} ★ (${profile.totalReviews} reviews)',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Profile setup progress card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile setup progress',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${profile.setupProgress}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (profile.setupProgress / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppTheme.surfaceLow,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Availability toggle card
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: profile.isAvailable
                            ? AppTheme.primaryContainer
                            : AppTheme.surfaceLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        profile.isAvailable
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: profile.isAvailable
                            ? AppTheme.primaryEmerald
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.isAvailable
                                ? 'Available for jobs'
                                : 'Currently offline',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.isAvailable
                                ? 'Customers can view and book your services'
                                : 'Toggle to start receiving job offers',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: profile.isAvailable,
                      activeThumbColor: AppTheme.primaryEmerald,
                      onChanged: _toggleAvailability,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              sectionLabel('Professional details'),
              AppCard(
                child: Column(
                  children: [
                    _WorkerDetail(
                      icon: Icons.description_outlined,
                      label: 'Professional bio',
                      value: profile.bio?.isNotEmpty == true
                          ? profile.bio!
                          : 'No bio added yet',
                    ),
                    const Divider(height: 24),
                    _WorkerDetail(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Hourly rate',
                      value: profile.hourlyRate != null
                          ? '₹${profile.hourlyRate!.toStringAsFixed(0)}/hr'
                          : 'Not set',
                    ),
                    const Divider(height: 24),
                    _WorkerDetail(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Payout preference',
                      value: profile.payoutPreference,
                    ),
                    const Divider(height: 24),
                    _WorkerDetail(
                      icon: Icons.phone_outlined,
                      label: 'Phone number',
                      value: profile.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              sectionLabel('Skills (${profile.skills.length})'),
              if (profile.skills.isEmpty)
                const AppCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No skills listed yet. Tap Edit below to select your skills.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.skills.map((s) {
                    final label = s.skillName != null && s.skillName!.isNotEmpty
                        ? '${s.skillName} (${s.experienceYears}y)'
                        : 'Skill (${s.experienceYears}y)';
                    return Chip(
                      avatar: const Icon(
                        Icons.handyman_rounded,
                        size: 16,
                        color: AppTheme.primaryEmerald,
                      ),
                      label: Text(label),
                      backgroundColor: AppTheme.surface,
                      side: const BorderSide(color: AppTheme.borderColor),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await context.push('/worker-form');
                  if (mounted) _loadProfile();
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit professional profile'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _onLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Log out'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerDetail extends StatelessWidget {
  const _WorkerDetail({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppTheme.textSecondary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ],
  );
}
