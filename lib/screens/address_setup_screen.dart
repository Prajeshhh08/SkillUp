import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Screen 8: Manual Address Setup
/// Visual: Form fields with prefix icons for Flat/Building, Street/Area, Landmark, and Pincode, capped with a primary "Save & Finish Setup" button.
/// Behavior: Validates inputs and completes the flow.
class AddressSetupScreen extends StatefulWidget {
  const AddressSetupScreen({super.key});

  @override
  State<AddressSetupScreen> createState() => _AddressSetupScreenState();
}

class _AddressSetupScreenState extends State<AddressSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _flatController = TextEditingController(text: 'Flat 4B, Emerald Heights');
  final _streetController = TextEditingController(text: '742 Evergreen Terrace');
  final _landmarkController = TextEditingController(text: 'Near City Central Park');
  final _pincodeController = TextEditingController(text: '560001');

  String _addressType = 'Home';

  @override
  void dispose() {
    _flatController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _onSaveAndFinish() {
    if (_formKey.currentState?.validate() ?? false) {
      // Show confirmation dialog / bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryContainer,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 44,
                    color: AppTheme.primaryEmerald,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Setup Complete!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your address has been saved and your profile is now ready to use SkillUp.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _addressType == 'Home'
                              ? Icons.home_rounded
                              : _addressType == 'Work'
                                  ? Icons.work_rounded
                                  : Icons.location_on_rounded,
                          size: 18,
                          color: AppTheme.primaryEmerald,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saved as $_addressType',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_flatController.text}, ${_streetController.text}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${_landmarkController.text} • Pincode: ${_pincodeController.text}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/customer-home');
                },
                child: const Text('Start Exploring'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/role');
            }
          },
        ),
        title: Text(
          'Set Your Location',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Location Bar
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Search for your address...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppTheme.surface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Current Location Quick Action
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Updated to current GPS location!'),
                              backgroundColor: AppTheme.primaryEmerald,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.my_location_rounded,
                                size: 18,
                                color: AppTheme.primaryEmerald,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Use current location',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryEmerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Styled Map Preview Card
                      Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Minimal Vector Map Background Grid
                            CustomPaint(
                              size: const Size(double.infinity, 160),
                              painter: _MapGridPainter(),
                            ),
                            // Center Emerald Pin with Pulsing Shadow
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryEmerald,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryEmerald
                                            .withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Zoom buttons
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Column(
                                children: [
                                  _mapControlButton(Icons.add),
                                  const SizedBox(height: 6),
                                  _mapControlButton(Icons.remove),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Section Header
                      Text(
                        'ADDRESS DETAILS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Flat / Building Field
                      TextFormField(
                        controller: _flatController,
                        decoration: const InputDecoration(
                          labelText: 'Flat / Building / Floor',
                          prefixIcon: Icon(
                            Icons.apartment_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter flat or building details'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      // Street / Area Field
                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Street / Area / Colony',
                          prefixIcon: Icon(
                            Icons.signpost_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter street/area details'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      // Landmark Field
                      TextFormField(
                        controller: _landmarkController,
                        decoration: const InputDecoration(
                          labelText: 'Landmark (Optional)',
                          prefixIcon: Icon(
                            Icons.near_me_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Pincode Field
                      TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pincode / Postal Code',
                          prefixIcon: Icon(
                            Icons.pin_drop_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter a valid pincode'
                                : null,
                      ),
                      const SizedBox(height: 20),
                      // Address Type Chips
                      Text(
                        'Save Address As',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTypeChip('Home', Icons.home_rounded),
                          const SizedBox(width: 8),
                          _buildTypeChip('Work', Icons.work_rounded),
                          const SizedBox(width: 8),
                          _buildTypeChip('Other', Icons.location_on_rounded),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Sticky Bottom Action
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
              child: ElevatedButton(
                onPressed: _onSaveAndFinish,
                child: const Text('Save & Finish Setup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    final isSelected = _addressType == label;

    return InkWell(
      onTap: () {
        setState(() {
          _addressType = label;
        });
      },
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryEmerald
                : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppTheme.primaryEmerald
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryEmerald
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapControlButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E6E2)
      ..strokeWidth = 1.0;

    // Draw stylized road grid
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );

    // Subtle boundary lines
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
