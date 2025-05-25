import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';
import '../../core/utils/date_formatter.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get avatar URL based on notification type
    String? avatarUrl;
    String? userId;
    
    switch (notification.type) {
      case 'FOLLOW':
        avatarUrl = notification.followerAvatar;
        userId = notification.followerId;
        break;
      case 'LIKE':
        avatarUrl = notification.data['likerAvatar']?.toString();
        userId = notification.data['likerId']?.toString();
        break;
      case 'COMMENT':
        avatarUrl = notification.data['commenterAvatar']?.toString();
        userId = notification.data['commenterId']?.toString();
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'notification_avatar_${userId ?? notification.id}',
          child: CircleAvatar(
            radius: 24,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : null,
            onBackgroundImageError: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? (_, __) {}
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? const Icon(Icons.person, size: 24)
                : null,
          ),
        ),
        title: Text(
          notification.content,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: notification.isRead
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                _getNotificationIcon(notification.type),
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatTimeAgo(notification.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'FOLLOW':
        return Icons.person_add;
      case 'LIKE':
        return Icons.favorite;
      case 'COMMENT':
        return Icons.comment;
      default:
        return Icons.notifications;
    }
  }
} 