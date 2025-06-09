import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../di/injection_container.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:convert';

class DirectChatMessagesScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const DirectChatMessagesScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<DirectChatMessagesScreen> createState() => _DirectChatMessagesScreenState();
}

class _DirectChatMessagesScreenState extends State<DirectChatMessagesScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Get GetCurrentUserUseCase from dependency injection
      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
      
      final user = await getCurrentUserUseCase();
      
      setState(() {
        currentUserId = user.id;
      });
    } catch (e) {
      // Fallback to SharedPreferences if use case fails
      await _loadCurrentUserIdFromPrefs();
    }
  }

  Future<void> _loadCurrentUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        try {
          final Map<String, dynamic> userJson = json.decode(userData);
          final userId = userJson['id']?.toString();
          if (userId != null && userId.isNotEmpty) {
            setState(() {
              currentUserId = userId;
            });
          }
        } catch (e) {
          // Handle JSON parsing error
        }
      }
    } catch (e) {
      // Handle SharedPreferences error
    }
  }

  void _loadMessages() {
    context.read<ChatBloc>().add(LoadDirectChatMessages(
      userId: widget.userId,
      page: 1,
      limit: 50,
    ));
  }

  void _loadMoreMessages() {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      context.read<ChatBloc>().add(LoadMoreDirectChatMessages(
        userId: widget.userId,
        page: _currentPage + 1,
        limit: 50,
      ));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is DirectChatMessagesLoaded) {
            setState(() {
              _currentPage = state.page;
              _isLoadingMore = false;
            });
          }
        },
        builder: (context, state) {
          if (state is DirectChatMessagesLoading && _currentPage == 1) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is DirectChatMessagesLoaded) {
            return _buildMessagesList(state);
          } else if (state is DirectChatMessagesError) {
            return _buildErrorWidget(state.message);
          } else {
            return const Center(
              child: Text('Không có tin nhắn nào'),
            );
          }
        },
      ),
    );
  }

  Widget _buildMessagesList(DirectChatMessagesLoaded state) {
    if (state.messages.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Pagination info
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Trang ${state.page}/${state.totalPages} - ${state.messages.length}/${state.total} tin nhắn',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true, // Show newest messages at bottom
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.messages.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final message = state.messages[state.messages.length - 1 - index];
              return _buildMessageItem(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(Chat message) {
    final isCurrentUser = message.senderId == currentUserId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.sender.avatar != null
                  ? NetworkImage(message.sender.avatar!)
                  : null,
              child: message.sender.avatar == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser) ...[
                    Text(
                      message.sender.fullName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCurrentUser ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    timeago.format(message.createdAt, locale: 'vi'),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: message.sender.avatar != null
                  ? NetworkImage(message.sender.avatar!)
                  : null,
              child: message.sender.avatar == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu trò chuyện với ${widget.userName}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Thử lại',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 