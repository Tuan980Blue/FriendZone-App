import 'package:flutter/material.dart';
import 'package:friendzoneapp/presentation/screens/posts_page.dart';
import 'package:friendzoneapp/presentation/screens/profile_screen.dart';
import 'package:friendzoneapp/presentation/screens/user_suggestions_page.dart';
import 'package:friendzoneapp/presentation/widgets/bottom_nav_bar.dart';
import 'package:friendzoneapp/presentation/widgets/app_bar.dart';
import '../../di/injection_container.dart';
import '../../domain/usecases/posts/get_posts_usecase.dart';
import '../../domain/usecases/users/get_user_suggestions_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GetPostsUseCase _getPostsUseCase = sl<GetPostsUseCase>();
  final GetUserSuggestionsUseCase _getUserSuggestionsUseCase = sl<GetUserSuggestionsUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
  final LogoutUseCase _logoutUseCase = sl<LogoutUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PostsPage(getPostsUseCase: _getPostsUseCase),
      UserSuggestionsPage(getUserSuggestionsUseCase: _getUserSuggestionsUseCase),
      ProfileScreen(
        getCurrentUserUseCase: _getCurrentUserUseCase,
        logoutUseCase: _logoutUseCase,
        getUserByIdUseCase: _getUserByIdUseCase,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? const CustomAppBar() : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
} 