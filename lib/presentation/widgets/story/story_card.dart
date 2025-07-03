import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryCard extends StatefulWidget {
  final String userImageUrl;
  final String userName;
  final List<StoryItem> storyItems;

  const StoryCard({
    Key? key,
    required this.userImageUrl,
    required this.userName,
    required this.storyItems,
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
            builder: (context) => StoryView(
              storyItems: widget.storyItems,
              controller: storyController,
              inline: false,
              repeat: false,
              onComplete: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink,
                  Colors.purple,
                  Colors.orange,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.userImageUrl),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.userName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}