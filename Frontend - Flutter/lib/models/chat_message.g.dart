// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String?,
  chatId: json['chatId'] as String?,
  role: $enumDecodeNullable(_$ChatMessageRoleEnumMap, json['role']),
  content: json['content'] as String?,
  actions: _actionsFromJson(json['actions']),
  toolCalls: _actionsFromJson(json['toolCalls']),
  toolResults: _actionsFromJson(json['toolResults']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'role': _$ChatMessageRoleEnumMap[instance.role],
      'content': instance.content,
      'actions': instance.actions,
      'toolCalls': instance.toolCalls,
      'toolResults': instance.toolResults,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ChatMessageRoleEnumMap = {
  ChatMessageRole.user: 'USER',
  ChatMessageRole.assistant: 'ASSISTANT',
  ChatMessageRole.system: 'SYSTEM',
};

/// Converts the `actions` field which may arrive as a JSON array (List)
/// or already-encoded JSON string. Stores as a JSON string for consistent access.
String? _actionsFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return jsonEncode(value);
}
