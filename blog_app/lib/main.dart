import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './providers/posts_provider.dart';
import './providers/user_provider.dart';

import './screens/login_screen.dart';
import './screens/timeline_screen.dart';
import './screens/splash_screen.dart';
import './screens/edit_post_screen.dart';
import './screens/manage_posts_screen.dart';
import './screens/post_detail_screen.dart';
import './screens/user_profile_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PostsProvider>(
          update: (_, authData, postData) => PostsProvider(authData.token,
              authData.userId, postData == null ? [] : postData.posts),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (_, authData, child) {
          // authData.autoLogin();
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.teal,
              accentColor: Colors.deepOrange,
              textTheme: ThemeData.light().textTheme.copyWith(),
            ),
            home: authData.isAuth
                ? TimelineScreen()
                : FutureBuilder(
                    future: authData.autoLogin(),
                    builder: (ctx, snapshot) => TimelineScreen()),
            routes: {
              ManagePostsScreen.routeName: (ctx) => ManagePostsScreen(),
              TimelineScreen.routeName: (ctx) => TimelineScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              EditPostScreen.routeName: (ctx) => EditPostScreen(),
              PostDetailScreen.routeName: (ctx) => PostDetailScreen(),
              UserProfileScreen.routeName: (ctx) => UserProfileScreen(),
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        "Blog App!",
      )),
    );
  }
}
