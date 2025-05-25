import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isCommentsExpanded = false;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount ?? 0;
    // TODO: Check if current user has liked this post
    // _isLiked = widget.post.isLikedByCurrentUser ?? false;
  }

  void _navigateToUserProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
          logoutUseCase: sl<LogoutUseCase>(),
          getUserByIdUseCase: sl<GetUserByIdUseCase>(),
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
            // Nếu API trả về liked: true thì tăng số lượt thích, ngược lại thì giảm
            if (isLiked) {
              _likeCount++;
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

  @override
  Widget build(BuildContext context) {
    final apiClient = sl<ApiClient>();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(
          color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(context, widget.post.author.id),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentPink,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.post.author.avatar != null && widget.post.author.avatar!.isNotEmpty
                          ? CachedNetworkImageProvider(widget.post.author.avatar!)
                          : null,
                      child: widget.post.author.avatar == null || widget.post.author.avatar!.isEmpty
                          ? Text(
                              widget.post.author.fullName.isNotEmpty 
                                  ? widget.post.author.fullName[0].toUpperCase() 
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
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
                          widget.post.author.fullName.isNotEmpty 
                              ? widget.post.author.fullName 
                              : 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToUserProfile(context, widget.post.author.id),
                        child: Text(
                          '@${widget.post.author.username.isNotEmpty ? widget.post.author.username : 'unknown'}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    // TODO: Implement post options menu
                  },
                ),
              ],
            ),
          ),
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (widget.post.images != null && widget.post.images!.isNotEmpty)
            Container(
              height: 300,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.post.images!.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.post.images![index];
                  if (imageUrl.isEmpty) return const SizedBox.shrink();
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(postId: widget.post.id),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      child: CachedNetworkImage(
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
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.favorite_border,
                      label: '$_likeCount',
                      onTap: widget.onLike,
                      color: AppTheme.accentPink,
                      isLikeButton: true,
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.comment_outlined,
                      label: '${widget.post.commentCount}',
                      onTap: () {
                        setState(() {
                          _isCommentsExpanded = !_isCommentsExpanded;
                        });
                      },
                    ),
                  ],
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '${widget.post.shareCount}',
                  onTap: widget.onShare,
                ),
              ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
    bool isLikeButton = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          InkWell(
            onTap: isLikeButton ? _handleLike : onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: isLikeButton && _isLikeLoading
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
                      isLikeButton && _isLiked ? Icons.favorite : icon,
                      size: 20,
                      color: isLikeButton && _isLiked
                          ? AppTheme.accentPink
                          : (color ?? AppTheme.textSecondary),
                    ),
            ),
          ),
          if (isLikeButton) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _showLikesDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  '$_likeCount',
                  style: TextStyle(
                    color: _isLiked ? AppTheme.accentPink : (color ?? AppTheme.textSecondary),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 