import '../../repositories/chat_repository.dart';
import '../../entities/chat.dart';

class GetRecentChatsUseCase {
  final ChatRepository _repository;

  GetRecentChatsUseCase(this._repository);

  Future<List<Chat>> call() async {
    print('🎯 [GetRecentChatsUseCase] UseCase called');
    try {
      final chats = await _repository.getRecentChats();
      print('🎯 [GetRecentChatsUseCase] Repository returned ${chats.length} chats');
      return chats;
    } catch (e) {
      print('❌ [GetRecentChatsUseCase] Error in use case: $e');
      rethrow;
    }
  }
} 