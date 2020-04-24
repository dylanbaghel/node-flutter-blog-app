import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../utils/http_exception.dart';

import '../widgets/app_drawer.dart';

enum AuthMode { REGISTER, LOGIN }

class LoginScreen extends StatefulWidget {
  static const routeName = '/auth';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  var _authMode = AuthMode.LOGIN;
  var _passwordController = TextEditingController();
  var _isSubmitting = false;
  var _hidePassword = true;

  var _authData = {'username': '', 'password': '', 'fullName': ''};

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

  void _submitForm() async {
    _form.currentState.save();
    if (_form.currentState.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        if (_authMode == AuthMode.LOGIN) {
          // Login Task
          print('Login');
          await Provider.of<AuthProvider>(context, listen: false)
              .login(_authData['username'], _authData['password']);
        } else {
          // Register Task
          print('Register');
          await Provider.of<AuthProvider>(context, listen: false).register(
            _authData['fullName'],
            _authData['username'],
            _authData['password'],
          );
        }
        Navigator.of(context).pushReplacementNamed('/');
      } on HttpException catch (error) {
        print(error);
        _renderErrorDialog(error.toString());
      } catch (error) {
        _renderErrorDialog(error.toString());
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).primaryColor.withOpacity(0.9),
                Theme.of(context).accentColor.withOpacity(0.9),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: size.height * 0.2,
                  margin: EdgeInsets.only(top: 40),
                  width: double.infinity,
                  child: Image.asset('assets/images/login_avatar.png'),
                ),
                Container(
                  width: orientation == Orientation.landscape
                      ? size.width * 0.6
                      : size.width * 0.9,
                  margin: const EdgeInsets.only(top: 5),
                  child: Card(
                    elevation: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Form(
                        key: _form,
                        child: Column(
                          children: <Widget>[
                            if (_authMode == AuthMode.REGISTER)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Full Name",
                                  suffixIcon: Icon(Icons.text_format),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Name is Required";
                                  }
                                  if (value.length < 6) {
                                    return "Name is Too Short";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData["fullName"] = value;
                                },
                              ),
                            if (_authMode == AuthMode.REGISTER)
                              SizedBox(
                                height: 15,
                              ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Username",
                                suffixIcon: Icon(
                                  Icons.perm_identity,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              onSaved: (value) {
                                _authData['username'] = value;
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please Ener Username";
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _hidePassword,
                              controller: _passwordController,
                              onSaved: (value) {
                                _authData['password'] = value;
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Password is Required!";
                                }
                                if (value.length < 6) {
                                  return "Password Too Short!";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            if (_authMode == AuthMode.REGISTER)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Confirm Password",
                                  suffixIcon: Icon(
                                    Icons.enhanced_encryption,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty ||
                                      value != _passwordController.text) {
                                    return "Password Do Not Match!";
                                  }
                                  return null;
                                },
                              ),
                            if (_authMode == AuthMode.REGISTER)
                              SizedBox(
                                height: 15,
                              ),
                            _isSubmitting
                                ? CircularProgressIndicator()
                                : Container(
                                    width: double.infinity,
                                    child: RaisedButton(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      elevation: 10,
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      child: Text(
                                        _authMode == AuthMode.LOGIN
                                            ? "Login"
                                            : "Register",
                                      ),
                                      onPressed: _submitForm,
                                    ),
                                  ),
                            SizedBox(
                              height: 15,
                            ),
                            FlatButton(
                              child: Text(
                                _authMode == AuthMode.REGISTER
                                    ? "Already Have An Account?"
                                    : "Need An Account?",
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_authMode == AuthMode.LOGIN) {
                                    _authMode = AuthMode.REGISTER;
                                  } else if (_authMode == AuthMode.REGISTER) {
                                    _authMode = AuthMode.LOGIN;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
