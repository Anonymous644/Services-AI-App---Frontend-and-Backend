// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookingsController)
final bookingsControllerProvider = BookingsControllerProvider._();

final class BookingsControllerProvider
    extends $AsyncNotifierProvider<BookingsController, List<Booking>> {
  BookingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingsControllerHash();

  @$internal
  @override
  BookingsController create() => BookingsController();
}

String _$bookingsControllerHash() =>
    r'a872e00795b936b8be9d3eafa30f5c7fbc78283d';

abstract class _$BookingsController extends $AsyncNotifier<List<Booking>> {
  FutureOr<List<Booking>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Booking>>, List<Booking>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Booking>>, List<Booking>>,
              AsyncValue<List<Booking>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
