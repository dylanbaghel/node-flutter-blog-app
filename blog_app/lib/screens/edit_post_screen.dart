import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/posts_provider.dart';

import '../widgets/app_drawer.dart';
import './timeline_screen.dart';
import '../widgets/pick_image_container.dart';
import './manage_posts_screen.dart';

class EditPostScreen extends StatefulWidget {
  static const routeName = '/edit-post';
  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  var _init = true;
  final _form = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {'title': '', 'body': '', 'published': true};
  File _image;
  var _isPickImageError = false;
  var _isSubmitting = false;
  String _imageUrl;
  Post _editedPost;

  @override
  void didChangeDependencies() {
    final postId = ModalRoute.of(context).settings.arguments as String;
    if (_init) {
      if (postId != null) {
        _editedPost =
            Provider.of<PostsProvider>(context, listen: false).findById(postId);
        _formData = {
          'title': _editedPost.title,
          'body': _editedPost.body,
          'published': _editedPost.published,
        };
        _imageUrl = _editedPost.imageUrl;
      }
    }
    _init = false;
    super.didChangeDependencies();
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

  Future<void> getImage({ImageSource source = ImageSource.camera}) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = image;
    });
  }

  void _showPickImageDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              "Choose Image",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  child: Text("Camera"),
                  onPressed: () {
                    getImage(source: ImageSource.camera);
                    Navigator.of(ctx).pop();
                  },
                ),
                FlatButton(
                  child: Text("Gallery"),
                  onPressed: () {
                    getImage(source: ImageSource.gallery);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _onSubmit() async {
    _form.currentState.save();
    if (_form.currentState.validate()) {
      if (_image == null && _imageUrl == null) {
        setState(() {
          _isPickImageError = true;
        });
        return;
      }
      setState(() {
        _isPickImageError = false;
        _isSubmitting = true;
      });

      try {
        if (_editedPost == null) {
          await Provider.of<PostsProvider>(context, listen: false).addPost(
              _formData['title'],
              _formData['body'],
              _formData['published'],
              _image);
          Navigator.of(context).pushReplacementNamed(TimelineScreen.routeName);
        } else {
          await Provider.of<PostsProvider>(context, listen: false).updatePost(
            _editedPost.id,
            _formData['title'],
            _formData['body'],
            _formData['published'],
            image: _image,
          );
          Navigator.of(context)
              .pushReplacementNamed(ManagePostsScreen.routeName);
        }
      } on HttpException catch (error) {
        _renderErrorDialog(error.toString());
      } catch (error) {
        print(error.toString());
        _renderErrorDialog(error.toString());
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Post",
        ),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  initialValue: _formData['title'],
                  decoration: InputDecoration(
                    labelText: "Title",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please Enter Title";
                    }
                    if (value.length < 6) {
                      return "Title is Too Short";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _formData['title'] = value;
                  },
                ),
                TextFormField(
                  initialValue: _formData['body'],
                  decoration: InputDecoration(labelText: "Body"),
                  maxLines: 4,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please Enter Body";
                    }
                    if (value.length < 20) {
                      return "Post Body is Too Short";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _formData['body'] = value;
                  },
                ),
                Row(
                  children: <Widget>[
                    Switch(
                      value: _formData['published'],
                      onChanged: (value) {
                        setState(() {
                          _formData['published'] = value;
                        });
                      },
                    ),
                    Text(_formData['published'] ? "Published" : "Draft"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // InkWell(
                    //   onTap: _showPickImageDialog,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(
                    //         color: Colors.black87,
                    //         width: 2,
                    //       )
                    //     ),
                    //     width: 150,
                    //     height: 150,
                    //     child: _image == null ? Center(child: Text("Add a Image",),) : Image.file(_image),
                    //   ),
                    // ),
                    PickImageContainer(
                      onTap: _showPickImageDialog,
                      image: _image,
                      imageUrl: _imageUrl,
                    ),
                  ],
                ),
                if (_isPickImageError)
                  SizedBox(
                    height: 20,
                  ),
                if (_isPickImageError)
                  Container(
                      width: double.infinity,
                      child: Text(
                        "Please Choose Image",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).errorColor,
                        ),
                      )),
                SizedBox(
                  height: 30,
                ),
                _isSubmitting
                    ? Container(
                        child: CircularProgressIndicator(),
                        alignment: Alignment.center,
                      )
                    : Container(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text("Submit"),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: _onSubmit,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
