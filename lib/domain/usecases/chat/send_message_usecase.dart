
import '../../../data/models/chat_model.dart';
import '../../../services/chat_service.dart';
import '../base_usecase.dart';

class SendMessageUseCase implements UseCase<ChatModel?, SendMessageParams> {
  final ChatService _chatService;

  SendMessageUseCase(this._chatService);

  @override
  Future<ChatModel?> call(SendMessageParams params) async {
    return await _chatService.sendMessage(
      params.receiverId,
      params.content,
      params.currentUserId, // truyền currentUserId xuống
      chatRoomId: params.chatRoomId,
    );
  }
}

class SendMessageParams {
  final String receiverId;
  final String content;
  final String currentUserId;
  final String? chatRoomId;

  SendMessageParams({
    required this.receiverId,
    required this.content,
    required this.currentUserId,
    this.chatRoomId,
  });
} 