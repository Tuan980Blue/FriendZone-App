import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../data/datasources/remote/auth_remote_data_source.dart';
import '../data/datasources/remote/post_remote_data_source.dart';
import '../data/datasources/remote/user_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/post_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/post_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/posts/get_posts_usecase.dart';
import '../domain/usecases/posts/create_post_usecase.dart';
import '../domain/usecases/posts/upload_image_usecase.dart';
import '../domain/usecases/users/get_user_suggestions_usecase.dart';
import '../../domain/usecases/user/get_user_by_id_usecase.dart';
import '../data/datasources/remote/notification_remote_data_source.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/usecases/notifications/get_notifications_usecase.dart';
import '../presentation/blocs/notification/notification_bloc.dart';

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

  // Use cases
  // Auth use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Post use cases
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => UploadImageUseCase(sl()));

  // User use cases
  sl.registerLazySingleton(() => GetUserSuggestionsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));

  // Notification use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => NotificationBloc(repository: sl()),
  );
} 