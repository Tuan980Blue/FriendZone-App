import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import 'login_screen.dart';
import '../../di/injection_container.dart';

class ProfileScreen extends StatefulWidget {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final String? userId; // null means current user's profile

  const ProfileScreen({
    super.key,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.getUserByIdUseCase,
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
            loginUseCase: _loginUseCase,
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _user?.avatar != null
                                  ? NetworkImage(_user!.avatar!)
                                  : null,
                              child: _user?.avatar == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _user?.username ?? '',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            if (_user?.fullName != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _user!.fullName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                            if (!isViewingOwnProfile && _user != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement follow/unfollow
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Follow functionality coming soon!'),
                                        ),
                                      );
                                    },
                                    child: Text(_user!.isFollowing ? 'Unfollow' : 'Follow'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      // TODO: Implement message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Message functionality coming soon!'),
                                        ),
                                      );
                                    },
                                    child: const Text('Message'),
                                  ),
                                ],
                              ),
                            ],
                            if (isViewingOwnProfile) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Implement edit profile
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Edit profile functionality coming soon!'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Posts', _user?.postsCount ?? 0),
                          _buildStatItem('Followers', _user?.followersCount ?? 0),
                          _buildStatItem('Following', _user?.followingCount ?? 0),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
                        Text(
                          'Bio',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(_user!.bio!),
                        const SizedBox(height: 24),
                      ],

                      // Contact Info
                      if (isViewingOwnProfile || !_user!.isPrivate) // Chỉ hiện thông tin liên hệ cho profile của mình hoặc profile public
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Information',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                if (isViewingOwnProfile || _user!.email != null)
                                  _buildInfoRow(
                                    Icons.email,
                                    'Email',
                                    _user?.email ?? '',
                                  ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.person,
                                  'Username',
                                  _user?.username ?? '',
                                ),
                                if (_user?.location != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.location_on,
                                    'Location',
                                    _user!.location!,
                                  ),
                                ],
                                if (_user?.website != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    Icons.link,
                                    'Website',
                                    _user!.website!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
} 