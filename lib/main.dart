 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'di/injection_container.dart' as di;
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/following/following_bloc.dart';
import 'presentation/blocs/followers/followers_bloc.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>(
          create: (context) => di.sl<ChatBloc>(),
        ),
        BlocProvider<FollowingBloc>(
          create: (context) => di.sl<FollowingBloc>(),
        ),
        BlocProvider<FollowersBloc>(
          create: (context) => di.sl<FollowersBloc>(),
        )
      ],
      child: MaterialApp(
        title: 'FriendZone',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
