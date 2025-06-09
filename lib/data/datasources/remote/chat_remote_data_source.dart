import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../models/chat_model.dart';
import '../../models/direct_chat_messages_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatModel>> getRecentChats();
  Future<DirectChatMessagesModel> getDirectChatMessages(String userId, {int page = 1, int limit = 50});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ChatModel>> getRecentChats() async {
    try {
      final response = await _apiClient.get(ApiConstants.recentChatsEndpoint);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> chatsJson = data['data'];
          
          final List<ChatModel> chats = chatsJson
              .map((chatJson) => ChatModel.fromJson(chatJson))
              .toList();
          
          return chats;
        } else {
          throw ServerException('Failed to load chats: Invalid response format');
        }
      } else {
        throw ServerException('Failed to load chats: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error occurred: $e');
    }
  }

  @override
  Future<DirectChatMessagesModel> getDirectChatMessages(String userId, {int page = 1, int limit = 50}) async {
    try {
      final endpoint = '${ApiConstants.directChatMessagesEndpoint}/$userId?page=$page&limit=$limit';
      final response = await _apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final DirectChatMessagesModel messages = DirectChatMessagesModel.fromJson(data['data']);
          return messages;
        } else {
          throw ServerException('Failed to load direct chat messages: Invalid response format');
        }
      } else {
        throw ServerException('Failed to load direct chat messages: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error occurred: $e');
    }
  }
} 