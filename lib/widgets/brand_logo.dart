import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Official Brand Logo widget for SkillUp.
class BrandLogo extends StatelessWidget {
  final double size;
  final double? borderRadius;
  final bool isLightMode;
  final bool showShadow;

  const BrandLogo({
    super.key,
    this.size = 56,
    this.borderRadius,
    this.isLightMode = false,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? (size * 0.25);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.06),
                ),
              ]
            : [],
        border: Border.all(
          color: isLightMode
              ? Colors.white.withValues(alpha: 0.3)
              : AppTheme.borderColor.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius - 1.5),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppTheme.primaryContainer,
            child: Icon(
              Icons.handshake_rounded,
              size: size * 0.5,
              color: AppTheme.primaryEmerald,
            ),
          ),
        ),
      ),
    );
  }
}
