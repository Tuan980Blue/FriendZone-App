import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/posts/get_posts_usecase.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post.dart';

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
      final posts = await widget.getPostsUseCase(currentPage, 9);

      if (!mounted) return;

      setState(() {
        this.posts.addAll(posts);
        currentPage++;
        hasMore = posts.isNotEmpty;
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
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + (hasMore ? 1 : 0) + 1, // +1 for CreatePostWidget
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const CreatePostEntry();
                  }
                  
                  final postIndex = index - 1;
                  if (postIndex == posts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return PostCard(post: posts[postIndex]);
                },
              ),
      ),
    );
  }
} 