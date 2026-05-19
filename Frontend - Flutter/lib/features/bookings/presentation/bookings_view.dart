import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bookings_controller.dart';
import '../../../core/widgets/booking_card.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../models/user.dart';

class BookingsView extends ConsumerStatefulWidget {
  const BookingsView({super.key});

  @override
  ConsumerState<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends ConsumerState<BookingsView> {
  BookingStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingsControllerProvider);
    final isProvider =
        ref.watch(authControllerProvider).value?.role == UserRole.provider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(BookingStatus.pending, 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip(BookingStatus.initialized, 'Active'),
                const SizedBox(width: 8),
                if (isProvider) ...[
                  _buildFilterChip(
                    BookingStatus.providerCompleted,
                    'Awaiting Review',
                  ),
                  const SizedBox(width: 8),
                ],
                _buildFilterChip(BookingStatus.completed, 'Completed'),
                const SizedBox(width: 8),
                _buildFilterChip(BookingStatus.cancelled, 'Cancelled'),
              ],
            ),
          ),
        ),
      ),
      body: bookingsState.when(
        data: (bookings) {
          final filtered = _selectedFilter == null
              ? bookings
              : bookings.where((b) => b.status == _selectedFilter).toList();

          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(bookingsControllerProvider.notifier)
                  .refreshBookings(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No bookings found.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(bookingsControllerProvider.notifier).refreshBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return BookingCard(
                  booking: filtered[index],
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.bookingDetails,
                      arguments: filtered[index].id,
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => RefreshIndicator(
          onRefresh: () =>
              ref.read(bookingsControllerProvider.notifier).refreshBookings(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 200),
              Center(child: Text('Error: $e')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BookingStatus? status, String label) {
    final isSelected = _selectedFilter == status;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primary,
      side: BorderSide(
        color: isSelected ? AppTheme.primary : const Color(0xFFD0D5E8),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
    );
  }
}
