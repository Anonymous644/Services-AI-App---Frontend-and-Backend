import 'package:flutter/material.dart';
import '../../../models/booking.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatName(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _formatName(BookingStatus status) {
    switch (status) {
      case BookingStatus.unpaid:
        return 'UNPAID';
      case BookingStatus.pending:
        return 'PENDING';
      case BookingStatus.initialized:
        return 'IN PROGRESS';
      case BookingStatus.providerCompleted:
        return 'AWAITING REVIEW';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.disputed:
        return 'DISPUTED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color _getColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.unpaid:
        return const Color(0xFFB45309); // amber-700
      case BookingStatus.pending:
        return const Color(0xFFD97706); // amber-500
      case BookingStatus.initialized:
        return const Color(0xFF1D4ED8); // blue-700
      case BookingStatus.providerCompleted:
        return const Color(0xFF6D28D9); // violet-700
      case BookingStatus.completed:
        return const Color(0xFF15803D); // green-700
      case BookingStatus.disputed:
        return const Color(0xFFDC2626); // red-600
      case BookingStatus.cancelled:
        return const Color(0xFF6B7280); // gray-500
    }
  }
}
