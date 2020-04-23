import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart' show PostsProvider;
import '../providers/auth_provider.dart';

import '../widgets/like_action.widget.dart';
import '../screens/login_screen.dart';

class PostDetailScreen extends StatelessWidget {
  static const routeName = '/post-detail';
  @override
  Widget build(BuildContext context) {
    var postId = ModalRoute.of(context).settings.arguments as String;
    var post = Provider.of<PostsProvider>(context).findById(postId);
    var authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 300,
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                post.title,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title,
              ),
            ),
            if (!authData.isAuth)
              RaisedButton(
                child: Text(
                  "Login To Like The Post",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(LoginScreen.routeName);
                },
              ),
            ChangeNotifierProvider.value(
                value: post, child: LikeActionWidget()),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              child: Text("Published At: ${post.createdAt}"),
            ),
            Container(
              width: double.infinity,
              height: 200,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.grey,
                width: 1,
              )),
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Text(
                  post.body,
                  // softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
