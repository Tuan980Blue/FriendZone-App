import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../di/injection_container.dart';
import '../../../domain/entities/post.dart';
import '../post_card.dart';


class ProfilePosts extends StatefulWidget {
  final String userId;
  final bool isViewingOwnProfile;

  const ProfilePosts({
    super.key,
    required this.userId,
    required this.isViewingOwnProfile,
  });

  @override
  State<ProfilePosts> createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts> {
  final List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 9;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final apiClient = sl<ApiClient>();
      final token = apiClient.headers['Authorization']?.replaceAll('Bearer ', '') ?? '';
      final response = await http.get(
        Uri.parse('https://web-socket-friendzone.onrender.com/api/posts/user/${widget.userId}?page=1&limit=$_limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> postsJson = jsonResponse['posts'];
        final pagination = jsonResponse['pagination'];
        setState(() {
          _posts.clear();
          _posts.addAll(postsJson.map((json) => Post.fromJson(json)));
          _hasMore = pagination['page'] < pagination['totalPages'];
          _currentPage = pagination['page'];
        });
      } else {
        setState(() {
          _error = 'Không thể tải bài viết';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Có lỗi xảy ra: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPosts,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.isViewingOwnProfile
                  ? 'Bạn chưa có bài viết nào'
                  : 'Người dùng này chưa có bài viết nào',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return _hasMore
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }
          return PostCard(
            post: _posts[index],
            onLike: () {
              _refreshPosts();
            },
          );
        },
      ),
    );
  }
} 