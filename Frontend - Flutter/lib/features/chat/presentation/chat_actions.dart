import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER SELECTION — shows "View Providers" → bottom sheet with 3 cards
// ─────────────────────────────────────────────────────────────────────────────

class ProviderSelectionAction extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String providerId) onProviderSelected;

  const ProviderSelectionAction({
    super.key,
    required this.data,
    required this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () => _showProviderSheet(context),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryContainer,
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: Size.zero,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 16),
          SizedBox(width: 6),
          Text(
            'View Providers',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showProviderSheet(BuildContext context) {
    final providers = (data['providers'] as List<dynamic>?) ?? [];
    final categoryName = data['categoryName'] as String? ?? 'Service';
    final overallReasoning = data['overallReasoning'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProviderSelectionSheet(
        categoryName: categoryName,
        overallReasoning: overallReasoning,
        providers: providers,
        onSelect: (providerId) {
          Navigator.pop(context);
          onProviderSelected(providerId);
        },
      ),
    );
  }
}

class _ProviderSelectionSheet extends StatelessWidget {
  final String categoryName;
  final String overallReasoning;
  final List<dynamic> providers;
  final void Function(String) onSelect;

  const _ProviderSelectionSheet({
    required this.categoryName,
    required this.overallReasoning,
    required this.providers,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      maxChildSize: 0.93,
      minChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    if (overallReasoning.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        overallReasoning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${providers.length} providers available',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: providers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = providers[i] as Map<String, dynamic>;
                    return _ProviderCard(
                      provider: p,
                      onSelect: () =>
                          onSelect(p['providerId'] as String? ?? ''),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final VoidCallback onSelect;

  const _ProviderCard({required this.provider, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rank = (provider['rank'] as num?)?.toInt() ?? 0;
    final name = provider['name'] as String? ?? 'Provider';
    final rating = (provider['rating'] as num?)?.toDouble() ?? 0.0;
    final totalJobs = (provider['totalJobs'] as num?)?.toInt() ?? 0;
    final experience = (provider['experience'] as num?)?.toInt() ?? 0;
    final distance = (provider['distance'] as num?)?.toDouble() ?? 0.0;
    final bio = provider['bio'] as String? ?? '';
    final reasoning = provider['reasoning'] as String? ?? '';
    final estimatedPrice = (provider['estimatedPrice'] as num?)?.toInt() ?? 0;
    final isTopPick = provider['isTopPick'] == true;

    const rankColors = [
      Color(0xFFFFC107),
      Color(0xFF9E9E9E),
      Color(0xFFCD7F32),
    ];
    final rankColor = rank >= 1 && rank <= 3
        ? rankColors[rank - 1]
        : AppTheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopPick
              ? AppTheme.primary.withValues(alpha: 0.35)
              : const Color(0xFFE8EAED),
          width: isTopPick ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: rankColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          if (isTopPick) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'TOP PICK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' · $totalJobs jobs · ${experience}yr exp',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (distance > 0) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Color(0xFF757575),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${NumberFormat('#,###').format(estimatedPrice)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'est.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          if (reasoning.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 13,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reasoning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.primary.withValues(alpha: 0.85),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSelect,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT REQUEST — inline card with amount & credits, "Pay Now" → confirm dialog
// ─────────────────────────────────────────────────────────────────────────────

class PaymentRequestAction extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String bookingId) onPay;

  const PaymentRequestAction({
    super.key,
    required this.data,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingId = data['bookingId'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toInt() ?? 0;
    final customerCredits = (data['customerCredits'] as num?)?.toInt() ?? 0;
    final canPayWithCredits = data['canPayWithCredits'] == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Required',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      'PKR ${NumberFormat('#,###').format(amount)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: (canPayWithCredits ? Colors.green : Colors.orange)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  canPayWithCredits
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 14,
                  color: canPayWithCredits
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    canPayWithCredits
                        ? 'Your credits (PKR ${NumberFormat('#,###').format(customerCredits)}) will cover this booking'
                        : 'Credit balance: PKR ${NumberFormat('#,###').format(customerCredits)} — remaining will be charged to card',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: canPayWithCredits
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _confirmPay(context, bookingId, amount),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Pay PKR ${NumberFormat('#,###').format(amount)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPay(BuildContext context, String bookingId, int amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm Payment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Proceed with payment of PKR ${NumberFormat('#,###').format(amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onPay(bookingId);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING INFO CARD — read-only, no action sent to backend
// ─────────────────────────────────────────────────────────────────────────────

class BookingInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BookingInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = data['status'] as String? ?? '';
    final categoryName = data['categoryName'] as String? ?? '';
    final subCategoryName = data['subCategoryName'] as String? ?? '';
    final providerName = data['providerName'] as String? ?? '';
    final scheduledAt = data['scheduledAt'] as String?;
    final totalAmount = (data['totalAmount'] as num?)?.toInt();
    final paidAt = data['paidAt'] as String?;
    final location = data['location'] as Map<String, dynamic>?;
    final locationAddress = location?['address'] as String? ?? '';
    final locationCity = location?['city'] as String? ?? '';
    final locationText = [
      locationAddress,
      locationCity,
    ].where((e) => e.isNotEmpty).join(', ');

    final statusLabel = _statusLabel(status);
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 16,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  [
                    categoryName,
                    subCategoryName,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (providerName.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.person_outline_rounded, text: providerName),
          ],
          if (scheduledAt != null && scheduledAt.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.schedule_outlined,
              text: _formatDate(scheduledAt),
            ),
          ],
          if (totalAmount != null) ...[
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.payments_outlined,
              text: 'PKR ${NumberFormat('#,###').format(totalAmount)}',
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'UNPAID':
        return 'Unpaid';
      case 'PENDING':
        return 'Pending';
      case 'INITIALIZED':
        return 'In Progress';
      case 'PROVIDER_COMPLETED':
        return 'Awaiting Confirmation';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'DISPUTED':
        return 'Disputed';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'UNPAID':
        return const Color(0xFF757575);
      case 'PENDING':
        return const Color(0xFF1976D2);
      case 'INITIALIZED':
        return const Color(0xFFF57C00);
      case 'PROVIDER_COMPLETED':
        return const Color(0xFF388E3C);
      case 'COMPLETED':
        return const Color(0xFF388E3C);
      case 'CANCELLED':
        return const Color(0xFFD32F2F);
      case 'DISPUTED':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF757575);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d · h:mm a').format(dt.toLocal());
    } catch (_) {
      return dateStr;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRM COMPLETION — Confirm ✓ or Dispute ✗ (with reason dialog)
// ─────────────────────────────────────────────────────────────────────────────

class ConfirmCompletionAction extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(bool confirmed, String? reason) onResponse;

  const ConfirmCompletionAction({
    super.key,
    required this.data,
    required this.onResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final providerName = data['providerName'] as String? ?? 'the provider';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  size: 18,
                  color: Color(0xFF388E3C),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Was the job completed by $providerName?',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => onResponse(true, null),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Confirm'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDisputeDialog(context),
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: const Text('Dispute'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                    side: const BorderSide(color: Color(0xFFD32F2F)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDisputeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Dispute Reason',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please describe what went wrong:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Work was not completed properly...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final reason = controller.text.trim();
              onResponse(false, reason.isEmpty ? null : reason);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Submit Dispute'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW REQUEST — "Leave a Review" → star rating dialog with optional comment
// ─────────────────────────────────────────────────────────────────────────────

class ReviewRequestAction extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(int rating, String? comment) onReview;

  const ReviewRequestAction({
    super.key,
    required this.data,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final providerName = data['providerName'] as String? ?? 'the provider';
    return FilledButton.tonal(
      onPressed: () => _showReviewDialog(context, providerName),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryContainer,
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: Size.zero,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_outline_rounded, size: 16),
          SizedBox(width: 6),
          Text(
            'Leave a Review',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, String providerName) {
    showDialog(
      context: context,
      builder: (ctx) => _ReviewDialog(
        providerName: providerName,
        onSubmit: (rating, comment) {
          Navigator.pop(ctx);
          onReview(rating, comment);
        },
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final String providerName;
  final void Function(int rating, String? comment) onSubmit;

  const _ReviewDialog({required this.providerName, required this.onSubmit});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Rate ${widget.providerName}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _selectedRating;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 38,
                      color: filled
                          ? const Color(0xFFFFC107)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_selectedRating > 0) ...[
            const SizedBox(height: 6),
            Text(
              _ratingLabel(_selectedRating),
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFFFC107),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedRating == 0
              ? null
              : () {
                  final comment = _commentController.text.trim();
                  widget.onSubmit(
                    _selectedRating,
                    comment.isEmpty ? null : comment,
                  );
                },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text('Submit Review'),
        ),
      ],
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION REQUEST — shows current location + opens map bottom sheet to confirm
// ─────────────────────────────────────────────────────────────────────────────

class LocationRequestAction extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> locationData) onUpdateLocation;

  const LocationRequestAction({
    super.key,
    required this.data,
    required this.onUpdateLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentAddress = data['currentAddress'] as String? ?? '';
    final currentCity = data['currentCity'] as String? ?? '';
    final currentLat = (data['currentLatitude'] as num?)?.toDouble() ?? 0.0;
    final currentLng = (data['currentLongitude'] as num?)?.toDouble() ?? 0.0;
    final locationText = [
      currentAddress,
      currentCity,
    ].where((e) => e.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Booking Location',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    if (locationText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        locationText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openMapSheet(context, currentLat, currentLng),
              icon: const Icon(Icons.map_outlined, size: 16),
              label: const Text(
                'Confirm on Map',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMapSheet(
    BuildContext context,
    double registeredLat,
    double registeredLng,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationPickerSheet(
        registeredLat: registeredLat,
        registeredLng: registeredLng,
        onConfirm: onUpdateLocation,
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final double registeredLat;
  final double registeredLng;
  final void Function(Map<String, dynamic> locData) onConfirm;

  const _LocationPickerSheet({
    required this.registeredLat,
    required this.registeredLng,
    required this.onConfirm,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  LatLng? _pinned;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isConfirming = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  Future<void> _initPosition() async {
    // Start with the registered coordinates if valid, otherwise default Lahore
    LatLng initial = (widget.registeredLat != 0 || widget.registeredLng != 0)
        ? LatLng(widget.registeredLat, widget.registeredLng)
        : const LatLng(31.5204, 74.3587);

    // Try to get live GPS position
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        initial = LatLng(pos.latitude, pos.longitude);
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _pinned = initial;
      _markers = {Marker(markerId: const MarkerId('pin'), position: initial)};
      _isLoading = false;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(initial));
  }

  void _onMapTap(LatLng pos) {
    setState(() {
      _pinned = pos;
      _markers = {Marker(markerId: const MarkerId('pin'), position: pos)};
    });
  }

  Future<void> _onConfirm() async {
    if (_pinned == null || _isConfirming) return;
    setState(() => _isConfirming = true);

    String address = 'Pinned Location';
    String city = 'Unknown City';
    String state = '';

    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        _pinned!.latitude,
        _pinned!.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
        ].where((e) => e != null && e.isNotEmpty).toList();
        address = parts.isNotEmpty ? parts.join(', ') : 'Pinned Location';
        city = p.locality ?? p.subAdministrativeArea ?? 'Unknown City';
        state = p.administrativeArea ?? '';
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    if (!mounted) return;
    Navigator.pop(context);
    widget.onConfirm({
      'location': {
        'address': address,
        'city': city,
        'state': state,
        'coordinates': [_pinned!.longitude, _pinned!.latitude],
      },
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 14),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pin Your Booking Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tap anywhere on the map to move the pin. Address is auto-detected.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Map
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _pinned!,
                          zoom: 15,
                        ),
                        onMapCreated: (c) => _mapController = c,
                        onTap: _onMapTap,
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                      // Center crosshair hint
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: Icon(Icons.add, color: Colors.transparent),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          // Confirm bar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isConfirming ? null : _onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirm Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
