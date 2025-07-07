import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';

class GenericStoryViewScreen extends StatelessWidget {
  final List<String> mediaUrls;
  final List<String> mediaTypes;

  const GenericStoryViewScreen({
    super.key,
    required this.mediaUrls,
    required this.mediaTypes,
  });

  @override
  Widget build(BuildContext context) {
    final storyController = StoryController();

    final storyItems = List.generate(mediaUrls.length, (index) {
      final type = mediaTypes[index].toUpperCase();
      final url = mediaUrls[index];

      if (type == 'IMAGE') {
        return StoryItem.pageImage(
          url: url,
          controller: storyController,
        );
      } else if (type == 'VIDEO') {
        return StoryItem.pageVideo(
          url,
          controller: storyController,
        );
      } else {
        return StoryItem.text(
          title: "Unsupported type",
          backgroundColor: Colors.red,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// 🎥 Story view chính
            StoryView(
              storyItems: storyItems,
              controller: storyController,
              onComplete: () => Navigator.pop(context),
              repeat: false,
              inline: true,
            ),

            /// ❌ Nút Đóng (X)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            /// ❤️ Nút Tim
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❤️ Bạn đã thích story này')),
                    );
                  },
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
