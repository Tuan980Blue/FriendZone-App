import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../data/datasources/remote/auth_remote_data_source.dart';
import '../data/datasources/remote/post_remote_data_source.dart';
import '../data/datasources/remote/story_remote_data_source.dart';
import '../data/datasources/remote/user_remote_data_source.dart';
import '../data/datasources/remote/notification_remote_data_source.dart';
import '../data/datasources/remote/chat_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/post_repository_impl.dart';
import '../data/repositories/story_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/post_repository.dart';
import '../domain/repositories/story_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/notification/get_unread_notifications_count_usecase.dart';
import '../domain/usecases/notification/mark_notification_as_read_usecase.dart';
import '../domain/usecases/notification/mark_all_notifications_as_read_usecase.dart';
import '../domain/usecases/notifications/get_notifications_usecase.dart';
import '../domain/usecases/posts/get_posts_usecase.dart';
import '../domain/usecases/posts/create_post_usecase.dart';
import '../domain/usecases/posts/upload_image_usecase.dart';
import '../domain/usecases/storys/create_story_usecase.dart';
import '../domain/usecases/storys/get_my_stories_usecase.dart';
import '../domain/usecases/storys/get_story_feed_usecase.dart';
import '../domain/usecases/storys/upload_story_media_usecase.dart';
import '../domain/usecases/users/get_user_suggestions_usecase.dart';
import '../domain/usecases/user/get_user_by_id_usecase.dart';
import '../domain/usecases/chat/get_recent_chats_usecase.dart';
import '../domain/usecases/chat/get_direct_chat_messages_usecase.dart';
import '../presentation/blocs/notification/notification_bloc.dart';
import '../presentation/blocs/chat/chat_bloc.dart';
import '../presentation/blocs/following/following_bloc.dart';
import '../presentation/blocs/followers/followers_bloc.dart';
import '../../domain/usecases/auth/google_sign_in_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../presentation/blocs/search/search_bloc.dart';
import '../domain/usecases/users/follow_user_usecase.dart';
import '../domain/usecases/users/unfollow_user_usecase.dart';
import '../domain/usecases/users/get_following_users_usecase.dart';
import '../domain/usecases/users/get_followers_users_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<StoryRemoteDataSource>(
        () => StoryRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(sl()),
  );

  // Use cases
  // Auth use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase());

  // Post use cases
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => UploadImageUseCase(sl()));

  // User use cases
  sl.registerLazySingleton(() => GetUserSuggestionsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => FollowUserUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowUserUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowingUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetFollowersUsersUseCase(sl()));

  // Notification use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationsCountUseCase(sl()));

  // Chat use cases
  sl.registerLazySingleton(() => GetRecentChatsUseCase(sl()));
  sl.registerLazySingleton(() => GetDirectChatMessagesUseCase(sl()));

  // Story use cases
  sl.registerLazySingleton(() => UploadStoryMediaUseCase(sl()));
  sl.registerLazySingleton(() => CreateStoryUseCase(sl()));
  sl.registerLazySingleton(() => GetStoryFeedUseCase(sl()));
  sl.registerLazySingleton(() => GetMyStoriesUseCase(sl()));


  // BLoCs
  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      markNotificationAsReadUseCase: sl(),
      markAllNotificationsAsReadUseCase: sl(),
      getUnreadCountUseCase: sl(),
    ),
  );
  
  sl.registerFactory(() => SearchBloc(apiClient: sl()));
  
  sl.registerFactory(
    () => ChatBloc(
      getRecentChatsUseCase: sl(),
      getDirectChatMessagesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FollowingBloc(
      getFollowingUsersUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FollowersBloc(
      getFollowersUsersUseCase: sl(),
    ),
  );
} 