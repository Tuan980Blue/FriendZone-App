import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

class GenericStoryViewScreen extends StatelessWidget {
  final List<String> mediaUrls;
  final List<String> mediaTypes;

  const GenericStoryViewScreen({
    super.key,
    required this.mediaUrls,
    required this.mediaTypes,
  });

  @override
  Widget build(BuildContext context) {
    final storyController = StoryController();

    final storyItems = List.generate(mediaUrls.length, (index) {
      final type = mediaTypes[index].toUpperCase();
      final url = mediaUrls[index];

      if (type == 'IMAGE') {
        return StoryItem.pageImage(
          url: url,
          controller: storyController,
        );
      } else if (type == 'VIDEO') {
        return StoryItem.pageVideo(
          url,
          controller: storyController,
        );
      } else {
        return StoryItem.text(title: "Unsupported type", backgroundColor: Colors.red);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: StoryView(
        storyItems: storyItems,
        controller: storyController,
        onComplete: () => Navigator.pop(context),
      ),
    );
  }
}
