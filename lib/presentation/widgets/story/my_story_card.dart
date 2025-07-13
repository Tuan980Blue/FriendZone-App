import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import '../../../di/injection_container.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/storys/get_my_stories_usecase.dart';
import '../../../domain/entities/story.dart';
import '../../screens/generic_story_view_screen.dart';

class MyStoryCard extends StatefulWidget {
  const MyStoryCard({super.key});

  @override
  State<MyStoryCard> createState() => _MyStoryCardState();
}

class _MyStoryCardState extends State<MyStoryCard> {
  late Future<User> _userFuture;
  late Future<List<Story>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = sl<GetCurrentUserUseCase>().call();
    _storiesFuture = sl<GetMyStoriesUseCase>().call(null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState != ConnectionState.done) {
          return _buildLoadingPlaceholder();
        }

        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return _buildErrorPlaceholder();
        }

        final user = userSnapshot.data!;
        final userImageUrl = user.avatar;

        return FutureBuilder<List<Story>>(
          future: _storiesFuture,
          builder: (context, storySnapshot) {
            final isDone = storySnapshot.connectionState == ConnectionState.done;
            final hasStories = isDone && storySnapshot.hasData && storySnapshot.data!.isNotEmpty;

            return GestureDetector(
              onTap: () {
                final stories = storySnapshot.data;

                if (!isDone) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang tải story...')),
                  );
                  return;
                }

                if (stories == null || stories.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn không có story nào')),
                  );
                  return;
                }

                final storyItems = stories.map((story) {
                  final mediaUrl = story.mediaUrl;
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
                    builder: (_) => GenericStoryViewScreen(
                      stories: stories,
                      isMyStory: true,
                      onDeleted: (deletedStoryId) {
                        setState(() {
                          _storiesFuture = _storiesFuture.then(
                                (stories) => stories.where((story) => story.id != deletedStoryId).toList(),
                          );
                        });
                      },

                    ),
                  ),
                );
              },
              child: Container(
                width: 115,
                height: 190,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: hasStories ? Colors.pink[100] : Colors.grey[300],
                  border: Border.all(
                    color: hasStories ? Colors.blue : Colors.grey[400]!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
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
                        color: Colors.black87,
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
