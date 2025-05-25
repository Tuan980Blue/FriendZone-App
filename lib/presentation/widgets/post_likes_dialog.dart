import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class PostLikesDialog extends StatefulWidget {
  final String postId;
  final String authToken;
  final Function(String) onUserTap;

  const PostLikesDialog({
    Key? key,
    required this.postId,
    required this.authToken,
    required this.onUserTap,
  }) : super(key: key);

  @override
  State<PostLikesDialog> createState() => _PostLikesDialogState();
}

class _PostLikesDialogState extends State<PostLikesDialog> {
  bool isLoading = true;
  String? error;
  List<dynamic>? likes;

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  Future<void> _fetchLikes() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.authToken}',
      };

      final response = await http.get(
        Uri.parse('https://web-socket-friendzone.onrender.com/api/posts/${widget.postId}/likes?page=1&limit=10'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['success'] == true) {
          setState(() {
            likes = jsonBody['data']['likes'] as List;
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Không thể tải danh sách người thích';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          error = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Không thể tải danh sách người thích';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Không thể tải danh sách người thích';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Người đã thích',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchLikes,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
            else if (likes == null || likes!.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Chưa có ai thích bài viết này'),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: likes!.length,
                  itemBuilder: (context, index) {
                    final like = likes![index];
                    final user = like['user'];
                    return ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onUserTap(user['id']);
                      },
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          user['avatar'] ?? '',
                        ),
                        onBackgroundImageError: (_, __) {},
                        child: user['avatar'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        user['fullName'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('@${user['username']}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
} 