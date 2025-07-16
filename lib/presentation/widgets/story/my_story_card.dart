import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../di/injection_container.dart';
import '../../../domain/entities/story.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/storys/get_my_stories_usecase.dart';
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
        final userImageUrl = user.avatar ?? '';

        return FutureBuilder<List<Story>>(
          future: _storiesFuture,
          builder: (context, storySnapshot) {
            final isDone = storySnapshot.connectionState == ConnectionState.done;
            final hasStories = isDone && storySnapshot.hasData && storySnapshot.data!.isNotEmpty;
            final stories = storySnapshot.data ?? [];

            final String storyImageUrl = hasStories
                ? stories.first.mediaUrl
                : 'https://via.placeholder.com/150'; // fallback image

            return GestureDetector(
              onTap: () {
                if (!isDone) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang tải story...')),
                  );
                  return;
                }

                if (stories.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bạn không có story nào')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenericStoryViewScreen(
                      stories: stories,
                      isMyStory: true,
                      onDeleted: (deletedStoryId) {
                        setState(() {
                          _storiesFuture = _storiesFuture.then(
                                (stories) => stories.where((s) => s.id != deletedStoryId).toList(),
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
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    // Story image background
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        storyImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.image, size: 40)),
                        ),
                      ),
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Avatar
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: userImageUrl.isNotEmpty ? NetworkImage(userImageUrl) : null,
                          child: userImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 16)
                              : null,
                        ),
                      ),
                    ),

                    // My Story text
                    Positioned(
                      bottom: 10,
                      left: 8,
                      right: 8,
                      child: const Text(
                        "My Story",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
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
      width: 115,
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 115,
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: const Center(child: Icon(Icons.error)),
    );
  }
}
