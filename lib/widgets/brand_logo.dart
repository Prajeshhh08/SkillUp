import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Clean, scalable vector brand logo widget for SkillUp.
class BrandLogo extends StatelessWidget {
  final double size;
  final bool isLightMode;
  final bool showBadge;

  const BrandLogo({
    super.key,
    this.size = 56,
    this.isLightMode = false,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isLightMode
        ? Colors.white
        : AppTheme.primaryContainer;
    final iconColor = isLightMode
        ? AppTheme.primaryEmerald
        : AppTheme.primaryEmerald;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isLightMode ? Colors.black : AppTheme.primaryEmerald)
                .withValues(alpha: 0.08),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.05),
          ),
        ],
        border: Border.all(
          color: isLightMode
              ? Colors.white.withValues(alpha: 0.2)
              : AppTheme.borderColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.handshake_rounded,
          size: size * 0.52,
          color: iconColor,
        ),
      ),
    );
  }
}
