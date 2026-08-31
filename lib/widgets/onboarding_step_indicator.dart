import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 3-step pill-and-dot progress indicator for Onboarding screens.
class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  final int totalSteps;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber == currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 32 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryEmerald
                : const Color(0xFFDFE0E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
