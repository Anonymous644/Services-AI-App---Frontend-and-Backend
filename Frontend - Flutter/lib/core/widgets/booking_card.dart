import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/booking.dart';
import '../../../core/theme/app_theme.dart';
import 'status_badge.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  Color _accentColor(BookingStatus? status) {
    switch (status) {
      case BookingStatus.unpaid:
        return const Color(0xFFB45309);
      case BookingStatus.pending:
        return const Color(0xFFD97706);
      case BookingStatus.initialized:
        return const Color(0xFF1D4ED8);
      case BookingStatus.providerCompleted:
        return const Color(0xFF6D28D9);
      case BookingStatus.completed:
        return const Color(0xFF15803D);
      case BookingStatus.disputed:
        return const Color(0xFFDC2626);
      case BookingStatus.cancelled:
        return const Color(0xFF6B7280);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final accent = _accentColor(booking.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row + status
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  booking.subCategoryName ?? 'AI Service',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (booking.status != null)
                                StatusBadge(status: booking.status!),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Date
                          _InfoRow(
                            icon: Icons.schedule_outlined,
                            text: booking.scheduledAt != null
                                ? dateFormat.format(booking.scheduledAt!)
                                : 'Not scheduled yet',
                          ),
                          const SizedBox(height: 6),

                          // Location
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            text:
                                booking.location?.address ?? 'Location not set',
                            maxLines: 1,
                          ),

                          if (booking.totalAmount != null) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'PKR ${booking.totalAmount!.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Right arrow
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;

  const _InfoRow({required this.icon, required this.text, this.maxLines = 2});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
