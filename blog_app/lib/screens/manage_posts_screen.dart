import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart' show PostsProvider;

import '../widgets/app_drawer.dart';
import '../screens/edit_post_screen.dart';
import '../widgets/add_post_floating_button.dart';

class ManagePostsScreen extends StatefulWidget {
  static const routeName = '/manage-posts';

  @override
  _ManagePostsScreenState createState() => _ManagePostsScreenState();
}

class _ManagePostsScreenState extends State<ManagePostsScreen> {
  var _loadMoreSize = 20;
  var _isLoading = false;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<PostsProvider>(context, listen: false)
        .fetchMyPostsAndSave()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  void _renderErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("An Error Occured!"),
        content: Text(
          message,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Okay",
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Provider.of<PostsProvider>(context, listen: false)
        .fetchMyPostsAndSave();
  }

  Future<bool> _onConfirmDismissPost(DismissDirection direction) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Are You Sure?",
        ),
        content: Text(
            "Do You Really Want To Delete This Post? Action Can't Be Undone."),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Yes",
            ),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
          ),
          FlatButton(
            child: Text(
              "No",
            ),
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Posts",
        ),
      ),
      floatingActionButton: AddPostFloatingButton(),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: const EdgeInsets.all(
                  8.0,
                ),
                child: Consumer<PostsProvider>(
                  builder: (ctx, postData, child) =>
                      NotificationListener<ScrollNotification>(
                    child: ListView.builder(
                      itemCount: postData.posts.length,
                      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                        value: postData.posts[index],
                        child: Dismissible(
                          key: ValueKey(postData.posts[index].id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            child: Icon(
                              Icons.delete,
                              size: 40,
                              color: Colors.white,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: 10,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                          ),
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              try {
                                await Provider.of<PostsProvider>(context,
                                        listen: false)
                                    .removePost(
                                  postData.posts[index].id,
                                );
                              } catch (error) {
                                _renderErrorDialog(error.toString());
                              }
                            }
                          },
                          confirmDismiss: _onConfirmDismissPost,
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  child: FadeInImage.assetNetwork(
                                    placeholder:
                                        "assets/images/placeholder.png",
                                    image: postData.posts[index].imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    EditPostScreen.routeName,
                                    arguments: postData.posts[index].id,
                                  );
                                },
                              ),
                              title: Text(
                                postData.posts[index].title,
                              ),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Published: ${postData.posts[index].published}",
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                        ),
                      ),
                    ),
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        if (_loadMoreSize < postData.totalPosts) {
                          setState(() {
                            _loadMoreSize += 10;
                          });
                          Provider.of<PostsProvider>(context, listen: false)
                              .fetchMyPostsAndSave(
                            size: _loadMoreSize,
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
        onRefresh: _onRefresh,
      ),
    );
  }
}
