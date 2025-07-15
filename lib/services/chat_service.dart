import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/remote/chat_remote_data_source.dart';
import '../data/models/chat_model.dart';
import '../data/models/direct_chat_messages_model.dart';
import '../core/errors/exceptions.dart';
import '../domain/entities/chat.dart';
import '../data/models/chat_model.dart';
import 'socket_service.dart';

class ChatService {
  final SocketService _socketService;
  final ChatRemoteDataSource _chatRemoteDataSource;
  
  // Stream controllers for UI
  final StreamController<ChatModel> _messageStreamController = StreamController<ChatModel>.broadcast();
  final StreamController<String> _errorStreamController = StreamController<String>.broadcast();
  final StreamController<bool> _connectionStatusStreamController = StreamController<bool>.broadcast();
  final StreamController<Map<String, bool>> _typingStreamController = StreamController<Map<String, bool>>.broadcast();

  // Internal state
  final Map<String, bool> _typingUsers = {};
  bool _isInitialized = false;

  ChatService(this._socketService, this._chatRemoteDataSource) {
    _setupSocketCallbacks();
  }

  // Getters for streams
  Stream<ChatModel> get messageStream => _messageStreamController.stream;
  Stream<String> get errorStream => _errorStreamController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusStreamController.stream;
  Stream<Map<String, bool>> get typingStream => _typingStreamController.stream;

  // Getters for current state
  bool get isConnected => _socketService.isConnected;
  bool get isConnecting => _socketService.isConnecting;
  bool get connectionStatus => _socketService.connectionStatus;
  int get reconnectionAttempts => _socketService.reconnectionAttempts;
  Map<String, bool> get typingUsers => Map.unmodifiable(_typingUsers);

  void _setupSocketCallbacks() {
    _socketService.onMessageReceived = (message) {
      _messageStreamController.add(message);
    };

    _socketService.onUserTyping = (userId, isTyping) {
      if (isTyping) {
        _typingUsers[userId] = true;
      } else {
        _typingUsers.remove(userId);
      }
      _typingStreamController.add(Map.unmodifiable(_typingUsers));
    };

    _socketService.onUserStatusChanged = (userId, status) {
    };

    _socketService.onConnectionStatusChanged = (isConnected) {
      _connectionStatusStreamController.add(isConnected);
    };

    _socketService.onError = (error) {
      _errorStreamController.add(error);
    };
  }

  /// Initialize the chat service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _socketService.connect();
      _isInitialized = true;
    } catch (e) {
      _errorStreamController.add('Failed to initialize chat service: $e');
    }
  }

  /// Get recent chats
  Future<List<ChatModel>> getRecentChats() async {
    try {
      return await _chatRemoteDataSource.getRecentChats();
    } catch (e) {
      _errorStreamController.add('Failed to get recent chats: $e');
      rethrow;
    }
  }

  /// Get direct chat messages
  Future<DirectChatMessagesModel> getDirectChatMessages(String userId, {int page = 1, int limit = 50}) async {
    try {
      return await _chatRemoteDataSource.getDirectChatMessages(userId, page: page, limit: limit);
    } catch (e) {
      _errorStreamController.add('Failed to get chat messages: $e');
      rethrow;
    }
  }

  /// Send message with fallback mechanism
  Future<ChatModel?> sendMessage(String receiverId, String content, String currentUserId, {String? chatRoomId}) async {
    
    if (content.trim().isEmpty) {
      _errorStreamController.add('Message content cannot be empty');
      return null;
    }

    // Try socket first (real-time)
    if (_socketService.isConnected) {
      final tempMessageId = 'temp_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecondsSinceEpoch % 1000)}';
      final socketSuccess = _socketService.sendMessage(tempMessageId, receiverId, content, chatRoomId: chatRoomId);
      
      if (socketSuccess) {
        return await _createOptimisticMessage(tempMessageId, receiverId, content, currentUserId);
      } else {
        print('❌ [ChatService] Socket message failed, trying HTTP fallback');
      }
    } else {
      print('🎯 [ChatService] Socket not connected, trying HTTP fallback');
    }

    // Fallback to HTTP if socket fails or not connected
    try {
      final message = await _chatRemoteDataSource.sendMessage(receiverId, content);
      _messageStreamController.add(message); // Add to stream for UI consistency
      return message;
    } catch (e) {
      print('❌ [ChatService] HTTP fallback failed: $e');
      _errorStreamController.add('Failed to send message: $e');
      return null;
    }
  }

  /// Send typing indicator
  void sendTypingIndicator(String receiverId, bool isTyping) {
    if (_socketService.isConnected) {
      _socketService.sendTyping(receiverId, isTyping);
    }
  }

  /// Join a chat room
  void joinChatRoom(String chatRoomId) {
    if (_socketService.isConnected) {
      _socketService.joinChatRoom(chatRoomId);
    }
  }

  /// Leave a chat room
  void leaveChatRoom(String chatRoomId) {
    if (_socketService.isConnected) {
      _socketService.leaveChatRoom(chatRoomId);
    }
  }

  /// Get current user ID from SharedPreferences
  Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        final Map<String, dynamic> userJson = json.decode(userData);
        return userJson['id']?.toString();
      }
    } catch (e) {
      print('❌ [ChatService] Failed to get current user ID: $e');
    }
    return null;
  }

  /// Create optimistic message for immediate UI feedback
  Future<ChatModel> _createOptimisticMessage(String messageId, String receiverId, String content, String currentUserId) async {
    return ChatModel(
      id: messageId,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      senderId: currentUserId,
      receiverId: receiverId,
      sender: ChatUser(
        id: currentUserId,
        username: 'You',
        fullName: 'You',
      ),
      receiver: ChatUser(
        id: receiverId,
        username: 'User',
        fullName: 'User',
      ),
    );
  }

  /// Reconnect socket if disconnected
  Future<void> reconnect() async {
    if (!_socketService.isConnected && !_socketService.isConnecting) {
      await _socketService.connect();
    }
  }

  /// Force reconnect the socket
  Future<void> forceReconnect() async {
    await _socketService.forceReconnect();
  }

  /// Emit custom event
  bool emitEvent(String eventName, Map<String, dynamic> data) {
    return _socketService.emitEvent(eventName, data);
  }

  /// Listen to custom event
  void onEvent(String eventName, Function(dynamic) callback) {
    _socketService.onEvent(eventName, callback);
  }

  /// Remove event listener
  void offEvent(String eventName) {
    _socketService.offEvent(eventName);
  }

  /// Update authentication token
  Future<void> updateToken(String newToken) async {
    await _socketService.updateToken(newToken);
  }

  /// Send ping to server
  bool sendPing() {
    return _socketService.sendPing();
  }

  /// Check connection health
  bool get isHealthy => _socketService.isHealthy;

  /// Get socket ID
  String? get socketId => _socketService.socketId;

  /// Reset reconnection attempts
  void resetReconnectionAttempts() {
    _socketService.resetReconnectionAttempts();
  }

  /// Dispose resources
  void dispose() {
    _socketService.disconnect();
    _messageStreamController.close();
    _errorStreamController.close();
    _connectionStatusStreamController.close();
    _typingStreamController.close();
    _typingUsers.clear();
    _isInitialized = false;
  }
}

 