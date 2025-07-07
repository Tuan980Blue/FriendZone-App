import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:friendzoneapp/presentation/widgets/story/create_story.dart';
import '../../data/models/story_feed.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/posts/get_posts_usecase.dart';
import '../../domain/usecases/storys/get_story_feed_usecase.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post.dart';
import '../widgets/story/my_story_card.dart';
import '../widgets/story/story_card.dart';
import '../../di/injection_container.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';

class PostsPage extends StatefulWidget {
  final GetPostsUseCase getPostsUseCase;
  final GetStoryFeedUseCase getStoryFeedUseCase;

  const PostsPage({
    super.key,
    required this.getPostsUseCase,
    required this.getStoryFeedUseCase,
  });

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final ScrollController _scrollController = ScrollController();
  List<Post> posts = [];
  List<StoryFeedItem> feedStoryList = [];

  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  String error = '';
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchPosts();
    fetchStoryFeed();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchCurrentUser() async {
    final user = await sl<GetCurrentUserUseCase>().call();
    setState(() {
      currentUserId = user?.id ?? '';
    });
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
        error = 'Error: \${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> fetchStoryFeed() async {
    try {
      final stories = await widget.getStoryFeedUseCase(currentUserId);
      setState(() {
        feedStoryList = stories;
      });
    } catch (e, stack) {
      if (kDebugMode) {
        print("Lỗi khi lấy story feed: $e");
      }
      if (kDebugMode) {
        print("Chi tiết lỗi: $stack");
      }
    }
  }

  void _refreshPosts() {
    setState(() {
      posts.clear();
      currentPage = 1;
      hasMore = true;
    });
    fetchPosts();
    fetchStoryFeed();
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
        )
            : CustomScrollView(
          controller: _scrollController,
          slivers: [
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
                      itemCount: feedStoryList.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: MyStoryCard(),
                          );
                        }

                        if (index == 1) {
                          return const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: CreateStoryEntry(text: 'Tạo tin'),
                          );
                        }

                        final item = feedStoryList[index - 2];

                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: StoryCard(
                            userImageUrl: item.author.avatar ?? '',
                            userName: item.author.fullName ?? 'Người dùng',
                            storyItems: [],
                            storyImageUrl: item.stories.isNotEmpty ? item.stories.first.mediaUrl ?? '' : '',
                            stories: item.stories,
                            isMyStory: item.author.id == currentUserId,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

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
