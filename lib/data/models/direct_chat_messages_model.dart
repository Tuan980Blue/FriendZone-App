import '../../domain/entities/chat.dart';
import 'chat_model.dart';

class DirectChatMessagesModel {
  final List<Chat> messages;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const DirectChatMessagesModel({
    required this.messages,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory DirectChatMessagesModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> messagesJson = json['messages'] ?? [];
    final List<Chat> messages = messagesJson
        .map((messageJson) => ChatModel.fromJson(messageJson))
        .toList();

    return DirectChatMessagesModel(
      messages: messages,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 50,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
} 