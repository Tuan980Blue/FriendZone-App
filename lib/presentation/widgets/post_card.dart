import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../screens/profile_screen.dart';
import '../../di/injection_container.dart';

class PostCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () => _navigateToUserProfile(context, post.author.id),
              child: CircleAvatar(
                backgroundImage: post.author.avatar != null && post.author.avatar!.isNotEmpty
                    ? CachedNetworkImageProvider(post.author.avatar!)
                    : null,
                child: post.author.avatar == null || post.author.avatar!.isEmpty
                    ? Text(post.author.fullName.isNotEmpty 
                        ? post.author.fullName[0].toUpperCase() 
                        : '?')
                    : null,
              ),
            ),
            title: GestureDetector(
              onTap: () => _navigateToUserProfile(context, post.author.id),
              child: Text(
                post.author.fullName.isNotEmpty 
                    ? post.author.fullName 
                    : 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: GestureDetector(
              onTap: () => _navigateToUserProfile(context, post.author.id),
              child: Text('@${post.author.username.isNotEmpty ? post.author.username : 'unknown'}'),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Implement post options menu
              },
            ),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(post.content),
            ),
          if (post.images != null && post.images!.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.images!.length,
                itemBuilder: (context, index) {
                  final imageUrl = post.images![index];
                  if (imageUrl.isEmpty) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: 200,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: '${post.likeCount}',
                  onTap: onLike,
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '${post.commentCount}',
                  onTap: onComment,
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: '${post.shareCount}',
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
} 