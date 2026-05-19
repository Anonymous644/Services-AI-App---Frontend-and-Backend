// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String?,
  customerId: json['customerId'] as String?,
  providerId: json['providerId'] as String?,
  categoryId: json['categoryId'] as String?,
  status: $enumDecodeNullable(_$BookingStatusEnumMap, json['status']),
  subCategoryName: json['subCategoryName'] as String?,
  serviceDetails: json['serviceDetails'] as String?,
  customerNotes: json['customerNotes'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  totalAmount: (json['totalAmount'] as num?)?.toDouble(),
  platformFee: (json['platformFee'] as num?)?.toDouble(),
  providerPayout: (json['providerPayout'] as num?)?.toDouble(),
  matchReasoning: json['matchReasoning'] as String?,
  cancelledBy: $enumDecodeNullable(_$CancelledByEnumMap, json['cancelledBy']),
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  initializedAt: json['initializedAt'] == null
      ? null
      : DateTime.parse(json['initializedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  disputedAt: json['disputedAt'] == null
      ? null
      : DateTime.parse(json['disputedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  provider: json['provider'] == null
      ? null
      : User.fromJson(json['provider'] as Map<String, dynamic>),
  customer: json['customer'] == null
      ? null
      : User.fromJson(json['customer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'providerId': instance.providerId,
  'categoryId': instance.categoryId,
  'status': _$BookingStatusEnumMap[instance.status],
  'subCategoryName': instance.subCategoryName,
  'serviceDetails': instance.serviceDetails,
  'customerNotes': instance.customerNotes,
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
  'estimatedDuration': instance.estimatedDuration,
  'location': instance.location,
  'totalAmount': instance.totalAmount,
  'platformFee': instance.platformFee,
  'providerPayout': instance.providerPayout,
  'matchReasoning': instance.matchReasoning,
  'cancelledBy': _$CancelledByEnumMap[instance.cancelledBy],
  'paidAt': instance.paidAt?.toIso8601String(),
  'initializedAt': instance.initializedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
  'disputedAt': instance.disputedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'provider': instance.provider,
  'customer': instance.customer,
};

const _$BookingStatusEnumMap = {
  BookingStatus.unpaid: 'UNPAID',
  BookingStatus.pending: 'PENDING',
  BookingStatus.initialized: 'INITIALIZED',
  BookingStatus.providerCompleted: 'PROVIDER_COMPLETED',
  BookingStatus.completed: 'COMPLETED',
  BookingStatus.disputed: 'DISPUTED',
  BookingStatus.cancelled: 'CANCELLED',
};

const _$CancelledByEnumMap = {
  CancelledBy.customer: 'CUSTOMER',
  CancelledBy.provider: 'PROVIDER',
};
