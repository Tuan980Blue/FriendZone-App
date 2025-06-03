import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/user.dart';

class ProfileAccountInfo extends StatelessWidget {
  final User user;

  const ProfileAccountInfo({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Created At',
              DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt.toLocal()),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.update,
              'Last Updated',
              DateFormat('dd/MM/yyyy HH:mm').format(user.updatedAt.toLocal()),
            ),
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