import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/booking.dart';
import '../data/bookings_repository.dart';

part 'bookings_controller.g.dart';

@riverpod
class BookingsController extends _$BookingsController {
  @override
  FutureOr<List<Booking>> build() async {
    return await ref.read(bookingsRepositoryProvider).getBookings();
  }

  Future<void> refreshBookings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(bookingsRepositoryProvider).getBookings();
    });
  }

  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    final previousState = state;
    try {
      final updatedBooking = await ref
          .read(bookingsRepositoryProvider)
          .updateStatus(id, status);
      if (updatedBooking != null) {
        state = AsyncValue.data([
          for (final booking in state.value ?? [])
            if (booking.id == id) updatedBooking else booking,
        ]);
      }
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> payBooking(String id) async {
    try {
      final success = await ref.read(bookingsRepositoryProvider).payBooking(id);
      if (success) {
        await refreshBookings();
      }
    } catch (e) {
      // Error handled globally by interceptor
    }
  }

  Future<bool> submitReview(
    String bookingId,
    int rating,
    String? comment,
  ) async {
    try {
      return await ref
          .read(bookingsRepositoryProvider)
          .submitReview(bookingId, rating, comment);
    } catch (e) {
      return false;
    }
  }
}
