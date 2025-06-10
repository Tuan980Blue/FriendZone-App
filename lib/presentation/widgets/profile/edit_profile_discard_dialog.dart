import 'package:flutter/material.dart';

class EditProfileDiscardDialog extends StatelessWidget {
  const EditProfileDiscardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 24,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'Hủy thay đổi?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: const Text(
        'Bạn có chắc chắn muốn hủy các thay đổi chưa lưu?',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black54,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Tiếp tục chỉnh sửa',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[500],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Hủy thay đổi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
} 