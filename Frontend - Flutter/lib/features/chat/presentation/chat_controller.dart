import 'dart:async';
import 'dart:collection';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/chat_message.dart';
import '../data/chat_repository.dart';

part 'chat_controller.g.dart';

// Sentinel used to distinguish "not provided" from explicit null in copyWith.
const _unset = Object();

class ChatState {
  final List<ChatMessage> messages;
  final bool isAiThinking;
  final String? streamingContent;
  final String? thinkingMessage;

  ChatState({
    required this.messages,
    this.isAiThinking = false,
    this.streamingContent,
    this.thinkingMessage,
  });

  // Using Object? + sentinel so callers can explicitly pass null to CLEAR a field.
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isAiThinking,
    Object? streamingContent = _unset,
    Object? thinkingMessage = _unset,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      streamingContent: identical(streamingContent, _unset)
          ? this.streamingContent
          : streamingContent as String?,
      thinkingMessage: identical(thinkingMessage, _unset)
          ? this.thinkingMessage
          : thinkingMessage as String?,
    );
  }
}

@riverpod
class ChatController extends _$ChatController {
  StreamSubscription? _historySub;
  StreamSubscription? _completeSub;
  StreamSubscription? _thinkingSub;
  StreamSubscription? _streamSub;
  StreamSubscription? _chatClearedSub;
  late ChatRepository _repo;

  // Word-by-word streaming throttle
  final Queue<String> _wordQueue = Queue();
  Timer? _wordTimer;
  int _idleTicks = 0;
  String _displayedStreamContent = '';
  ChatMessage? _pendingCompleteMessage;

  @override
  ChatState build() {
    // ref.watch keeps chatRepositoryProvider (and its SocketClient) alive
    // for the entire lifetime of this controller.
    _repo = ref.watch(chatRepositoryProvider);
    _initListeners();
    ref.onDispose(() {
      _historySub?.cancel();
      _completeSub?.cancel();
      _thinkingSub?.cancel();
      _streamSub?.cancel();
      _chatClearedSub?.cancel();
      _wordTimer?.cancel();
      _repo.disconnect();
    });
    return ChatState(messages: []);
  }

  void connect() {
    _repo.connectAndListen();
  }

  void _initListeners() {
    _historySub = _repo.chatHistoryStream.listen((data) {
      final messages = data.map((e) => ChatMessage.fromJson(e)).toList();
      state = state.copyWith(messages: messages);
    });

    _completeSub = _repo.messageCompleteStream.listen((data) {
      final message = ChatMessage.fromJson(data);
      // Skip the server echo of the user's own message — already added optimistically.
      if (message.role == ChatMessageRole.user) return;

      // If words are still being drained from the queue, defer finalization
      // until the queue is empty so no streamed words are swallowed.
      if (_wordQueue.isNotEmpty || _wordTimer?.isActive == true) {
        _pendingCompleteMessage = message;
      } else {
        _applyCompleteMessage(message);
      }
    });

    _chatClearedSub = _repo.chatClearedStream.listen((_) {
      _resetStreamState();
      state = ChatState(messages: []);
    });

    _thinkingSub = _repo.thinkingStream.listen((msg) {
      state = state.copyWith(isAiThinking: true, thinkingMessage: msg);
    });

    _streamSub = _repo.streamStream.listen((content) {
      // Tokenise the incoming chunk into words and queue them for
      // throttled reveal — preserving punctuation attached to words.
      final words = content
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      _wordQueue.addAll(words);
      _startWordTimer();
    });
  }

  // Drains one word from the queue every 90 ms so the user sees words
  // appear at a readable pace regardless of how fast the backend streams.
  void _startWordTimer() {
    if (_wordTimer?.isActive == true) return;
    _idleTicks = 0;
    _wordTimer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      if (_wordQueue.isNotEmpty) {
        _idleTicks = 0;
        final word = _wordQueue.removeFirst();
        _displayedStreamContent += _displayedStreamContent.isEmpty
            ? word
            : ' $word';
        state = state.copyWith(
          isAiThinking: true,
          streamingContent: _displayedStreamContent,
        );
      } else if (_pendingCompleteMessage != null) {
        // Queue fully drained and backend already finished — commit the message.
        _wordTimer?.cancel();
        _wordTimer = null;
        _applyCompleteMessage(_pendingCompleteMessage!);
        _pendingCompleteMessage = null;
      } else {
        // Nothing to display yet; auto-cancel after ~2 s to avoid zombie timers.
        if (++_idleTicks >= 22) {
          _wordTimer?.cancel();
          _wordTimer = null;
          _idleTicks = 0;
        }
      }
    });
  }

  void _applyCompleteMessage(ChatMessage message) {
    final newMessages = List<ChatMessage>.from(state.messages)..add(message);
    state = state.copyWith(
      messages: newMessages,
      isAiThinking: false,
      streamingContent: null,
      thinkingMessage: null,
    );
    _displayedStreamContent = '';
  }

  void _resetStreamState() {
    _wordQueue.clear();
    _wordTimer?.cancel();
    _wordTimer = null;
    _idleTicks = 0;
    _displayedStreamContent = '';
    _pendingCompleteMessage = null;
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty) return;
    _resetStreamState();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatMessageRole.user,
      content: content,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isAiThinking: true,
      streamingContent: null,
      thinkingMessage: null,
    );

    _repo.sendMessage(content);
  }

  void sendActionResponse(String actionType, Map<String, dynamic> data) {
    final content = _actionToUserMessage(actionType, data);
    if (content != null) {
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: ChatMessageRole.user,
        content: content,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, userMsg],
        isAiThinking: true,
        streamingContent: null,
        thinkingMessage: null,
      );
    }
    _repo.sendActionResponse(actionType, data);
  }

  String? _actionToUserMessage(String actionType, Map<String, dynamic> data) {
    switch (actionType) {
      case 'LOCATION_UPDATED':
        final loc = data['location'] as Map<String, dynamic>?;
        final address = loc?['address'] as String? ?? '';
        final city = loc?['city'] as String? ?? '';
        final parts = [address, city].where((e) => e.isNotEmpty).join(', ');
        return 'My location: $parts';
      case 'SELECT_PROVIDER':
        return "I'd like to select this provider for my booking.";
      case 'PAY':
        return 'Please proceed with the payment.';
      case 'CONFIRM_COMPLETION':
        final confirmed = data['confirmed'] as bool? ?? false;
        if (confirmed) return 'Yes, the job was completed successfully.';
        final reason = data['reason'] as String?;
        return (reason != null && reason.isNotEmpty)
            ? 'I want to dispute this — $reason'
            : 'I want to dispute this completion.';
      case 'SUBMIT_REVIEW':
        final rating = data['rating'] as int? ?? 0;
        final comment = data['comment'] as String?;
        final stars = List.filled(rating, '⭐').join();
        return (comment != null && comment.isNotEmpty)
            ? '$stars\n$comment'
            : stars;
      default:
        return null;
    }
  }

  void clearChat() {
    _repo.clearChat();
  }
}
