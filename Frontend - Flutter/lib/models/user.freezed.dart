// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String? get id; String? get email; String? get firstName; String? get lastName; String? get phone; UserRole? get role; String? get avatarUrl; String? get fcmToken; double? get creditBalance; Location? get location;// Provider specific
 String? get bio; int? get experience; double? get rating; int? get totalJobs; double? get serviceRadius; bool? get isVerified; bool? get isActive; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.creditBalance, creditBalance) || other.creditBalance == creditBalance)&&(identical(other.location, location) || other.location == location)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalJobs, totalJobs) || other.totalJobs == totalJobs)&&(identical(other.serviceRadius, serviceRadius) || other.serviceRadius == serviceRadius)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,firstName,lastName,phone,role,avatarUrl,fcmToken,creditBalance,location,bio,experience,rating,totalJobs,serviceRadius,isVerified,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, role: $role, avatarUrl: $avatarUrl, fcmToken: $fcmToken, creditBalance: $creditBalance, location: $location, bio: $bio, experience: $experience, rating: $rating, totalJobs: $totalJobs, serviceRadius: $serviceRadius, isVerified: $isVerified, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String? id, String? email, String? firstName, String? lastName, String? phone, UserRole? role, String? avatarUrl, String? fcmToken, double? creditBalance, Location? location, String? bio, int? experience, double? rating, int? totalJobs, double? serviceRadius, bool? isVerified, bool? isActive, DateTime? createdAt, DateTime? updatedAt
});


$LocationCopyWith<$Res>? get location;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? role = freezed,Object? avatarUrl = freezed,Object? fcmToken = freezed,Object? creditBalance = freezed,Object? location = freezed,Object? bio = freezed,Object? experience = freezed,Object? rating = freezed,Object? totalJobs = freezed,Object? serviceRadius = freezed,Object? isVerified = freezed,Object? isActive = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,creditBalance: freezed == creditBalance ? _self.creditBalance : creditBalance // ignore: cast_nullable_to_non_nullable
as double?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,experience: freezed == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,totalJobs: freezed == totalJobs ? _self.totalJobs : totalJobs // ignore: cast_nullable_to_non_nullable
as int?,serviceRadius: freezed == serviceRadius ? _self.serviceRadius : serviceRadius // ignore: cast_nullable_to_non_nullable
as double?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? email,  String? firstName,  String? lastName,  String? phone,  UserRole? role,  String? avatarUrl,  String? fcmToken,  double? creditBalance,  Location? location,  String? bio,  int? experience,  double? rating,  int? totalJobs,  double? serviceRadius,  bool? isVerified,  bool? isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.phone,_that.role,_that.avatarUrl,_that.fcmToken,_that.creditBalance,_that.location,_that.bio,_that.experience,_that.rating,_that.totalJobs,_that.serviceRadius,_that.isVerified,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? email,  String? firstName,  String? lastName,  String? phone,  UserRole? role,  String? avatarUrl,  String? fcmToken,  double? creditBalance,  Location? location,  String? bio,  int? experience,  double? rating,  int? totalJobs,  double? serviceRadius,  bool? isVerified,  bool? isActive,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.phone,_that.role,_that.avatarUrl,_that.fcmToken,_that.creditBalance,_that.location,_that.bio,_that.experience,_that.rating,_that.totalJobs,_that.serviceRadius,_that.isVerified,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? email,  String? firstName,  String? lastName,  String? phone,  UserRole? role,  String? avatarUrl,  String? fcmToken,  double? creditBalance,  Location? location,  String? bio,  int? experience,  double? rating,  int? totalJobs,  double? serviceRadius,  bool? isVerified,  bool? isActive,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.phone,_that.role,_that.avatarUrl,_that.fcmToken,_that.creditBalance,_that.location,_that.bio,_that.experience,_that.rating,_that.totalJobs,_that.serviceRadius,_that.isVerified,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({this.id, this.email, this.firstName, this.lastName, this.phone, this.role, this.avatarUrl, this.fcmToken, this.creditBalance, this.location, this.bio, this.experience, this.rating, this.totalJobs, this.serviceRadius, this.isVerified, this.isActive = true, this.createdAt, this.updatedAt});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String? id;
@override final  String? email;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? phone;
@override final  UserRole? role;
@override final  String? avatarUrl;
@override final  String? fcmToken;
@override final  double? creditBalance;
@override final  Location? location;
// Provider specific
@override final  String? bio;
@override final  int? experience;
@override final  double? rating;
@override final  int? totalJobs;
@override final  double? serviceRadius;
@override final  bool? isVerified;
@override@JsonKey() final  bool? isActive;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.creditBalance, creditBalance) || other.creditBalance == creditBalance)&&(identical(other.location, location) || other.location == location)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalJobs, totalJobs) || other.totalJobs == totalJobs)&&(identical(other.serviceRadius, serviceRadius) || other.serviceRadius == serviceRadius)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,email,firstName,lastName,phone,role,avatarUrl,fcmToken,creditBalance,location,bio,experience,rating,totalJobs,serviceRadius,isVerified,isActive,createdAt,updatedAt]);

@override
String toString() {
  return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, phone: $phone, role: $role, avatarUrl: $avatarUrl, fcmToken: $fcmToken, creditBalance: $creditBalance, location: $location, bio: $bio, experience: $experience, rating: $rating, totalJobs: $totalJobs, serviceRadius: $serviceRadius, isVerified: $isVerified, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? email, String? firstName, String? lastName, String? phone, UserRole? role, String? avatarUrl, String? fcmToken, double? creditBalance, Location? location, String? bio, int? experience, double? rating, int? totalJobs, double? serviceRadius, bool? isVerified, bool? isActive, DateTime? createdAt, DateTime? updatedAt
});


@override $LocationCopyWith<$Res>? get location;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? role = freezed,Object? avatarUrl = freezed,Object? fcmToken = freezed,Object? creditBalance = freezed,Object? location = freezed,Object? bio = freezed,Object? experience = freezed,Object? rating = freezed,Object? totalJobs = freezed,Object? serviceRadius = freezed,Object? isVerified = freezed,Object? isActive = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_User(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,creditBalance: freezed == creditBalance ? _self.creditBalance : creditBalance // ignore: cast_nullable_to_non_nullable
as double?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,experience: freezed == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,totalJobs: freezed == totalJobs ? _self.totalJobs : totalJobs // ignore: cast_nullable_to_non_nullable
as int?,serviceRadius: freezed == serviceRadius ? _self.serviceRadius : serviceRadius // ignore: cast_nullable_to_non_nullable
as double?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
