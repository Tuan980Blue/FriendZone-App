import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final bool isViewingOwnProfile;
  final VoidCallback onEditProfile;
  final VoidCallback onFollow;
  final VoidCallback onMessage;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isViewingOwnProfile,
    required this.onEditProfile,
    required this.onFollow,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.username ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (user.fullName != null) ...[
            const SizedBox(height: 4),
            Text(
              user.fullName!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          if (!isViewingOwnProfile && user != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onFollow,
                  child: Text(user.isFollowing ? 'Unfollow' : 'Follow'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onMessage,
                  child: const Text('Message'),
                ),
              ],
            ),
          ],
          if (isViewingOwnProfile) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ],
      ),
    );
  }
} 