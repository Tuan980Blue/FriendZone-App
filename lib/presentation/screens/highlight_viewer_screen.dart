import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import '../../data/datasources/remote/story_remote_data_source.dart';
import '../../di/injection_container.dart';
import '../../data/models/hightlight_model.dart';
import '../widgets/common/custom_snackbar.dart';

class HighlightViewerScreen extends StatefulWidget {
  final HighlightModel highlight;

  const HighlightViewerScreen({super.key, required this.highlight});

  @override
  State<HighlightViewerScreen> createState() => _HighlightViewerScreenState();
}

class _HighlightViewerScreenState extends State<HighlightViewerScreen> {
  final StoryController controller = StoryController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleDeleteHighlight() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xoá Highlight"),
        content: const Text("Bạn có chắc chắn muốn xoá highlight này không?"),
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
      await sl<StoryRemoteDataSource>().deleteHighlight(widget.highlight.id);

      CustomSnackBar.showSuccess(
        context: context,
        message: "Đã xoá highlight thành công",
      );

      Navigator.of(context).pop();
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: "Lỗi khi xoá highlight",
      );
    }
  }

  void _showViewersDialog() async {
    final storyId = widget.highlight.stories.first.id;

    try {
      controller.pause();
      final storyRemote = sl<StoryRemoteDataSource>();

      final results = await Future.wait([
        storyRemote.fetchStoryViews(storyId),
        storyRemote.fetchStoryLikes(storyId),
      ]);

      final viewers = results[0];
      final likers = results[1];
      final likedUserIds = likers.map((e) => e.user.id).toSet();

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.grey, size: 24),
                      const SizedBox(width: 6),
                      Text(
                        '${viewers.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.favorite, color: Colors.red, size: 24),
                      const SizedBox(width: 6),
                      Text(
                        '${likers.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewers.length,
                    itemBuilder: (context, index) {
                      final viewer = viewers[index];
                      final isLiked = likedUserIds.contains(viewer.user.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(viewer.user.avatar),
                        ),
                        title: Text(viewer.user.fullName),
                        subtitle: Text('@${viewer.user.username}'),
                        trailing: isLiked
                            ? const Icon(Icons.favorite, color: Colors.red, size: 20)
                            : null,
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đóng"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) print("Lỗi khi lấy viewers: $e");

      CustomSnackBar.showError(
        context: context,
        message: "Lỗi khi lấy danh sách người xem",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyItems = widget.highlight.stories.map((story) {
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
        return StoryItem.text(
          title: "Unsupported",
          backgroundColor: Colors.red,
        );
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
          Positioned(
            bottom: 40,
            right: 80,
            child: IconButton(
              icon: const Icon(Icons.group_outlined, color: Colors.white, size: 28),
              onPressed: _showViewersDialog,
            ),
          ),
          Positioned(
            bottom: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
              onPressed: _handleDeleteHighlight,
            ),
          ),
        ],
      ),
    );
  }
}
