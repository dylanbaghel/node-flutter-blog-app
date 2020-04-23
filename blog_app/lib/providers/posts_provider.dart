import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/url.dart' show BASE_URL;
import '../utils/http_exception.dart' show HttpException;

class Post with ChangeNotifier {
  String id;
  String title;
  String body;
  bool published;
  DateTime createdAt;
  User creator;
  bool isLiked;
  String imageUrl;
  List<dynamic> likes;

  Post({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.published,
    @required this.createdAt,
    @required this.creator,
    @required this.imageUrl,
    @required this.likes,
    this.isLiked = false,
  });

  Future<void> toggleLike(String token, String userId) async {
    var oldStatus = this.isLiked;
    this.isLiked = !this.isLiked;

    if (oldStatus) {
      this.likes.removeWhere((like) => like == userId);
    } else {
      this.likes.add(userId);
    }

    notifyListeners();

    final url = "$BASE_URL/posts/${this.id}/like";

    try {
      final response = await http.put(url, headers: {
        'Authorization': 'Bearer $token',
      });
      final responseData = json.decode(response.body);
      if (responseData['statusCode'] != 200) {
        throw HttpException("Unable To Like The Post, Please Try Again!");
      }
    } catch (error) {
      this.isLiked = oldStatus;
      notifyListeners();
      throw error;
    }
  }
}

class PostsProvider with ChangeNotifier {
  List<Post> _posts = [];
  int _totalPosts = 0;
  List<Post> _myPosts = [];

  /// Input */
  String token;
  String userId;

  PostsProvider(this.token, this.userId, this._posts);

  List<Post> get posts {
    return _posts;
  }

  int get totalPosts {
    return _totalPosts;
  }

  Future<void> fetchPostsAndSave({int size = 20}) async {
    final url = "$BASE_URL/posts?size=$size";
    final response = await http.get(url);
    final responseData = json.decode(response.body);

    print(userId);

    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }
    final posts = responseData['data'] as List<dynamic>;
    List<Post> data = [];
    posts.forEach((post) {
      data.add(
        Post(
          id: post['_id'],
          title: post['title'],
          body: post['body'],
          published: post['published'],
          createdAt: DateTime.parse(post['createdAt']),
          imageUrl: post['image']['imagePath'],
          likes: post['likes'],
          isLiked:
              (post['likes'] as List<dynamic>).any((like) => like == userId),
          creator: User(
            role: post['_creator']['role'],
            id: post['_creator']['_id'],
            fullName: post['_creator']['fullName'],
            username: post['_creator']['username'],
            cratedAt: DateTime.parse(post['_creator']['createdAt']),
          ),
        ),
      );
    });
    _totalPosts = responseData['pagination']['totalDocuments'];
    _posts = data;
    print(_posts[0].isLiked);
    notifyListeners();
  }

  Future<void> addPost(
      String title, String body, bool published, File image) async {
    const url = "$BASE_URL/posts";
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..fields['title'] = title
      ..fields['body'] = body
      ..fields['published'] = published.toString()
      ..files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['image'] = Uri.encodeComponent(image.path);
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);
    final responseData = json.decode(response.body);

    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }

    print(responseData);
  }

  Future<void> fetchMyPostsAndSave({int size = 10}) async {
    final url = "$BASE_URL/posts/my?size=$size";
    final response =
        await http.get(url, headers: {'Authorization': "Bearer $token"});
    final responseData = json.decode(response.body);

    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }

    final posts = responseData['data'] as List<dynamic>;
    List<Post> data = [];
    posts.forEach((post) {
      data.add(
        Post(
          id: post['_id'],
          title: post['title'],
          body: post['body'],
          published: post['published'],
          createdAt: DateTime.parse(post['createdAt']),
          imageUrl: post['image']['imagePath'],
          likes: post['likes'],
          isLiked:
              (post['likes'] as List<dynamic>).any((like) => like == userId),
          creator: User(
            role: post['_creator']['role'],
            id: post['_creator']['_id'],
            fullName: post['_creator']['fullName'],
            username: post['_creator']['username'],
            cratedAt: DateTime.parse(post['_creator']['createdAt']),
          ),
        ),
      );
    });
    _totalPosts = responseData['pagination']['totalDocuments'];
    _posts = data;
    notifyListeners();
  }

  Future<void> updatePost(String id, String title, String body, bool published,
      {File image}) async {
    print(image);
    final url = "$BASE_URL/posts/$id";
    final request = http.MultipartRequest('PATCH', Uri.parse(url))
      ..headers.addAll({'Authorization': 'Bearer $token'})
      ..fields['title'] = title
      ..fields['body'] = body
      ..fields['published'] = published.toString();
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['image'] = Uri.encodeComponent(image.path);
    }
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);
    final responseData = json.decode(response.body);
    if (responseData['statusCode'] != 200) {
      throw new HttpException(responseData['message']);
    }
  }

  Future<void> removePost(String id) async {
    final url = "$BASE_URL/posts/$id";
    final existingPostIndex = _posts.indexWhere((post) => post.id == id);
    Post existingPost = _posts[existingPostIndex];
    _posts.removeAt(existingPostIndex);
    notifyListeners();

    try {
      final response = await http.delete(url, headers: {
        'Authorization': 'Bearer $token',
      });
      final responseData = json.decode(response.body);

      if (responseData['statusCode'] != 200) {
        throw new HttpException(responseData["message"]);
      }
      existingPost = null;
    } catch (error) {
      _posts.insert(existingPostIndex, existingPost);
      notifyListeners();
      throw error;
    }
  }

  Post findById(String id) {
    return _posts.firstWhere((post) => post.id == id);
  }
}
