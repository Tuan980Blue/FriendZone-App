import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

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
      final data = await ApiService.fetchPosts(currentPage, 9);
      final List<dynamic> postsData = data['posts'];
      final pagination = data['pagination'];

      if (!mounted) return;

      setState(() {
        posts.addAll(postsData.map((post) => Post.fromJson(post)));
        currentPage++;
        hasMore = currentPage <= pagination['totalPages'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            posts.clear();
            currentPage = 1;
            hasMore = true;
          });
          await fetchPosts();
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
                            onPressed: () {
                              setState(() {
                                posts.clear();
                                currentPage = 1;
                                hasMore = true;
                              });
                              fetchPosts();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return PostCard(post: posts[index]);
                },
              ),
      ),
    );
  }
} 