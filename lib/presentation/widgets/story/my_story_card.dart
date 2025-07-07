import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import '../../../di/injection_container.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/storys/get_my_stories_usecase.dart';
import '../../../domain/entities/story.dart';

class MyStoryCard extends StatelessWidget {
  const MyStoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
    final getMyStoriesUseCase = sl<GetMyStoriesUseCase>();

    return FutureBuilder<User>(
      future: getCurrentUserUseCase.call(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }

        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return _buildErrorPlaceholder();
        }

        final user = userSnapshot.data!;
        final userImageUrl = user.avatar;

        return FutureBuilder<List<Story>>(
          future: getMyStoriesUseCase.call(null),
          builder: (context, storySnapshot) {
            final hasStories = storySnapshot.hasData && storySnapshot.data!.isNotEmpty;

            return GestureDetector(
              onTap: () {
                if (storySnapshot.connectionState != ConnectionState.done) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang tải story...')),
                  );
                  return;
                }

                final stories = storySnapshot.data;

                if (stories == null || stories.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn không có story nào')),
                  );
                  return;
                }

                final storyItems = stories.map((story) {
                  final mediaUrl = story.mediaUrl;
                  if (mediaUrl == null || mediaUrl.isEmpty) {
                    return StoryItem.text(
                      title: 'Không tìm thấy media',
                      backgroundColor: Colors.grey,
                    );
                  }

                  final location = story.location ?? '';

                  if (story.mediaType.toUpperCase() == 'IMAGE') {
                    return StoryItem.pageImage(
                      url: mediaUrl,
                      caption: Text(location),
                      controller: StoryController(),
                    );
                  } else if (story.mediaType.toUpperCase() == 'VIDEO') {
                    return StoryItem.pageVideo(
                      mediaUrl,
                      controller: StoryController(),
                      caption: Text(location),
                    );
                  } else {
                    return StoryItem.text(
                      title: 'Unsupported Media',
                      backgroundColor: Colors.red,
                    );
                  }
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      body: StoryView(
                        storyItems: storyItems,
                        controller: StoryController(),
                        onComplete: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: 115,
                height: 190,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: hasStories ? Colors.pink[300] : Colors.grey[300],
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hasStories ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: userImageUrl != null
                            ? NetworkImage(userImageUrl)
                            : null,
                        child: userImageUrl == null
                            ? const Icon(Icons.person, size: 28, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "My Story",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: 110,
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 110,
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: const Center(child: Icon(Icons.error)),
    );
  }
}
