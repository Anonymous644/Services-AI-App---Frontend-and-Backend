import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum ChatMessageRole {
  @JsonValue('USER')
  user,
  @JsonValue('ASSISTANT')
  assistant,
  @JsonValue('SYSTEM')
  system,
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    String? id,
    String? chatId,
    ChatMessageRole? role,
    String? content,
    String? actions,
    String? toolCalls,
    String? toolResults,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
