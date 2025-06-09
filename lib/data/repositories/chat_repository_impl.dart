import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Chat>> getRecentChats() async {
    try {
      final chats = await _remoteDataSource.getRecentChats();
      return chats;
    } catch (e) {
      print('❌ [ChatRepository] Error in repository: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDirectChatMessages(String userId, {int page = 1, int limit = 50}) async {
    try {
      final messagesData = await _remoteDataSource.getDirectChatMessages(userId, page: page, limit: limit);
      return {
        'messages': messagesData.messages,
        'total': messagesData.total,
        'page': messagesData.page,
        'limit': messagesData.limit,
        'totalPages': messagesData.totalPages,
      };
    } catch (e) {
      print('❌ [ChatRepository] Error getting direct chat messages: $e');
      rethrow;
    }
  }
} 