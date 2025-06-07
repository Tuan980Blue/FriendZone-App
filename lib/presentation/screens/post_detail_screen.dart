import 'package:flutter/material.dart';
import 'package:friendzoneapp/presentation/screens/profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:friendzoneapp/presentation/widgets/post_likes_dialog.dart';
import 'package:friendzoneapp/presentation/widgets/post_comments_section.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../di/injection_container.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../../domain/usecases/users/follow_user_usecase.dart';
import '../../domain/usecases/users/unfollow_user_usecase.dart';


class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> with SingleTickerProviderStateMixin {
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
  final LogoutUseCase _logoutUseCase = sl<LogoutUseCase>();
  final UpdateProfileUseCase _updateProfileUseCase = sl<UpdateProfileUseCase>();
  final FollowUserUseCase _followUserUseCase = sl<FollowUserUseCase>();
  final UnfollowUserUseCase _unfollowUserUseCase = sl<UnfollowUserUseCase>();

  Map<String, dynamic>? postData;
  bool isLoading = true;
  String? error;
  String? authToken;
  final TextEditingController _commentController = TextEditingController();
  bool isSubmittingComment = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          getCurrentUserUseCase: _getCurrentUserUseCase,
          logoutUseCase: _logoutUseCase,
          getUserByIdUseCase: _getUserByIdUseCase,
          updateProfileUseCase: _updateProfileUseCase,
          followUserUseCase: _followUserUseCase,
          unfollowUserUseCase: _unfollowUserUseCase,
          userId: userId,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    fetchPost();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('auth_token');
    });
  }

  Future<void> fetchPost() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('https://web-socket-friendzone.onrender.com/api/posts/${widget.postId}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['success'] == true) {
          setState(() {
            postData = jsonBody['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Không tìm thấy bài viết!';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Lỗi server: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi mạng hoặc dữ liệu!';
        isLoading = false;
      });
    }
  }

  Future<void> _showLikesDialog() async {
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để xem danh sách người thích')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PostLikesDialog(
        postId: widget.postId,
        authToken: authToken!,
        onUserTap: _navigateToUserProfile,
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return timeago.format(date, locale: 'vi');
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildAuthorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile_${postData!['authorId']}',
            child: GestureDetector(
              onTap: () => _navigateToUserProfile(postData!['authorId']),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: postData!['author']?['avatar'] != null
                      ? NetworkImage(postData!['author']['avatar'])
                      : null,
                  child: postData!['author']?['avatar'] == null
                      ? const Icon(Icons.person, size: 32)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(postData!['authorId']),
                  child: Text(
                    postData!['author']?['fullName'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '@${postData!['author']?['username'] ?? ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDate(postData!['createdAt']),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildPostContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (postData!['content'] != null && postData!['content'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                postData!['content'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          if (postData!['images'] != null && (postData!['images'] as List).isNotEmpty)
            Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: postData!['images'][0],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.grey[600], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Không thể tải ảnh',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (postData!['tags'] != null && (postData!['tags'] as List).isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (postData!['tags'] as List).map<Widget>((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          if (postData!['location'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    postData!['location'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatButton(
            icon: Icons.favorite,
            count: postData!['likeCount'] ?? 0,
            color: Colors.red[400]!,
            onTap: _showLikesDialog,
          ),
          _buildStatButton(
            icon: Icons.comment,
            count: postData!['commentCount'] ?? 0,
            color: Colors.blue[400]!,
            onTap: () {},
          ),
          _buildStatButton(
            icon: Icons.share,
            count: postData!['shareCount'] ?? 0,
            color: Colors.green[400]!,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitComment(String content) async {
    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để bình luận')),
      );
      return;
    }

    setState(() {
      isSubmittingComment = true;
    });

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.post(
        Uri.parse('https://web-socket-friendzone.onrender.com/api/posts/${widget.postId}/comments'),
        headers: headers,
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        fetchPost(); // Refresh post data to get new comment
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể đăng bình luận')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đăng bình luận')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? _buildLoadingState()
          : error != null
              ? _buildErrorState()
              : postData == null
                  ? const Center(child: Text('Không có dữ liệu'))
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author Info
                          _buildAuthorInfo(),
                          
                          // Post Content
                          _buildPostContent(),
                          
                          // Post Stats
                          _buildPostStats(),
                          
                          // Comments Section
                          PostCommentsSection(
                            comments: postData!['comments'] ?? [],
                            onUserTap: _navigateToUserProfile,
                            onCommentSubmit: _submitComment,
                            commentController: _commentController,
                            isSubmitting: isSubmittingComment,
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: postData != null
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Viết bình luận...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.emoji_emotions_outlined),
                                onPressed: () {
                                  // TODO: Implement emoji picker
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              _submitComment(_commentController.text);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 200,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            Text(
              error ?? 'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red[400],
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchPost,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}