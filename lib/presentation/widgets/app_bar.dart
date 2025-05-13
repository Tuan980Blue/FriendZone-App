import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(int)? onTabChanged;
  final int selectedIndex;

  const CustomAppBar({
    super.key,
    this.onTabChanged,
    this.selectedIndex = 0,
  });

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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedIndex == 2 
                      ? AppTheme.accentPink.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: selectedIndex == 2 
                        ? AppTheme.accentPink
                        : AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    // Chuyển đến tab notifications (index 2)
                    onTabChanged?.call(2);
                  },
                ),
              ),
              const SizedBox(width: 4),
              // Message icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedIndex == 3 
                      ? AppTheme.accentPink.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: selectedIndex == 3 
                        ? AppTheme.accentPink
                        : AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    // TODO: Implement message functionality
                  },
                ),
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