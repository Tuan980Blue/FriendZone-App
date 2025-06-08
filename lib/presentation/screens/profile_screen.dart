import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import 'login_screen.dart';
import '../../di/injection_container.dart';
import '../../domain/usecases/auth/google_sign_in_usecase.dart';
import '../widgets/profile/profile_stats.dart';
import '../widgets/profile/profile_personal_info.dart';
import '../widgets/profile/profile_contact_info.dart';
import '../widgets/profile/profile_account_info.dart';
import '../widgets/profile/profile_edit_dialog.dart';
import '../widgets/profile/profile_posts.dart';
import '../theme/app_theme.dart';
import 'change_password_screen.dart';
import '../theme/app_page_transitions.dart';
import '../../domain/usecases/users/follow_user_usecase.dart';
import '../../domain/usecases/users/unfollow_user_usecase.dart';
import '../widgets/common/custom_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;
  final String? userId;

  const ProfileScreen({
    super.key,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    required this.getUserByIdUseCase,
    required this.updateProfileUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  User? _user;
  User? _currentUser;
  bool _isLoading = true;
  String _error = '';
  final LoginUseCase _loginUseCase = sl<LoginUseCase>();
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get isViewingOwnProfile {
    if (_currentUser == null || _user == null) return false;
    return _currentUser!.id == _user!.id;
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    
    _tabController = TabController(
      length: 3, // Always 3 tabs, just different content based on isViewingOwnProfile
      vsync: this,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      _currentUser = await widget.getCurrentUserUseCase();
      if (widget.userId == null || widget.userId == _currentUser!.id) {
        _user = _currentUser;
      } else {
        _user = await widget.getUserByIdUseCase(widget.userId!);
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    if (!isViewingOwnProfile) return;
    
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 40,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng xuất',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: AppTheme.accentPink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) return;

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

  Future<void> _handleFollow() async {
    if (_user == null) return;
    
    try {
      if (_user!.isFollowing) {
        await widget.unfollowUserUseCase(UnfollowUserParams(_user!.id));
      } else {
        await widget.followUserUseCase(FollowUserParams(_user!.id));
      }
      
      // Refresh user profile to get updated following status
      await _loadUserProfile();
      
      if (!mounted) return;
      
      // Show success notification
      CustomSnackBar.showSuccess(
        context: context,
        message: _user!.isFollowing 
          ? 'Bạn đã theo dõi ${_user!.fullName}'
          : 'Bạn đã hủy theo dõi ${_user!.fullName}',
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show error notification
      CustomSnackBar.showError(
        context: context,
        message: 'Không thể ${_user!.isFollowing ? 'hủy theo dõi' : 'theo dõi'} ${_user!.fullName}. Vui lòng thử lại sau.',
        onRetry: _handleFollow,
      );
    }
  }

  void _handleMessage() {
    // TODO: Implement message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message functionality coming soon!'),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Hero(
                tag: 'profile_${_user?.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentPink,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: _user?.avatar != null
                        ? CachedNetworkImage(
                            imageUrl: _user!.avatar!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.person, size: 50),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, size: 50),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user?.fullName ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_user?.username != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '@${_user!.username}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Action Buttons
                    if (isViewingOwnProfile)
                      ElevatedButton.icon(
                        onPressed: _showEditProfileDialog,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Chỉnh sửa hồ sơ'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          backgroundColor: AppTheme.accentPink,
                          foregroundColor: Colors.white,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _handleFollow,
                              icon: Icon(
                                _user!.isFollowing ? Icons.person_remove : Icons.person_add,
                                size: 18,
                              ),
                              label: Text(_user!.isFollowing ? 'Following' : 'Follow'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                backgroundColor: _user!.isFollowing ? Colors.grey[200] : AppTheme.accentPink,
                                foregroundColor: _user!.isFollowing ? Colors.grey[800] : Colors.white,
                                elevation: _user!.isFollowing ? 0 : 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _handleMessage,
                              icon: const Icon(Icons.message, size: 18),
                              label: const Text('Message'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                foregroundColor: AppTheme.accentPink,
                                side: const BorderSide(color: AppTheme.accentPink),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                _user!.bio!,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Stats
          ProfileStats(
            postsCount: _user?.postsCount ?? 0,
            followersCount: _user?.followersCount ?? 0,
            followingCount: _user?.followingCount ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.accentPink,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppTheme.accentPink,
        indicatorWeight: 3,
        tabs: isViewingOwnProfile
            ? const [
                Tab(icon: Icon(Icons.grid_on), text: 'Bài viết'),
                Tab(icon: Icon(Icons.person_outline), text: 'Thông tin'),
                Tab(icon: Icon(Icons.settings_outlined), text: 'Cài đặt'),
              ]
            : const [
                Tab(icon: Icon(Icons.grid_on), text: 'Bài viết'),
                Tab(icon: Icon(Icons.person_outline), text: 'Thông tin'),
                Tab(icon: Icon(Icons.info_outline), text: 'Giới thiệu'),
              ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Posts Tab (Same for both views)
        ProfilePosts(
          userId: _user!.id,
          isViewingOwnProfile: isViewingOwnProfile,
        ),
        
        // Info Tab (Same for both views)
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ProfilePersonalInfo(user: _user!),
              const SizedBox(height: 16),
              ProfileContactInfo(
                user: _user!,
                isViewingOwnProfile: isViewingOwnProfile,
              ),
            ],
          ),
        ),
        
        // Third Tab (Different based on isViewingOwnProfile)
        if (isViewingOwnProfile)
          // Settings Tab for own profile
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileAccountInfo(user: _user!),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.blue),
                  title: const Text('Đổi mật khẩu'),
                  onTap: () {
                    Navigator.of(context).push(
                      AppPageTransitions.slideUp(
                        const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất'),
                  onTap: _handleLogout,
                ),
              ],
            ),
          )
        else
          // About Tab for other profiles
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giới thiệu về ${_user!.fullName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_user?.bio != null && _user!.bio!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      _user!.bio!,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Thông tin cơ bản',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ProfilePersonalInfo(user: _user!),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _user == null
                  ? const Center(child: Text('Không tìm thấy người dùng'))
                  : NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            expandedHeight: 0,
                            floating: true,
                            pinned: true,
                            elevation: 0,
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            systemOverlayStyle: SystemUiOverlayStyle.dark,
                            leading: !isViewingOwnProfile
                                ? IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.arrow_back),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                : null,
                            actions: [
                              if (isViewingOwnProfile)
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.logout),
                                  ),
                                  onPressed: _handleLogout,
                                ),
                            ],
                            title: AnimatedOpacity(
                              opacity: _showAppBarTitle ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                isViewingOwnProfile ? 'Hồ sơ của tôi' : _user?.fullName ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _buildProfileHeader(),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              _buildTabBar(),
                            ),
                            pinned: true,
                          ),
                        ];
                      },
                      body: _buildTabContent(),
                    ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
} 