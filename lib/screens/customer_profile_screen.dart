import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/customer_address.dart';
import '../models/customer_profile.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  CustomerProfile? _profile;
  CustomerMetrics? _metrics;
  List<CustomerAddress> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        CustomerService.instance.getProfile(),
        CustomerService.instance.getMetrics(),
        CustomerService.instance.getAddresses(),
      ]);

      if (!mounted) return;
      setState(() {
        _profile = results[0] as CustomerProfile;
        _metrics = results[1] as CustomerMetrics;
        _addresses = results[2] as List<CustomerAddress>;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load profile. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onEditProfile() async {
    if (_profile == null) return;
    final nameController = TextEditingController(text: _profile!.fullName);
    final emailController = TextEditingController(text: _profile!.email ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Account Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setModalState(() => saving = true);
                          try {
                            final newName = nameController.text.trim();
                            final newEmail = emailController.text.trim();
                            await CustomerService.instance.updateProfile(
                              fullName: newName,
                              email: newEmail.isEmpty ? null : newEmail,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            await _loadData();
                          } on ApiException catch (e) {
                            setModalState(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                            }
                          } catch (e) {
                            setModalState(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update details.'),
                                ),
                              );
                            }
                          }
                        },
                  child: Text(saving ? 'Saving changes...' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to sign out of your SkillUp account?',
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
        title: 'Your profile',
        bottomNavigationBar: customerDashboardNav(context, 2),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
        ),
      );
    }

    if (_errorMessage != null) {
      return FlowScaffold(
        title: 'Your profile',
        bottomNavigationBar: customerDashboardNav(context, 2),
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
                  onPressed: _loadData,
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
    final metrics = _metrics;

    return FlowScaffold(
      title: 'Your profile',
      bottomNavigationBar: customerDashboardNav(context, 2),
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryEmerald,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
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
              const Text(
                'Customer account',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              // Activity metrics card
              if (metrics != null)
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${metrics.bookingTotals}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryEmerald,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total Bookings',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: AppTheme.borderColor,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${metrics.orderAcceptancePercentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryEmerald,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Acceptance Rate',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Account details card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sectionLabel('Account details'),
                  TextButton.icon(
                    onPressed: _onEditProfile,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryEmerald,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              AppCard(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Full name',
                      value: profile.fullName,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email?.isNotEmpty == true
                          ? profile.email!
                          : 'Not provided',
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: profile.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Saved addresses section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sectionLabel('Saved addresses (${_addresses.length})'),
                  TextButton.icon(
                    onPressed: () async {
                      await context.push('/address');
                      if (mounted) _loadData();
                    },
                    icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                    label: const Text('Manage'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryEmerald,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              if (_addresses.isEmpty)
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'No saved address yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Set up an address for faster local service booking.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            await context.push('/address');
                            if (mounted) _loadData();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._addresses.map(
                  (addr) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: addr.isDefault
                                  ? AppTheme.primaryContainer
                                  : AppTheme.surfaceLow,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              addr.label.toLowerCase() == 'work'
                                  ? Icons.work_rounded
                                  : Icons.home_rounded,
                              size: 20,
                              color: addr.isDefault
                                  ? AppTheme.primaryEmerald
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (addr.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          'DEFAULT',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryEmerald,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  addr.shortLine,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  '${addr.city}, ${addr.postalCode}',
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
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Booking history button
              OutlinedButton.icon(
                onPressed: () => context.push('/booking-history'),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('View booking history'),
              ),
              const SizedBox(height: 12),
              // Sign out button
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
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
