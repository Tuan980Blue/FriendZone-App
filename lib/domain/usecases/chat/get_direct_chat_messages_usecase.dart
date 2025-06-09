import '../../repositories/chat_repository.dart';

class GetDirectChatMessagesUseCase {
  final ChatRepository _chatRepository;

  GetDirectChatMessagesUseCase(this._chatRepository);

  Future<Map<String, dynamic>> call(String userId, {int page = 1, int limit = 50}) async {
    try {
      print('🎯 [GetDirectChatMessagesUseCase] Getting direct chat messages for user: $userId, page: $page, limit: $limit');
      final result = await _chatRepository.getDirectChatMessages(userId, page: page, limit: limit);
      print('🎯 [GetDirectChatMessagesUseCase] Successfully retrieved direct chat messages');
      return result;
    } catch (e) {
      print('❌ [GetDirectChatMessagesUseCase] Error: $e');
      rethrow;
    }
  }
} 