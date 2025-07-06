import 'package:flutter/material.dart';
import 'package:friendzoneapp/presentation/widgets/story/create_story.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/posts/get_posts_usecase.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post.dart';
import '../widgets/story/story_card.dart';

class PostsPage extends StatefulWidget {
  final GetPostsUseCase getPostsUseCase;

  const PostsPage({
    super.key,
    required this.getPostsUseCase,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final ScrollController _scrollController = ScrollController();
  List<Post> posts = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  String error = '';

  // Sample stories data - replace with your actual data source
  final List<Map<String, dynamic>> stories = [
    {
      'userImageUrl': 'https://example.com/avatar1.jpg',
      'userName': 'User 1',
    },
    {
      'userImageUrl': 'https://example.com/avatar2.jpg',
      'userName': 'User 2',
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        fetchPosts();
      }
    }
  }

  Future<void> fetchPosts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final newPosts = await widget.getPostsUseCase(currentPage, 9);

      if (!mounted) return;

      setState(() {
        posts.addAll(newPosts);
        currentPage++;
        hasMore = newPosts.isNotEmpty;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _refreshPosts() {
    setState(() {
      posts.clear();
      currentPage = 1;
      hasMore = true;
    });
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshPosts();
        },
        child: posts.isEmpty && !isLoading
            ? Center(
          child: error.isNotEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshPosts,
                child: const Text('Retry'),
              ),
            ],
          )
              : const CircularProgressIndicator(),
        ) : CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Create Post Entry
            const SliverToBoxAdapter(
              child: CreatePostEntry(),
            ),

            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: CreateStoryEntry(
                              text: 'Your Story',
                            ),
                          );
                        }
                        final story = stories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: StoryCard(
                            userImageUrl: story['userImageUrl'],
                            userName: story['userName'], storyItems: const [], storyImageUrl: '',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Posts List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index == posts.length && hasMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return PostCard(post: posts[index]);
                },
                childCount: posts.length + (hasMore ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}