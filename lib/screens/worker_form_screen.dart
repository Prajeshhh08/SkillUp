import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/skill_category.dart';
import '../models/worker_profile.dart';
import '../services/api_client.dart';
import '../services/worker_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class WorkerFormScreen extends StatefulWidget {
  const WorkerFormScreen({super.key});

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  String _availability = 'Weekdays';
  String _payoutMethod = 'UPI';
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<SkillCategory> _categories = [];
  final Set<String> _selectedCategoryIds = {};
  final Map<String, int> _categoryExperience = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        WorkerService.instance.getSkillCategories(),
        WorkerService.instance.getProfile(),
      ]);

      if (!mounted) return;

      final categories = results[0] as List<SkillCategory>;
      final profile = results[1] as WorkerProfile;

      setState(() {
        _categories = categories;

        if (profile.bio != null && profile.bio!.isNotEmpty) {
          _bioController.text = profile.bio!;
        }
        if (profile.hourlyRate != null) {
          _hourlyRateController.text = profile.hourlyRate!.toStringAsFixed(0);
        }
        if (profile.payoutPreference.toUpperCase() == 'BANK_TRANSFER') {
          _payoutMethod = 'Bank transfer';
        } else {
          _payoutMethod = 'UPI';
        }

        for (final skill in profile.skills) {
          _selectedCategoryIds.add(skill.skillCategoryId);
          _categoryExperience[skill.skillCategoryId] = skill.experienceYears;
        }

        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load profile details.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onSaveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one skill category.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final skills = _selectedCategoryIds.map((id) {
      return WorkerSkillItem(
        skillCategoryId: id,
        experienceYears: _categoryExperience[id] ?? 2,
      );
    }).toList();

    final rate = double.tryParse(_hourlyRateController.text.trim());
    final payout = _payoutMethod == 'Bank transfer' ? 'BANK_TRANSFER' : 'UPI';

    final payload = WorkerProfileUpdatePayload(
      bio: _bioController.text.trim(),
      hourlyRate: rate,
      isAvailable: _availability != 'Unavailable',
      payoutPreference: payout,
      skills: skills,
    );

    try {
      await WorkerService.instance.updateProfile(payload);
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professional profile saved successfully.'),
          backgroundColor: AppTheme.primaryEmerald,
        ),
      );

      if (context.canPop()) {
        context.pop(true);
      } else {
        context.push('/verification-pending');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppTheme.error),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FlowScaffold(
        title: 'Complete profile',
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
        ),
      );
    }

    if (_errorMessage != null && _categories.isEmpty) {
      return FlowScaffold(
        title: 'Complete profile',
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
                  onPressed: _loadInitialData,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FlowScaffold(
      title: 'Complete profile',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              flowTitle(
                'Tell customers about your work',
                'Complete the final details for a stronger profile.',
              ),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Professional bio',
                  hintText:
                      'Describe your expertise, work experience, and services offered...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter a short professional bio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('hourly-rate'),
                controller: _hourlyRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hourly rate',
                  prefixText: '₹ ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your hourly rate';
                  }
                  final rate = double.tryParse(val.trim());
                  if (rate == null || rate <= 0) {
                    return 'Enter a valid hourly rate greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _availability,
                decoration: const InputDecoration(labelText: 'Availability'),
                items: const ['Weekdays', 'Weekends', 'Every day']
                    .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _availability = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _payoutMethod,
                decoration: const InputDecoration(labelText: 'Payout method'),
                items: const ['Bank transfer', 'UPI']
                    .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _payoutMethod = val);
                  }
                },
              ),
              const SizedBox(height: 22),
              // Skills selection
              sectionLabel('Select Your Skills'),
              if (_categories.isEmpty)
                const Text(
                  'No skill categories available.',
                  style: TextStyle(color: AppTheme.textSecondary),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategoryIds.contains(cat.id);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(cat.name),
                      selectedColor: AppTheme.primaryContainer,
                      checkmarkColor: AppTheme.primaryEmerald,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryEmerald
                            : AppTheme.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryIds.add(cat.id);
                            _categoryExperience[cat.id] =
                                _categoryExperience[cat.id] ?? 2;
                          } else {
                            _selectedCategoryIds.remove(cat.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 28),
              primaryAction(
                _isSubmitting ? 'Saving profile...' : 'Save profile',
                _isSubmitting ? null : _onSaveProfile,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
