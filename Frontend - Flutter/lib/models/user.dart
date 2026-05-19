import 'package:freezed_annotation/freezed_annotation.dart';
import 'location.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  @JsonValue('CUSTOMER') customer,
  @JsonValue('PROVIDER') provider,
}

@freezed
abstract class User with _$User {
  const factory User({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    String? fcmToken,
    double? creditBalance,
    Location? location,
    
    // Provider specific
    String? bio,
    int? experience,
    double? rating,
    int? totalJobs,
    double? serviceRadius,
    bool? isVerified,
    
    @Default(true) bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
