import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bookings_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../models/booking.dart';
import '../../../models/user.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/theme/app_theme.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(bookingsControllerProvider);
    final user = ref.watch(authControllerProvider).value;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: bookingsState.when(
        data: (bookings) {
          final booking = bookings.firstWhere(
            (b) => b.id == bookingId,
            orElse: () => const Booking(),
          );

          if (booking.id == null) {
            return const Center(child: Text('Booking not found'));
          }

          final isProvider = user?.role == UserRole.provider;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (booking.status != null &&
                  !const [
                    BookingStatus.cancelled,
                    BookingStatus.disputed,
                  ].contains(booking.status))
                _StatusTimeline(booking: booking),

              if (booking.status == BookingStatus.cancelled ||
                  booking.status == BookingStatus.disputed)
                _StatusBanner(booking: booking, theme: theme),

              if (!isProvider && booking.provider != null) ...[
                _PersonCard(
                  person: booking.provider!,
                  role: 'Your Provider',
                  icon: Icons.handyman_outlined,
                  showProviderDetails: true,
                ),
                const SizedBox(height: 12),
              ],
              if (isProvider && booking.customer != null) ...[
                _PersonCard(
                  person: booking.customer!,
                  role: 'Customer',
                  icon: Icons.person_outline,
                  showProviderDetails: false,
                ),
                const SizedBox(height: 12),
              ],

              _SectionCard(
                title: 'Service Info',
                icon: Icons.home_repair_service_outlined,
                children: [
                  _DetailRow(
                    label: 'Service',
                    value: booking.subCategoryName ?? 'AI Service',
                  ),
                  if (booking.serviceDetails != null &&
                      booking.serviceDetails!.isNotEmpty)
                    _DetailRow(
                      label: 'Details',
                      value: booking.serviceDetails!,
                    ),
                  if (booking.estimatedDuration != null)
                    _DetailRow(
                      label: 'Duration',
                      value: '~${booking.estimatedDuration} min',
                    ),
                  if (booking.scheduledAt != null)
                    _DetailRow(
                      label: 'Scheduled',
                      value: DateFormat(
                        'MMM d, yyyy • h:mm a',
                      ).format(booking.scheduledAt!),
                    ),
                  if (booking.customerNotes != null &&
                      booking.customerNotes!.isNotEmpty)
                    _DetailRow(label: 'Notes', value: booking.customerNotes!),
                ],
              ),
              const SizedBox(height: 12),

              _LocationMapPreview(booking: booking),
              const SizedBox(height: 12),

              if (booking.matchReasoning != null &&
                  booking.matchReasoning!.isNotEmpty) ...[
                _MatchReasoningTile(reasoning: booking.matchReasoning!),
                const SizedBox(height: 12),
              ],

              _SectionCard(
                title: 'Payment',
                icon: Icons.payments_outlined,
                children: [
                  _DetailRow(
                    label: 'Total',
                    value: booking.totalAmount != null
                        ? 'PKR ${booking.totalAmount!.toStringAsFixed(0)}'
                        : 'To be determined',
                    valueStyle: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isProvider && booking.providerPayout != null)
                    _DetailRow(
                      label: 'Your Payout',
                      value:
                          'PKR ${booking.providerPayout!.toStringAsFixed(0)}',
                      valueStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF15803D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (booking.status != null)
                    _DetailRow(
                      label: 'Status',
                      value: '',
                      trailing: StatusBadge(status: booking.status!),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              if (isProvider) _ProviderActions(booking: booking),
              if (!isProvider) _CustomerActions(booking: booking),
              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Error loading booking')),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Booking booking;
  final ThemeData theme;
  const _StatusBanner({required this.booking, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isCancelled = booking.status == BookingStatus.cancelled;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFF3F4F6) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.gavel_outlined,
            color: isCancelled
                ? const Color(0xFF6B7280)
                : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCancelled
                  ? 'This booking has been cancelled${booking.cancelledBy == CancelledBy.provider ? " by the provider" : ""}.'
                  : 'This booking is under dispute.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCancelled
                    ? const Color(0xFF6B7280)
                    : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final Booking booking;
  const _StatusTimeline({required this.booking});

  static const _steps = [
    (label: 'Unpaid', status: BookingStatus.unpaid),
    (label: 'Pending', status: BookingStatus.pending),
    (label: 'In Progress', status: BookingStatus.initialized),
    (label: 'Review', status: BookingStatus.providerCompleted),
    (label: 'Done', status: BookingStatus.completed),
  ];

  DateTime? _timestampFor(BookingStatus status, Booking b) {
    return switch (status) {
      BookingStatus.unpaid => b.createdAt,
      BookingStatus.pending => b.paidAt,
      BookingStatus.initialized => b.initializedAt,
      BookingStatus.completed => b.completedAt,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((s) => s.status == booking.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final isActive = (i ~/ 2) < currentIndex;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Container(
                  height: 2,
                  color: isActive ? AppTheme.primary : const Color(0xFFE8EAED),
                ),
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final step = _steps[stepIdx];
          final isDone = stepIdx < currentIndex;
          final isCurrent = stepIdx == currentIndex;
          final ts = _timestampFor(step.status, booking);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone || isCurrent
                      ? AppTheme.primary
                      : const Color(0xFFE8EAED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check : Icons.circle,
                  size: isDone ? 16 : 8,
                  color: isDone || isCurrent
                      ? Colors.white
                      : const Color(0xFFBDBDBD),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                step.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isDone || isCurrent
                      ? AppTheme.primary
                      : const Color(0xFF9E9E9E),
                ),
              ),
              if (ts != null && (isDone || isCurrent)) ...[
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d\nh:mm a').format(ts),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF9E9E9E),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final User person;
  final String role;
  final IconData icon;
  final bool showProviderDetails;

  const _PersonCard({
    required this.person,
    required this.role,
    required this.icon,
    required this.showProviderDetails,
  });

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2)
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    if (parts.isNotEmpty && parts.first.isNotEmpty)
      return parts.first[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = '${person.firstName ?? ''} ${person.lastName ?? ''}'.trim();
    final initials = _initials(name);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                role,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                backgroundImage: person.avatarUrl != null
                    ? NetworkImage(person.avatarUrl!)
                    : null,
                child: person.avatarUrl == null
                    ? Text(
                        initials,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isNotEmpty ? name : 'Unknown',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showProviderDetails &&
                            person.isVerified == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 12,
                                  color: Color(0xFF0284C7),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF0284C7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (showProviderDetails) ...[
                      const SizedBox(height: 4),
                      if (person.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              person.rating!.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (person.totalJobs != null)
                              Text(
                                '  (${person.totalJobs} jobs)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      if (person.experience != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${person.experience} yr${person.experience != 1 ? "s" : ""} experience',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (person.phone != null)
                IconButton.filled(
                  onPressed: () => _call(person.phone!),
                  icon: const Icon(Icons.call, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                  ),
                  tooltip: 'Call',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationMapPreview extends StatelessWidget {
  final Booking booking;
  const _LocationMapPreview({required this.booking});

  Future<void> _openMaps(double lat, double lng, String? address) async {
    final query = Uri.encodeComponent(address ?? '$lat,$lng');
    final geoUri = Uri.parse('geo:$lat,$lng?q=$query');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      final webUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coords = booking.location?.geo?.coordinates;
    final hasCoords = coords != null && coords.length >= 2;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const Spacer(),
                if (hasCoords)
                  const Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Color(0xFF9E9E9E),
                  ),
              ],
            ),
          ),
          if (hasCoords)
            GestureDetector(
              onTap: () =>
                  _openMaps(coords[1], coords[0], booking.location?.address),
              child: SizedBox(
                height: 160,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(coords[1], coords[0]),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('booking_location'),
                      position: LatLng(coords[1], coords[0]),
                    ),
                  },
                  zoomGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  liteModeEnabled: true,
                ),
              ),
            )
          else
            Container(
              height: 80,
              color: const Color(0xFFF8F9FA),
              child: const Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 32,
                  color: Color(0xFFD1D5DB),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (booking.location?.address != null)
                  Text(
                    booking.location!.address!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (booking.location?.city != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    booking.location!.city!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (booking.location?.address == null &&
                    booking.location?.city == null)
                  Text(
                    'Location not specified',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchReasoningTile extends StatefulWidget {
  final String reasoning;
  const _MatchReasoningTile({required this.reasoning});

  @override
  State<_MatchReasoningTile> createState() => _MatchReasoningTileState();
}

class _MatchReasoningTileState extends State<_MatchReasoningTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Why this provider?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF9E9E9E),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.reasoning,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? trailing;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (trailing != null)
            trailing!
          else
            Expanded(
              child: Text(
                value,
                style:
                    valueStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProviderActions extends ConsumerStatefulWidget {
  final Booking booking;
  const _ProviderActions({required this.booking});

  @override
  ConsumerState<_ProviderActions> createState() => _ProviderActionsState();
}

class _ProviderActionsState extends ConsumerState<_ProviderActions> {
  bool _isLoading = false;

  Future<void> _updateStatus(BookingStatus status) async {
    setState(() => _isLoading = true);
    await ref
        .read(bookingsControllerProvider.notifier)
        .updateBookingStatus(widget.booking.id!, status);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'The customer will be notified and receive a full refund.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Back'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _updateStatus(BookingStatus.cancelled);
  }

  Widget get _loader => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    final status = widget.booking.status;

    if (status == BookingStatus.pending) {
      return Column(
        children: [
          FilledButton.icon(
            onPressed: _isLoading
                ? null
                : () => _updateStatus(BookingStatus.initialized),
            icon: _isLoading ? _loader : const Icon(Icons.play_arrow_rounded),
            label: const Text('Initialize Job'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _cancel(context),
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: const Text(
              'Cancel Booking',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      );
    } else if (status == BookingStatus.initialized) {
      return Column(
        children: [
          FilledButton.icon(
            onPressed: _isLoading
                ? null
                : () => _updateStatus(BookingStatus.providerCompleted),
            icon: _isLoading ? _loader : const Icon(Icons.check_circle_outline),
            label: const Text('Mark as Completed'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFF15803D),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _cancel(context),
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: const Text(
              'Cancel Booking',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _CustomerActions extends ConsumerWidget {
  final Booking booking;
  const _CustomerActions({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (booking.status == BookingStatus.unpaid) {
      return FilledButton.icon(
        onPressed: () => ref
            .read(bookingsControllerProvider.notifier)
            .payBooking(booking.id!),
        icon: const Icon(Icons.payments_outlined),
        label: const Text('Proceed to Pay'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      );
    }
    if (booking.status == BookingStatus.completed) {
      return FilledButton.icon(
        onPressed: () => _showReviewSheet(context, ref, booking.id!),
        icon: const Icon(Icons.star_outline),
        label: const Text('Leave a Review'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: const Color(0xFFF59E0B),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref, String bookingId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ReviewBottomSheet(
        bookingId: bookingId,
        onSubmit: (rating, comment) => ref
            .read(bookingsControllerProvider.notifier)
            .submitReview(bookingId, rating, comment),
      ),
    );
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  final String bookingId;
  final Future<bool> Function(int rating, String? comment) onSubmit;

  const _ReviewBottomSheet({required this.bookingId, required this.onSubmit});

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _isLoading = true);
    final comment = _commentController.text.trim();
    final success = await widget.onSubmit(
      _rating,
      comment.isEmpty ? null : comment,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Review submitted. Thank you!'
              : 'Failed to submit review. Please try again.',
        ),
        backgroundColor: success ? const Color(0xFF15803D) : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAED),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rate this service',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How was your experience with the provider?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: filled
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a comment (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8EAED)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8EAED)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_rating == 0 || _isLoading) ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFFF59E0B),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Review',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}
