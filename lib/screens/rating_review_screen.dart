import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking_flow_state.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class RatingReviewScreen extends StatefulWidget {
  const RatingReviewScreen({super.key, this.bookingId, this.bookingService});

  final String? bookingId;
  final BookingService? bookingService;

  @override
  State<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends State<RatingReviewScreen> {
  late final BookingService _bookingService =
      widget.bookingService ?? BookingService.instance;

  String? _resolvedBookingId;
  int _stars = 5;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedBadges = {'Punctual', 'Clean Work'};

  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _availableBadges = [
    'Punctual',
    'Clean Work',
    'Polite',
    'Highly Skilled',
    'Fair Pricing',
  ];

  @override
  void initState() {
    super.initState();
    _resolvedBookingId =
        widget.bookingId ?? BookingFlowState.instance.activeBooking?.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final queryId = GoRouterState.of(
        context,
      ).uri.queryParameters['bookingId'];
      if (queryId != null && queryId.isNotEmpty) {
        _resolvedBookingId = queryId;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    String? targetId = _resolvedBookingId;
    if (targetId == null || targetId.isEmpty) {
      try {
        final list = await _bookingService.getCustomerBookings();
        final completed = list.where((b) => b.isCompleted).toList();
        if (completed.isNotEmpty) {
          targetId = completed.first.id;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    if (targetId == null || targetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No booking found to review.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _bookingService.createReview(
        targetId,
        ReviewCreatePayload(
          rating: _stars,
          comment: _commentController.text.trim().isNotEmpty
              ? _commentController.text.trim()
              : null,
          badges: _selectedBadges.toList(),
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully! Thank you.'),
        ),
      );
      context.go('/customer-home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      title: 'Rate service',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          flowTitle(
            'How was your experience?',
            'Your rating and feedback help fellow customers choose with confidence.',
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: () => setState(() => _stars = i + 1),
                icon: Icon(
                  i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          sectionLabel('Compliments & Badges'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableBadges.map((badge) {
              final isSelected = _selectedBadges.contains(badge);
              return FilterChip(
                label: Text(badge),
                selected: isSelected,
                selectedColor: AppTheme.primaryEmerald.withAlpha(40),
                checkmarkColor: AppTheme.primaryEmerald,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedBadges.add(badge);
                    } else {
                      _selectedBadges.remove(badge);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Write a review (optional)',
              hintText: 'Share what you liked about the service...',
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: AppTheme.error)),
          ],
          const Spacer(),
          primaryAction(
            _isSubmitting ? 'Submitting...' : 'Submit review',
            _isSubmitting ? () {} : _submitReview,
          ),
        ],
      ),
    );
  }
}
