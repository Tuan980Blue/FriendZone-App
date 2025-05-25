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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? Theme.of(context).cardColor
            : Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with notification type indicator
                Stack(
                  children: [
                    Hero(
                      tag: 'notification_avatar_${userId ?? notification.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getNotificationColor(context, notification.type),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                              ? NetworkImage(avatarUrl)
                              : null,
                          onBackgroundImageError: (avatarUrl != null && avatarUrl.isNotEmpty)
                              ? (_, __) {}
                              : null,
                          child: (avatarUrl == null || avatarUrl.isEmpty)
                              ? Icon(Icons.person, 
                                  size: 28,
                                  color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(context, notification.type),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).cardColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getNotificationIcon(notification.type),
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.content,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                          color: notification.isRead
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                              : Theme.of(context).colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatTimeAgo(notification.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
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

  Color _getNotificationColor(BuildContext context, String type) {
    switch (type) {
      case 'FOLLOW':
        return Theme.of(context).colorScheme.secondary;
      case 'LIKE':
        return Colors.red;
      case 'COMMENT':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
} 