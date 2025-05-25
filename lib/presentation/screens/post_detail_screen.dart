import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? postData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPost();
  }

  Future<void> fetchPost() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await http.get(Uri.parse(
        'https://web-socket-friendzone.onrender.com/api/posts/${widget.postId}',
      ));
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(Icons.remove_red_eye, postData!['viewCount'] ?? 0),
        _buildStatItem(Icons.favorite, postData!['likeCount'] ?? 0),
        _buildStatItem(Icons.comment, postData!['commentCount'] ?? 0),
        _buildStatItem(Icons.share, postData!['shareCount'] ?? 0),
      ],
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

  Widget _buildCommentSection() {
    final comments = postData!['comments'] as List? ?? [];
    if (comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Chưa có bình luận nào'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Bình luận (${comments.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            comment['author']['avatar'] ?? '',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment['author']['fullName'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '@${comment['author']['username']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(comment['createdAt']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(comment['content'] ?? ''),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
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
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundImage: postData!['author']?['avatar'] != null
                                              ? NetworkImage(postData!['author']['avatar'])
                                              : null,
                                          child: postData!['author']?['avatar'] == null
                                              ? const Icon(Icons.person)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                postData!['author']?['fullName'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
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
                                        height: 300, // Fixed height for the image
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
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildCommentSection(),
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