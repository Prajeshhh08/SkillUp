import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

/// Screen 6: Location Permission
/// Visual: Location pin hero icon, explanatory text regarding GPS access, and primary "Allow Location Access" button.
/// Behavior: Requests hardware GPS permission and proceeds to Screen 7 (/role).
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handlePermissionRequest() async {
    setState(() => _isRequesting = true);
    try {
      final permission = await LocationService.instance.requestPermission();
      if (!mounted) return;

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // Warm up position cache in the background
        LocationService.instance.getCurrentPosition();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location enabled successfully!'),
            backgroundColor: AppTheme.primaryEmerald,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission was permanently denied. Default location will be used.',
            ),
            backgroundColor: AppTheme.textSecondary,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location access was not granted. Default location will be used.',
            ),
            backgroundColor: AppTheme.textSecondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      // Gracefully continue on any platform exception
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
        context.push('/role');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding-3');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Radar Pulse Hero Location Graphic
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer animated radar pulse ring
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 100 + (120 * _pulseAnimation.value),
                            height: 100 + (120 * _pulseAnimation.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryEmerald.withValues(
                                  alpha: (1.0 - _pulseAnimation.value) * 0.4,
                                ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                      // Inner soft glow ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      // Main Pin Card
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 1.5,
                          ),
                          boxShadow: AppTheme.elevatedShadow,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 52,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
              // Typography
              Text(
                'Enable Location Services',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'SkillUp uses your precise location to match you with the closest verified workers and nearby job opportunities.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              // Action Button
              ElevatedButton(
                onPressed: _isRequesting ? null : _handlePermissionRequest,
                child: _isRequesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.my_location_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Allow Location Access'),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              // Skip option
              TextButton(
                onPressed: _isRequesting ? null : () => context.push('/role'),
                child: Text(
                  'Skip for now',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
