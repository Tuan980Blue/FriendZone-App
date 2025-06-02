import 'package:flutter/material.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../../domain/usecases/users/get_user_suggestions_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../widgets/user_card.dart';
import 'profile_screen.dart';
import '../../di/injection_container.dart';

class UserSuggestionsPage extends StatefulWidget {
  final GetUserSuggestionsUseCase getUserSuggestionsUseCase;

  const UserSuggestionsPage({
    super.key,
    required this.getUserSuggestionsUseCase,
  });

  @override
  State<UserSuggestionsPage> createState() => _UserSuggestionsPageState();
}

class _UserSuggestionsPageState extends State<UserSuggestionsPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  String error = '';
  final ScrollController _scrollController = ScrollController();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
  final LogoutUseCase _logoutUseCase = sl<LogoutUseCase>();
  final UpdateProfileUseCase _updateProfileUseCase = sl<UpdateProfileUseCase>();

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
      final suggestions = await widget.getUserSuggestionsUseCase();
      
      if (!mounted) return;

      setState(() {
        users = suggestions;
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

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          getCurrentUserUseCase: _getCurrentUserUseCase,
          logoutUseCase: _logoutUseCase,
          getUserByIdUseCase: _getUserByIdUseCase,
          updateProfileUseCase: _updateProfileUseCase,
          userId: userId,
        ),
      ),
    );
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
                      return GestureDetector(
                        onTap: () => _navigateToUserProfile(user['id']),
                        child: UserCard(
                          user: user,
                          onFollowPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Follow functionality coming soon!'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 