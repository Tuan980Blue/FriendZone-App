import 'package:flutter/material.dart';
import 'package:friendzoneapp/presentation/screens/profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:friendzoneapp/presentation/widgets/post_likes_dialog.dart';
import 'package:friendzoneapp/presentation/widgets/post_comments_section.dart';

import '../../di/injection_container.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';


class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
  final LogoutUseCase _logoutUseCase = sl<LogoutUseCase>();

  Map<String, dynamic>? postData;
  bool isLoading = true;
  String? error;
  String? authToken;
  final TextEditingController _commentController = TextEditingController();
  bool isSubmittingComment = false;

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          getCurrentUserUseCase: _getCurrentUserUseCase,
          logoutUseCase: _logoutUseCase,
          getUserByIdUseCase: _getUserByIdUseCase,
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
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Đang tải bài viết...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error ?? 'Có lỗi xảy ra',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: fetchPost,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showLikesDialog,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 20, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${postData!['likeCount'] ?? 0} lượt thích',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.comment, size: 20, color: Colors.blue[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${postData!['commentCount'] ?? 0} bình luận',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildStatItem(Icons.share, postData!['shareCount'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
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
        elevation: 0,
      ),
      body: isLoading
          ? _buildLoadingState()
          : error != null
              ? _buildErrorState()
              : postData == null
                  ? const Center(child: Text('Không có dữ liệu'))
                  : RefreshIndicator(
                      onRefresh: fetchPost,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author info
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _navigateToUserProfile(postData!['authorId']),
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundImage: postData!['author']?['avatar'] != null
                                                ? NetworkImage(postData!['author']['avatar'])
                                                : null,
                                            child: postData!['author']?['avatar'] == null
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
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
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '@${postData!['author']?['username'] ?? ''}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _formatDate(postData!['createdAt']),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Content
                                    if (postData!['content'] != null && postData!['content'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Text(
                                          postData!['content'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    // Images
                                    if (postData!['images'] != null && (postData!['images'] as List).isNotEmpty)
                                      Container(
                                        width: double.infinity,
                                        height: 300,
                                        margin: const EdgeInsets.only(bottom: 16),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: postData!['images'][0],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
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
                                    const SizedBox(height: 16),
                                    // Tags
                                    if (postData!['tags'] != null && (postData!['tags'] as List).isNotEmpty)
                                      Wrap(
                                        spacing: 8,
                                        children: (postData!['tags'] as List).map<Widget>((tag) {
                                          return Chip(
                                            label: Text('#$tag'),
                                            backgroundColor: Colors.blue[50],
                                          );
                                        }).toList(),
                                      ),
                                    if (postData!['tags'] != null && (postData!['tags'] as List).isNotEmpty)
                                      const SizedBox(height: 16),
                                    // Location
                                    if (postData!['location'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              postData!['location'],
                                              style: TextStyle(color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Stats
                                    _buildPostStats(),
                                  ],
                                ),
                              ),
                            ),
                            // Comments section
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
                    ),
      bottomNavigationBar: postData != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // TODO: Implement comment functionality
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}