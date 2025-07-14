import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import '../../data/datasources/remote/story_remote_data_source.dart';
import '../../di/injection_container.dart';
import '../../domain/entities/story.dart';
import '../widgets/common/custom_snackbar.dart';
import 'highlight_stories_screen.dart';

class GenericStoryViewScreen extends StatefulWidget {
  final List<Story> stories;
  final bool isMyStory;
  final void Function(String deletedStoryId)? onDeleted;

  const GenericStoryViewScreen({
    super.key,
    required this.stories,
    required this.isMyStory,
    this.onDeleted,
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
    if (widget.stories.isNotEmpty) {
      isLiked = widget.stories.first.isLikedByCurrentUser;
    } else {
      isLiked = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        CustomSnackBar.showError(
          context: context,
          message: "Không có story nào để hiển thị",
        );
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleDeleteStory() async {
    final storyId = widget.stories.first.id;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xoá Story"),
        content: const Text("Bạn có chắc chắn muốn xoá story này không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Xoá", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await sl<StoryRemoteDataSource>().deleteStory(storyId);

      CustomSnackBar.showSuccess(
          context: context,
          message: "Đã xoá story thành công",
      );

      widget.onDeleted?.call(widget.stories.first.id);
      Navigator.of(context).pop();
    } catch (e) {
      if (kDebugMode) print("Lỗi xoá story: $e");

      CustomSnackBar.showError(
        context: context,
        message: "Lỗi khi xoá story",
      );
    }
  }

  void _navigateToCreateHighlight() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HighlightCreationScreen(),
      ),
    );
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
                      IconButton(
                        icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                        onPressed: _navigateToCreateHighlight,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white, size: 25),
                        onPressed: _handleDeleteStory,
                      ),
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
                        isLiked = true;
                      });

                      CustomSnackBar.showSuccess(
                        context: context,
                        message: "Đã thích story",
                      );
                    } catch (e, stackTrace) {
                      if (kDebugMode) {
                        print("Lỗi khi like: $e");
                        print("Chi tiết lỗi: $stackTrace");
                      }

                      CustomSnackBar.showError(
                        context: context,
                        message: "Lỗi khi like",
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

