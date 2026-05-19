import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/socket_client.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final SocketClient _socketClient;

  final _chatHistoryController = StreamController<List<dynamic>>.broadcast();
  final _messageCompleteController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _thinkingController = StreamController<String>.broadcast();
  final _aiThinkingController = StreamController<String>.broadcast();
  final _streamController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _chatClearedController = StreamController<void>.broadcast();

  Stream<List<dynamic>> get chatHistoryStream => _chatHistoryController.stream;
  Stream<Map<String, dynamic>> get messageCompleteStream =>
      _messageCompleteController.stream;
  Stream<String> get thinkingStream => _thinkingController.stream;
  Stream<String> get aiThinkingStream => _aiThinkingController.stream;
  Stream<String> get streamStream => _streamController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<void> get chatClearedStream => _chatClearedController.stream;

  ChatRepository(this._socketClient);

  Future<void> connectAndListen() async {
    await _socketClient.connect();

    final socket = _socketClient.socket;
    if (socket == null) return;

    socket.off('chat_history');
    socket.off('message_complete');
    socket.off('thinking');
    socket.off('ai_thinking');
    socket.off('stream');
    socket.off('error');
    socket.off('chat_cleared');

    socket.on('chat_history', (data) {
      if (data != null) _chatHistoryController.add(data as List);
    });

    socket.on('message_complete', (data) {
      if (data != null)
        _messageCompleteController.add(Map<String, dynamic>.from(data));
    });

    socket.on('thinking', (data) {
      if (data != null)
        _thinkingController.add(data['message']?.toString() ?? '');
    });

    socket.on('ai_thinking', (data) {
      if (data != null)
        _aiThinkingController.add(data['content']?.toString() ?? '');
    });

    socket.on('stream', (data) {
      if (data != null)
        _streamController.add(data['content']?.toString() ?? '');
    });

    socket.on('error', (data) {
      if (data != null)
        _errorController.add(data['message']?.toString() ?? 'Unknown error');
    });

    socket.on('chat_cleared', (_) => _chatClearedController.add(null));
  }

  void sendMessage(String content) {
    _socketClient.socket?.emit('send_message', {'content': content});
  }

  void sendActionResponse(String actionType, Map<String, dynamic> data) {
    _socketClient.socket?.emit('action_response', {
      'actionType': actionType,
      'data': data,
    });
  }

  void clearChat() {
    _socketClient.socket?.emit('clear_chat');
  }

  void disconnect() {
    _socketClient.disconnect();
  }
}

@riverpod
ChatRepository chatRepository(Ref ref) {
  final socketClient = ref.watch(socketClientProvider);
  return ChatRepository(socketClient);
}
