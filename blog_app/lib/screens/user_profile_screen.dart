import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/user-profile';
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  var _init = true;
  File _image;
  var _isSubmitting = false;
  var _form = GlobalKey<FormState>();
  final _userNameTextController = TextEditingController();
  final _fullNameTextController = TextEditingController();
  final _emailTextController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_init) {
      final authData = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<UserProvider>(context, listen: false)
          .getMe(authData.token)
          .then((_) {
        final userData = Provider.of<UserProvider>(context, listen: false);
        _userNameTextController.text = userData.username;
        _fullNameTextController.text = userData.fullName;
        _emailTextController.text =
            userData.email != null ? userData.email : "";
      });
    }
    _init = false;
    super.didChangeDependencies();
  }

  Future<void> getImage({ImageSource source = ImageSource.camera}) async {
    var image = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = image;
    });
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

  void _onSave(
      String token, String username, String fullName, String email) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_image != null) {
        await Provider.of<UserProvider>(context, listen: false)
            .updateProfilePhoto(token, image: _image);
      }
      await Provider.of<UserProvider>(context, listen: false)
          .updateUserInfo(token, username, fullName, email);
      setState(() {
        _isSubmitting = false;
      });
    } catch (error) {
      _renderErrorDialog(error.toString());
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _renderImage(String imagePath, {bool isRounded = true}) {
    var borderWidth = isRounded ? 100.0 : 0.0;
    return _image == null
        ? (imagePath == null
            ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderWidth)),
                child: Image.asset(
                  "assets/images/login_avatar.png",
                  fit: BoxFit.cover,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderWidth)),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                )))
        : ClipRRect(
            child: Image.file(_image),
            borderRadius: BorderRadius.all(Radius.circular(borderWidth)),
          );
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context);
    final userData = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey,
                  child: _renderImage(userData.imagePath, isRounded: false),
                ),
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.black.withOpacity(0.6),
                ),
                Positioned(
                  bottom: 20,
                  left: 120,
                  child: InkWell(
                    onTap: _showPickImageDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.teal,
                          width: 5,
                        ),
                      ),
                      width: 150,
                      height: 150,
                      child: _renderImage(userData.imagePath),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _userNameTextController,
                      decoration: InputDecoration(
                        labelText: "Username",
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Username Cannot Be Empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _fullNameTextController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Full Name Cannot Be Empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailTextController,
                      decoration:
                          InputDecoration(labelText: "Email (Optional)"),
                    ),
                  ],
                ),
              ),
            ),
            _isSubmitting
                ? CircularProgressIndicator()
                : RaisedButton(
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      var email;
                      if (_emailTextController.text.isNotEmpty) {
                        email = _emailTextController.text;
                      }
                      _onSave(
                        authData.token,
                        _userNameTextController.text,
                        _fullNameTextController.text,
                        email,
                      );
                    },
                    color: Theme.of(context).accentColor,
                  ),
          ],
        ),
      ),
    );
  }
}
