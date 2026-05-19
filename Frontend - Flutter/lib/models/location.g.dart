// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) => _GeoPoint(
  type: json['type'] as String? ?? 'Point',
  coordinates: (json['coordinates'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$GeoPointToJson(_GeoPoint instance) => <String, dynamic>{
  'type': instance.type,
  'coordinates': instance.coordinates,
};

_Location _$LocationFromJson(Map<String, dynamic> json) => _Location(
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String? ?? 'PK',
  geo: json['geo'] == null
      ? null
      : GeoPoint.fromJson(json['geo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LocationToJson(_Location instance) => <String, dynamic>{
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
  'geo': instance.geo,
};
