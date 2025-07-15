import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:friendzoneapp/domain/usecases/user/update_profile_usecase.dart';
import 'package:friendzoneapp/domain/usecases/users/follow_user_usecase.dart';
import 'package:friendzoneapp/domain/usecases/users/unfollow_user_usecase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:friendzoneapp/presentation/widgets/post_likes_dialog.dart';
import 'package:friendzoneapp/presentation/widgets/comments_section.dart';
import 'package:friendzoneapp/presentation/screens/post_detail_screen.dart';
import 'package:friendzoneapp/presentation/theme/app_theme.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../screens/profile_screen.dart';
import '../../di/injection_container.dart';
import '../../core/network/api_client.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:friendzoneapp/presentation/widgets/ai_suggestion_widget.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  bool _isCommentsExpanded = false;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLikeLoading = false;
  bool _isSaved = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount ?? 0;
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToUserProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
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

  Future<void> _showLikesDialog(BuildContext context) async {
    final apiClient = sl<ApiClient>();
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => PostLikesDialog(
        postId: widget.post.id,
        authToken: apiClient.headers['Authorization']?.replaceAll('Bearer ', '') ?? '',
        onUserTap: (userId) => _navigateToUserProfile(context, userId),
      ),
    );
  }

  Future<void> _handleLike() async {
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    try {
      final apiClient = sl<ApiClient>();
      final token = apiClient.headers['Authorization']?.replaceAll('Bearer ', '') ?? '';
      
      final response = await http.post(
        Uri.parse('https://web-socket-friendzone.onrender.com/api/posts/${widget.post.id}/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final bool isLiked = jsonResponse['data']['liked'] ?? false;
          setState(() {
            _isLiked = isLiked;
            if (isLiked) {
              _likeCount++;
              _likeAnimationController.forward(from: 0.0);
            } else {
              _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
            }
          });
          if (widget.onLike != null) {
            widget.onLike!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message'] ?? 'Không thể thực hiện thao tác like'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại'),
            backgroundColor: AppTheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thực hiện thao tác like'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra, vui lòng thử lại'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLikeLoading = false;
      });
    }
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _handleLike();
    }
    setState(() {
      _showHeart = true;
    });
    _likeAnimationController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = sl<ApiClient>();
    return Card(
      margin: const EdgeInsets.only(top: 5.0),
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(context, widget.post.author.id),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentPink,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.post.author.avatar != null && widget.post.author.avatar!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.post.author.avatar!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  widget.post.author.fullName.isNotEmpty 
                                      ? widget.post.author.fullName[0].toUpperCase() 
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToUserProfile(context, widget.post.author.id),
                        child: Text(
                          widget.post.author.username.isNotEmpty 
                              ? widget.post.author.username 
                              : 'unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (widget.post.location != null && widget.post.location!.isNotEmpty)
                        Text(
                          widget.post.location!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // TODO: Implement post options menu
                  },
                ),
              ],
            ),
          ),

          // Images
          if (widget.post.images != null && widget.post.images!.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(postId: widget.post.id),
                        ),
                      );
                    },
                    onDoubleTap: _handleDoubleTap,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.post.images!.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final imageUrl = widget.post.images![index];
                        if (imageUrl.isEmpty) return const SizedBox.shrink();
                        
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.error_outline,
                              color: AppTheme.error,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.post.images!.length > 1)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${widget.post.images!.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (_showHeart)
                  ScaleTransition(
                    scale: _likeAnimation,
                    child: const Icon(
                      Icons.favorite,
                      size: 80,
                      color: AppTheme.accentPink,
                    ),
                  ),
              ],
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                _buildActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? AppTheme.accentPink : null,
                  onTap: _handleLike,
                  isLoading: _isLikeLoading,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    setState(() {
                      _isCommentsExpanded = !_isCommentsExpanded;
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.send_outlined,
                  onTap: widget.onShare,
                ),
                const Spacer(),
                _buildActionButton(
                  icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  onTap: () {
                    setState(() {
                      _isSaved = !_isSaved;
                    });
                    if (widget.onSave != null) {
                      widget.onSave!();
                    }
                  },
                ),
              ],
            ),
          ),

          // Likes count
          if (_likeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GestureDetector(
                onTap: () => _showLikesDialog(context),
                child: Text(
                  '$_likeCount lượt thích',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // Caption
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '${widget.post.author.username} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: widget.post.content),
                  ],
                ),
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 8.0),
            child: Text(
              timeago.format(widget.post.createdAt, locale: 'vi'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),

          // Comments section
          if ((widget.post.commentCount ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCommentsExpanded = true;
                  });
                  // Hoặc chuyển sang màn hình chi tiết post nếu muốn
                },
                child: Text(
                  'Xem tất cả ${widget.post.commentCount} bình luận',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          CommentsSection(
            postId: widget.post.id,
            authToken: apiClient.headers['Authorization']?.replaceAll('Bearer ', '') ?? '',
            onUserTap: (userId) => _navigateToUserProfile(context, userId),
            isExpanded: _isCommentsExpanded,
            onToggle: () {
              setState(() {
                _isCommentsExpanded = !_isCommentsExpanded;
              });
            },
            postContent: widget.post.content, // Truyền nội dung bài đăng
          ),
          // AI Suggestion Widget
          AiSuggestionWidget(
            postContent: widget.post.content,
            imageUrls: widget.post.images,
            location: widget.post.location,
            authorName: widget.post.author.username,
            onSuggestionTap: (suggestion) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bạn đã chọn: $suggestion')),
              );
            },
            apiKey: 'AIzaSyAKXT0Wdq2gk0XnUS_tCVCxB7qF9nAnb-w', // <-- Thay bằng API key thật của bạn
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color ?? AppTheme.accentPink,
                    ),
                  ),
                )
              : Icon(
                  icon,
                  size: 24,
                  color: color ?? Colors.black,
                ),
        ),
      ),
    );
  }
} 