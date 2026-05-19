import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';
import 'user.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus {
  @JsonValue('UNPAID') unpaid,
  @JsonValue('PENDING') pending,
  @JsonValue('INITIALIZED') initialized,
  @JsonValue('PROVIDER_COMPLETED') providerCompleted,
  @JsonValue('COMPLETED') completed,
  @JsonValue('DISPUTED') disputed,
  @JsonValue('CANCELLED') cancelled,
}

enum CancelledBy {
  @JsonValue('CUSTOMER') customer,
  @JsonValue('PROVIDER') provider,
}

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    String? id,
    String? customerId,
    String? providerId,
    String? categoryId,
    BookingStatus? status,
    String? subCategoryName,
    String? serviceDetails,
    String? customerNotes,
    DateTime? scheduledAt,
    int? estimatedDuration,
    Location? location,
    double? totalAmount,
    double? platformFee,
    double? providerPayout,
    String? matchReasoning,
    CancelledBy? cancelledBy,
    DateTime? paidAt,
    DateTime? initializedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? disputedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? provider,
    User? customer,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}
