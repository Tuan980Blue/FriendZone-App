import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';

class ProfileContactInfo extends StatelessWidget {
  final User user;
  final bool isViewingOwnProfile;

  const ProfileContactInfo({
    super.key,
    required this.user,
    required this.isViewingOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (!isViewingOwnProfile && user.isPrivate) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (isViewingOwnProfile || user.email != null)
              _buildInfoRow(
                context,
                Icons.email,
                'Email',
                user.email ?? '',
              ),
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.phone,
                'Phone',
                user.phoneNumber!,
              ),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.person,
              'Username',
              user.username ?? '',
            ),
            if (user.location != null && user.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.location_on,
                'Location',
                user.location!,
              ),
            ],
            if (user.website != null && user.website!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.link,
                'Website',
                user.website!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
} 