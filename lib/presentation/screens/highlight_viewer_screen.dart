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
