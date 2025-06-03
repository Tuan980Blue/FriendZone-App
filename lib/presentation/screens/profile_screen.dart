import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import 'login_screen.dart';
import '../../di/injection_container.dart';
import '../../domain/usecases/auth/google_sign_in_usecase.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats.dart';
import '../widgets/profile/profile_personal_info.dart';
import '../widgets/profile/profile_contact_info.dart';
import '../widgets/profile/profile_account_info.dart';
import '../widgets/profile/profile_edit_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final String? userId; // null means current user's profile

  const ProfileScreen({
    super.key,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.getUserByIdUseCase,
    required this.updateProfileUseCase,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  User? _currentUser;
  bool _isLoading = true;
  String _error = '';
  final LoginUseCase _loginUseCase = sl<LoginUseCase>();

  // Kiểm tra xem đang xem profile của chính mình hay không
  bool get isViewingOwnProfile {
    if (_currentUser == null || _user == null) return false;
    return _currentUser!.id == _user!.id;
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Luôn lấy thông tin user hiện tại trước
      _currentUser = await widget.getCurrentUserUseCase();

      // Sau đó mới lấy thông tin profile cần xem
      if (widget.userId == null || widget.userId == _currentUser!.id) {
        // Nếu là profile của chính mình
        _user = _currentUser;
      } else {
        // Nếu là profile của người khác
        _user = await widget.getUserByIdUseCase(widget.userId!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    if (!isViewingOwnProfile) return; // Chỉ cho phép logout từ profile của chính mình
    
    try {
      await widget.logoutUseCase();
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            loginUseCase: sl<LoginUseCase>(),
            googleSignInUseCase: sl<GoogleSignInUseCase>(),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (!isViewingOwnProfile || _user == null) return;

    await showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        user: _user!,
        updateProfileUseCase: widget.updateProfileUseCase,
        onProfileUpdated: (updatedUser) {
          setState(() {
            _user = updatedUser;
            _currentUser = updatedUser;
          });
        },
      ),
    );
  }

  void _handleFollow() {
    // TODO: Implement follow/unfollow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Follow functionality coming soon!'),
      ),
    );
  }

  void _handleMessage() {
    // TODO: Implement message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message functionality coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isViewingOwnProfile ? 'My Profile' : 'Profile'),
        actions: [
          if (isViewingOwnProfile)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _user == null
                  ? const Center(child: Text('User not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          ProfileHeader(
                            user: _user!,
                            isViewingOwnProfile: isViewingOwnProfile,
                            onEditProfile: _showEditProfileDialog,
                            onFollow: _handleFollow,
                            onMessage: _handleMessage,
                          ),
                          const SizedBox(height: 24),

                          // Stats
                          ProfileStats(
                            postsCount: _user!.postsCount ?? 0,
                            followersCount: _user!.followersCount ?? 0,
                            followingCount: _user!.followingCount ?? 0,
                          ),
                          const SizedBox(height: 24),

                          // Bio
                          if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                            Text(
                              'Bio',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(_user!.bio!),
                            const SizedBox(height: 24),
                          ],

                          // Personal Information
                          ProfilePersonalInfo(user: _user!),
                          const SizedBox(height: 16),

                          // Contact Information
                          ProfileContactInfo(
                            user: _user!,
                            isViewingOwnProfile: isViewingOwnProfile,
                          ),
                          const SizedBox(height: 16),

                          // Account Information
                          if (isViewingOwnProfile)
                            ProfileAccountInfo(user: _user!),
                        ],
                      ),
                    ),
    );
  }
} 