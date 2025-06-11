import 'package:flutter/material.dart';

class NewMessageScreen extends StatelessWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Tin nhắn mới',
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
          // 2 lựa chọn đầu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.groups, color: Colors.black54, size: 26),
                  ),
                  title: const Text('Tạo nhóm chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                  onTap: () {},
                ),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.smart_toy_outlined, color: Colors.black54, size: 26),
                  ),
                  title: const Text('Đoạn chat với AI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('MỚI', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Text(
              'Gợi ý',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.blueAccent),
            ),
          ),
          // Placeholder cho danh sách gợi ý
          Expanded(
            child: Center(
              child: Text(
                'Danh sách gợi ý sẽ hiển thị ở đây',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 