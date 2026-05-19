import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:services_ai_app/global_constant.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../storage/secure_storage.dart';

part 'socket_client.g.dart';

class SocketClient {
  io.Socket? _socket;
  final SecureStorage _secureStorage;

  SocketClient(this._secureStorage);

  Future<void> connect() async {
    // Prevent creating a new socket if already connected or connecting.
    if (_socket != null && (_socket!.connected)) return;

    final token = await _secureStorage.getToken();
    if (token == null) return;

    _socket = io.io(
      '${GlobalConstant.backendUrl}/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      debugPrint('Socket connected');
    });

    _socket?.onConnectError((err) {
      debugPrint('Socket connection error: $err');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  io.Socket? get socket => _socket;
}

@riverpod
SocketClient socketClient(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SocketClient(secureStorage);
}
