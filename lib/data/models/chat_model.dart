import '../../domain/entities/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required super.id,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    required super.senderId,
    required super.receiverId,
    super.chatRoomId,
    required super.sender,
    required super.receiver,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      chatRoomId: json['chatRoomId']?.toString(),
      sender: ChatUser.fromJson(json['sender'] ?? {}),
      receiver: ChatUser.fromJson(json['receiver'] ?? {}),
    );
  }

  factory ChatModel.fromEntity(Chat chat) {
    return ChatModel(
      id: chat.id,
      content: chat.content,
      createdAt: chat.createdAt,
      updatedAt: chat.updatedAt,
      senderId: chat.senderId,
      receiverId: chat.receiverId,
      chatRoomId: chat.chatRoomId,
      sender: chat.sender,
      receiver: chat.receiver,
    );
  }
} 