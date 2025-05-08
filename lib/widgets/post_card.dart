import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import 'action_button.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.author['avatar'] != null &&
                      post.author['avatar'].toString().startsWith('http')
                  ? CachedNetworkImageProvider(post.author['avatar'])
                  : null,
              child: post.author['avatar'] == null ||
                      !post.author['avatar'].toString().startsWith('http')
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              post.author['fullName'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('@${post.author['username']}'),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(post.content),
            ),
          if (post.images.isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.images.length,
                itemBuilder: (context, imageIndex) {
                  final imageUrl = post.images[imageIndex];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ActionButton(
                  icon: Icons.visibility,
                  count: post.viewCount.toString(),
                  onPressed: () {},
                ),
                ActionButton(
                  icon: Icons.favorite_border,
                  count: post.likeCount.toString(),
                  onPressed: () {},
                ),
                ActionButton(
                  icon: Icons.comment_outlined,
                  count: post.commentCount.toString(),
                  onPressed: () {},
                ),
                ActionButton(
                  icon: Icons.share_outlined,
                  count: post.shareCount.toString(),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 