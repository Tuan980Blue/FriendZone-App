class Chat {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String senderId;
  final String receiverId;
  final String? chatRoomId;
  final ChatUser sender;
  final ChatUser receiver;

  const Chat({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.senderId,
    required this.receiverId,
    this.chatRoomId,
    required this.sender,
    required this.receiver,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'senderId': senderId,
      'receiverId': receiverId,
      'chatRoomId': chatRoomId,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
    };
  }
}

class ChatUser {
  final String id;
  final String username;
  final String? avatar;
  final String fullName;

  const ChatUser({
    required this.id,
    required this.username,
    this.avatar,
    required this.fullName,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      fullName: json['fullName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'fullName': fullName,
    };
  }
} 