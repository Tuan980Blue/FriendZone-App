import '../entities/chat.dart';

abstract class ChatRepository {
  Future<List<Chat>> getRecentChats();
  Future<Map<String, dynamic>> getDirectChatMessages(String userId, {int page = 1, int limit = 50});
} 