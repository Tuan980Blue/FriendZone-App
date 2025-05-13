import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.cardLight,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo image
          Image.asset(
            'assets/images/logo04.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          // Action icons
          Row(
            children: [
              // Notification icon
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  // TODO: Implement notification functionality
                },
              ),
              // Message icon
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  // TODO: Implement message functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 