import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onFollowPressed;

  const UserCard({
    super.key,
    required this.user,
    required this.onFollowPressed,
  });

  Widget _buildUserAvatar(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.person),
      );
    }

    return CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(avatarUrl),
      onBackgroundImageError: (_, __) {
        // Handle image loading error
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: ListTile(
        leading: _buildUserAvatar(user['avatar']),
        title: Text(
          user['fullName'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('@${user['username']}'),
        trailing: ElevatedButton(
          onPressed: onFollowPressed,
          child: const Text('Follow'),
        ),
      ),
    );
  }
} 