import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import '../../data/datasources/remote/story_remote_data_source.dart';
import '../../di/injection_container.dart';
import '../../domain/entities/story.dart';

class GenericStoryViewScreen extends StatefulWidget {
  final List<Story> stories;
  final bool isMyStory;

  const GenericStoryViewScreen({
    super.key,
    required this.stories,
    required this.isMyStory,
  });

  @override
  State<GenericStoryViewScreen> createState() => _GenericStoryViewScreenState();
}

class _GenericStoryViewScreenState extends State<GenericStoryViewScreen> {
  final controller = StoryController();

  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.stories.first.isLikedByCurrentUser; // Lấy trạng thái ban đầu
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyItems = widget.stories.map((story) {
      final caption = story.location ?? '';
      if (story.mediaType.toUpperCase() == 'IMAGE') {
        return StoryItem.pageImage(
          url: story.mediaUrl,
          caption: Text(caption),
          controller: controller,
        );
      } else if (story.mediaType.toUpperCase() == 'VIDEO') {
        return StoryItem.pageVideo(
          story.mediaUrl,
          controller: controller,
          caption: Text(caption),
        );
      } else {
        return StoryItem.text(title: "Unsupported", backgroundColor: Colors.red);
      }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StoryView(
            storyItems: storyItems,
            controller: controller,
            onComplete: () => Navigator.pop(context),
          ),

          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          if (widget.isMyStory)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.stories.first.viewCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.stories.first.likeCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),

          if (!widget.isMyStory)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      final storyId = widget.stories.first.id;

                      await sl<StoryRemoteDataSource>().likeStory(storyId);

                      setState(() {
                        isLiked = true; // Cập nhật UI khi like
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❤️ Bạn đã thích story')),
                      );
                    } catch (e, stackTrace) {
                      if (kDebugMode) {
                        print("Lỗi khi like: $e");
                        print("Chi tiết lỗi: $stackTrace");
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi khi like: ${e.toString()}')),
                      );
                    }
                  },
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

