import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../domain/entities/user.dart';

class StoryOptionDialog extends StatefulWidget {
  final User user;

  const StoryOptionDialog({
    super.key,
    required this.user,
  });

  @override
  State<StoryOptionDialog> createState() => _StoryOptionDialogState();
}

class _StoryOptionDialogState extends State<StoryOptionDialog> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _recentImages;
  bool _isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  Future<void> _loadRecentImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(limit: 20);
      setState(() {
        _recentImages = images;
        _isLoadingImages = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingImages = false;
      });
      debugPrint('Error loading images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 9),

                // Horizontal Options
                _buildHorizontalOptions(),

                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Thư viện',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Grid Images
                Expanded(
                  child: _isLoadingImages
                      ? const Center(child: CircularProgressIndicator())
                      : _recentImages == null || _recentImages!.isEmpty
                      ? const Center(child: Text('Không có ảnh trong thư viện'))
                      : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _recentImages!.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_recentImages![index].path),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Floating Action Button ở góc dưới bên phải
            Positioned(
              bottom: 12,
              right: 12,
              child: SizedBox(
                width: 64,
                height: 64,
                child: FloatingActionButton(
                  onPressed: () async {
                    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                    if (photo != null) {
                      Navigator.pop(context, photo);
                    }
                  },
                  child: const Icon(Icons.camera_alt, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'Tạo tin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHorizontalOptions() {
    const options = [
      {'icon': Icons.text_fields, 'label': 'Văn bản'},
      {'icon': Icons.music_note, 'label': 'Nhạc'},
      {'icon': Icons.loop, 'label': 'Boomerang'},
      {'icon': Icons.photo_library, 'label': 'Mẫu'},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(options[index]['icon'] as IconData),
                ),
                const SizedBox(height: 4),
                Text(
                  options[index]['label'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
