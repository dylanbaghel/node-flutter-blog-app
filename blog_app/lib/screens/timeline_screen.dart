import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart' show PostsProvider, Post;

import '../widgets/app_drawer.dart';
import '../widgets/post_item.dart';
import '../widgets/add_post_floating_button.dart';

class TimelineScreen extends StatefulWidget {
  static const routeName = '/timeline';

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  var _loadMoreSize = 20;
  var _isLoading = false;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<PostsProvider>(context, listen: false)
        .fetchPostsAndSave()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> _onRefresh() async {
    await Provider.of<PostsProvider>(context, listen: false)
        .fetchPostsAndSave();
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
                child: Consumer<PostsProvider>(
                  builder: (ctx, postData, child) =>
                      NotificationListener<ScrollNotification>(
                    child: ListView.builder(
                      itemCount: postData.posts.length,
                      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                        value: postData.posts[index],
                        child: PostItem(),
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
                              .fetchPostsAndSave(
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
