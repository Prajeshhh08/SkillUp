import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';

/// Screen 7: Role Selection
/// Visual: Two selectable role cards—"I want to hire workers" (Customer) and "I am a worker" (Worker)—with distinct icons, descriptions, and active border highlight.
/// Behavior: Selecting a role starts its corresponding account setup flow.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'customer' or 'worker'

  @override
  Widget build(BuildContext context) {
    final isRoleSelected = _selectedRole != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/location');
            }
          },
        ),
        title: const BrandLogo(size: 40),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'How will you use SkillUp?',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your primary role to customize your cooperative experience.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Customer Card
                    _buildRoleCard(
                      roleId: 'customer',
                      title: 'Customer',
                      description: 'I want to hire workers for home or business tasks.',
                      iconData: Icons.person_rounded,
                      badgeText: 'Hire Services',
                    ),
                    const SizedBox(height: 16),
                    // Worker Card
                    _buildRoleCard(
                      roleId: 'worker',
                      title: 'Worker',
                      description: 'I am a skilled professional offering my services & crafts.',
                      iconData: Icons.handyman_rounded,
                      badgeText: 'Provide Services',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.background,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: isRoleSelected
                        ? () => context.push(
                              _selectedRole == 'customer'
                                  ? '/customer-signup'
                                  : '/worker-signup',
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRoleSelected
                          ? AppTheme.primaryEmerald
                          : const Color(0xFFDFE0E0),
                      foregroundColor: isRoleSelected
                          ? Colors.white
                          : AppTheme.textTertiary,
                    ),
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You can always switch your role later in account settings.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String description,
    required IconData iconData,
    required String badgeText,
  }) {
    final isSelected = _selectedRole == roleId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = roleId;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer.withValues(alpha: 0.35)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryEmerald : AppTheme.borderColor,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryEmerald
                    : AppTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  iconData,
                  size: 28,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryEmerald.withValues(alpha: 0.12)
                              : AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryEmerald
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryEmerald : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryEmerald
                      : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
