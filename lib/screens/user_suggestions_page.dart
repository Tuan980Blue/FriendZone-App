import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';

class UserSuggestionsPage extends StatefulWidget {
  const UserSuggestionsPage({super.key});

  @override
  State<UserSuggestionsPage> createState() => _UserSuggestionsPageState();
}

class _UserSuggestionsPageState extends State<UserSuggestionsPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  String error = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final data = await ApiService.fetchUserSuggestions();
      
      if (!mounted) return;

      if (data['success'] == true) {
        setState(() {
          users = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load suggestions';
          isLoading = false;
        });
      }
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
        title: const Text('User Suggestions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchUsers,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: users.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserCard(
                        user: user,
                        onFollowPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Follow functionality coming soon!'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
} 