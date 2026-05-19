// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String?,
  email: json['email'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  phone: json['phone'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
  avatarUrl: json['avatarUrl'] as String?,
  fcmToken: json['fcmToken'] as String?,
  creditBalance: (json['creditBalance'] as num?)?.toDouble(),
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  bio: json['bio'] as String?,
  experience: (json['experience'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  totalJobs: (json['totalJobs'] as num?)?.toInt(),
  serviceRadius: (json['serviceRadius'] as num?)?.toDouble(),
  isVerified: json['isVerified'] as bool?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phone': instance.phone,
  'role': _$UserRoleEnumMap[instance.role],
  'avatarUrl': instance.avatarUrl,
  'fcmToken': instance.fcmToken,
  'creditBalance': instance.creditBalance,
  'location': instance.location,
  'bio': instance.bio,
  'experience': instance.experience,
  'rating': instance.rating,
  'totalJobs': instance.totalJobs,
  'serviceRadius': instance.serviceRadius,
  'isVerified': instance.isVerified,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.customer: 'CUSTOMER',
  UserRole.provider: 'PROVIDER',
};
