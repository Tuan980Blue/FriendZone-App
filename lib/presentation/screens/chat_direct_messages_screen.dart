import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/chat_model.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../theme/app_page_transitions.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../../domain/usecases/users/follow_user_usecase.dart';
import '../../domain/usecases/users/unfollow_user_usecase.dart';
import '../../di/injection_container.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:convert';
import 'dart:async';
import 'profile_screen.dart';
import '../../services/chat_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/location_message_widget.dart';

class DirectChatMessagesScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;

  const DirectChatMessagesScreen({
    Key? key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  }) : super(key: key);

  @override
  State<DirectChatMessagesScreen> createState() => _DirectChatMessagesScreenState();
}

class _DirectChatMessagesScreenState extends State<DirectChatMessagesScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _isSendingMessage = false;
  String? currentUserId;
  bool _isTyping = false;
  late AnimationController _typingAnimationController;
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonScaleAnimation;
  late ChatService _chatService;
  StreamSubscription<ChatModel>? _messageSubscription;
  StreamSubscription<String>? _errorSubscription;
  
  // Add message cache to avoid unnecessary reloads
  final List<Chat> _cachedMessages = [];
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadCurrentUser();
    _loadMessages();
    _scrollController.addListener(_onScroll);
    
    // Initialize animations
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _sendButtonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _sendButtonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to text changes for typing indicator
    _messageController.addListener(_onTextChanged);
  }

  Future<void> _loadCurrentUser() async {
    try {
      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
      final user = await getCurrentUserUseCase();
      setState(() {
        currentUserId = user.id;
      });
    } catch (e) {
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
        } catch (e) {}
      }
    } catch (e) {}
  }

  // --- Auto scroll to bottom after adding message ---
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addMessageToCache(Chat message) {
    final existingMessageIndex = _cachedMessages.indexWhere((m) =>
      m.id == message.id ||
      (m.id.startsWith('temp_') && m.content == message.content && m.senderId == message.senderId)
    );
    if (existingMessageIndex == -1) {
      setState(() {
        _cachedMessages.insert(0, message); // Thêm vào đầu danh sách
      });
      _scrollToBottom();

    } else {
      setState(() {
        _cachedMessages[existingMessageIndex] = message;
      });
      _scrollToBottom();

    }
  }

  // --- Sử dụng _addMessageToCache ở mọi nơi thêm message ---

  void _initializeServices() {
    _chatService = sl<ChatService>();
    _chatService.initialize();
    _setupTimeagoLocale();
    _messageSubscription = _chatService.messageStream.listen((message) {
      if (mounted && (message.senderId == widget.userId || message.receiverId == widget.userId)) {
        _addMessageToCache(message);
      }
    });
    _errorSubscription = _chatService.errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $error'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _setupTimeagoLocale() {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _typingAnimationController.dispose();
    _sendButtonAnimationController.dispose();
    
    // Cancel stream subscriptions
    _messageSubscription?.cancel();
    _errorSubscription?.cancel();
    
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
    }
    
    // Send typing indicator with debounce
    if (hasText) {
      _chatService.sendTypingIndicator(widget.userId, true);
    } else {
      // Stop typing indicator
      _chatService.sendTypingIndicator(widget.userId, false);
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

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSendingMessage) return;
    if (currentUserId == null) {
      return;
    }
    _sendButtonAnimationController.forward().then((_) {
      _sendButtonAnimationController.reverse();
    });
    setState(() {
      _isSendingMessage = true;
    });
    context.read<ChatBloc>().add(SendDirectMessage(
      receiverId: widget.userId,
      content: message,
      currentUserId: currentUserId!,
    ));
    _messageController.clear();
    _messageFocusNode.unfocus();
  }

  // Thêm hàm lấy vị trí và gửi message vị trí
  Future<void> _shareLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng bật dịch vụ vị trí trên thiết bị.')),
        );
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn cần cấp quyền truy cập vị trí.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối vĩnh viễn.')),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final content = 'LOCATION:${position.latitude},${position.longitude}';
      if (currentUserId == null) return;
      // Thêm dialog xác nhận trước khi gửi vị trí
      final shouldSend = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Xác nhận gửi vị trí'),
            content: const Text('Bạn có chắc chắn muốn chia sẻ vị trí hiện tại của mình cho người này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Gửi'),
              ),
            ],
          );
        },
      );
      if (shouldSend != true) return;
      context.read<ChatBloc>().add(SendDirectMessage(
        receiverId: widget.userId,
        content: content,
        currentUserId: currentUserId!,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy vị trí: $e')),
      );
    }
  }

  void _popWithAnimation() {
    // Custom pop with smooth animation
    Navigator.of(context).pop();
  }

  void _navigateToProfile(String userId, String userName) {
    Navigator.of(context).push(
      AppPageTransitions.slideRight(
        ProfileScreen(
          getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
          logoutUseCase: sl<LogoutUseCase>(),
          getUserByIdUseCase: sl<GetUserByIdUseCase>(),
          updateProfileUseCase: sl<UpdateProfileUseCase>(),
          followUserUseCase: sl<FollowUserUseCase>(),
          unfollowUserUseCase: sl<UnfollowUserUseCase>(),
          userId: userId,
        ),
      ),
    );
  }

  // Thêm hàm mở Google Maps trên trình duyệt ngoài
  Future<void> openMapInBrowser(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('❌ Không thể mở trình duyệt với Google Maps URL.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        _popWithAnimation();
        return false; // Prevent default pop behavior
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is DirectChatMessagesLoaded) {
                    setState(() {
                      _currentPage = state.page;
                      _isLoadingMore = false;
                      _isInitialLoad = false;
                      if (state.page == 1) {
                        _cachedMessages.clear();
                        _cachedMessages.addAll(state.messages.reversed); // Đảo ngược để phù hợp insert(0, ...)
                      } else {
                        for (final message in state.messages) {
                          if (!_cachedMessages.any((m) => m.id == message.id)) {
                            _cachedMessages.insert(0, message);
                          }
                        }
                      }
                    });
                  } else if (state is MessageSent) {
                    setState(() {
                      _isSendingMessage = false;
                    });
                    _addMessageToCache(state.message);
                  } else if (state is MessageSendError) {
                    setState(() {
                      _isSendingMessage = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi gửi tin nhắn: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is SendingMessage) {
                    setState(() {
                      _isSendingMessage = true;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is DirectChatMessagesLoading && _isInitialLoad) {
                    return _buildLoadingState();
                  } else if (state is DirectChatMessagesLoaded || _cachedMessages.isNotEmpty) {
                    return _buildMessagesList(_cachedMessages);
                  } else if (state is DirectChatMessagesError) {
                    return _buildErrorWidget(state.message);
                  } else {
                    return _buildEmptyState();
                  }
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: _popWithAnimation,
        ),
      ),
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          String? receiverAvatar = widget.userAvatar;
          String receiverName = widget.userName;
          
          if (state is DirectChatMessagesLoaded && state.messages.isNotEmpty) {
            final firstMessage = state.messages.first;
            if (firstMessage.receiverId == widget.userId) {
              receiverAvatar = firstMessage.receiver.avatar;
              receiverName = firstMessage.receiver.fullName;
            } else if (firstMessage.senderId == widget.userId) {
              receiverAvatar = firstMessage.sender.avatar;
              receiverName = firstMessage.sender.fullName;
            }
          }
          
          return Row(
            children: [
              GestureDetector(
                onTap: () => _navigateToProfile(widget.userId, receiverName),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: receiverAvatar != null
                        ? NetworkImage(receiverAvatar)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: receiverAvatar == null
                        ? Icon(Icons.person, size: 24, color: Colors.grey.shade600)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(widget.userId, receiverName),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        receiverName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          StreamBuilder<bool>(
                            stream: _chatService.connectionStatusStream,
                            builder: (context, snapshot) {
                              final isConnected = snapshot.data ?? false;
                              return Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isConnected ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          StreamBuilder<bool>(
                            stream: _chatService.connectionStatusStream,
                            builder: (context, snapshot) {
                              final isConnected = snapshot.data ?? false;
                              return Text(
                                isConnected ? 'Trực tuyến' : 'Ngoại tuyến',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isConnected ? Colors.green.shade600 : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Typing indicator
        StreamBuilder<Map<String, bool>>(
          stream: _chatService.typingStream,
          builder: (context, snapshot) {
            final typingUsers = snapshot.data ?? {};
            final isTyping = typingUsers[widget.userId] == true;
            
            if (isTyping) {
              return const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'đang nhập...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: Colors.black87),
            onPressed: _loadMessages,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessagesList(List<Chat> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }
        final message = messages[index]; // Không đảo ngược index nữa
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(Chat message) {
    final isCurrentUser = message.senderId == currentUserId;
    // Kiểm tra nếu là message vị trí
    if (message.content.startsWith('LOCATION:')) {
      final coords = message.content.substring(9).split(',');
      double? lat = double.tryParse(coords[0]);
      double? lng = coords.length > 1 ? double.tryParse(coords[1]) : null;
      if (lat != null && lng != null) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _navigateToProfile(message.sender.id, message.sender.fullName),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: message.sender.avatar != null
                          ? NetworkImage(message.sender.avatar!)
                          : null,
                      backgroundColor: Colors.grey.shade200,
                      child: message.sender.avatar == null
                          ? Icon(Icons.person, size: 16, color: Colors.grey.shade600)
                          : null,
                    ),
                  ),
                ),
              ],
              Flexible(
                child: LocationMessageWidget(
                  latitude: lat!,
                  longitude: lng!,
                  isCurrentUser: isCurrentUser,
                  onTapMap: () async {
                    await openMapInBrowser(lat, lng);
                  },
                ),
              ),
            ],
          ),
        );
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _navigateToProfile(message.sender.id, message.sender.fullName),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: message.sender.avatar != null
                      ? NetworkImage(message.sender.avatar!)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: message.sender.avatar == null
                      ? Icon(Icons.person, size: 16, color: Colors.grey.shade600)
                      : null,
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isCurrentUser 
                          ? const Color(0xFF007AFF)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                        bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: isCurrentUser ? Colors.white : Colors.black87,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(
                      left: isCurrentUser ? 0 : 8,
                      right: isCurrentUser ? 8 : 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(message.createdAt, locale: 'vi'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.done_all,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Attachment button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implement attachment functionality
                  },
                  icon: Icon(
                    Icons.attach_file,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              // Nút chia sẻ vị trí
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _shareLocation,
                  icon: Icon(
                    Icons.location_on,
                    size: 22,
                    color: Colors.red.shade400,
                  ),
                  tooltip: 'Chia sẻ vị trí',
                ),
              ),
              const SizedBox(width: 12),
              
              // Message input field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isTyping ? const Color(0xFF007AFF) : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Send button
              AnimatedBuilder(
                animation: _sendButtonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sendButtonScaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _isTyping && !_isSendingMessage
                            ? const LinearGradient(
                                colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: _isTyping && !_isSendingMessage
                            ? null
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: _isTyping && !_isSendingMessage
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF007AFF).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _isTyping && !_isSendingMessage ? _sendMessage : null,
                          child: Container(
                            width: 48,
                            height: 48,
                            child: _isSendingMessage
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.send_rounded,
                                    color: _isTyping && !_isSendingMessage
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Đang tải tin nhắn...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng chờ trong giây lát',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 48,
                    color: const Color(0xFF007AFF),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chưa có tin nhắn nào',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bắt đầu trò chuyện với ${widget.userName}\nđể kết nối và chia sẻ',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        _messageFocusNode.requestFocus();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bắt đầu chat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _loadMessages,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.grey.shade700,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thử lại',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF0056CC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _popWithAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Quay lại',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 