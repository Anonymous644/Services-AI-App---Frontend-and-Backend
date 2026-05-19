import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
abstract class GeoPoint with _$GeoPoint {
  const factory GeoPoint({
    @Default('Point') String? type,
    List<double>? coordinates,
  }) = _GeoPoint;

  factory GeoPoint.fromJson(Map<String, dynamic> json) => _$GeoPointFromJson(json);
}

@freezed
abstract class Location with _$Location {
  const factory Location({
    String? address,
    String? city,
    String? state,
    @Default('PK') String? country,
    GeoPoint? geo,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
}
