import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../screens/edit_post_screen.dart';

class AddPostFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context);
    return authData.isAuth
        ? FloatingActionButton(
            child: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(EditPostScreen.routeName);
            },
          )
        : Container(
            width: 0,
            height: 0,
          );
  }
}
