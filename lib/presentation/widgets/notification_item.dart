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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'notification_avatar_${notification.data.followerId}',
          child: CircleAvatar(
            radius: 24,
            backgroundImage: notification.data.followerAvatar.isNotEmpty
                ? NetworkImage(notification.data.followerAvatar)
                : null,
            onBackgroundImageError: (_, __) {},
            child: notification.data.followerAvatar.isEmpty
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