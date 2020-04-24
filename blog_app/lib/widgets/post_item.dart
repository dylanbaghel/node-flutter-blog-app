import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart' show Post;

import '../screens/post_detail_screen.dart';

class PostItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final post = Provider.of<Post>(context);
    final authData = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            PostDetailScreen.routeName,
            arguments: post.id,
          );
        },
        child: Card(
          elevation: 10,
          child: Column(
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: "assets/images/placeholder.png",
                image: post.imageUrl,
                fit: BoxFit.cover,
                height: 300,
                width: double.infinity,
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      softWrap: true,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (authData.isAuth &&
                            authData.userId != post.creator.id)
                          IconButton(
                            icon: Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () async {
                              try {
                                await Provider.of<Post>(context, listen: false)
                                    .toggleLike(
                                        authData.token, authData.userId);
                              } catch (error) {
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error.toString(),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        if (!authData.isAuth) Text("Please Login To Like"),
                        if (authData.userId == post.creator.id) Text("My Post"),
                        Text(
                          "Likes: ${post.likes.length}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
