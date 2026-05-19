// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String? get id; String? get customerId; String? get providerId; String? get categoryId; BookingStatus? get status; String? get subCategoryName; String? get serviceDetails; String? get customerNotes; DateTime? get scheduledAt; int? get estimatedDuration; Location? get location; double? get totalAmount; double? get platformFee; double? get providerPayout; String? get matchReasoning; CancelledBy? get cancelledBy; DateTime? get paidAt; DateTime? get initializedAt; DateTime? get completedAt; DateTime? get cancelledAt; DateTime? get disputedAt; DateTime? get createdAt; DateTime? get updatedAt; User? get provider; User? get customer;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.status, status) || other.status == status)&&(identical(other.subCategoryName, subCategoryName) || other.subCategoryName == subCategoryName)&&(identical(other.serviceDetails, serviceDetails) || other.serviceDetails == serviceDetails)&&(identical(other.customerNotes, customerNotes) || other.customerNotes == customerNotes)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&(identical(other.location, location) || other.location == location)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.providerPayout, providerPayout) || other.providerPayout == providerPayout)&&(identical(other.matchReasoning, matchReasoning) || other.matchReasoning == matchReasoning)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.initializedAt, initializedAt) || other.initializedAt == initializedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.disputedAt, disputedAt) || other.disputedAt == disputedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.customer, customer) || other.customer == customer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerId,providerId,categoryId,status,subCategoryName,serviceDetails,customerNotes,scheduledAt,estimatedDuration,location,totalAmount,platformFee,providerPayout,matchReasoning,cancelledBy,paidAt,initializedAt,completedAt,cancelledAt,disputedAt,createdAt,updatedAt,provider,customer]);

@override
String toString() {
  return 'Booking(id: $id, customerId: $customerId, providerId: $providerId, categoryId: $categoryId, status: $status, subCategoryName: $subCategoryName, serviceDetails: $serviceDetails, customerNotes: $customerNotes, scheduledAt: $scheduledAt, estimatedDuration: $estimatedDuration, location: $location, totalAmount: $totalAmount, platformFee: $platformFee, providerPayout: $providerPayout, matchReasoning: $matchReasoning, cancelledBy: $cancelledBy, paidAt: $paidAt, initializedAt: $initializedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, disputedAt: $disputedAt, createdAt: $createdAt, updatedAt: $updatedAt, provider: $provider, customer: $customer)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String? id, String? customerId, String? providerId, String? categoryId, BookingStatus? status, String? subCategoryName, String? serviceDetails, String? customerNotes, DateTime? scheduledAt, int? estimatedDuration, Location? location, double? totalAmount, double? platformFee, double? providerPayout, String? matchReasoning, CancelledBy? cancelledBy, DateTime? paidAt, DateTime? initializedAt, DateTime? completedAt, DateTime? cancelledAt, DateTime? disputedAt, DateTime? createdAt, DateTime? updatedAt, User? provider, User? customer
});


