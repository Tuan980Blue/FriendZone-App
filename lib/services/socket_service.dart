// lib/services/socket_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../data/models/chat_model.dart';

class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Typing indicator debounce
  Timer? _typingDebounceTimer;
  static const Duration _typingDebounceDelay = Duration(milliseconds: 500);

  // Callbacks
  Function(ChatModel)? onMessageReceived;
  Function(String, bool)? onUserTyping;
  Function(String, String)? onUserStatusChanged;
  Function(bool)? onConnectionStatusChanged;
  Function(String)? onError;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;

    try {
      _isConnecting = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _handleError('No authentication token found');
        return;
      }

      _socket = IO.io('https://web-socket-friendzone.onrender.com', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'timeout': 20000,
        'reconnection': false, // We'll handle reconnection manually
        'forceNew': true, // Force new connection
        'upgrade': false, // Disable upgrade to avoid issues
      });

      _setupSocketListeners();
      _socket!.connect();

    } catch (e) {
      _handleError('Failed to initialize socket connection: $e');
    } finally {
      _isConnecting = false;
    }
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      print('Socket connected successfully');
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      onConnectionStatusChanged?.call(true);
    });

    _socket!.onConnectTimeout((_) {
      print('Socket connection timeout');
      _isConnected = false;
      _isConnecting = false;
      _handleError('Connection timeout');
      _scheduleReconnect();
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
      onConnectionStatusChanged?.call(false);
      _scheduleReconnect();
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
      _isConnected = false;
      _isConnecting = false;
      _handleError('Connection error: $error');
      _scheduleReconnect();
    });

    _socket!.onError((error) {
      print('Socket error: $error');
      _handleError('Socket error: $error');
    });

    _socket!.on('receive_message', (data) {
      try {
        final message = ChatModel.fromJson(data);
        onMessageReceived?.call(message);
      } catch (e) {
        _handleError('Failed to parse received message: $e');
      }
    });

    _socket!.on('user_typing', (data) {
      try {
        final userId = data['userId']?.toString() ?? '';
        final isTyping = data['isTyping'] == true;
        onUserTyping?.call(userId, isTyping);
      } catch (e) {
        _handleError('Failed to parse typing indicator: $e');
      }
    });

    _socket!.on('user_status_changed', (data) {
      try {
        final userId = data['userId']?.toString() ?? '';
        final status = data['status']?.toString() ?? '';
        onUserStatusChanged?.call(userId, status);
      } catch (e) {
        _handleError('Failed to parse user status change: $e');
      }
    });

    _socket!.on('message_sent_success', (data) {
      print('Message sent successfully: $data');
    });

    _socket!.on('message_sent_error', (data) {
      final error = data['error']?.toString() ?? 'Unknown error';
      _handleError('Failed to send message: $error');
    });

    _socket!.on('pong', (data) {
      print('Received pong from server');
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _handleError('Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      print('Attempting to reconnect... (${_reconnectAttempts}/$_maxReconnectAttempts)');
      connect();
    });
  }

  /// Reset reconnection attempts
  void resetReconnectionAttempts() {
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
  }

  void _handleError(String error) {
    print('SocketService Error: $error');
    onError?.call(error);
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _typingDebounceTimer?.cancel();
    _reconnectAttempts = 0;
    _isConnected = false;
    _isConnecting = false;
    
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    
    onConnectionStatusChanged?.call(false);
  }

  // Gửi tin nhắn real-time
  bool sendMessage(String messageId, String receiverId, String content, {String? chatRoomId}) {
    if (!_isConnected || _socket == null) {
      _handleError('Socket not connected. Cannot send message.');
      return false;
    }

    try {
      _socket!.emit('send_message', {
        'messageId': messageId,
        'receiverId': receiverId,
        'content': content,
        'chatRoomId': chatRoomId,
      });
      return true;
    } catch (e) {
      _handleError('Failed to send message via socket: $e');
      return false;
    }
  }

  // Gửi typing indicator
  bool sendTyping(String receiverId, bool isTyping) {
    if (!_isConnected || _socket == null) {
      return false;
    }

    // Cancel previous timer if exists
    _typingDebounceTimer?.cancel();

    if (isTyping) {
      // Send typing start immediately
      try {
        _socket!.emit('typing', {
          'receiverId': receiverId,
          'isTyping': true,
        });
        return true;
      } catch (e) {
        _handleError('Failed to send typing indicator: $e');
        return false;
      }
    } else {
      // Debounce typing stop
      _typingDebounceTimer = Timer(_typingDebounceDelay, () {
        if (_isConnected && _socket != null) {
          try {
            _socket!.emit('typing', {
              'receiverId': receiverId,
              'isTyping': false,
            });
          } catch (e) {
            _handleError('Failed to send typing stop indicator: $e');
          }
        }
      });
      return true;
    }
  }

  // Join chat room
  bool joinChatRoom(String chatRoomId) {
    if (!_isConnected || _socket == null) {
      return false;
    }

    try {
      _socket!.emit('join_room', {'chatRoomId': chatRoomId});
      return true;
    } catch (e) {
      _handleError('Failed to join chat room: $e');
      return false;
    }
  }

  // Leave chat room
  bool leaveChatRoom(String chatRoomId) {
    if (!_isConnected || _socket == null) {
      return false;
    }

    try {
      _socket!.emit('leave_room', {'chatRoomId': chatRoomId});
      return true;
    } catch (e) {
      _handleError('Failed to leave chat room: $e');
      return false;
    }
  }

  /// Force reconnect the socket
  Future<void> forceReconnect() async {
    print('Force reconnecting socket...');
    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  /// Get connection status
  bool get connectionStatus => _isConnected;

  /// Get reconnection attempts count
  int get reconnectionAttempts => _reconnectAttempts;

  /// Emit custom event
  bool emitEvent(String eventName, Map<String, dynamic> data) {
    if (!_isConnected || _socket == null) {
      _handleError('Socket not connected. Cannot emit event: $eventName');
      return false;
    }

    try {
      _socket!.emit(eventName, data);
      return true;
    } catch (e) {
      _handleError('Failed to emit event $eventName: $e');
      return false;
    }
  }

  /// Listen to custom event
  void onEvent(String eventName, Function(dynamic) callback) {
    if (_socket == null) {
      _handleError('Socket not initialized. Cannot listen to event: $eventName');
      return;
    }

    try {
      _socket!.on(eventName, callback);
    } catch (e) {
      _handleError('Failed to listen to event $eventName: $e');
    }
  }

  /// Remove event listener
  void offEvent(String eventName) {
    if (_socket == null) return;

    try {
      _socket!.off(eventName);
    } catch (e) {
      _handleError('Failed to remove event listener for $eventName: $e');
    }
  }

  /// Update authentication token and reconnect
  Future<void> updateToken(String newToken) async {
    print('Updating socket authentication token...');
    
    // Disconnect current connection
    disconnect();
    
    // Wait a bit before reconnecting with new token
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Connect with new token
    await connect();
  }

  /// Send ping to server
  bool sendPing() {
    if (!_isConnected || _socket == null) {
      return false;
    }

    try {
      _socket!.emit('ping');
      return true;
    } catch (e) {
      _handleError('Failed to send ping: $e');
      return false;
    }
  }

  /// Check connection health
  bool get isHealthy => _isConnected && _socket != null && _socket!.connected;

  /// Get socket ID
  String? get socketId => _socket?.id;
}