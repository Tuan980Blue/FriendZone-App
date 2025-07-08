import 'package:flutter/material.dart';
import '../../data/models/hightlight_model.dart';
import 'generic_story_view_screen.dart';

class HighlightViewerScreen extends StatelessWidget {
  final HighlightModel highlight;

  const HighlightViewerScreen({super.key, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final stories = highlight.stories;

    return GenericStoryViewScreen(
      stories: stories,
      isMyStory: true,
    );
  }
}