$LocationCopyWith<$Res>? get location;$UserCopyWith<$Res>? get provider;$UserCopyWith<$Res>? get customer;

}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? customerId = freezed,Object? providerId = freezed,Object? categoryId = freezed,Object? status = freezed,Object? subCategoryName = freezed,Object? serviceDetails = freezed,Object? customerNotes = freezed,Object? scheduledAt = freezed,Object? estimatedDuration = freezed,Object? location = freezed,Object? totalAmount = freezed,Object? platformFee = freezed,Object? providerPayout = freezed,Object? matchReasoning = freezed,Object? cancelledBy = freezed,Object? paidAt = freezed,Object? initializedAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? disputedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? provider = freezed,Object? customer = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,providerId: freezed == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus?,subCategoryName: freezed == subCategoryName ? _self.subCategoryName : subCategoryName // ignore: cast_nullable_to_non_nullable
as String?,serviceDetails: freezed == serviceDetails ? _self.serviceDetails : serviceDetails // ignore: cast_nullable_to_non_nullable
as String?,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double?,platformFee: freezed == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double?,providerPayout: freezed == providerPayout ? _self.providerPayout : providerPayout // ignore: cast_nullable_to_non_nullable
as double?,matchReasoning: freezed == matchReasoning ? _self.matchReasoning : matchReasoning // ignore: cast_nullable_to_non_nullable
as String?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as CancelledBy?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,initializedAt: freezed == initializedAt ? _self.initializedAt : initializedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disputedAt: freezed == disputedAt ? _self.disputedAt : disputedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as User?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as User?,
  ));
}
/// Create a copy of Booking
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
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? customerId,  String? providerId,  String? categoryId,  BookingStatus? status,  String? subCategoryName,  String? serviceDetails,  String? customerNotes,  DateTime? scheduledAt,  int? estimatedDuration,  Location? location,  double? totalAmount,  double? platformFee,  double? providerPayout,  String? matchReasoning,  CancelledBy? cancelledBy,  DateTime? paidAt,  DateTime? initializedAt,  DateTime? completedAt,  DateTime? cancelledAt,  DateTime? disputedAt,  DateTime? createdAt,  DateTime? updatedAt,  User? provider,  User? customer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.customerId,_that.providerId,_that.categoryId,_that.status,_that.subCategoryName,_that.serviceDetails,_that.customerNotes,_that.scheduledAt,_that.estimatedDuration,_that.location,_that.totalAmount,_that.platformFee,_that.providerPayout,_that.matchReasoning,_that.cancelledBy,_that.paidAt,_that.initializedAt,_that.completedAt,_that.cancelledAt,_that.disputedAt,_that.createdAt,_that.updatedAt,_that.provider,_that.customer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? customerId,  String? providerId,  String? categoryId,  BookingStatus? status,  String? subCategoryName,  String? serviceDetails,  String? customerNotes,  DateTime? scheduledAt,  int? estimatedDuration,  Location? location,  double? totalAmount,  double? platformFee,  double? providerPayout,  String? matchReasoning,  CancelledBy? cancelledBy,  DateTime? paidAt,  DateTime? initializedAt,  DateTime? completedAt,  DateTime? cancelledAt,  DateTime? disputedAt,  DateTime? createdAt,  DateTime? updatedAt,  User? provider,  User? customer)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.customerId,_that.providerId,_that.categoryId,_that.status,_that.subCategoryName,_that.serviceDetails,_that.customerNotes,_that.scheduledAt,_that.estimatedDuration,_that.location,_that.totalAmount,_that.platformFee,_that.providerPayout,_that.matchReasoning,_that.cancelledBy,_that.paidAt,_that.initializedAt,_that.completedAt,_that.cancelledAt,_that.disputedAt,_that.createdAt,_that.updatedAt,_that.provider,_that.customer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? customerId,  String? providerId,  String? categoryId,  BookingStatus? status,  String? subCategoryName,  String? serviceDetails,  String? customerNotes,  DateTime? scheduledAt,  int? estimatedDuration,  Location? location,  double? totalAmount,  double? platformFee,  double? providerPayout,  String? matchReasoning,  CancelledBy? cancelledBy,  DateTime? paidAt,  DateTime? initializedAt,  DateTime? completedAt,  DateTime? cancelledAt,  DateTime? disputedAt,  DateTime? createdAt,  DateTime? updatedAt,  User? provider,  User? customer)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.customerId,_that.providerId,_that.categoryId,_that.status,_that.subCategoryName,_that.serviceDetails,_that.customerNotes,_that.scheduledAt,_that.estimatedDuration,_that.location,_that.totalAmount,_that.platformFee,_that.providerPayout,_that.matchReasoning,_that.cancelledBy,_that.paidAt,_that.initializedAt,_that.completedAt,_that.cancelledAt,_that.disputedAt,_that.createdAt,_that.updatedAt,_that.provider,_that.customer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({this.id, this.customerId, this.providerId, this.categoryId, this.status, this.subCategoryName, this.serviceDetails, this.customerNotes, this.scheduledAt, this.estimatedDuration, this.location, this.totalAmount, this.platformFee, this.providerPayout, this.matchReasoning, this.cancelledBy, this.paidAt, this.initializedAt, this.completedAt, this.cancelledAt, this.disputedAt, this.createdAt, this.updatedAt, this.provider, this.customer});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String? id;
@override final  String? customerId;
@override final  String? providerId;
@override final  String? categoryId;
@override final  BookingStatus? status;
@override final  String? subCategoryName;
@override final  String? serviceDetails;
@override final  String? customerNotes;
@override final  DateTime? scheduledAt;
@override final  int? estimatedDuration;
@override final  Location? location;
@override final  double? totalAmount;
@override final  double? platformFee;
@override final  double? providerPayout;
@override final  String? matchReasoning;
@override final  CancelledBy? cancelledBy;
@override final  DateTime? paidAt;
@override final  DateTime? initializedAt;
@override final  DateTime? completedAt;
@override final  DateTime? cancelledAt;
@override final  DateTime? disputedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  User? provider;
@override final  User? customer;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.status, status) || other.status == status)&&(identical(other.subCategoryName, subCategoryName) || other.subCategoryName == subCategoryName)&&(identical(other.serviceDetails, serviceDetails) || other.serviceDetails == serviceDetails)&&(identical(other.customerNotes, customerNotes) || other.customerNotes == customerNotes)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&(identical(other.location, location) || other.location == location)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.providerPayout, providerPayout) || other.providerPayout == providerPayout)&&(identical(other.matchReasoning, matchReasoning) || other.matchReasoning == matchReasoning)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.initializedAt, initializedAt) || other.initializedAt == initializedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.disputedAt, disputedAt) || other.disputedAt == disputedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.customer, customer) || other.customer == customer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,customerId,providerId,categoryId,status,subCategoryName,serviceDetails,customerNotes,scheduledAt,estimatedDuration,location,totalAmount,platformFee,providerPayout,matchReasoning,cancelledBy,paidAt,initializedAt,completedAt,cancelledAt,disputedAt,createdAt,updatedAt,provider,customer]);

