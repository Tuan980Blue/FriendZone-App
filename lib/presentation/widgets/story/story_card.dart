import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import '../../../domain/entities/story.dart';
import '../../screens/generic_story_view_screen.dart';

class StoryCard extends StatefulWidget {
  final String userImageUrl;
  final String userName;
  final List<StoryItem> storyItems;
  final String storyImageUrl;
  final List<Story> stories;
  final bool isMyStory;

  const StoryCard({
    Key? key,
    required this.userImageUrl,
    required this.userName,
    required this.storyItems,
    required this.storyImageUrl,
    required this.stories,
    required this.isMyStory,
  }) : super(key: key);

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GenericStoryViewScreen(
              stories: widget.stories,
              isMyStory: widget.isMyStory,
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
                widget.storyImageUrl,
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

            // User avatar at top left
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
                  backgroundImage: NetworkImage(widget.userImageUrl),
                  child: widget.userImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
              ),
            ),

            // User name at bottom left
            Positioned(
              bottom: 10,
              left: 8,
              right: 8,
              child: Text(
                widget.userName,
                style: const TextStyle(
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
  }
}