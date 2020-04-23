import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../screens/login_screen.dart';
import '../screens/timeline_screen.dart';
import '../screens/manage_posts_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 15,
            ),
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 150,
            color: Theme.of(context).primaryColor,
            child: Text(
              "Blog App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
              ),
            ),
          ),
          if (!authData.isAuth)
            ListTile(
              leading: Icon(
                Icons.person,
              ),
              title: Text(
                "Login",
              ),
              onTap: () {
                // Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                  LoginScreen.routeName,
                );
              },
            ),
          ListTile(
            leading: Icon(
              Icons.pages,
            ),
            title: Text(
              "Timeline",
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(
                TimelineScreen.routeName,
              );
            },
          ),
          if (authData.isAuth)
            ListTile(
              leading: Icon(Icons.work,),
              title: Text("Manage Posts",),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(ManagePostsScreen.routeName,);
              },
            ),
          if (authData.isAuth)
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
        ],
      ),
    );
  }
}
