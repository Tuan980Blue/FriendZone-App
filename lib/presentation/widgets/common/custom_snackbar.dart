import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
        action: isError && onRetry != null
            ? SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  // Convenience method for showing success messages
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      isError: false,
      duration: duration,
    );
  }

  // Convenience method for showing error messages
  static void showError({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      isError: true,
      onRetry: onRetry,
      duration: duration,
    );
  }
} 