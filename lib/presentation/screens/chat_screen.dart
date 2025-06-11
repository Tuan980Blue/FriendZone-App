import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../widgets/chat_item_widget.dart';
import '../theme/app_page_transitions.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../di/injection_container.dart';
import 'dart:convert';
import 'chat_direct_messages_screen.dart';
import 'chat_new_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  String? currentUserId;
  User? currentUser;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'unread', 'online'

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _titleAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _searchAnimation;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // FAB Animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    // Search Animation
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _searchAnimationController, curve: Curves.easeInOut),
    );

    // Title Animation
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _titleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _titleAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    _titleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Get GetCurrentUserUseCase from dependency injection
      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();

      final user = await getCurrentUserUseCase();

      setState(() {
        currentUser = user;
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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
        _searchAnimationController.reverse();
        _titleAnimationController.reverse();
      } else {
        _searchFocusNode.requestFocus();
        _searchAnimationController.forward();
        _titleAnimationController.forward();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<Chat> _filterChats(List<Chat> chats) {
    List<Chat> filteredChats = chats;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredChats = filteredChats.where((chat) {
        final otherUser =
            chat.receiverId == currentUserId ? chat.sender : chat.receiver;
        return otherUser.fullName.toLowerCase().contains(_searchQuery) ||
            otherUser.username.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filteredChats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: currentUserId == null
          ? _buildLoadingState()
          : Column(
              children: [
                // User info header with enhanced design
                if (currentUser != null) _buildUserHeader(),
                // Chat list
                Expanded(
                  child: BlocConsumer<ChatBloc, ChatState>(
                    listener: (context, state) {
                      // Handle state changes if needed
                    },
                    builder: (context, state) {
                      if (state is ChatInitial) {
                        context.read<ChatBloc>().add(LoadRecentChats());
                        return _buildLoadingState();
                      } else if (state is ChatLoading) {
                        return _buildLoadingState();
                      } else if (state is ChatLoaded) {
                        final filteredChats = _filterChats(state.chats);
                        return _buildChatList(filteredChats);
                      } else if (state is ChatError) {
                        return _buildErrorWidget(state.message);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải thông tin người dùng...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearching
            ? Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm chat...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      isDense: true,
                    ),
                  ),
                ),
              )
            : const Text(
                'Chat',
                key: ValueKey('title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.pinkAccent,
                ),
              ),
      ),
      leading: _isSearching
          ? IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black87,
                size: 24,
              ),
              onPressed: _toggleSearch,
            )
          : null,
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: _toggleSearch,
          ),
        if (!_isSearching)
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.black87,
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).push(
                AppPageTransitions.slideUp(
                  const NewMessageScreen(),
                ),
              );
            },
          ),
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.black87,
            size: 24,
          ),
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          onSelected: (value) {
            switch (value) {
              case 'mark_all_read':
                // TODO: Implement mark all as read
                break;
              case 'clear_all':
                // TODO: Implement clear all chats
                break;
              case 'settings':
                // TODO: Navigate to chat settings
                break;
            }
          },
          itemBuilder: (context) => [
            _buildPopupMenuItem(
              'mark_all_read',
              Icons.mark_email_read,
              'Đánh dấu tất cả đã đọc',
            ),
            _buildPopupMenuItem(
              'clear_all',
              Icons.clear_all,
              'Xóa tất cả chat',
            ),
            _buildPopupMenuItem(
              'settings',
              Icons.settings,
              'Cài đặt chat',
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.black87,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade100.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: currentUser!.avatar != null
                      ? NetworkImage(currentUser!.avatar!)
                      : null,
                  backgroundColor: Colors.blue.shade100,
                  child: currentUser!.avatar == null
                      ? Icon(Icons.person,
                          size: 28, color: Colors.blue.shade600)
                      : null,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser!.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${currentUser!.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade600, size: 20),
              onPressed: () {
                // TODO: Navigate to edit profile
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<Chat> chats) {
    if (chats.isEmpty) {
      return _buildEmptyState();
    }

    if (currentUserId == null) {
      return _buildLoadingState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatBloc>().add(RefreshChats());
      },
      color: Colors.blue.shade400,
      backgroundColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: Colors.grey.shade100,
            ),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatItemWidget(
                chat: chat,
                currentUserId: currentUserId!,
                onTap: () {
                  _navigateToChatDetail(chat);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.chat_bubble_outline,
              size: 80,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _searchQuery.isNotEmpty
                ? 'Không tìm thấy kết quả'
                : 'Chưa có tin nhắn nào',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Bắt đầu trò chuyện với bạn bè',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          if (_searchQuery.isEmpty) ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade300.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to new message screen
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Bắt đầu trò chuyện',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to find friends screen
              },
              icon: Icon(Icons.people, color: Colors.blue.shade600, size: 20),
              label: Text(
                'Tìm bạn bè',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600,
                ),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade50,
                  Colors.orange.shade50,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade100.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade300.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ChatBloc>().add(LoadRecentChats());
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Thử lại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blueAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              AppPageTransitions.slideUp(
                const NewMessageScreen(),
              ),
            );
          },
          backgroundColor: Colors.pink[400],
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add, size: 34),
        ),
      ),
    );
  }

  void _navigateToChatDetail(Chat chat) {
    // Navigate to direct chat messages screen with professional chat transition
    Navigator.of(context).push(
      AppPageTransitions.chatTransition(
        DirectChatMessagesScreen(
          userId: chat.receiverId == currentUserId
              ? chat.senderId
              : chat.receiverId,
          userName: chat.receiverId == currentUserId
              ? chat.sender.fullName
              : chat.receiver.fullName,
          userAvatar: chat.receiverId == currentUserId
              ? chat.sender.avatar
              : chat.receiver.avatar,
        ),
      ),
    );
  }
}
