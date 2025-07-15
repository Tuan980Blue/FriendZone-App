import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../domain/usecases/users/get_following_users_usecase.dart';
import '../../domain/entities/following_user.dart';
import '../../di/injection_container.dart';
import 'chat_direct_messages_screen.dart';
import '../theme/app_page_transitions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/search/search_event.dart';
import '../blocs/search/search_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(apiClient: sl<ApiClient>()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Tin nhắn mới',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh tìm kiếm
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm người dùng',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchBloc>().add(ClearSearch());
                                setState(() => _isSearching = false);
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        context.read<SearchBloc>().add(SearchUsers(value));
                        setState(() => _isSearching = true);
                      } else {
                        context.read<SearchBloc>().add(ClearSearch());
                        setState(() => _isSearching = false);
                      }
                    },
                  ),
                ),
                // 2 lựa chọn đầu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.groups, color: Colors.black54, size: 26),
                        ),
                        title: const Text('Tạo nhóm chat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.smart_toy_outlined, color: Colors.black54, size: 26),
                        ),
                        title: const Text('Đoạn chat với AI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('MỚI', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                          ],
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Text(
                    'Gợi ý',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.blueAccent),
                  ),
                ),
                // Kết quả search hoặc danh sách gợi ý
                Expanded(
                  child: _isSearching
                      ? BlocBuilder<SearchBloc, SearchState>(
                          builder: (context, state) {
                            if (state is SearchLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is SearchLoaded) {
                              if (state.users.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Không tìm thấy người dùng nào',
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                                  ),
                                );
                              }
                              return ListView.separated(
                                itemCount: state.users.length,
                                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100, indent: 72),
                                itemBuilder: (context, index) {
                                  final user = state.users[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: user.avatar != null && user.avatar.isNotEmpty ? CachedNetworkImageProvider(user.avatar) : null,
                                      backgroundColor: Colors.blue.shade100,
                                      child: (user.avatar == null || user.avatar.isEmpty)
                                          ? Icon(Icons.person, color: Colors.blue.shade600)
                                          : null,
                                      radius: 26,
                                    ),
                                    title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('@${user.username}', style: TextStyle(color: Colors.grey.shade600)),
                                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        AppPageTransitions.chatTransition(
                                          DirectChatMessagesScreen(
                                            userId: user.id,
                                            userName: user.fullName,
                                            userAvatar: user.avatar,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            } else if (state is SearchError) {
                              return Center(
                                child: Text(
                                  state.message,
                                  style: TextStyle(color: Colors.red, fontSize: 16),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      : FutureBuilder<List<FollowingUser>>(
                          future: sl<GetFollowingUsersUseCase>()(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Lỗi khi tải danh sách: \n${snapshot.error.toString()}'),
                              );
                            }
                            final users = snapshot.data ?? [];
                            if (users.isEmpty) {
                              return Center(
                                child: Text(
                                  'Bạn chưa theo dõi ai để gợi ý nhắn tin.',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: users.length,
                              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100, indent: 72),
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                                    backgroundColor: Colors.blue.shade100,
                                    child: user.avatar == null
                                        ? Icon(Icons.person, color: Colors.blue.shade600)
                                        : null,
                                    radius: 26,
                                  ),
                                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('@${user.username}', style: TextStyle(color: Colors.grey.shade600)),
                                  trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      AppPageTransitions.chatTransition(
                                        DirectChatMessagesScreen(
                                          userId: user.id,
                                          userName: user.fullName,
                                          userAvatar: user.avatar,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 