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
  late List<Story> _stories;
  final ValueNotifier<int> currentIndexNotifier = ValueNotifier<int>(0);
  late bool isLiked;

  Story get currentStory => _stories[currentIndexNotifier.value];

  @override
  void initState() {
    super.initState();
    _stories = List.from(widget.stories);

    if (_stories.isNotEmpty) {
      isLiked = _stories.first.isLikedByCurrentUser;
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
    currentIndexNotifier.dispose();
    super.dispose();
  }

  void _handleDeleteStory() async {
    final storyId = currentStory.id;

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

      widget.onDeleted?.call(storyId);
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
    final storyItems = _stories.map((story) {
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
            onStoryShow: (storyItem, index) {
              currentIndexNotifier.value = index;
              isLiked = _stories[index].isLikedByCurrentUser;
            },
            onComplete: () => Navigator.pop(context),
          ),
          ValueListenableBuilder<int>(
            valueListenable: currentIndexNotifier,
            builder: (context, currentIndex, _) {
              final location = _stories[currentIndex].location ?? '';
              if (location.isEmpty) return const SizedBox.shrink();
              return Positioned(
                top: 60,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
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
                      IconButton(
                        icon: const Icon(Icons.group_outlined, color: Colors.white, size: 20),
                        onPressed: _showViewersDialog,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                        onPressed: _navigateToCreateHighlight,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
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
                    final storyId = currentStory.id;
                    if (!isLiked) {
                      try {
                        await sl<StoryRemoteDataSource>().likeStory(storyId);
                        setState(() {
                          isLiked = true;
                          _stories[currentIndexNotifier.value] =
                              _stories[currentIndexNotifier.value]
                                  .copyWith(isLikedByCurrentUser: true);
                        });
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: "Đã thích story",
                        );
                      } catch (e) {
                        CustomSnackBar.showError(
                          context: context,
                          message: "Lỗi khi thích story",
                        );
                      }
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

  void _showViewersDialog() async {
    final storyId = currentStory.id;

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
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.grey, size: 24),
                      const SizedBox(width: 6),
                      Text('${viewers.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(width: 24),
                      const Icon(Icons.favorite, color: Colors.red, size: 24),
                      const SizedBox(width: 6),
                      Text('${likers.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      onPressed: () {
                        Navigator.pop(context);
                        controller.play();
                      },
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
}
