import 'package:flutter/material.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../../domain/usecases/users/follow_user_usecase.dart';
import '../../domain/usecases/users/get_user_suggestions_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/users/unfollow_user_usecase.dart';
import 'profile_screen.dart';
import '../../di/injection_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../widgets/common/custom_snackbar.dart';

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
  final FollowUserUseCase _followUserUseCase = sl<FollowUserUseCase>();
  final UnfollowUserUseCase _unfollowUserUseCase = sl<UnfollowUserUseCase>();

  // Thêm Map để theo dõi trạng thái loading của từng userId
  final Map<String, bool> _isButtonLoading = {};

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
        error = 'Lỗi: ${e.toString().replaceAll('Exception: ', '')}';
        isLoading = false;
      });
    }
  }

  Future<void> _handleFollow(String userId, bool isFollowing) async {
    if (_isButtonLoading[userId] == true) return; // Ngăn chặn nhấn nhiều lần khi đang loading

    // Đặt trạng thái loading cho userId này
    setState(() {
      _isButtonLoading[userId] = true;
    });

    if (isFollowing) {
      // Lấy thông tin người dùng từ danh sách
      final user = users.firstWhere((u) => u['id'] == userId, orElse: () => null);
      if (user == null) {
        setState(() {
          _isButtonLoading[userId] = false;
        });
        return;
      }
      // Hiển thị dialog xác nhận
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    imageUrl: user['avatar'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bỏ theo dõi?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                '@${user['username'] ?? 'unknown'}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Bỏ theo dõi', style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      if (result != true || !mounted) {
        setState(() {
          _isButtonLoading[userId] = false;
        });
        return; // Thoát nếu không đồng ý hoặc không còn mounted
      }
    }

    try {
      if (isFollowing) {
        await _unfollowUserUseCase(UnfollowUserParams(userId));
      } else {
        await _followUserUseCase(FollowUserParams(userId));
      }

      if (!mounted) return;

      // Cập nhật trạng thái theo dõi trong danh sách
      setState(() {
        final index = users.indexWhere((user) => user['id'] == userId);
        if (index != -1) {
          users[index]['isFollowing'] = !isFollowing;
        }
        _isButtonLoading[userId] = false; // Tắt loading sau khi hoàn tất
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isButtonLoading[userId] = false; // Tắt loading nếu có lỗi
      });
      CustomSnackBar.showError(
        context: context,
        message: 'Không thể ${isFollowing ? 'hủy theo dõi' : 'theo dõi'}. Vui lòng thử lại.',
        onRetry: () => _handleFollow(userId, isFollowing),
      );
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
          followUserUseCase: _followUserUseCase,
          unfollowUserUseCase: _unfollowUserUseCase,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Khám phá mọi người',
          style: TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
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
              child: const Text('Thử lại'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchUsers,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(user['id']),
                    child: Container(
                      width: 50,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: user['avatar'] ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, size: 25),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['fullName'] ?? user['username'] ?? 'unknown',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4), // Khoảng cách trước "Gợi ý theo dõi"
                        Text(
                          'Gợi ý cho bạn',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _handleFollow(user['id'], user['isFollowing'] ?? false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: const Size(100, 0),
                      foregroundColor: _isButtonLoading[user['id']] == true
                          ? Colors.grey
                          : (user['isFollowing'] ?? false ? Colors.pinkAccent : Colors.pinkAccent),
                      side: BorderSide(
                        color: _isButtonLoading[user['id']] == true
                            ? Colors.grey
                            : (user['isFollowing'] ?? false ? Colors.pinkAccent.withOpacity(0.5) : Colors.pinkAccent),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isButtonLoading[user['id']] == true
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      user['isFollowing'] ?? false ? 'Đang theo dõi' : 'Theo dõi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isButtonLoading[user['id']] == true
                            ? Colors.grey
                            : (user['isFollowing'] ?? false ? Colors.pinkAccent.withOpacity(0.7) : Colors.pinkAccent),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}