@override
String toString() {
  return 'Booking(id: $id, customerId: $customerId, providerId: $providerId, categoryId: $categoryId, status: $status, subCategoryName: $subCategoryName, serviceDetails: $serviceDetails, customerNotes: $customerNotes, scheduledAt: $scheduledAt, estimatedDuration: $estimatedDuration, location: $location, totalAmount: $totalAmount, platformFee: $platformFee, providerPayout: $providerPayout, matchReasoning: $matchReasoning, cancelledBy: $cancelledBy, paidAt: $paidAt, initializedAt: $initializedAt, completedAt: $completedAt, cancelledAt: $cancelledAt, disputedAt: $disputedAt, createdAt: $createdAt, updatedAt: $updatedAt, provider: $provider, customer: $customer)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? customerId, String? providerId, String? categoryId, BookingStatus? status, String? subCategoryName, String? serviceDetails, String? customerNotes, DateTime? scheduledAt, int? estimatedDuration, Location? location, double? totalAmount, double? platformFee, double? providerPayout, String? matchReasoning, CancelledBy? cancelledBy, DateTime? paidAt, DateTime? initializedAt, DateTime? completedAt, DateTime? cancelledAt, DateTime? disputedAt, DateTime? createdAt, DateTime? updatedAt, User? provider, User? customer
});


@override $LocationCopyWith<$Res>? get location;@override $UserCopyWith<$Res>? get provider;@override $UserCopyWith<$Res>? get customer;

}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? customerId = freezed,Object? providerId = freezed,Object? categoryId = freezed,Object? status = freezed,Object? subCategoryName = freezed,Object? serviceDetails = freezed,Object? customerNotes = freezed,Object? scheduledAt = freezed,Object? estimatedDuration = freezed,Object? location = freezed,Object? totalAmount = freezed,Object? platformFee = freezed,Object? providerPayout = freezed,Object? matchReasoning = freezed,Object? cancelledBy = freezed,Object? paidAt = freezed,Object? initializedAt = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,Object? disputedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? provider = freezed,Object? customer = freezed,}) {
  return _then(_Booking(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,providerId: freezed == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus?,subCategoryName: freezed == subCategoryName ? _self.subCategoryName : subCategoryName // ignore: cast_nullable_to_non_nullable
as String?,serviceDetails: freezed == serviceDetails ? _self.serviceDetails : serviceDetails // ignore: cast_nullable_to_non_nullable
as String?,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as int?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double?,platformFee: freezed == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double?,providerPayout: freezed == providerPayout ? _self.providerPayout : providerPayout // ignore: cast_nullable_to_non_nullable
as double?,matchReasoning: freezed == matchReasoning ? _self.matchReasoning : matchReasoning // ignore: cast_nullable_to_non_nullable
as String?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as CancelledBy?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,initializedAt: freezed == initializedAt ? _self.initializedAt : initializedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disputedAt: freezed == disputedAt ? _self.disputedAt : disputedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as User?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as User?,
  ));
}

/// Create a copy of Booking
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
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}

// dart format on
