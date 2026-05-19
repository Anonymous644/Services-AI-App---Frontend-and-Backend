import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/booking.dart';

part 'bookings_repository.g.dart';

class BookingsRepository {
  final Dio _dio;

  BookingsRepository(this._dio);

  Future<List<Booking>> getBookings() async {
    final response = await _dio.get('/bookings');
    if (response.statusCode == 200) {
      final data = response.data;
      // API returns a paginated object { bookings: [...], total, page, limit }
      final list = (data is Map ? data['bookings'] : data) as List;
      return list
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Booking?> getBookingById(String id) async {
    final response = await _dio.get('/bookings/$id');
    if (response.statusCode == 200) {
      return Booking.fromJson(response.data);
    }
    return null;
  }

  Future<Booking?> updateStatus(String id, BookingStatus status) async {
    final response = await _dio.patch(
      '/bookings/$id/status',
      data: {'status': _statusToApiString(status)},
    );
    if (response.statusCode == 200) {
      return Booking.fromJson(response.data);
    }
    return null;
  }

  Future<bool> payBooking(String id) async {
    final response = await _dio.post('/bookings/$id/pay');
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> submitReview(String id, int rating, String? comment) async {
    final response = await _dio.post(
      '/bookings/$id/review',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  String _statusToApiString(BookingStatus status) {
    switch (status) {
      case BookingStatus.unpaid:
        return 'UNPAID';
      case BookingStatus.pending:
        return 'PENDING';
      case BookingStatus.initialized:
        return 'INITIALIZED';
      case BookingStatus.providerCompleted:
        return 'PROVIDER_COMPLETED';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.disputed:
        return 'DISPUTED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

@riverpod
BookingsRepository bookingsRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return BookingsRepository(dio);
}
