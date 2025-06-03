import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../domain/entities/user.dart';

class ProfilePersonalInfo extends StatelessWidget {
  final User user;

  const ProfilePersonalInfo({
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
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (user.gender != null) ...[
              _buildInfoRow(
                context,
                Icons.person_outline,
                'Gender',
                _formatGender(user.gender!),
              ),
              const SizedBox(height: 8),
            ],
            if (user.birthDate != null) ...[
              _buildInfoRow(
                context,
                Icons.cake,
                'Birth Date',
                DateFormat('dd/MM/yyyy').format(user.birthDate!.toLocal()),
              ),
              const SizedBox(height: 8),
            ],
            if (user.status != null) ...[
              Row(
                children: [
                  Icon(
                    _getStatusIcon(user.status!),
                    size: 20,
                    color: _getStatusColor(user.status!),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        Text(
                          _formatStatus(user.status!),
                          style: TextStyle(
                            color: _getStatusColor(user.status!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (user.lastSeen != null) ...[
              _buildInfoRow(
                context,
                Icons.access_time,
                'Last Seen',
                timeago.format(user.lastSeen!.toLocal()),
              ),
              const SizedBox(height: 8),
            ],
            if (user.role != null && user.role != 'USER') ...[
              _buildInfoRow(
                context,
                Icons.verified_user,
                'Role',
                user.role!,
              ),
              const SizedBox(height: 8),
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

  String _formatGender(String gender) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return 'Online';
      case 'OFFLINE':
        return 'Offline';
      case 'AWAY':
        return 'Away';
      case 'BUSY':
        return 'Busy';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return Icons.circle;
      case 'OFFLINE':
        return Icons.circle_outlined;
      case 'AWAY':
        return Icons.access_time;
      case 'BUSY':
        return Icons.do_not_disturb_on;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return Colors.green;
      case 'OFFLINE':
        return Colors.grey;
      case 'AWAY':
        return Colors.orange;
      case 'BUSY':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 