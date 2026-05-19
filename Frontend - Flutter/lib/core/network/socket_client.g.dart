// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'socket_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socketClient)
final socketClientProvider = SocketClientProvider._();

final class SocketClientProvider
    extends $FunctionalProvider<SocketClient, SocketClient, SocketClient>
    with $Provider<SocketClient> {
  SocketClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socketClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socketClientHash();

  @$internal
  @override
  $ProviderElement<SocketClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SocketClient create(Ref ref) {
    return socketClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocketClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocketClient>(value),
    );
  }
}

String _$socketClientHash() => r'cb58a71f95dd17096d359211e8c46b6acac5b0b1';
