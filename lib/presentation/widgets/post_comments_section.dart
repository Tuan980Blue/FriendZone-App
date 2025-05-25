import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCommentsSection extends StatelessWidget {
  final List<dynamic> comments;
  final Function(String) onUserTap;
  final Function(String) onCommentSubmit;
  final TextEditingController commentController;
  final bool isSubmitting;

  const PostCommentsSection({
    Key? key,
    required this.comments,
    required this.onUserTap,
    required this.onCommentSubmit,
    required this.commentController,
    this.isSubmitting = false,
  }) : super(key: key);

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return timeago.format(date, locale: 'vi');
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        if (comments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Chưa có bình luận nào'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final user = comment['author'];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => onUserTap(user['id']),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: CachedNetworkImageProvider(
                                user['avatar'] ?? '',
                              ),
                              onBackgroundImageError: (_, __) {},
                              child: user['avatar'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => onUserTap(user['id']),
                                  child: Text(
                                    user['fullName'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '@${user['username']}',
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
} 