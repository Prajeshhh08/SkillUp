import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/onboarding_step_indicator.dart';

/// Screen 3: Onboarding - Verified Workers
/// Visual: Step 1 of 3 indicator, verified icon, title, value description, top "Skip" button, and "Next" primary button.
/// Behavior: "Next" navigates to Screen 4; "Skip" jumps directly to Screen 6.
class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BrandLogo(size: 36, borderRadius: 8),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/location'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Hero Visual Art Container
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft Ambient Glow
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryContainer
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          // Decorative rotated card
                          Transform.rotate(
                            angle: -0.08,
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLow,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // Main Hero Card
                          Transform.rotate(
                            angle: 0.04,
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: AppTheme.primaryLight
                                      .withValues(alpha: 0.4),
                                  width: 2,
                                ),
                                boxShadow: AppTheme.elevatedShadow,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.primaryContainer,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.verified_user_rounded,
                                          size: 44,
                                          color: AppTheme.primaryEmerald,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryEmerald,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '100% Vetted',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
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
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Typography Group
                    Text(
                      'Verified Workers',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Every member is vetted for skill and safety to ensure quality service and dependable support.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // Bottom Action Area with Step Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: const Border(
                  top: BorderSide(color: AppTheme.borderColor, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OnboardingStepIndicator(currentStep: 1),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/onboarding-2'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Next'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
