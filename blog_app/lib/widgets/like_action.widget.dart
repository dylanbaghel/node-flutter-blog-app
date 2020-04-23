import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart' show Post;
import '../providers/auth_provider.dart' show AuthProvider;

class LikeActionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final post = Provider.of<Post>(context);
    final authData = Provider.of<AuthProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (authData.isAuth && authData.userId != post.creator.id)
          IconButton(
            icon: Icon(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () async {
              try {
                await Provider.of<Post>(context, listen: false)
                    .toggleLike(authData.token, authData.userId);
              } catch (error) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    error.toString(),
                  ),
                  duration: Duration(seconds: 5),
                ));
              }
            },
          ),
        Text(
          "Likes: ${post.likes.length}",
        ),
      ],
    );
  }
}
