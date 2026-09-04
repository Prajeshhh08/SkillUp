import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/customer_address.dart';
import '../services/api_client.dart';
import '../services/customer_service.dart';
import '../theme/app_theme.dart';

/// Screen 8: Manual Address Setup & Address Management
/// Visual: Form fields with prefix icons for Flat/Building, Street/Area, Landmark, and Pincode,
/// capped with a primary "Save & Finish Setup" button.
/// Behavior: Validates inputs, saves address to API, and shows saved addresses.
class AddressSetupScreen extends StatefulWidget {
  const AddressSetupScreen({super.key});

  @override
  State<AddressSetupScreen> createState() => _AddressSetupScreenState();
}

class _AddressSetupScreenState extends State<AddressSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _flatController = TextEditingController(
    text: 'Flat 4B, Emerald Heights',
  );
  final _streetController = TextEditingController(
    text: '742 Evergreen Terrace',
  );
  final _landmarkController = TextEditingController(
    text: 'Near City Central Park',
  );
  final _cityController = TextEditingController(text: 'Bengaluru');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _pincodeController = TextEditingController(text: '560001');

  String _addressType = 'Home';
  bool _isDefault = true;
  double _latitude = 12.9716;
  double _longitude = 77.5946;

  bool _isSaving = false;
  bool _isLoadingAddresses = false;
  List<CustomerAddress> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _flatController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAddresses() async {
    setState(() => _isLoadingAddresses = true);
    try {
      final list = await CustomerService.instance.getAddresses();
      if (!mounted) return;
      setState(() {
        _savedAddresses = list;
        _isLoadingAddresses = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _onSaveAndFinish() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final payload = AddressCreatePayload(
      label: _addressType,
      streetAddress: _streetController.text.trim(),
      apartmentUnit: _flatController.text.trim().isNotEmpty
          ? _flatController.text.trim()
          : null,
      city: _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : 'Bengaluru',
      state: _stateController.text.trim().isNotEmpty
          ? _stateController.text.trim()
          : 'Karnataka',
      postalCode: _pincodeController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
    );

    try {
      final created = await CustomerService.instance.createAddress(payload);
      if (!mounted) return;
      setState(() => _isSaving = false);

      await _showSuccessBottomSheet(created);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: AppTheme.error),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save address. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _showSuccessBottomSheet(CustomerAddress address) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                        address.label == 'Home'
                            ? Icons.home_rounded
                            : address.label == 'Work'
                            ? Icons.work_rounded
                            : Icons.location_on_rounded,
                        size: 18,
                        color: AppTheme.primaryEmerald,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Saved as ${address.label}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
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
                  const SizedBox(height: 6),
                  Text(
                    address.shortLine,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${address.city}, ${address.state} • Pincode: ${address.postalCode}',
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
                Navigator.pop(ctx);
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/customer-home');
                }
              },
              child: const Text('Start Exploring'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAddress(CustomerAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text(
          'Are you sure you want to remove "${address.label}: ${address.shortLine}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CustomerService.instance.deleteAddress(address.id);
        _loadSavedAddresses();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Address removed.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not delete address.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saved addresses list if user already has addresses
                      if (_savedAddresses.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SAVED ADDRESSES (${_savedAddresses.length})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (_isLoadingAddresses)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryEmerald,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ..._savedAddresses.map(
                          (addr) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                              border: Border.all(
                                color: addr.isDefault
                                    ? AppTheme.primaryEmerald
                                    : AppTheme.borderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  addr.label.toLowerCase() == 'work'
                                      ? Icons.work_rounded
                                      : Icons.home_rounded,
                                  color: addr.isDefault
                                      ? AppTheme.primaryEmerald
                                      : AppTheme.textSecondary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            addr.label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (addr.isDefault) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppTheme.primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'DEFAULT',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      AppTheme.primaryEmerald,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        addr.shortLine,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${addr.city}, ${addr.postalCode}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () => _deleteAddress(addr),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                      ],

                      // Section title: Add New Address
                      Text(
                        _savedAddresses.isEmpty
                            ? 'ADDRESS DETAILS'
                            : 'ADD NEW ADDRESS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Current Location Quick Action
                      InkWell(
                        onTap: () {
                          setState(() {
                            _latitude = 12.9716;
                            _longitude = 77.5946;
                            _cityController.text = 'Bengaluru';
                            _stateController.text = 'Karnataka';
                            _pincodeController.text = '560001';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Updated coordinates to current GPS location (12.9716, 77.5946)!',
                              ),
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
                                'Use current GPS location',
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
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 160),
                              painter: _MapGridPainter(),
                            ),
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
                      const SizedBox(height: 16),

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
                      ),
                      const SizedBox(height: 14),

                      // Street / Area Field
                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Street / Area / Colony *',
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

                      // City & State Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City *',
                                prefixIcon: Icon(
                                  Icons.location_city_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Enter city'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: const InputDecoration(
                                labelText: 'State *',
                                prefixIcon: Icon(
                                  Icons.map_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Enter state'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Pincode Field
                      TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pincode / Postal Code *',
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
                      const SizedBox(height: 14),

                      // Set as default checkbox
                      CheckboxListTile(
                        value: _isDefault,
                        onChanged: (val) =>
                            setState(() => _isDefault = val ?? true),
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.primaryEmerald,
                        title: const Text(
                          'Set as default address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: const Text(
                          'Used automatically for new service bookings',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                onPressed: _isSaving ? null : _onSaveAndFinish,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save & Finish Setup'),
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
          color: isSelected ? AppTheme.primaryContainer : AppTheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppTheme.primaryEmerald : AppTheme.borderColor,
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: Center(child: Icon(icon, size: 18, color: AppTheme.textPrimary)),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E6E2)
      ..strokeWidth = 1.0;

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

    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
